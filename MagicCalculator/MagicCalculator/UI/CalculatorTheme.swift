import SwiftUI

/// Design tokens matching the latest iOS Calculator (Liquid Glass / Class UI, forced dark).
enum CalculatorTheme {
    // Values below are measured from a stock iOS 26 Calculator screenshot (390 pt wide, @3x).

    /// Stock canvas is pure black.
    static let background = Color.black

    /// Operator tint — sampled #EF9838.
    static let operatorTint = Color(red: 239 / 255, green: 152 / 255, blue: 56 / 255)

    /// Backspace / C / % share one gray — sampled #5E5E5E.
    static let functionTint = Color(white: 94 / 255)
    static let backspaceTint = functionTint

    /// Digit keys — sampled #343434.
    static let digitTint = Color(white: 52 / 255)

    static let digitLabel = Color.white
    static let functionLabel = Color.white
    static let operatorLabel = Color.white

    static let displayPrimary = Color.white
    static let displaySecondary = Color(white: 0.55)

    /// Fallback (pre–iOS 26) solid fills
    static let digitFill = digitTint
    static let functionFill = functionTint
    static let backspaceFill = functionTint
    static let operatorFill = operatorTint
    static let keyStroke = Color.white.opacity(0.14)
    static let keyStrokeWidth: CGFloat = 0.5

    /// Toolbar — 44 pt glass circles flush with the top safe area; glyphs ~22 pt.
    static let toolbarIcon = Color.white
    static let toolbarButtonSize: CGFloat = 44
    static let toolbarIconSize: CGFloat = 22
    static let toolbarFill = Color(white: 18 / 255)

    /// History sheet
    static let historySheet = Color(white: 0.12).opacity(0.92)
    static let historyExpression = Color(white: 0.55)
    static let historyResult = Color.white
    static let historySection = Color(white: 0.55)
    static let historyDivider = Color.white.opacity(0.12)

    /// Layout — 16 pt side margins, 8⅓ pt gutters, keys ≈ 83.7 pt on a 390 pt screen.
    static let columnCount = 4
    static let sideMargin: CGFloat = 16
    static let gutter: CGFloat = 25.0 / 3.0
    /// Gap between the last key row and the home-indicator safe area.
    static let bottomSafePadding: CGFloat = 28
    static let toolbarTopPadding: CGFloat = 0
    /// Gap between the display baseline and the top key row.
    static let displayBaselineToKeypad: CGFloat = 22.7

    /// Display — SF Pro Regular 64 pt (stock "0" glyph is 46.7 pt tall with a 5.7 pt stem).
    static let displayFontSize: CGFloat = 64
    static let expressionFontSize: CGFloat = 28
    static let displayMinimumScaleFactor: CGFloat = 0.3

    /// Key glyphs (digits, C, operators, symbols) are SF Regular at 0.43 × key diameter (≈ 36 pt);
    /// the backspace glyph is a touch smaller (≈ 34 pt).
    static let keyLabelScale: CGFloat = 0.43
    static let backspaceLabelScale: CGFloat = 0.41
}
