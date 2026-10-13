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
    var body: some View {
        List {
            NavigationLink(value: BackstageRoute.profiles) {
                Label("Profile configuration", systemImage: "rectangle.stack")
            }
        }
        .navigationTitle("Behind the Scenes")
        .navigationBarTitleDisplayMode(.inline)
    }
}
