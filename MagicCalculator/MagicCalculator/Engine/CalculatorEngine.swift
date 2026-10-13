import Foundation
import Combine

/// iOS 18+/26 Calculator–style expression engine: the full expression is typed inline
/// (`12+3×4`), evaluated with standard precedence on `=`, then shown as a gray tape above the result.
@MainActor
final class CalculatorEngine: ObservableObject {
    /// Main (large) line: the expression being typed, or the result after `=`.
    @Published private(set) var display: String
    /// Secondary (gray) line: the finished expression after `=`, empty while typing.
    @Published private(set) var expression: String
    @Published private(set) var isClearAll: Bool
    @Published private(set) var history: [HistoryEntry] = []

    enum InputEvent {
        /// The expression changed; carries the digits of each number the user keyed in.
        case changed(operands: [String])
        /// `=` finished an expression; carries the numbers it was built from.
        case committed(operands: [String])
    }

    /// Keyed-in numbers, for profile capture. Numbers carried over from a result are excluded.
    let inputs = PassthroughSubject<InputEvent, Never>()

    /// Digit budget per number (sign / decimal point do not count).
    private let maxDigits = 9

    private struct Term {
        /// Raw entry text, e.g. `-12.50`, `0.`, `7`.
        var text: String
        var isPercent = false
        /// False for numbers the user didn't key in (a carried-over result, `5+=` reuse).
        var isTyped = true
    }

    /// Numbers and operators alternate: `terms.count == ops.count` means waiting for an operand.
    private var terms: [Term] = []
    private var ops: [CalculatorOperation] = []
    /// Value of the last `=`; non-nil while the result is showing.
    private var result: Double?
    /// Last operator + operand, re-applied by repeated `=`.
    private var repeatOperation: CalculatorOperation?
    private var repeatOperand: Double?
    private var hasError = false

    init() {
        display = "0"
        expression = ""
        isClearAll = true
    }

    // MARK: - Inputs

    func inputDigit(_ digit: Int) {
        precondition((0...9).contains(digit))
        if hasError || result != nil { resetAll() }

        if awaitingOperand {
            terms.append(Term(text: String(digit)))
        } else {
            var term = terms[terms.count - 1]
            guard !term.isPercent, digitCount(in: term.text) < maxDigits else { return }
            if term.text == "0" {
                term.text = String(digit)
            } else if term.text == "-0" {
                term.text = "-" + String(digit)
            } else {
                term.text += String(digit)
            }
            terms[terms.count - 1] = term
        }
        refresh()
    }

    func inputDecimal() {
        if hasError || result != nil { resetAll() }

        if awaitingOperand {
            terms.append(Term(text: "0."))
        } else {
            var term = terms[terms.count - 1]
            guard !term.isPercent, !term.text.contains(".") else { return }
            term.text += "."
            terms[terms.count - 1] = term
        }
        refresh()
    }

    func setOperation(_ op: CalculatorOperation) {
        if hasError { resetAll() }

        if let value = result {
            terms = [Term(text: format(value), isTyped: false)]
            ops = []
            result = nil
        }
        if terms.isEmpty {
            terms = [Term(text: "0", isTyped: false)]
        }
        if awaitingOperand {
            ops[ops.count - 1] = op
        } else {
            ops.append(op)
        }
        refresh()
    }

    func toggleSign() {
        if hasError { return }

        if let value = result {
            terms = [Term(text: format(-value), isTyped: false)]
            ops = []
            result = nil
        } else if awaitingOperand {
            terms.append(Term(text: "-0"))
        } else {
            var term = terms[terms.count - 1]
            if term.text.hasPrefix("-") {
                term.text.removeFirst()
            } else {
                term.text = "-" + term.text
            }
            terms[terms.count - 1] = term
        }
        refresh()
    }

    func percent() {
        if hasError { return }

        if let value = result {
            terms = [Term(text: format(value), isTyped: false)]
            ops = []
            result = nil
        }
        guard !awaitingOperand else { return }
        terms[terms.count - 1].isPercent.toggle()
        refresh()
    }

    /// C clears the expression; AC (nothing to clear) also resets the repeat state.
    func clear() {
        resetAll()
    }

    func delete() {
        if hasError || result != nil {
            resetAll()
            return
        }
        guard !terms.isEmpty else { return }

        if awaitingOperand {
            ops.removeLast()
        } else if terms[terms.count - 1].isPercent {
            terms[terms.count - 1].isPercent = false
        } else {
            var text = terms[terms.count - 1].text
            text.removeLast()
            if text.isEmpty || text == "-" {
                terms.removeLast()
                if terms.isEmpty { ops.removeAll() }
            } else {
                terms[terms.count - 1].text = text
            }
        }
        refresh()
    }

    func equals() {
        if hasError { return }

        if let value = result {
            guard let op = repeatOperation, let rhs = repeatOperand else { return }
            let tape = "\(formatGrouped(value))\(op.symbol)\(formatGrouped(rhs))"
            guard let next = apply(op, lhs: value, rhs: rhs) else { return presentError() }
            finish(tape: tape, value: next)
            return
        }
        guard !terms.isEmpty else { return }

        // `5+=` reuses the last number as the missing operand, like the classic keypad.
        if awaitingOperand, let last = terms.last {
            terms.append(Term(text: last.text, isTyped: false))
        }
        inputs.send(.committed(operands: typedOperands))
        guard let value = evaluate() else { return presentError() }

        repeatOperation = ops.last
        repeatOperand = ops.isEmpty ? nil : number(terms[terms.count - 1])
        finish(tape: tapeText(), value: value)
    }

    func applyHistoryResult(_ entry: HistoryEntry) {
        resetAll()
        let raw = entry.result.replacingOccurrences(of: ",", with: "")
        guard let value = Double(raw) else { return }
        result = value
        display = entry.result
    }

    func deleteHistory(ids: Set<UUID>) {
        history.removeAll { ids.contains($0.id) }
    }

    func clearHistory() {
        history.removeAll()
    }

    // MARK: - Internals

    private var awaitingOperand: Bool {
        terms.count == ops.count
    }

    private var typedOperands: [String] {
        terms.filter(\.isTyped).map { $0.text.filter(\.isNumber) }
    }

    private func number(_ term: Term) -> Double {
        var text = term.text
        if text.hasSuffix(".") { text.removeLast() }
        return Double(text) ?? 0
    }

    /// Standard precedence (× ÷ before + −). `A ± B%` means `A ± A·B/100`; `A × B%` means `A × B/100`.
    private func evaluate() -> Double? {
        guard let first = terms.first else { return 0 }
        var total: Double = 0
        var additive: CalculatorOperation = .add
        var product = number(first) / (first.isPercent ? 100 : 1)

        for (op, term) in zip(ops, terms.dropFirst()) {
            let value = number(term)
            switch op {
            case .multiply, .divide:
                guard let next = apply(op, lhs: product, rhs: term.isPercent ? value / 100 : value) else {
                    return nil
                }
                product = next
            case .add, .subtract:
                total = apply(additive, lhs: total, rhs: product) ?? total
                additive = op
                product = term.isPercent ? total * value / 100 : value
            }
        }
        return apply(additive, lhs: total, rhs: product)
    }

    private func apply(_ op: CalculatorOperation, lhs: Double, rhs: Double) -> Double? {
        switch op {
        case .add: return lhs + rhs
        case .subtract: return lhs - rhs
        case .multiply: return lhs * rhs
        case .divide:
            if rhs == 0 { return nil }
            return lhs / rhs
        }
    }

    private func finish(tape: String, value: Double) {
        let text = formatGrouped(value)
        guard text != "Error" else { return presentError() }
        history.insert(HistoryEntry(expression: tape, result: text), at: 0)
        terms = []
        ops = []
        result = value
        expression = tape
        display = text
        isClearAll = true
    }

    private func presentError() {
        resetAll()
        display = "Error"
        hasError = true
    }

    private func resetAll() {
        terms = []
        ops = []
        result = nil
        repeatOperation = nil
        repeatOperand = nil
        hasError = false
        refresh()
    }

    private func refresh() {
        expression = ""
        display = terms.isEmpty ? "0" : tapeText()
        isClearAll = terms.isEmpty
        inputs.send(.changed(operands: typedOperands))
    }

    /// Inline expression, e.g. `1,250×3+15%` (trailing operator included while waiting).
    private func tapeText() -> String {
        var text = ""
        for (index, term) in terms.enumerated() {
            if index > 0 { text += ops[index - 1].symbol }
            text += groupEntry(term.text) + (term.isPercent ? "%" : "")
        }
        if awaitingOperand, let op = ops.last {
            text += op.symbol
        }
        return text
    }

    private func digitCount(in text: String) -> Int {
        text.filter(\.isNumber).count
    }

    /// Groups the integer part of a raw entry while keeping trailing `.`/zeros the user typed.
    private func groupEntry(_ raw: String) -> String {
        let negative = raw.hasPrefix("-")
        let body = negative ? String(raw.dropFirst()) : raw
        let parts = body.split(separator: ".", omittingEmptySubsequences: false)
        var integer = String(parts[0])
        var grouped = ""
        while integer.count > 3 {
            grouped = "," + integer.suffix(3) + grouped
            integer.removeLast(3)
        }
        grouped = integer + grouped
        if parts.count > 1 {
            grouped += "." + parts[1]
        }
        return (negative ? "−" : "") + grouped
    }

    /// Plain decimal text for a computed value: no grouping, trailing zeros trimmed.
    private func format(_ value: Double) -> String {
        if value.isNaN || value.isInfinite { return "Error" }

        let absValue = abs(value)
        if absValue != 0 && (absValue >= 1e16 || absValue < 1e-15) {
            return "Error"
        }

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 15
        formatter.minimumFractionDigits = 0
        formatter.maximumIntegerDigits = 16
        guard var text = formatter.string(from: NSNumber(value: value)) else {
            return String(value)
        }

        if digitCount(in: text.replacingOccurrences(of: "-", with: "")) > maxDigits + 6 {
            text = String(format: "%.\(maxDigits)g", value)
            if text.contains("e") || text.contains("E") {
                return "Error"
            }
        }

        if text.contains(".") {
            while text.last == "0" { text.removeLast() }
            if text.last == "." { text.removeLast() }
        }
        if text == "-0" { return "0" }
        return text.isEmpty ? "0" : text
    }

    /// Display / history text uses grouping separators like stock Calculator (`1,500`).
    private func formatGrouped(_ value: Double) -> String {
        let plain = format(value)
        if plain == "Error" { return plain }
        return groupEntry(plain)
    }
}

private extension CalculatorOperation {
    var symbol: String {
        switch self {
        case .add: return "+"
        case .subtract: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        }
    }
}
