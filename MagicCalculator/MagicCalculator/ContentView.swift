import SwiftUI

struct ContentView: View {
    /// Opens the behind-the-scenes menu (hold `=`).
    var onOpenBackstage: () -> Void = {}

    @EnvironmentObject private var profiles: ProfileStore
    @StateObject private var engine = CalculatorEngine()
    @State private var capture = ProfileCapture()
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
        .onChange(of: profiles.activeProfileID) {
            capture.reset()
        }
        .onDisappear {
            flashTask?.cancel()
            flashTask = nil
            flash = nil
        }
    }

    /// Hold 1–9 loads that slot's profile; hold 0 turns capture off.
    private func loadProfile(slot: Int) {
        if slot == 0 {
            profiles.deactivate()
            engine.clear()
            showFlash("Off")
            return
        }
        guard let profile = profiles.activate(slot: slot) else { return }
        // The held digit was already entered; start the profile on a clean slate.
        engine.clear()
        capture.reset()
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
        guard let profile = profiles.activeProfile else { return }
        let entry: CapturedEntry?
        switch event {
        case .changed(let operands):
            entry = capture.update(operands: operands, profile: profile)
        case .committed(let operands):
            entry = capture.commit(operands: operands, profile: profile)
        }
        if let entry {
            Task { await EntryUploader.shared.submit(entry) }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ProfileStore())
        .preferredColorScheme(.dark)
}
