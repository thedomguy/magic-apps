import SwiftUI

struct CalculatorKeypad: View {
    @ObservedObject var engine: CalculatorEngine
    var onDigitTouchDown: ((Int) -> Void)? = nil
    var onDigitTouchUp: ((Int) -> Void)? = nil

    @State private var selectedOp: CalculatorOperation?

    private let rowCount: CGFloat = 5

    var body: some View {
        // Width-driven intrinsic height so the keypad never expands into the home indicator.
        GeometryReader { geo in
            let diameter = Self.keyDiameter(for: geo.size.width)
            VStack(spacing: CalculatorTheme.gutter) {
                functionRow(diameter: diameter)
                digitRow([7, 8, 9], operation: .multiply, diameter: diameter)
                digitRow([4, 5, 6], operation: .subtract, diameter: diameter)
                digitRow([1, 2, 3], operation: .add, diameter: diameter)
                bottomRow(diameter: diameter)
            }
            .padding(.horizontal, CalculatorTheme.sideMargin)
            .frame(width: geo.size.width, alignment: .top)
        }
        .aspectRatio(aspect, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }

    /// width : height for 4 columns × 5 rows with gutters + horizontal margins cancel in ratio of key area.
    private var aspect: CGFloat {
        // Approximate: usable key grid is square-ish cells; 4 wide, 5 tall + 4 gutters relative to diameter.
        // Using diameter D, height = 5D + 4G, width = 4D + 3G + 2M; with G≈0.18D and M≈0.2D → ~0.78
        let g = CalculatorTheme.gutter
        let m = CalculatorTheme.sideMargin
        // Solve for symbolic ratio assuming D=100 for ratio stability
        let d: CGFloat = 100
        let width = 4 * d + 3 * g + 2 * m
        let height = rowCount * d + (rowCount - 1) * g
        return width / height
    }

    // MARK: - Rows

    @ViewBuilder
    private func functionRow(diameter: CGFloat) -> some View {
        HStack(spacing: CalculatorTheme.gutter) {
            Button {
                selectedOp = nil
                engine.clear()
            } label: {
                Text(engine.isClearAll ? "AC" : "C")
            }
            .buttonStyle(CalculatorButtonStyle(role: .function, diameter: diameter))
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.45)
                    .onEnded { _ in
                        selectedOp = nil
                        engine.clear()
                    }
            )

            Button {
                engine.toggleSign()
            } label: {
                Image(systemName: "plusminus")
            }
            .buttonStyle(CalculatorButtonStyle(role: .function, diameter: diameter))

            Button {
                engine.percent()
            } label: {
                Image(systemName: "percent")
            }
            .buttonStyle(CalculatorButtonStyle(role: .function, diameter: diameter))

            operatorButton(.divide, diameter: diameter)
        }
    }

    @ViewBuilder
    private func digitRow(
        _ digits: [Int],
        operation: CalculatorOperation,
        diameter: CGFloat
    ) -> some View {
        HStack(spacing: CalculatorTheme.gutter) {
            ForEach(digits, id: \.self) { digit in
                digitKey(digit, diameter: diameter)
            }
            operatorButton(operation, diameter: diameter)
        }
    }

    @ViewBuilder
    private func bottomRow(diameter: CGFloat) -> some View {
        HStack(spacing: CalculatorTheme.gutter) {
            Image(systemName: "function")
                .calculatorKeyChrome(role: .mode, diameter: diameter)
                .accessibilityHidden(true)

            digitKey(0, diameter: diameter)

            Button {
                selectedOp = nil
                engine.inputDecimal()
            } label: {
                Text(".")
            }
            .buttonStyle(CalculatorButtonStyle(role: .digit, diameter: diameter))

            Button {
                selectedOp = nil
                engine.equals()
            } label: {
                Image(systemName: "equal")
            }
            .buttonStyle(CalculatorButtonStyle(role: .operator, diameter: diameter))
        }
    }

    private func digitKey(_ digit: Int, diameter: CGFloat) -> some View {
        DigitTouchKey(
            digit: digit,
            diameter: diameter,
            onTouchDown: {
                selectedOp = nil
                onDigitTouchDown?(digit)
                engine.inputDigit(digit)
            },
            onTouchUp: {
                onDigitTouchUp?(digit)
            }
        )
    }

    private func operatorButton(
        _ op: CalculatorOperation,
        diameter: CGFloat
    ) -> some View {
        Button {
            selectedOp = op
            engine.setOperation(op)
        } label: {
            Image(systemName: op.systemImageName)
        }
        .buttonStyle(
            CalculatorButtonStyle(
                role: .operator,
                isSelected: selectedOp == op,
                diameter: diameter
            )
        )
    }

    static func keyDiameter(for width: CGFloat) -> CGFloat {
        let columns = CGFloat(CalculatorTheme.columnCount)
        let gutters = CalculatorTheme.gutter * (columns - 1)
        let usable = width - (CalculatorTheme.sideMargin * 2) - gutters
        return max(44, floor(usable / columns))
    }
}

private struct DigitTouchKey: View {
    let digit: Int
    let diameter: CGFloat
    let onTouchDown: () -> Void
    let onTouchUp: () -> Void

    @State private var isPressed = false

    var body: some View {
        Text("\(digit)")
            .calculatorKeyChrome(role: .digit, isPressed: isPressed, diameter: diameter)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        onTouchDown()
                    }
                    .onEnded { _ in
                        isPressed = false
                        onTouchUp()
                    }
            )
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel("\(digit)")
            .accessibilityAction {
                onTouchDown()
                onTouchUp()
            }
    }
}

private extension CalculatorOperation {
    var systemImageName: String {
        switch self {
        case .divide: return "divide"
        case .multiply: return "multiply"
        case .subtract: return "minus"
        case .add: return "plus"
        }
    }
}
