import CoreBluetooth
import Foundation
import Network
import UIKit

/// Sends every broadcast event straight to nearby UnityOS devices, over Bluetooth LE and local
/// Wi-Fi at once, alongside the backend upload. UnityOS keeps the first copy of each event id.
@MainActor
final class LocalLink: ObservableObject {
    static let shared = LocalLink()

    /// For the backstage menu.
    struct Status {
        let bluetooth: String
        let wifi: String
    }

    @Published private(set) var status = Status(bluetooth: "starting", wifi: "starting")

    private let ble = BlePeripheral()
    private let lan = LanServer()
    /// Sealed frames of the latest events, replayed to each new connection so UnityOS catches up.
    private var recent: [Data] = []

    private static let replayCount = 30

    private struct Message: Encodable {
        let k: String
        var e: BroadcastEvent?
        var app: String?
        var name: String?
        var v: Int?
    }

    private init() {
        ble.onSubscribe = { [weak self] in
            guard let self else { return }
            ble.send(hello)
            recent.forEach(ble.send)
        }
        lan.onConnect = { [weak self] connection in
            guard let self else { return }
            lan.send(hello, to: connection)
            recent.forEach { self.lan.send($0, to: connection) }
        }
        ble.onChange = { [weak self] in self?.refreshStatus() }
        lan.onChange = { [weak self] in self?.refreshStatus() }
        lan.start()
    }

    func send(_ events: [BroadcastEvent]) {
        for event in events {
            guard let frame = seal(Message(k: "event", e: event)) else { continue }
            recent.append(frame)
            ble.send(frame)
            lan.send(frame)
        }
        if recent.count > Self.replayCount {
            recent.removeFirst(recent.count - Self.replayCount)
        }
    }

    /// Back in the foreground: the Wi-Fi listener doesn't survive suspension.
    func resume() {
        lan.resume()
    }

    private var hello: Data {
        seal(Message(k: "hello", app: "calculator", name: UIDevice.current.name, v: 1)) ?? Data()
    }

    private func seal(_ message: Message) -> Data? {
        guard let json = try? BroadcastEvent.encoder.encode(message) else { return nil }
        return LinkCrypto.seal(json)
    }

    private func refreshStatus() {
        let bluetooth = switch ble.state {
        case .poweredOn: ble.subscribers.isEmpty ? "advertising" : "\(ble.subscribers.count) linked"
        case .unauthorized: "not allowed"
        case .poweredOff: "off"
        case .unsupported: "unsupported"
        default: "starting"
        }
        let wifi = !lan.isListening ? "not listening"
            : lan.connections.isEmpty ? "listening" : "\(lan.connections.count) linked"
        status = Status(bluetooth: bluetooth, wifi: wifi)
    }
}
