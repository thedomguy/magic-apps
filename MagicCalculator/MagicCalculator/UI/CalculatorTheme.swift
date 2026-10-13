import SwiftUI

/// Design tokens for the iOS 18–inspired Basic calculator (forced dark, flat circular keys).
enum CalculatorTheme {
    static let background = Color.black

    /// Digit / decimal / mode keys — ~#333
    static let digitFill = Color(red: 0.2, green: 0.2, blue: 0.2)

    /// Function row (AC/C, ±, %) — iOS 18 dark gray with white labels
    static let functionFill = Color(white: 0.3)

    /// Operator keys
    static let operatorFill = Color.orange

    /// Sticky selected operator: white fill, orange glyph
    static let selectedOperatorFill = Color.white
    static let selectedOperatorLabel = Color.orange

    static let digitLabel = Color.white
    static let functionLabel = Color.white
    static let operatorLabel = Color.white

    static let displayPrimary = Color.white
    static let displaySecondary = Color(white: 0.55)

    /// Layout
    static let columnCount = 4
    static let sideMargin: CGFloat = 16
    static let gutter: CGFloat = 14
    /// Extra space above the home-indicator safe area (matches stock Calculator breathing room).
    static let bottomSafePadding: CGFloat = 12

    static let displayFontSize: CGFloat = 84
    static let expressionFontSize: CGFloat = 28
    static let displayMinimumScaleFactor: CGFloat = 0.3

    static let keyLabelFontSize: CGFloat = 32
    static let keySymbolFontSize: CGFloat = 28
}
