import Foundation

/// One captured performance, as posted to magic-app-backend.
struct CapturedEntry: Codable, Identifiable, Equatable {
    struct ProfileRef: Codable, Equatable {
        let slot: Int
        let name: String
    }

    struct Field: Codable, Equatable {
        let label: String
        let digitCount: Int
        let value: String
    }

    var id = UUID()
    var createdAt = Date()
    let profile: ProfileRef
    let fields: [Field]
    /// Every number keyed in, digits only, for reconstructing odd entries later.
    let operands: [String]
    let complete: Bool
}

/// Maps the numbers keyed into one calculation onto the active profile's fields.
///
/// - Single field: digits accumulate across every number typed (`98 + 7654 + 3210`) and the
///   entry is sent as soon as the field's digit count is reached.
/// - Several fields: each number typed is one field (`3 × 12 × 7`). The entry is sent once the
///   last field reaches its digit count, or on `=`.
///
/// A calculation sends at most one entry; `=` sends whatever was captured if nothing went yet.
struct ProfileCapture {
    private var sent = false

    mutating func reset() {
        sent = false
    }

    /// Called on every edit of the expression.
    mutating func update(operands: [String], profile: Profile) -> CapturedEntry? {
        if operands.isEmpty {
            sent = false
            return nil
        }
        guard !sent else { return nil }
        let (fields, complete) = Self.fill(operands, profile: profile, committed: false)
        guard complete else { return nil }
        sent = true
        return entry(profile: profile, fields: fields, operands: operands, complete: true)
    }

    /// Called on `=`, with the numbers from the finished expression.
    mutating func commit(operands: [String], profile: Profile) -> CapturedEntry? {
        defer { sent = false }
        guard !sent, operands.contains(where: { !$0.isEmpty }) else { return nil }
        let (fields, complete) = Self.fill(operands, profile: profile, committed: true)
        return entry(profile: profile, fields: fields, operands: operands, complete: complete)
    }

    private func entry(
        profile: Profile,
        fields: [CapturedEntry.Field],
        operands: [String],
        complete: Bool
    ) -> CapturedEntry {
        CapturedEntry(
            profile: .init(slot: profile.slot, name: profile.displayName),
            fields: fields,
            operands: operands,
            complete: complete
        )
    }

    private static func fill(
        _ operands: [String],
        profile: Profile,
        committed: Bool
    ) -> (fields: [CapturedEntry.Field], complete: Bool) {
        let values: [String]
        let complete: Bool

        if profile.isSingleField {
            let stream = operands.joined()
            let count = profile.fields[0].digitCount
            values = [String(stream.prefix(count))]
            complete = stream.count >= count
        } else {
            values = profile.fields.indices.map { $0 < operands.count ? operands[$0] : "" }
            let last = profile.fields.count - 1
            let allTyped = operands.count > last && values.allSatisfy { !$0.isEmpty }
            // A number past the last field means the last one is closed off too.
            complete = allTyped && (
                committed
                || operands.count > profile.fields.count
                || values[last].count >= profile.fields[last].digitCount
            )
        }

        let fields = profile.fields.indices.map { index in
            CapturedEntry.Field(
                label: profile.displayLabel(at: index),
                digitCount: profile.fields[index].digitCount,
                value: values[index]
            )
        }
        return (fields, complete)
    }
}
