import SwiftUI

struct ContentView: View {
    @StateObject private var engine = CalculatorEngine()
    @State private var holdTask: Task<Void, Never>?
    @State private var showHello = false
    @State private var showHistory = false
    @State private var mode: CalculatorMode = .basic

    var body: some View {
        VStack(spacing: 0) {
            CalculatorToolbar(mode: $mode, onHistory: { showHistory = true })

            DisplayView(
                expression: engine.expression,
                display: engine.display
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

            CalculatorKeypad(
                engine: engine,
                onDigitTouchDown: { digit in
                    guard digit == 1 else { return }
                    holdTask?.cancel()
                    holdTask = Task {
                        do {
                            try await Task.sleep(nanoseconds: 5_000_000_000)
                            await MainActor.run {
                                showHello = true
                            }
                        } catch {
                            // Cancelled
                        }
                    }
                },
                onDigitTouchUp: { digit in
                    guard digit == 1 else { return }
                    holdTask?.cancel()
                    holdTask = nil
                }
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
        .fullScreenCover(isPresented: $showHello) {
            HelloWorldView()
        }
        .onDisappear {
            holdTask?.cancel()
            holdTask = nil
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
