import SwiftUI

struct DisplayView: View {
    let expression: String
    let display: String
    /// Profile config shown briefly in place of the display when a profile loads.
    var flash: String? = nil

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if let flash {
                Text(flash)
                    .font(.system(size: CalculatorTheme.flashFontSize, weight: .light))
                    .foregroundStyle(CalculatorTheme.displayPrimary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(5)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .transition(.opacity)
            } else {
                if !expression.isEmpty {
                    Text(expression)
                        .font(.system(size: CalculatorTheme.expressionFontSize, weight: .regular))
                        .foregroundStyle(CalculatorTheme.displaySecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(CalculatorTheme.displayMinimumScaleFactor)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                Text(display)
                    .font(.system(size: CalculatorTheme.displayFontSize, weight: .regular))
                    .foregroundStyle(CalculatorTheme.displayPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(CalculatorTheme.displayMinimumScaleFactor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .contentTransition(.numericText())
            }
        }
        .animation(.easeInOut(duration: 0.2), value: flash)
        .padding(.horizontal, CalculatorTheme.sideMargin)
        // Text frames end at the font descender; pad so the *baseline* sits the stock distance above the keys.
        .padding(.bottom, CalculatorTheme.displayBaselineToKeypad - Self.primaryDescent)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private static let primaryDescent = -UIFont.systemFont(ofSize: CalculatorTheme.displayFontSize).descender

    private var accessibilitySummary: String {
        if expression.isEmpty {
            return display
        }
        return "\(expression), \(display)"
    }
}
