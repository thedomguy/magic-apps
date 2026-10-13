import Foundation

enum CalculatorMode: String, CaseIterable, Identifiable {
    case basic
    case scientific
    case mathNotes
    case convert

    var id: String { rawValue }

    var title: String {
        switch self {
        case .basic: return "Basic"
        case .scientific: return "Scientific"
        case .mathNotes: return "Math Notes"
        case .convert: return "Convert"
        }
    }

    var systemImage: String {
        switch self {
        case .basic: return "plus.forwardslash.minus"
        case .scientific: return "function"
        case .mathNotes: return "chart.xyaxis.line"
        case .convert: return "arrow.left.arrow.right"
        }
    }

    /// Modes listed above the separator in the system menu.
    static let primaryModes: [CalculatorMode] = [.basic, .scientific, .mathNotes]
}
