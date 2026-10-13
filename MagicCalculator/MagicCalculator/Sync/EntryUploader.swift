import Foundation

/// Sends captured entries to magic-app-backend through a disk-backed outbox, so entries made
/// offline (or while the server is down) go out on the next attempt.
actor EntryUploader {
    static let shared = EntryUploader()

    private struct Config {
        let entriesURL: URL
        let key: String

        /// Read from Info.plist, which takes them from `Config/Backend*.xcconfig`.
        static func fromBundle() -> Config? {
            let info = Bundle.main.infoDictionary ?? [:]
            guard let raw = info["MagicBackendURL"] as? String,
                  let base = URL(string: raw.trimmingCharacters(in: .whitespaces)),
                  base.scheme != nil else { return nil }
            return Config(
                entriesURL: base.appending(path: "api/entries"),
                key: info["MagicBackendKey"] as? String ?? ""
            )
        }
    }

    private enum UploadError: Error {
        /// Worth retrying later (offline, 5xx, auth not set up yet).
        case transient
        /// The server will never accept this entry.
        case rejected
    }

    private static let maxQueued = 500
    private static let retryDelay: Duration = .seconds(10)

    private let config = Config.fromBundle()
    private let fileURL: URL
    private var outbox: [CapturedEntry]
    private var isFlushing = false
    private var retryTask: Task<Void, Never>?

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private init() {
        let directory = URL.applicationSupportDirectory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appending(path: "outbox.json")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        outbox = (try? Data(contentsOf: fileURL))
            .flatMap { try? decoder.decode([CapturedEntry].self, from: $0) } ?? []
    }

    func submit(_ entry: CapturedEntry) async {
        outbox.append(entry)
        if outbox.count > Self.maxQueued {
            outbox.removeFirst(outbox.count - Self.maxQueued)
        }
        save()
        await flush()
    }

    func flush() async {
        guard let config, !isFlushing else { return }
        isFlushing = true
        defer { isFlushing = false }

        // New entries are appended while we await, so the head is always the one just sent.
        while let next = outbox.first {
            do {
                try await post(next, config: config)
            } catch UploadError.rejected {
                // Drop it rather than block everything queued behind it.
            } catch {
                scheduleRetry()
                return
            }
            outbox.removeFirst()
            save()
        }
    }

    private func post(_ entry: CapturedEntry, config: Config) async throws {
        var request = URLRequest(url: config.entriesURL, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !config.key.isEmpty {
            request.setValue("Bearer \(config.key)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try encoder.encode(entry)

        guard let (_, response) = try? await URLSession.shared.data(for: request),
              let status = (response as? HTTPURLResponse)?.statusCode else {
            throw UploadError.transient
        }
        switch status {
        case 200..<300: return
        case 400, 413, 422: throw UploadError.rejected
        default: throw UploadError.transient
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
