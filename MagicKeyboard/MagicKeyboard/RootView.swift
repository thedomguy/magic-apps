import SwiftUI

struct RootView: View {
    @StateObject private var controller = KeyboardController()

    var body: some View {
        NavigationStack {
            ControlView(controller: controller)
        }
        .onAppear { controller.start() }
    }
}
