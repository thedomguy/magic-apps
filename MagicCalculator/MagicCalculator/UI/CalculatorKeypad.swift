import SwiftUI

struct CalculatorKeypad: View {
    @ObservedObject var engine: CalculatorEngine
    var onDigitTouchDown: ((Int) -> Void)? = nil
    var onDigitTouchUp: ((Int) -> Void)? = nil

    var body: some View {
        let grid = VStack(spacing: CalculatorTheme.gutter) {
            functionRow
            digitRow([7, 8, 9], operation: .multiply)
            digitRow([4, 5, 6], operation: .subtract)
            digitRow([1, 2, 3], operation: .add)
            bottomRow
        }
        .padding(.horizontal, CalculatorTheme.sideMargin)
        .frame(maxWidth: .infinity)

        Group {
            if #available(iOS 26, *) {
                GlassEffectContainer(spacing: CalculatorTheme.gutter) {
                    grid
                }
                .frame(maxWidth: .infinity)
            } else {
                grid
            }
        }
    }

    // MARK: - Rows

    private var functionRow: some View {
        HStack(spacing: CalculatorTheme.gutter) {
            keySlot {
                Button {
                    engine.delete()
                } label: {
                    Image(systemName: "delete.left")
                }
                .buttonStyle(CalculatorButtonStyle(role: .backspace))
                .accessibilityLabel("Delete")
            }

            keySlot {
                Button {
                    engine.clear()
                } label: {
                    Text(engine.isClearAll ? "AC" : "C")
                }
                .buttonStyle(CalculatorButtonStyle(role: .function))
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.45)
                        .onEnded { _ in
                            engine.clear()
                        }
                )
            }

            keySlot {
                Button {
                    engine.percent()
                } label: {
                    Image(systemName: "percent")
                }
                .buttonStyle(CalculatorButtonStyle(role: .function))
            }

            keySlot {
                operatorButton(.divide)
            }
        }
    }

    private func digitRow(_ digits: [Int], operation: CalculatorOperation) -> some View {
        HStack(spacing: CalculatorTheme.gutter) {
            ForEach(digits, id: \.self) { digit in
                keySlot {
                    digitKey(digit)
                }
            }
            keySlot {
                operatorButton(operation)
            }
        }
    }

    private var bottomRow: some View {
        HStack(spacing: CalculatorTheme.gutter) {
            keySlot {
                Button {
                    engine.toggleSign()
                } label: {
                    Image(systemName: "plus.forwardslash.minus")
                }
                .buttonStyle(CalculatorButtonStyle(role: .digit))
                .accessibilityLabel("Plus or minus")
            }

            keySlot {
                digitKey(0)
            }

            keySlot {
                Button {
                    engine.inputDecimal()
                } label: {
                    Text(".")
                }
                .buttonStyle(CalculatorButtonStyle(role: .digit))
            }

            keySlot {
                Button {
                    engine.equals()
                } label: {
                    Image(systemName: "equal")
                }
                .buttonStyle(CalculatorButtonStyle(role: .operator))
            }
        }
    }

    /// Equal-width column slot; key becomes a circle from the slot’s width.
    private func keySlot<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
    }

    private func digitKey(_ digit: Int) -> some View {
        DigitTouchKey(
            digit: digit,
            onTouchDown: {
                onDigitTouchDown?(digit)
                engine.inputDigit(digit)
            },
            onTouchUp: {
                onDigitTouchUp?(digit)
            }
        )
    }

    private func operatorButton(_ op: CalculatorOperation) -> some View {
        Button {
            engine.setOperation(op)
        } label: {
            Image(systemName: op.systemImageName)
        }
        .buttonStyle(CalculatorButtonStyle(role: .operator))
    }
}

private struct DigitTouchKey: View {
    let digit: Int
    let onTouchDown: () -> Void
    let onTouchUp: () -> Void

    @State private var isPressed = false

    var body: some View {
        Text("\(digit)")
            .calculatorKeyChrome(role: .digit, isPressed: isPressed)
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
