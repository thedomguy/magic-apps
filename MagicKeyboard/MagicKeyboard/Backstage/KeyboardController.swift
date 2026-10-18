import Combine
import Foundation

/// Wires HID peripheral and passcode store into Wake / Keypad / Fire / Auto.
@MainActor
final class KeyboardController: ObservableObject {
    let peripheral = HIDPeripheral()
    private var cancellables = Set<AnyCancellable>()

    @Published var passcode: String = PasscodeStore.load() {
        didSet {
            let digits = passcode.filter(\.isNumber)
            if digits != passcode { passcode = digits }
            if PasscodeStore.isValid(passcode) {
                _ = PasscodeStore.save(passcode)
                passcodeMessage = "Saved (\(passcode.count) digits)"
            } else if passcode.isEmpty {
                PasscodeStore.clear()
                passcodeMessage = "Enter 4 or 6 digits"
            } else {
                passcodeMessage = "Need 4 or 6 digits"
            }
        }
    }

    @Published private(set) var passcodeMessage = "Enter 4 or 6 digits"
    @Published private(set) var lastAction = "—"
    @Published private(set) var isRunningAuto = false

    /// Delay after Wake before Keypad focus (screen on → passcode UI).
    @Published var wakeToKeypadMs: Int = 900 {
        didSet { UserDefaults.standard.set(wakeToKeypadMs, forKey: Self.wakeToKeypadKey) }
    }
    /// Delay after Keypad focus before typing digits.
    @Published var keypadToFireMs: Int = 450 {
        didSet { UserDefaults.standard.set(keypadToFireMs, forKey: Self.keypadToFireKey) }
    }

    private static let wakeToKeypadKey = "routine.wakeToKeypadMs"
    private static let keypadToFireKey = "routine.keypadToFireMs"
    private var autoTask: Task<Void, Never>?

    var advertiseName: String {
        get { peripheral.advertiseName }
        set { peripheral.advertiseName = newValue }
    }

    var canFire: Bool {
        peripheral.canSend && PasscodeStore.isValid(passcode) && !isRunningAuto
    }

    init() {
        let wakeDelay = UserDefaults.standard.object(forKey: Self.wakeToKeypadKey) as? Int
        let fireDelay = UserDefaults.standard.object(forKey: Self.keypadToFireKey) as? Int
        wakeToKeypadMs = wakeDelay ?? 900
        keypadToFireMs = fireDelay ?? 450

        // The peripheral is a nested ObservableObject; forward its changes so views
        // observing the controller re-read peripheral.statusText / connectionState live.
        peripheral.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func start() {
        peripheral.start()
        if PasscodeStore.isValid(passcode) {
            passcodeMessage = "Saved (\(passcode.count) digits)"
        }
    }

    func stop() {
        autoTask?.cancel()
        autoTask = nil
        isRunningAuto = false
        peripheral.stop()
    }

    func wake() {
        guard !isRunningAuto else { return }
        lastAction = "Wake"
        Task { await peripheral.wake() }
    }

    /// Opens the passcode keypad (throwaway digit + backspace).
    func focusKeypad() {
        guard !isRunningAuto else { return }
        lastAction = "Keypad"
        Task { await peripheral.focusKeypad() }
    }

    func fire() {
        guard !isRunningAuto else { return }
        lastAction = "Fire"
        Task { await peripheral.typePasscode(passcode) }
    }

    /// Wake → wait → Keypad → wait → Fire.
    func runAuto() {
        guard peripheral.canSend, PasscodeStore.isValid(passcode) else {
            lastAction = "Auto blocked"
            return
        }
        guard !isRunningAuto else { return }

        autoTask?.cancel()
        isRunningAuto = true
        autoTask = Task { [weak self] in
            guard let self else { return }
            defer {
                self.isRunningAuto = false
                self.autoTask = nil
            }

            self.lastAction = "Auto: Wake"
            await self.peripheral.wake()
            guard !Task.isCancelled else { return }

            try? await Task.sleep(nanoseconds: UInt64(self.wakeToKeypadMs) * 1_000_000)
            guard !Task.isCancelled else { return }

            self.lastAction = "Auto: Keypad"
            await self.peripheral.focusKeypad()
            guard !Task.isCancelled else { return }

            try? await Task.sleep(nanoseconds: UInt64(self.keypadToFireMs) * 1_000_000)
            guard !Task.isCancelled else { return }

            self.lastAction = "Auto: Fire"
            await self.peripheral.typePasscode(self.passcode)
            guard !Task.isCancelled else { return }

            self.lastAction = "Auto: Done"
        }
    }

    func resetForRepair() {
        autoTask?.cancel()
        autoTask = nil
        isRunningAuto = false
        lastAction = "Re-pair"
        peripheral.resetForRepair()
    }
}
