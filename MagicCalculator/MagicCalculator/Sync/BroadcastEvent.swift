import Foundation

/// One action broadcast to magic-app-backend for the peek app. Events of one calculation share a
/// `session` and count up in `seq`; nil properties are left out of the JSON.
struct BroadcastEvent: Codable, Identifiable, Equatable {
    enum Kind: String, Codable {
        /// A profile was loaded (hold 1–9). `fields` describes it, without values.
        case profile
        /// Capture turned off (hold 0). `profile` is the one that was active.
        case off
        /// A keyed-in number, sent when the operator or `=` after it is pressed.
        case number
        /// An operator; a later one at the same `index` replaces it.
        case operation = "operator"
        /// `=`, with the finished `expression` and its `value`.
        case equals
        /// AC / C.
        case clear
        /// The numbers mapped onto the profile's fields.
        case capture
    }

    struct ProfileRef: Codable, Equatable {
        let slot: Int
        let name: String
    }

    var id = UUID()
    let session: UUID
    let seq: Int
    var at = Date()
    let type: Kind
    let profile: ProfileRef
    var index: Int?
    var value: String?
    /// The expression as shown on the calculator after this action.
    var expression: String?
    var fields: [FieldValue]?
    var complete: Bool?
}
