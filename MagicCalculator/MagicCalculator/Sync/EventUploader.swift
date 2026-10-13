import Foundation

/// Sends broadcast events to magic-app-backend, in order, through a disk-backed outbox, so events
/// made offline (or while the server is down) go out on the next attempt.
actor EventUploader {
    static let shared = EventUploader()

    private struct Config {
        let eventsURL: URL
        let key: String

        /// Read from Info.plist, which takes them from `Config/Backend*.xcconfig`.
        static func fromBundle() -> Config? {
            let info = Bundle.main.infoDictionary ?? [:]
            guard let raw = info["MagicBackendURL"] as? String,
                  let base = URL(string: raw.trimmingCharacters(in: .whitespaces)),
                  base.scheme != nil else { return nil }
            return Config(
                eventsURL: base.appending(path: "api/events"),
                key: info["MagicBackendKey"] as? String ?? ""
            )
        }
    }

    private enum UploadError: Error {
        /// Worth retrying later (offline, 5xx, auth not set up yet).
        case transient(String)
        /// The server will never accept this event.
        case rejected(String)
    }

    /// For the backstage menu, so a silent failure is visible.
    struct Status: Sendable {
        let server: String?
        let queued: Int
        let lastSentAt: Date?
        let lastError: String?
    }

    private static let maxQueued = 2000
    /// `2026-10-13T14:34:31.156Z`
    private static let timestamp = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    private static let retryDelay: Duration = .seconds(10)

    private let config = Config.fromBundle()
    private let fileURL: URL
    private var outbox: [BroadcastEvent]
    private var isFlushing = false
    private var retryTask: Task<Void, Never>?
    /// Keeps events in call order; a `Task` per submit would not.
    private let incoming: AsyncStream<[BroadcastEvent]>
    private let continuation: AsyncStream<[BroadcastEvent]>.Continuation
    private var lastSentAt: Date?
    private var lastError: String?

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        // Milliseconds: one key press can produce several events within the same second.
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(date.formatted(Self.timestamp))
        }
        return encoder
    }()

    private init() {
        let directory = URL.applicationSupportDirectory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appending(path: "events-outbox.json")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            return try Date(text, strategy: Self.timestamp)
        }
        outbox = (try? Data(contentsOf: fileURL))
            .flatMap { try? decoder.decode([BroadcastEvent].self, from: $0) } ?? []

        (incoming, continuation) = AsyncStream.makeStream(of: [BroadcastEvent].self)
        Task { await self.consume() }
    }

    /// Queues events for sending. Callable from anywhere without awaiting.
    nonisolated func enqueue(_ events: [BroadcastEvent]) {
        guard !events.isEmpty else { return }
        continuation.yield(events)
    }

    private func consume() async {
        for await events in incoming {
            outbox += events
            if outbox.count > Self.maxQueued {
                outbox.removeFirst(outbox.count - Self.maxQueued)
            }
            save()
            // Not awaited, so a slow network never holds up queuing (and saving) the next events.
            Task { await flush() }
        }
    }

    func status() -> Status {
        Status(
            server: config?.eventsURL.host(),
            queued: outbox.count,
            lastSentAt: lastSentAt,
            lastError: config == nil ? "No server configured" : lastError
        )
    }

    func flush() async {
        guard let config, !isFlushing else { return }
        isFlushing = true
        defer { isFlushing = false }

        // New events are appended while we await, so the head is always the one just sent.
        while let next = outbox.first {
            do {
                try await post(next, config: config)
                lastSentAt = Date()
                lastError = nil
            } catch UploadError.rejected(let reason) {
                // Drop it rather than block everything queued behind it.
                lastError = "Dropped an event: \(reason)"
            } catch UploadError.transient(let reason) {
                lastError = reason
                scheduleRetry()
                return
            } catch {
                lastError = error.localizedDescription
                scheduleRetry()
                return
            }
            outbox.removeFirst()
            save()
        }
    }

    private func post(_ event: BroadcastEvent, config: Config) async throws {
        var request = URLRequest(url: config.eventsURL, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !config.key.isEmpty {
            request.setValue("Bearer \(config.key)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try encoder.encode(event)

        let response: URLResponse
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw UploadError.transient(error.localizedDescription)
        }
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        switch status {
        case 200..<300: return
        case 400, 413, 422: throw UploadError.rejected("HTTP \(status)")
        case 401: throw UploadError.transient("HTTP 401: key doesn't match the server's MAGIC_KEY")
        default: throw UploadError.transient("HTTP \(status)")
        }
    }

    private func scheduleRetry() {
        guard retryTask == nil else { return }
        retryTask = Task {
            try? await Task.sleep(for: Self.retryDelay)
            retryTask = nil
            await flush()
        }
    }

    private func save() {
        guard let data = try? encoder.encode(outbox) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
