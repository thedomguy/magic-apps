import SwiftUI

enum CalculatorKeyRole {
    case digit
    case function
    case backspace
    case `operator`
}

struct CalculatorButtonStyle: ButtonStyle {
    let role: CalculatorKeyRole

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .calculatorKeyChrome(role: role, isPressed: configuration.isPressed)
    }
}

/// Circular key chrome shared by `Button` keys and the digit drag-gesture keys.
/// Stock keys have no sticky "selected operator" state in iOS 26 — the operator shows in the display.
struct CalculatorKeyChrome: ViewModifier {
    let role: CalculatorKeyRole
    var isPressed: Bool = false

    func body(content: Content) -> some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            content
                .font(.system(size: side * labelScale, weight: .regular))
                .imageScale(.medium)
                .foregroundStyle(foreground)
                .frame(width: side, height: side)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Circle())
                .modifier(GlassKeyBackground(role: role, isPressed: isPressed))
        }
        .aspectRatio(1, contentMode: .fit)
        .animation(.easeOut(duration: 0.12), value: isPressed)
    }

    private var labelScale: CGFloat {
        role == .backspace ? CalculatorTheme.backspaceLabelScale : CalculatorTheme.keyLabelScale
    }

    private var foreground: Color {
        switch role {
        case .digit: return CalculatorTheme.digitLabel
        case .function, .backspace: return CalculatorTheme.functionLabel
        case .operator: return CalculatorTheme.operatorLabel
        }
    }
}

/// Applies iOS 26 Liquid Glass when available; falls back to solid circular fills.
private struct GlassKeyBackground: ViewModifier {
    let role: CalculatorKeyRole
    var isPressed: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular.tint(tint).interactive(), in: .circle)
        } else {
            content
                .background {
                    Circle()
                        .fill(tint)
                        .overlay {
                            Circle()
                                .strokeBorder(
                                    CalculatorTheme.keyStroke,
                                    lineWidth: CalculatorTheme.keyStrokeWidth
                                )
                        }
                }
                .opacity(isPressed ? 0.72 : 1)
        }
    }

    private var tint: Color {
        switch role {
        case .digit: return CalculatorTheme.digitTint
        case .function: return CalculatorTheme.functionTint
        case .backspace: return CalculatorTheme.backspaceTint
        case .operator: return CalculatorTheme.operatorTint
        }
    }
}

extension View {
    func calculatorKeyChrome(role: CalculatorKeyRole, isPressed: Bool = false) -> some View {
        modifier(CalculatorKeyChrome(role: role, isPressed: isPressed))
    }
}
