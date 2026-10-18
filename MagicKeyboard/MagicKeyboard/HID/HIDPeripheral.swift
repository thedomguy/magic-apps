import CoreBluetooth
import Foundation
import UIKit

/// HOGP keyboard peripheral. Advertises HID + local name; sends via Report Protocol
/// (0x2A4D) and Boot Keyboard Input (0x2A22) so Apple hosts can bind either path.
@MainActor
final class HIDPeripheral: NSObject, ObservableObject {
    enum ConnectionState: Equatable {
        case poweredOff
        case unauthorized
        case unsupported
        case idle
        case advertising
        case connected
        case ready
    }

    @Published private(set) var connectionState: ConnectionState = .idle
    @Published private(set) var statusText = "Bluetooth idle"
    @Published private(set) var lastError: String?
    /// What iOS will actually show on Apple hosts (Settings → About → Name).
    @Published private(set) var systemDeviceName = UIDevice.current.name

    @Published var advertiseName: String = HIDConstants.defaultAdvertiseName {
        didSet {
            let trimmed = Self.sanitizeAdvertiseName(advertiseName)
            if trimmed != advertiseName {
                advertiseName = trimmed
                return
            }
            guard !suppressNameSideEffects else { return }
            guard trimmed != lastAppliedAdvertiseName else { return }
            UserDefaults.standard.set(trimmed, forKey: Self.advertiseNameKey)
            scheduleAdvertisingRestart()
        }
    }

    private static let advertiseNameKey = "hid.advertiseName"

    private var manager: CBPeripheralManager?
    private var bootInputChar: CBMutableCharacteristic?
    private var reportInputChar: CBMutableCharacteristic?
    private var subscribedBoot: [UUID: CBCentral] = [:]
    private var subscribedReport: [UUID: CBCentral] = [:]
    private var seenCentrals: Set<UUID> = []

    private var isAdvertising = false
    private var advertiseCallInFlight = false
    private var servicesInstalled = false
    private var lastAppliedAdvertiseName = ""
    private var nameRestartTask: Task<Void, Never>?
    private var suppressNameSideEffects = true
    /// Sequential add: battery → deviceInfo → hid (matches working HOGP stacks).
    private enum InstallPhase { case idle, battery, deviceInfo, hid, done }
    private var installPhase: InstallPhase = .idle

    private let keystrokeGapNs: UInt64 = 40_000_000
    private var sendTask: Task<Void, Never>?
    private var cachedReport = BootKeyboardReport.release.data

    override init() {
        super.init()
        let stored = UserDefaults.standard.string(forKey: Self.advertiseNameKey)
        let name = Self.sanitizeAdvertiseName(stored ?? HIDConstants.defaultAdvertiseName)
        suppressNameSideEffects = true
        advertiseName = name
        lastAppliedAdvertiseName = name
        suppressNameSideEffects = false
    }

    static func sanitizeAdvertiseName(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return HIDConstants.defaultAdvertiseName }
        return String(trimmed.prefix(10))
    }

    func start() {
        systemDeviceName = UIDevice.current.name
        if manager != nil {
            if manager?.state == .poweredOn, !servicesInstalled {
                beginInstall()
            }
            return
        }
        manager = CBPeripheralManager(delegate: self, queue: nil, options: [
            CBPeripheralManagerOptionShowPowerAlertKey: true
        ])
    }

    func stop() {
        nameRestartTask?.cancel()
        nameRestartTask = nil
        sendTask?.cancel()
        sendTask = nil
        manager?.stopAdvertising()
        manager?.removeAllServices()
        manager = nil
        bootInputChar = nil
        reportInputChar = nil
        subscribedBoot.removeAll()
        subscribedReport.removeAll()
        seenCentrals.removeAll()
        isAdvertising = false
        advertiseCallInFlight = false
        servicesInstalled = false
        installPhase = .idle
        connectionState = .idle
        statusText = "Stopped"
    }

    func resetForRepair() {
        stop()
        start()
    }

    var canSend: Bool { !subscribedBoot.isEmpty || !subscribedReport.isEmpty }

    /// Lights the Lock Screen (modifier-only tap — no character).
    func wake() async {
        guard ensureCanSend() else { return }
        await send([BootKeyboardReport.wakeTap(), .release])
    }

    /// Opens the passcode keypad by typing a throwaway digit, then backspaces it
    /// so Fire can enter the real code cleanly.
    func focusKeypad() async {
        guard ensureCanSend() else { return }
        await send([
            .keyDown(.digit0),
            .release,
            .keyDown(.backspace),
            .release
        ])
    }

    func typePasscode(_ passcode: String, appendReturn: Bool = true) async {
        guard ensureCanSend() else { return }
        let digits = passcode.filter(\.isNumber)
        guard PasscodeStore.isValid(digits) else {
            lastError = "Passcode must be 4 or 6 digits"
            return
        }
        var reports: [BootKeyboardReport] = []
        for character in digits {
            guard let key = BootKeycode.digit(character) else { continue }
            reports.append(.keyDown(key))
            reports.append(.release)
        }
        if appendReturn {
            reports.append(.keyDown(.return))
            reports.append(.release)
        }
        await send(reports)
    }

    private func ensureCanSend() -> Bool {
        guard canSend else {
            lastError = "Host hasn’t subscribed yet — Forget on both sides, then re-pair"
            return false
        }
        return true
    }

    /// Sends reports sequentially; cancels any in-flight sequence.
    func send(_ reports: [BootKeyboardReport]) async {
        sendTask?.cancel()
        let task = Task { [weak self] in
            for report in reports {
                guard let self, !Task.isCancelled else { return }
                self.publish(report.data)
                try? await Task.sleep(nanoseconds: self.keystrokeGapNs)
            }
        }
        sendTask = task
        await task.value
    }

    private func publish(_ data: Data) {
        cachedReport = data
        guard let manager else { return }
        if let reportInputChar, !subscribedReport.isEmpty {
            _ = manager.updateValue(data, for: reportInputChar, onSubscribedCentrals: Array(subscribedReport.values))
        }
        if let bootInputChar, !subscribedBoot.isEmpty {
            _ = manager.updateValue(data, for: bootInputChar, onSubscribedCentrals: Array(subscribedBoot.values))
        }
    }

    private func beginInstall() {
        guard let manager, manager.state == .poweredOn else { return }
        guard installPhase == .idle || installPhase == .done else { return }

        manager.stopAdvertising()
        manager.removeAllServices()
        isAdvertising = false
        advertiseCallInFlight = false
        servicesInstalled = false
        bootInputChar = nil
        reportInputChar = nil

        installPhase = .battery
        manager.add(buildBatteryService())
    }

    private func buildBatteryService() -> CBMutableService {
        let battery = CBMutableService(type: HIDUUIDs.batteryService, primary: true)
        let batteryLevel = CBMutableCharacteristic(
            type: HIDUUIDs.batteryLevel,
            properties: [.read, .notify],
            value: nil,
            permissions: [.readable]
        )
        battery.characteristics = [batteryLevel]
        return battery
    }

    private func buildDeviceInfoService() -> CBMutableService {
        let deviceInfo = CBMutableService(type: HIDUUIDs.deviceInformationService, primary: true)
        deviceInfo.characteristics = [
            CBMutableCharacteristic(
                type: HIDUUIDs.manufacturerName,
                properties: .read,
                value: HIDConstants.manufacturerNameValue,
                permissions: .readable
            ),
            CBMutableCharacteristic(
                type: HIDUUIDs.modelNumber,
                properties: .read,
                value: HIDConstants.modelNumberValue,
                permissions: .readable
            ),
            CBMutableCharacteristic(
                type: HIDUUIDs.pnpID,
                properties: .read,
                value: HIDConstants.pnpIDValue,
                permissions: .readable
            )
        ]
        return deviceInfo
    }

    private func buildHIDService() -> CBMutableService {
        let hid = CBMutableService(type: HIDUUIDs.hidService, primary: true)

        let hidInfo = CBMutableCharacteristic(
            type: HIDUUIDs.hidInformation,
            properties: .read,
            value: HIDConstants.hidInformationValue,
            permissions: .readable
        )
        let reportMap = CBMutableCharacteristic(
            type: HIDUUIDs.reportMap,
            properties: .read,
            value: HIDConstants.reportMapData,
            permissions: .readable
        )
        // No .extendedProperties — that injects a descriptor and breaks HID binding.
        let protocolMode = CBMutableCharacteristic(
            type: HIDUUIDs.protocolMode,
            properties: [.read, .writeWithoutResponse],
            value: nil,
            permissions: [.readable, .writeable]
        )
        let controlPoint = CBMutableCharacteristic(
            type: HIDUUIDs.hidControlPoint,
            properties: .writeWithoutResponse,
            value: nil,
            permissions: .writeable
        )
        let bootInput = CBMutableCharacteristic(
            type: HIDUUIDs.bootKeyboardInputReport,
            properties: [.read, .notifyEncryptionRequired],
            value: nil,
            permissions: [.readEncryptionRequired]
        )
        let bootOutput = CBMutableCharacteristic(
            type: HIDUUIDs.bootKeyboardOutputReport,
            properties: [.read, .writeWithoutResponse, .write],
            value: nil,
            permissions: [.readable, .writeable]
        )
        let reportInput = CBMutableCharacteristic(
            type: HIDUUIDs.report,
            properties: [.read, .notifyEncryptionRequired],
            value: nil,
            permissions: [.readEncryptionRequired]
        )
        reportInput.descriptors = [
            CBMutableDescriptor(
                type: HIDUUIDs.reportReference,
                value: HIDConstants.keyboardReportReference as NSData
            )
        ]

        hid.characteristics = [
            controlPoint,
            protocolMode,
            hidInfo,
            bootInput,
            bootOutput,
            reportMap,
            reportInput
        ]
        bootInputChar = bootInput
        reportInputChar = reportInput
        return hid
    }

    private func startAdvertisingIfNeeded() {
        guard let manager, manager.state == .poweredOn else { return }
        guard installPhase == .done else { return }
        guard !isAdvertising, !advertiseCallInFlight else { return }

        advertiseCallInFlight = true
        lastAppliedAdvertiseName = advertiseName
        // Only LocalName + ServiceUUIDs are supported on CBPeripheralManager.
        // Use 16-bit 0x1812 so the name isn’t dropped from the 31-byte packet.
        manager.startAdvertising([
            CBAdvertisementDataLocalNameKey: advertiseName,
            CBAdvertisementDataServiceUUIDsKey: [HIDUUIDs.hidServiceShort]
        ])
    }

    private func scheduleAdvertisingRestart() {
        nameRestartTask?.cancel()
        nameRestartTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 600_000_000)
            guard let self, !Task.isCancelled else { return }
            self.restartAdvertising()
        }
    }

    func restartAdvertising() {
        guard let manager, manager.state == .poweredOn, installPhase == .done else { return }
        guard subscribedBoot.isEmpty, subscribedReport.isEmpty else { return }

        manager.stopAdvertising()
        isAdvertising = false
        advertiseCallInFlight = false
        startAdvertisingIfNeeded()
        refreshState()
    }

    private func noteCentralActivity(_ central: CBCentral) {
        seenCentrals.insert(central.identifier)
        refreshState()
    }

    private func refreshState() {
        systemDeviceName = UIDevice.current.name
        if canSend {
            connectionState = .ready
            statusText = "Ready — keyboard host subscribed"
        } else if !seenCentrals.isEmpty {
            connectionState = .connected
            statusText = "Host connected — waiting for HID subscribe"
        } else if isAdvertising || advertiseCallInFlight {
            connectionState = .advertising
            statusText = "Advertising HID as “\(advertiseName)” (Apple list may show “\(systemDeviceName)”)"
        } else {
            connectionState = .idle
            statusText = "Idle"
        }
    }

    private func isAlreadyAdvertisingError(_ error: Error) -> Bool {
        let text = error.localizedDescription.lowercased()
        return text.contains("already") && text.contains("advertis")
    }
}

extension HIDPeripheral: CBPeripheralManagerDelegate {
    nonisolated func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        Task { @MainActor in
            switch peripheral.state {
            case .poweredOn:
                lastError = nil
                if installPhase == .idle || (installPhase == .done && !servicesInstalled) {
                    installPhase = .idle
                    beginInstall()
                } else if installPhase == .done {
                    startAdvertisingIfNeeded()
                }
                refreshState()
            case .poweredOff:
                connectionState = .poweredOff
                statusText = "Bluetooth off"
                isAdvertising = false
                advertiseCallInFlight = false
            case .unauthorized:
                connectionState = .unauthorized
                statusText = "Bluetooth permission denied"
            case .unsupported:
                connectionState = .unsupported
                statusText = "Bluetooth unsupported"
            default:
                statusText = "Bluetooth unavailable"
            }
        }
    }

    nonisolated func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didAdd service: CBService,
        error: Error?
    ) {
        Task { @MainActor in
            if let error {
                lastError = "Add service: \(error.localizedDescription)"
                installPhase = .idle
                servicesInstalled = false
                return
            }
            switch service.uuid {
            case HIDUUIDs.batteryService:
                installPhase = .deviceInfo
                peripheral.add(buildDeviceInfoService())
            case HIDUUIDs.deviceInformationService:
                installPhase = .hid
                peripheral.add(buildHIDService())
            case HIDUUIDs.hidService:
                installPhase = .done
                servicesInstalled = true
                startAdvertisingIfNeeded()
                refreshState()
            default:
                break
            }
        }
    }

    nonisolated func peripheralManagerDidStartAdvertising(
        _ peripheral: CBPeripheralManager,
        error: Error?
    ) {
        Task { @MainActor in
            advertiseCallInFlight = false
            if let error {
                if isAlreadyAdvertisingError(error) {
                    isAdvertising = true
                    lastError = nil
                } else {
                    lastError = "Advertise: \(error.localizedDescription)"
                    isAdvertising = false
                }
            } else {
                isAdvertising = true
                lastError = nil
            }
            refreshState()
        }
    }

    nonisolated func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didSubscribeTo characteristic: CBCharacteristic
    ) {
        Task { @MainActor in
            noteCentralActivity(central)
            switch characteristic.uuid {
            case HIDUUIDs.bootKeyboardInputReport:
                subscribedBoot[central.identifier] = central
                if let bootInputChar {
                    _ = peripheral.updateValue(cachedReport, for: bootInputChar, onSubscribedCentrals: [central])
                }
            case HIDUUIDs.report:
                subscribedReport[central.identifier] = central
                if let reportInputChar {
                    _ = peripheral.updateValue(cachedReport, for: reportInputChar, onSubscribedCentrals: [central])
                }
            default:
                break
            }
            refreshState()
        }
    }

    nonisolated func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didUnsubscribeFrom characteristic: CBCharacteristic
    ) {
        Task { @MainActor in
            switch characteristic.uuid {
            case HIDUUIDs.bootKeyboardInputReport:
                subscribedBoot.removeValue(forKey: central.identifier)
            case HIDUUIDs.report:
                subscribedReport.removeValue(forKey: central.identifier)
            default:
                break
            }
            // Once a central holds no subscriptions, it's effectively gone — drop it so
            // the status falls back to advertising instead of a stale "connected".
            let id = central.identifier
            if subscribedBoot[id] == nil, subscribedReport[id] == nil {
                seenCentrals.remove(id)
            }
            if !canSend {
                startAdvertisingIfNeeded()
            }
            refreshState()
        }
    }

    nonisolated func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveRead request: CBATTRequest
    ) {
        Task { @MainActor in
            noteCentralActivity(request.central)

            let payload: Data?
            switch request.characteristic.uuid {
            case HIDUUIDs.protocolMode:
                payload = Data([HIDConstants.reportProtocolMode])
            case HIDUUIDs.bootKeyboardInputReport, HIDUUIDs.report:
                payload = cachedReport
            case HIDUUIDs.batteryLevel:
                payload = Data([100])
            case HIDUUIDs.bootKeyboardOutputReport:
                payload = Data([0x00])
            case HIDUUIDs.hidInformation:
                payload = HIDConstants.hidInformationValue
            case HIDUUIDs.reportMap:
                payload = HIDConstants.reportMapData
            case HIDUUIDs.manufacturerName:
                payload = HIDConstants.manufacturerNameValue
            case HIDUUIDs.modelNumber:
                payload = HIDConstants.modelNumberValue
            case HIDUUIDs.pnpID:
                payload = HIDConstants.pnpIDValue
            default:
                peripheral.respond(to: request, withResult: .requestNotSupported)
                return
            }
            guard let payload else {
                peripheral.respond(to: request, withResult: .unlikelyError)
                return
            }
            guard request.offset <= payload.count else {
                peripheral.respond(to: request, withResult: .invalidOffset)
                return
            }
            request.value = payload.subdata(in: request.offset..<payload.count)
            peripheral.respond(to: request, withResult: .success)
        }
    }

    nonisolated func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveWrite requests: [CBATTRequest]
    ) {
        Task { @MainActor in
            for request in requests {
                noteCentralActivity(request.central)
                if request.characteristic.properties.contains(.write) {
                    peripheral.respond(to: request, withResult: .success)
                }
            }
        }
    }
}
