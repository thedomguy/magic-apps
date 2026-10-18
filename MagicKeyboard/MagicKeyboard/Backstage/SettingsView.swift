import SwiftUI

/// Settings screen: BLE link, passcode, Auto timing.
struct SettingsView: View {
    @ObservedObject var controller: KeyboardController

    var body: some View {
        Form {
            Section("Link") {
                LabeledContent("Status") {
                    Text(controller.peripheral.statusText)
                        .foregroundStyle(controller.peripheral.connectionState.color)
                        .multilineTextAlignment(.trailing)
                }
                if let error = controller.peripheral.lastError {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                TextField("Advertise as", text: $controller.advertiseName)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .submitLabel(.done)

                LabeledContent("This iPhone’s name") {
                    Text(controller.peripheral.systemDeviceName)
                        .foregroundStyle(.secondary)
                }

                Text(
                    """
                    On Apple hosts the Bluetooth list almost always shows this iPhone’s \
                    About name (“\(controller.peripheral.systemDeviceName)”). Rename under \
                    Settings → General → About → Name, then Forget + re-pair on the target. \
                    Force-quit MagicNotes / MagicCalculator so they don’t advertise a second copy.
                    """
                )
                .font(.footnote)
                .foregroundStyle(.secondary)

                Button("Re-pair (reset GATT)") {
                    controller.resetForRepair()
                }
            }

            Section("Passcode") {
                SecureField("4 or 6 digits", text: $controller.passcode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                Text(controller.passcodeMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Auto timing") {
                Stepper(value: $controller.wakeToKeypadMs, in: 300...2000, step: 50) {
                    Text("Wake → Keypad: \(controller.wakeToKeypadMs) ms")
                }
                Stepper(value: $controller.keypadToFireMs, in: 200...1500, step: 50) {
                    Text("Keypad → Fire: \(controller.keypadToFireMs) ms")
                }
                Text("Keypad types 0 then Backspace to open the passcode UI.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                LabeledContent("Last action") {
                    Text(controller.lastAction)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
