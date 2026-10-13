import SwiftUI

/// The calculator is the stack's root with its bar hidden; the backstage screens push on top so
/// the system edge swipe returns to the calculator.
struct RootView: View {
    @State private var path: [BackstageRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ContentView(onOpenBackstage: { path = [.menu] })
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: BackstageRoute.self) { route in
                    route.destination
                }
        }
        .environment(\.backstagePush) { path.append($0) }
    }
}
