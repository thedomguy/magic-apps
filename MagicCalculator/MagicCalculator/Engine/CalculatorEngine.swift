import Foundation
import Combine

/// Apple Calculator–style binary engine: chained ops, repeating equals, C/AC, percent rules.
@MainActor
final class CalculatorEngine: ObservableObject {
    @Published private(set) var display: String
    @Published private(set) var expression: String
    @Published private(set) var isClearAll: Bool

    /// Digit budget for entry (sign / decimal point do not count).
    private let maxDigits = 9

    private var accumulator: Double = 0
    private var pendingOperation: CalculatorOperation?
    /// True while the user is editing the current entry.
    private var isEntering = false
    /// Next digit/decimal replaces `display` (after op, equals, clear entry, etc.).
    private var shouldReplaceDisplay = true
    /// Right operand + op remembered for repeating `=`.
    private var repeatOperand: Double?
    private var repeatOperation: CalculatorOperation?
    private var hasError = false

    init() {
        display = "0"
        expression = ""
        isClearAll = true
    }

    // MARK: - Inputs

    func inputDigit(_ digit: Int) {
        precondition((0...9).contains(digit))
        if hasError { resetAll() }

        if shouldReplaceDisplay || !isEntering {
            display = String(digit)
            isEntering = true
            shouldReplaceDisplay = false
        } else {
            if digitCount(in: display) >= maxDigits { return }
            if display == "0" {
                display = String(digit)
            } else if display == "-0" {
                display = "-" + String(digit)
            } else {
                display += String(digit)
            }
        }
        isClearAll = false
        updateExpressionTape()
    }

    func inputDecimal() {
        if hasError { resetAll() }

        if shouldReplaceDisplay || !isEntering {
            display = "0."
            isEntering = true
            shouldReplaceDisplay = false
        } else if !display.contains(".") {
            display += "."
        }
        isClearAll = false
        updateExpressionTape()
    }

    func setOperation(_ op: CalculatorOperation) {
        if hasError { resetAll() }

        if isEntering {
            if let pending = pendingOperation {
                let right = currentValue()
                if let result = apply(pending, lhs: accumulator, rhs: right) {
                    accumulator = result
                    display = format(result)
                } else {
                    presentError()
                    return
                }
            } else {
                accumulator = currentValue()
            }
        } else if pendingOperation == nil {
            // Starting a new op from a result / idle display.
            accumulator = currentValue()
        }
        // If already pending and not entering, only replace the operator (Apple behavior).

        pendingOperation = op
        isEntering = false
        shouldReplaceDisplay = true
        repeatOperand = nil
        repeatOperation = nil
        // Not mid-entry; UI may show AC until digits arrive again.
        isClearAll = true
        updateExpressionTape()
    }

    func toggleSign() {
        if hasError { return }

        if isEntering || !shouldReplaceDisplay {
            if display.hasPrefix("-") {
                display.removeFirst()
            } else {
                display = "-" + display
            }
        } else {
            display = format(-currentValue())
        }
        updateExpressionTape()
    }

    func percent() {
        if hasError { return }

        let value = currentValue()
        let result: Double
        // Percent: with pending add/subtract, B% → A×B/100 (so A±B% is correct).
        // With multiply/divide or no pending op, value → value/100.
        if let pending = pendingOperation, pending == .add || pending == .subtract {
            result = accumulator * value / 100
        } else {
            result = value / 100
        }

        display = format(result)
        isEntering = false
        shouldReplaceDisplay = true
        isClearAll = true
        updateExpressionTape()
    }

    func clear() {
        if isClearAll {
            resetAll()
            return
        }
        // C: clear current entry only; keep accumulator + pending op.
        display = "0"
        isEntering = false
        shouldReplaceDisplay = true
        isClearAll = true
        hasError = false
        updateExpressionTape()
    }

    func delete() {
        if hasError || !isEntering || shouldReplaceDisplay { return }

        if display.count <= 1 || display == "-0" || (display.hasPrefix("-") && display.count == 2) {
            display = "0"
            isEntering = false
            shouldReplaceDisplay = true
            isClearAll = true
        } else {
            display.removeLast()
            if display == "-" || display.isEmpty {
                display = "0"
                isEntering = false
                shouldReplaceDisplay = true
                isClearAll = true
            }
        }
        updateExpressionTape()
    }

    func equals() {
        if hasError { return }

        if let pending = pendingOperation {
            let rhs = currentValue()
            if let result = apply(pending, lhs: accumulator, rhs: rhs) {
                display = format(result)
                accumulator = result
                repeatOperation = pending
                repeatOperand = rhs
                pendingOperation = nil
            } else {
                presentError()
                return
            }
        } else if let op = repeatOperation, let rhs = repeatOperand {
            let lhs = currentValue()
            if let result = apply(op, lhs: lhs, rhs: rhs) {
                display = format(result)
                accumulator = result
            } else {
                presentError()
                return
            }
        }

        isEntering = false
        shouldReplaceDisplay = true
        isClearAll = true
        updateExpressionTape(finished: true)
    }

    // MARK: - Internals

    private func currentValue() -> Double {
        // Tolerate in-progress entry like "5." which `Double.init` rejects.
        var text = display
        if text.hasSuffix(".") {
            text.removeLast()
        }
        if text.isEmpty || text == "-" || text == "-0" { return 0 }
        return Double(text) ?? 0
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

    private func presentError() {
        display = "Error"
        expression = ""
        hasError = true
        pendingOperation = nil
        repeatOperand = nil
        repeatOperation = nil
        isEntering = false
        shouldReplaceDisplay = true
        isClearAll = true
        accumulator = 0
    }

    private func resetAll() {
        display = "0"
        expression = ""
        accumulator = 0
        pendingOperation = nil
        repeatOperand = nil
        repeatOperation = nil
        isEntering = false
        shouldReplaceDisplay = true
        isClearAll = true
        hasError = false
    }

    private func digitCount(in text: String) -> Int {
        text.filter(\.isNumber).count
    }

    /// Formats results for display: fixed decimal style, no grouping, trim trailing zeros.
    private func format(_ value: Double) -> String {
        if value.isNaN || value.isInfinite { return "Error" }

        // Keep typical calculator ranges out of scientific notation.
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

        // Cap total significant digits roughly to maxDigits for readability.
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

    private func updateExpressionTape(finished: Bool = false) {
        // Lightweight tape for UI; cleared when idle, after equals, or on error.
        guard !hasError, !finished, let pending = pendingOperation else {
            expression = ""
            return
        }
        let opSymbol: String
        switch pending {
        case .add: opSymbol = "+"
        case .subtract: opSymbol = "−"
        case .multiply: opSymbol = "×"
        case .divide: opSymbol = "÷"
        }
        expression = "\(format(accumulator)) \(opSymbol)"
    }
}
