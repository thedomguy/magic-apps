import Foundation
import Network

/// WebSocket server advertised over Bonjour (`_ulink._tcp`) for UnityOS on the same Wi-Fi or on
/// the S24's hotspot. Each binary message is one sealed frame. Runs on the main queue.
final class LanServer {
    static let serviceType = "_ulink._tcp"

    /// A UnityOS device connected; send it `hello` and the replay.
    var onConnect: (NWConnection) -> Void = { _ in }
    var onChange: () -> Void = {}

    private(set) var connections: [NWConnection] = []
    private(set) var isListening = false

    private var listener: NWListener?
    private var restartTask: Task<Void, Never>?

    func start() {
        guard listener == nil else { return }
        let socket = NWProtocolWebSocket.Options()
        socket.autoReplyPing = true
        let parameters = NWParameters.tcp
        parameters.defaultProtocolStack.applicationProtocols.insert(socket, at: 0)

        guard let listener = try? NWListener(using: parameters) else { return scheduleRestart() }
        listener.service = NWListener.Service(type: Self.serviceType)
        listener.newConnectionHandler = { [weak self] in self?.accept($0) }
        listener.stateUpdateHandler = { [weak self, weak listener] state in
            // A cancelled predecessor can report late; only the current listener counts.
            guard let self, let listener, listener === self.listener else { return }
            switch state {
            case .ready:
                isListening = true
                onChange()
            case .failed, .cancelled:
                isListening = false
                onChange()
                // Background suspension kills the listener; bring it back.
                if case .failed = state { scheduleRestart() }
            default:
                break
            }
        }
        self.listener = listener
        listener.start(queue: .main)
    }

    /// Restarts a listener that died while the app was in the background.
    func resume() {
        if !isListening { scheduleRestart(after: .zero) }
    }

    func send(_ frame: Data, to connection: NWConnection? = nil) {
        for target in connection.map({ [$0] }) ?? connections {
            let message = NWProtocolWebSocket.Metadata(opcode: .binary)
            let context = NWConnection.ContentContext(identifier: "frame", metadata: [message])
            target.send(content: frame, contentContext: context, isComplete: true, completion: .idempotent)
        }
    }

    private func accept(_ connection: NWConnection) {
        connection.stateUpdateHandler = { [weak self, weak connection] state in
            guard let self, let connection else { return }
            switch state {
            case .ready:
                connections.append(connection)
                onChange()
                onConnect(connection)
            case .failed, .cancelled:
                connections.removeAll { $0 === connection }
                onChange()
            default:
                break
            }
        }
        connection.start(queue: .main)
        receive(on: connection)
    }

    /// Drains incoming messages (reserved for commands from UnityOS) and notices hang-ups.
    private func receive(on connection: NWConnection) {
        connection.receiveMessage { [weak self] _, context, _, error in
            let metadata = context?.protocolMetadata(definition: NWProtocolWebSocket.definition)
            if error != nil || (metadata as? NWProtocolWebSocket.Metadata)?.opcode == .close {
                connection.cancel()
                return
            }
            self?.receive(on: connection)
        }
    }

    private func scheduleRestart(after delay: Duration = .seconds(2)) {
        restartTask?.cancel()
        restartTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: delay)
            guard let self, !Task.isCancelled else { return }
            listener?.cancel()
            listener = nil
            start()
        }
    }
}
