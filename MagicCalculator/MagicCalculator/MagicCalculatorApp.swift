import SwiftUI

@main
struct MagicCalculatorApp: App {
    @StateObject private var profiles = ProfileStore()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Start advertising right away so UnityOS links up before the first key press.
        _ = LocalLink.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(profiles)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { _, phase in
            // Send anything queued while offline or in the background.
            if phase == .active {
                Task { await EventUploader.shared.flush() }
                LocalLink.shared.resume()
            }
        }
    }
}
