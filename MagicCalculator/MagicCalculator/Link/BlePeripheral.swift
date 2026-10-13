import CoreBluetooth
import Foundation

/// Advertises the link service and notifies subscribed UnityOS devices with sealed frames,
/// chunked to fit the link (`header ‖ part`, header bit 7 = last part). Works with no network.
/// Runs on the main queue.
final class BlePeripheral: NSObject, CBPeripheralManagerDelegate {
    /// A UnityOS device subscribed; time to send `hello` and the replay.
    var onSubscribe: () -> Void = {}
    var onChange: () -> Void = {}

    private(set) var subscribers: [CBCentral] = []
    private(set) var state: CBManagerState = .unknown

    private var manager: CBPeripheralManager!
    private let events = CBMutableCharacteristic(
        type: LinkCrypto.eventsUUID,
        properties: [.notify],
        value: nil,
        permissions: [.readable]
    )
    /// Reserved for commands from UnityOS; accepted and ignored for now.
    private let control = CBMutableCharacteristic(
        type: LinkCrypto.controlUUID,
        properties: [.write, .writeWithoutResponse],
        value: nil,
        permissions: [.writeable]
    )
    /// Chunks waiting for room in the notify queue.
    private var pending: [Data] = []

    private static let lastPart: UInt8 = 0x80

    override init() {
        super.init()
        manager = CBPeripheralManager(
            delegate: self,
            queue: nil,
            options: [CBPeripheralManagerOptionShowPowerAlertKey: false]
        )
    }

    func send(_ frame: Data) {
        guard !subscribers.isEmpty else { return }
        // One size for everyone, so a single notify reaches all subscribers.
        let size = max(19, (subscribers.map(\.maximumUpdateValueLength).min() ?? 20) - 1)
        var offset = 0
        while offset < frame.count {
            let end = min(offset + size, frame.count)
            var chunk = Data([end == frame.count ? Self.lastPart : 0])
            chunk.append(frame[offset..<end])
            pending.append(chunk)
            offset = end
        }
        pump()
    }

    private func pump() {
        while let next = pending.first {
            // false = the queue is full; peripheralManagerIsReady calls back when there's room.
            guard manager.updateValue(next, for: events, onSubscribedCentrals: nil) else { return }
            pending.removeFirst()
        }
    }

    // MARK: - CBPeripheralManagerDelegate

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        state = peripheral.state
        if peripheral.state == .poweredOn {
            let service = CBMutableService(type: LinkCrypto.serviceUUID, primary: true)
            service.characteristics = [events, control]
            peripheral.removeAllServices()
            peripheral.add(service)
        } else {
            subscribers = []
            pending = []
        }
        onChange()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        guard error == nil else { return }
        // Service UUID only: no local name, nothing readable as "magic" to a scanner.
        peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [LinkCrypto.serviceUUID]])
    }

    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didSubscribeTo characteristic: CBCharacteristic
    ) {
        subscribers.removeAll { $0.identifier == central.identifier }
        subscribers.append(central)
        // Drop half-sent frames: the new subscriber would only get their tail.
        pending.removeAll()
        onChange()
        onSubscribe()
    }

    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didUnsubscribeFrom characteristic: CBCharacteristic
    ) {
        subscribers.removeAll { $0.identifier == central.identifier }
        if subscribers.isEmpty { pending.removeAll() }
        onChange()
    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        pump()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        if let first = requests.first {
            peripheral.respond(to: first, withResult: .success)
        }
    }
}
