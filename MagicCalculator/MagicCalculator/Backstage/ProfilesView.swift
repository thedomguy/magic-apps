import SwiftUI

struct ProfilesView: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.backstagePush) private var push
    @State private var pendingDelete: Profile?

    var body: some View {
        List {
            Section {
                ForEach(store.profiles) { profile in
                    NavigationLink(value: BackstageRoute.profile(profile.id)) {
                        ProfileRow(profile: profile, isActive: profile.id == store.activeProfileID)
                    }
                    .swipeActions(edge: .leading) {
                        if profile.id == store.activeProfileID {
                            Button("Turn Off") { store.deactivate() }
                        } else {
                            Button("Use") { store.activate(slot: profile.slot) }
                                .tint(CalculatorTheme.operatorTint)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", role: .destructive) { pendingDelete = profile }
                    }
                }
            } footer: {
                Text("On the calculator, hold 1–9 for 1.5 seconds to load that profile. Hold 0 to turn capture off.")
            }
        }
        .overlay {
            if store.profiles.isEmpty {
                ContentUnavailableView("No Profiles", systemImage: "rectangle.stack")
            }
        }
        .navigationTitle("Profiles")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    createProfile()
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(store.nextFreeSlot == nil)
                .accessibilityLabel("New Profile")
            }
        }
        .confirmationDialog(
            "Delete \(pendingDelete?.displayName ?? "")?",
            isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
            titleVisibility: .visible,
            presenting: pendingDelete
        ) { profile in
            Button("Delete Profile", role: .destructive) { store.delete(profile.id) }
        }
    }

    private func createProfile() {
        guard let profile = store.create() else { return }
        push(.profile(profile.id))
    }
}

struct ProfileRow: View {
    let profile: Profile
    let isActive: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text("\(profile.slot)")
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(Circle().fill(isActive ? CalculatorTheme.operatorTint : CalculatorTheme.digitTint))

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName)
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if isActive {
                Text("Active")
                    .font(.footnote)
                    .foregroundStyle(CalculatorTheme.operatorTint)
            }
        }
        .padding(.vertical, 2)
    }

    private var summary: String {
        profile.fields.indices
            .map { "\(profile.displayLabel(at: $0)) (\(profile.fields[$0].digitCount))" }
            .joined(separator: " × ")
    }
}
