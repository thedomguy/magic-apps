import SwiftUI

struct DisplayView: View {
    let expression: String
    let display: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if !expression.isEmpty {
                Text(expression)
                    .font(.system(size: CalculatorTheme.expressionFontSize, weight: .regular, design: .rounded))
                    .foregroundStyle(CalculatorTheme.displaySecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(CalculatorTheme.displayMinimumScaleFactor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Text(display)
                .font(.system(size: CalculatorTheme.displayFontSize, weight: .light, design: .rounded))
                .foregroundStyle(CalculatorTheme.displayPrimary)
                .lineLimit(1)
                .minimumScaleFactor(CalculatorTheme.displayMinimumScaleFactor)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, CalculatorTheme.sideMargin)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        if expression.isEmpty {
            return display
        }
        return "\(expression), \(display)"
    }
}
