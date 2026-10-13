import SwiftUI

struct CalculatorKeypad: View {
    @ObservedObject var engine: CalculatorEngine
    /// Fired after holding a digit key for `digitHold`; the digit itself was already entered.
    var onDigitHold: ((Int) -> Void)? = nil
    /// Fired after holding `=` for `equalsHold`, in place of `=`.
    var onEqualsHold: (() -> Void)? = nil

    static let digitHold: Duration = .milliseconds(1500)
    static let equalsHold: Duration = .seconds(3)

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
                PressKey(
                    role: .operator,
                    holdAfter: Self.equalsHold,
                    onTap: { engine.equals() },
                    onHold: onEqualsHold
                ) {
                    Image(systemName: "equal")
                }
                .accessibilityLabel("Equals")
            }
        }
    }

    /// Equal-width column slot; key becomes a circle from the slot’s width.
    private func keySlot<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
    }

    /// Digits enter on touch down, like the stock keypad.
    private func digitKey(_ digit: Int) -> some View {
        PressKey(
            role: .digit,
            holdAfter: Self.digitHold,
            onPress: { engine.inputDigit(digit) },
            onHold: onDigitHold.map { hold in { hold(digit) } }
        ) {
            Text("\(digit)")
        }
        .accessibilityLabel("\(digit)")
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

/// Key driven by a zero-distance drag so it can act on touch down and on a long hold.
/// `onTap` runs on release unless the hold already fired.
private struct PressKey<Label: View>: View {
    let role: CalculatorKeyRole
    var holdAfter: Duration
    var onPress: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil
    var onHold: (() -> Void)? = nil
    @ViewBuilder let label: () -> Label

    @State private var isPressed = false
    @State private var holdTask: Task<Void, Never>?
    @State private var didHold = false

    var body: some View {
        label()
            .calculatorKeyChrome(role: role, isPressed: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        didHold = false
                        onPress?()
                        startHoldTimer()
                    }
                    .onEnded { _ in
                        isPressed = false
                        holdTask?.cancel()
                        holdTask = nil
                        if !didHold { onTap?() }
                    }
            )
            .onDisappear {
                holdTask?.cancel()
                holdTask = nil
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                onPress?()
                onTap?()
            }
    }

    private func startHoldTimer() {
        guard let onHold else { return }
        holdTask?.cancel()
        holdTask = Task {
            try? await Task.sleep(for: holdAfter)
            guard !Task.isCancelled else { return }
            didHold = true
            onHold()
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
