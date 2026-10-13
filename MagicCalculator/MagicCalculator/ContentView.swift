import SwiftUI

struct ContentView: View {
    @StateObject private var engine = CalculatorEngine()
    @State private var holdTask: Task<Void, Never>?
    @State private var showHello = false

    var body: some View {
        VStack(spacing: 0) {
            DisplayView(
                expression: engine.expression,
                display: engine.display
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(.horizontal, CalculatorTheme.sideMargin)

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
        }
        // Keep keypad above the home indicator with Apple-like breathing room.
        .safeAreaPadding(.bottom, CalculatorTheme.bottomSafePadding)
        .background(CalculatorTheme.background.ignoresSafeArea())
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
