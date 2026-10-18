import SwiftUI

/// Main control surface: Wake / Keypad / Fire / Auto + link to Settings.
struct ControlView: View {
    @ObservedObject var controller: KeyboardController

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text(controller.peripheral.statusText)
                    .font(.subheadline)
                    .foregroundStyle(controller.peripheral.connectionState.color)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Text("Last: \(controller.lastAction)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if controller.isRunningAuto {
                    Text("Running…")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
            .padding(.top, 24)

            Spacer(minLength: 12)

            VStack(spacing: 12) {
                actionButton("Wake", systemImage: "sun.max.fill", enabled: !controller.isRunningAuto) {
                    controller.wake()
                }
                actionButton("Keypad", systemImage: "circle.grid.3x3.fill", enabled: !controller.isRunningAuto) {
                    controller.focusKeypad()
                }
                actionButton("Fire", systemImage: "flame.fill", enabled: !controller.isRunningAuto) {
                    controller.fire()
                }
                actionButton(
                    "Auto",
                    systemImage: "play.fill",
                    enabled: !controller.isRunningAuto,
                    emphasized: true
                ) {
                    controller.runAuto()
                }
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Magic Keyboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView(controller: controller)
                } label: {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
    }

    private func actionButton(
        _ title: String,
        systemImage: String,
        enabled: Bool,
        emphasized: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .contentShape(Rectangle())
                .background(
                    enabled
                        ? (emphasized ? Color.orange.opacity(0.9) : Color.white.opacity(0.2))
                        : Color.white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

extension HIDPeripheral.ConnectionState {
    /// Shared status tint for the control surface and Settings.
    var color: Color {
        switch self {
        case .ready: return .green
        case .advertising, .connected: return .orange
        case .poweredOff, .unauthorized, .unsupported: return .red
        case .idle: return .secondary
        }
    }
}
