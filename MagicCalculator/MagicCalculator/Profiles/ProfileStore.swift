import Foundation
import Combine

/// Profiles and the active one, persisted in `UserDefaults`.
@MainActor
final class ProfileStore: ObservableObject {
    /// Sorted by slot.
    @Published private(set) var profiles: [Profile] {
        didSet { persist() }
    }
    @Published private(set) var activeProfileID: UUID? {
        didSet { defaults.set(activeProfileID?.uuidString, forKey: Keys.active) }
    }

    private let defaults: UserDefaults

    private enum Keys {
        static let profiles = "profiles.v1"
        static let active = "profiles.active.v1"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Keys.profiles),
           let saved = try? JSONDecoder().decode([Profile].self, from: data) {
            profiles = saved
        } else {
            profiles = [.seed]
        }
        activeProfileID = defaults.string(forKey: Keys.active).flatMap(UUID.init(uuidString:))
    }

    var activeProfile: Profile? {
        activeProfileID.flatMap(profile(id:))
    }

    func profile(id: UUID) -> Profile? {
        profiles.first { $0.id == id }
    }

    func profile(slot: Int) -> Profile? {
        profiles.first { $0.slot == slot }
    }

    var nextFreeSlot: Int? {
        Profile.slotRange.first { profile(slot: $0) == nil }
    }

    // MARK: - Activation

    /// Makes the profile in `slot` active; nil when that slot is empty.
    @discardableResult
    func activate(slot: Int) -> Profile? {
        guard let profile = profile(slot: slot) else { return nil }
        activeProfileID = profile.id
        return profile
    }

    func deactivate() {
        activeProfileID = nil
    }

    // MARK: - CRUD

    /// Adds a one-field profile in the first free slot.
    func create() -> Profile? {
        guard let slot = nextFreeSlot else { return nil }
        let profile = Profile.starter(slot: slot)
        profiles.append(profile)
        sort()
        return profile
    }

    func update(_ id: UUID, _ change: (inout Profile) -> Void) {
        guard let index = profiles.firstIndex(where: { $0.id == id }) else { return }
        change(&profiles[index])
    }

    /// Moves a profile to `slot`; whoever held it takes the old slot.
    func move(_ id: UUID, toSlot slot: Int) {
        guard let current = profile(id: id), current.slot != slot else { return }
        if let other = profile(slot: slot) {
            update(other.id) { $0.slot = current.slot }
        }
        update(id) { $0.slot = slot }
        sort()
    }

    func delete(_ id: UUID) {
        profiles.removeAll { $0.id == id }
        if activeProfileID == id { activeProfileID = nil }
    }

    // MARK: - Internals

    private func sort() {
        profiles.sort { $0.slot < $1.slot }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(profiles) {
            defaults.set(data, forKey: Keys.profiles)
        }
    }
}
