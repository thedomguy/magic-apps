import SwiftUI

struct ContentView: View {
    /// Opens the behind-the-scenes menu (hold `=`).
    var onOpenBackstage: () -> Void = {}

    @EnvironmentObject private var profiles: ProfileStore
    @StateObject private var engine = CalculatorEngine()
    @State private var broadcaster = ActionBroadcaster()
    @State private var flash: String?
    @State private var flashTask: Task<Void, Never>?
    @State private var showHistory = false
    @State private var mode: CalculatorMode = .basic

    private static let flashDuration: Duration = .seconds(2)

    var body: some View {
        VStack(spacing: 0) {
            CalculatorToolbar(mode: $mode, onHistory: { showHistory = true })

            DisplayView(
                expression: engine.expression,
                display: engine.display,
                flash: flash
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

            CalculatorKeypad(
                engine: engine,
                onDigitHold: loadProfile(slot:),
                onEqualsHold: onOpenBackstage
            )
            // Keypad claims its full width-driven height first; the display takes what's left.
            // Without this the VStack splits height with the display and the keys shrink.
            .layoutPriority(1)
        }
        .safeAreaPadding(.bottom, CalculatorTheme.bottomSafePadding)
        .background {
            CalculatorTheme.background
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showHistory) {
            HistorySheet(engine: engine)
        }
        .onReceive(engine.inputs, perform: handleInput(_:))
        .onDisappear {
            flashTask?.cancel()
            flashTask = nil
            flash = nil
        }
    }

    /// Hold 1–9 loads that slot's profile; hold 0 turns capture off.
    /// Broadcast like any other action; the peek app shows which profile is live.
    private func loadProfile(slot: Int) {
        if slot == 0 {
            // Clear first so the open calculation closes under the profile it belongs to.
            engine.clear()
            if let previous = profiles.activeProfile {
                EventUploader.shared.enqueue(broadcaster.captureTurnedOff(previous))
            }
            profiles.deactivate()
            showFlash("Off")
            return
        }
        guard let profile = profiles.profile(slot: slot) else { return }
        // The held digit was already entered; start the profile on a clean slate.
        engine.clear()
        profiles.activate(slot: slot)
        EventUploader.shared.enqueue(broadcaster.profileLoaded(profile))
        showFlash(profile.flashText)
    }

    private func showFlash(_ text: String) {
        flashTask?.cancel()
        flash = text
        flashTask = Task {
            try? await Task.sleep(for: Self.flashDuration)
            guard !Task.isCancelled else { return }
            flash = nil
        }
    }

    private func handleInput(_ event: CalculatorEngine.InputEvent) {
        // Nothing is broadcast while capture is off.
        guard let profile = profiles.activeProfile else { return }
        EventUploader.shared.enqueue(broadcaster.handle(event, profile: profile))
    }
}

#Preview {
    ContentView()
        .environmentObject(ProfileStore())
        .preferredColorScheme(.dark)
}
