import SwiftUI

/// Screens of the behind-the-scenes menu, opened by holding `=` for 3 seconds.
enum BackstageRoute: Hashable {
    case menu
    case profiles
    case profile(Profile.ID)

    @ViewBuilder
    var destination: some View {
        switch self {
        case .menu: BackstageMenuView()
        case .profiles: ProfilesView()
        case .profile(let id): ProfileEditorView(id: id)
        }
    }
}

extension EnvironmentValues {
    /// Pushes a backstage screen onto the root stack (for pushes that follow an action).
    @Entry var backstagePush: (BackstageRoute) -> Void = { _ in }
}

struct BackstageMenuView: View {
    @EnvironmentObject private var profiles: ProfileStore
    @State private var sync: EntryUploader.Status?

    var body: some View {
        List {
            Section {
                NavigationLink(value: BackstageRoute.profiles) {
                    Label("Profile configuration", systemImage: "rectangle.stack")
                }
            } footer: {
                statusFooter
            }
        }
        .navigationTitle("Behind the Scenes")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Opening the menu also retries anything stuck in the queue.
            await EntryUploader.shared.flush()
            sync = await EntryUploader.shared.status()
        }
    }

    private var statusFooter: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Capturing: \(profiles.activeProfile.map { "\($0.slot) · \($0.displayName)" } ?? "off")")
            if let sync {
                Text("Server: \(sync.server ?? "none")")
                Text("Queued: \(sync.queued)")
                if let sent = sync.lastSentAt {
                    Text("Last sent: \(sent.formatted(date: .omitted, time: .standard))")
                }
                if let error = sync.lastError {
                    Text(error).foregroundStyle(.red)
                }
            }
        }
        .padding(.top, 8)
    }
}
