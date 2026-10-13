import SwiftUI

enum CalculatorKeyRole {
    case digit
    case function
    case `operator`
    case mode
}

struct CalculatorButtonStyle: ButtonStyle {
    let role: CalculatorKeyRole
    var isSelected: Bool = false
    var diameter: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: labelSize, weight: .medium, design: .rounded))
            .foregroundStyle(foreground)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(fill))
            .opacity(configuration.isPressed ? 0.72 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private var fill: Color {
        switch role {
        case .digit, .mode:
            return CalculatorTheme.digitFill
        case .function:
            return CalculatorTheme.functionFill
        case .operator:
            return isSelected
                ? CalculatorTheme.selectedOperatorFill
                : CalculatorTheme.operatorFill
        }
    }

    private var foreground: Color {
        switch role {
        case .digit, .mode:
            return CalculatorTheme.digitLabel
        case .function:
            return CalculatorTheme.functionLabel
        case .operator:
            return isSelected
                ? CalculatorTheme.selectedOperatorLabel
                : CalculatorTheme.operatorLabel
        }
    }

    private var labelSize: CGFloat {
        switch role {
        case .digit:
            return CalculatorTheme.keyLabelFontSize
        case .function, .operator, .mode:
            return CalculatorTheme.keySymbolFontSize
        }
    }
}

/// Circular key chrome used when the control is not a standard `Button` (e.g. digit drag-gesture keys).
struct CalculatorKeyChrome: ViewModifier {
    let role: CalculatorKeyRole
    var isSelected: Bool = false
    var isPressed: Bool = false
    var diameter: CGFloat

    func body(content: Content) -> some View {
        content
            .font(.system(size: labelSize, weight: .medium, design: .rounded))
            .foregroundStyle(foreground)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(fill))
            .opacity(isPressed ? 0.72 : 1)
            .animation(.easeOut(duration: 0.12), value: isPressed)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private var fill: Color {
        switch role {
        case .digit, .mode:
            return CalculatorTheme.digitFill
        case .function:
            return CalculatorTheme.functionFill
        case .operator:
            return isSelected
                ? CalculatorTheme.selectedOperatorFill
                : CalculatorTheme.operatorFill
        }
    }

    private var foreground: Color {
        switch role {
        case .digit, .mode:
            return CalculatorTheme.digitLabel
        case .function:
            return CalculatorTheme.functionLabel
        case .operator:
            return isSelected
                ? CalculatorTheme.selectedOperatorLabel
                : CalculatorTheme.operatorLabel
        }
    }

    private var labelSize: CGFloat {
        switch role {
        case .digit:
            return CalculatorTheme.keyLabelFontSize
        case .function, .operator, .mode:
            return CalculatorTheme.keySymbolFontSize
        }
    }
}

extension View {
    func calculatorKeyChrome(
        role: CalculatorKeyRole,
        isSelected: Bool = false,
        isPressed: Bool = false,
        diameter: CGFloat
    ) -> some View {
        modifier(
            CalculatorKeyChrome(
                role: role,
                isSelected: isSelected,
                isPressed: isPressed,
                diameter: diameter
            )
        )
    }
}
