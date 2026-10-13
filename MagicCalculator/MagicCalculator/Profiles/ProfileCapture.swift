import Foundation

/// A profile field, with the value captured for it (nil when only describing the profile).
struct FieldValue: Codable, Equatable {
    let label: String
    let digitCount: Int
    var value: String?
}

struct CapturedFields: Equatable {
    let fields: [FieldValue]
    let complete: Bool
}

/// Maps the numbers keyed into one calculation onto the active profile's fields.
///
/// - Single field: digits accumulate across every number typed (`98 + 7654 + 3210`) and the
///   fields are reported as soon as the digit count is reached.
/// - Several fields: each number typed is one field (`3 × 12 × 7`), reported once the
///   last field reaches its digit count, or on `=`.
///
/// A calculation reports at most once; `=` reports whatever was captured if nothing went yet.
struct ProfileCapture {
    private var sent = false

    mutating func reset() {
        sent = false
    }

    /// Called on every edit of the expression.
    mutating func update(operands: [String], profile: Profile) -> CapturedFields? {
        if operands.isEmpty {
            sent = false
            return nil
        }
        guard !sent else { return nil }
        let (fields, complete) = Self.fill(operands, profile: profile, committed: false)
        guard complete else { return nil }
        sent = true
        return CapturedFields(fields: fields, complete: true)
    }

    /// Called on `=`, with the numbers from the finished expression.
    mutating func commit(operands: [String], profile: Profile) -> CapturedFields? {
        defer { sent = false }
        guard !sent, operands.contains(where: { !$0.isEmpty }) else { return nil }
        let (fields, complete) = Self.fill(operands, profile: profile, committed: true)
        return CapturedFields(fields: fields, complete: complete)
    }

    private static func fill(
        _ operands: [String],
        profile: Profile,
        committed: Bool
    ) -> (fields: [FieldValue], complete: Bool) {
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
            FieldValue(
                label: profile.displayLabel(at: index),
                digitCount: profile.fields[index].digitCount,
                value: values[index]
            )
        }
        return (fields, complete)
    }
}
