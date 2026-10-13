import Foundation

struct ProfileField: Identifiable, Codable, Hashable {
    var id = UUID()
    var label: String
    var digitCount: Int

    static let digitRange = 1...20
}

/// A capture layout, loaded on the calculator by holding its slot digit (1–9).
struct Profile: Identifiable, Codable, Hashable {
    var id = UUID()
    var slot: Int
    var name: String
    var fields: [ProfileField]

    static let slotRange = 1...9

    var isSingleField: Bool { fields.count == 1 }

    func displayLabel(at index: Int) -> String {
        let label = fields[index].label.trimmingCharacters(in: .whitespaces)
        return label.isEmpty ? "Field \(index + 1)" : label
    }

    var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Profile \(slot)" : trimmed
    }

    /// Shown once on the display when the profile is loaded: `Card Suit | Card Value | 3`.
    var flashText: String {
        (fields.indices.map(displayLabel(at:)) + [String(slot)]).joined(separator: " | ")
    }

    static func starter(slot: Int) -> Profile {
        Profile(slot: slot, name: "", fields: [ProfileField(label: "", digitCount: 2)])
    }

    /// Profile 1 ships preconfigured: any 10-digit number, typed as a run of additions.
    static let seed = Profile(
        slot: 1,
        name: "Any number",
        fields: [ProfileField(label: "Number", digitCount: 10)]
    )
}
