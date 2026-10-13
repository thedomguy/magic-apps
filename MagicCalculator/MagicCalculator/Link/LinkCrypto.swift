import CoreBluetooth
import CryptoKit
import Foundation

/// The shared secret of the offline links (Bluetooth, local Wi-Fi) and what's derived from it.
/// UnityOS holds the same `linkKey`, so frames only open on your own devices. See
/// `docs/unity-link.md`.
enum LinkCrypto {
    /// `HMAC-SHA256(MAGIC_KEY, "unity-link-v1")`; the backend hands the same value to PIN sign-ins.
    static let linkKey: SymmetricKey = {
        let key = Bundle.main.infoDictionary?["MagicBackendKey"] as? String ?? ""
        let mac = HMAC<SHA256>.authenticationCode(
            for: Data("unity-link-v1".utf8),
            using: SymmetricKey(data: Data(key.utf8))
        )
        return SymmetricKey(data: Data(mac))
    }()

    static let serviceUUID = uuid("ble-service")
    static let eventsUUID = uuid("ble-events")
    static let controlUUID = uuid("ble-control")

    /// `nonce ‖ ciphertext ‖ tag`.
    static func seal(_ plaintext: Data) -> Data? {
        try? AES.GCM.seal(plaintext, using: linkKey).combined
    }

    static func open(_ frame: Data) -> Data? {
        guard let box = try? AES.GCM.SealedBox(combined: frame) else { return nil }
        return try? AES.GCM.open(box, using: linkKey)
    }

    /// First 16 bytes of `HMAC(linkKey, label)` with the version 4 / variant bits set.
    private static func uuid(_ label: String) -> CBUUID {
        var bytes = Array(HMAC<SHA256>.authenticationCode(for: Data(label.utf8), using: linkKey).prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return CBUUID(data: Data(bytes))
    }
}
