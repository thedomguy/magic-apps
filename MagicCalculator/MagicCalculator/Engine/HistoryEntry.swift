import Foundation

struct HistoryEntry: Identifiable, Equatable {
    let id: UUID
    let expression: String
    let result: String
    let date: Date

    init(id: UUID = UUID(), expression: String, result: String, date: Date = Date()) {
        self.id = id
        self.expression = expression
        self.result = result
        self.date = date
    }

    var monthSectionTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        return formatter.string(from: date)
    }
}
