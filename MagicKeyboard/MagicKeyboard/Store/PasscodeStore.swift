import Foundation
import Security

/// Keychain-backed store for the operator-entered passcode (4 or 6 digits).
enum PasscodeStore {
    private static let service = "com.rahulbhatt.MagicKeyboard.passcode"
    private static let account = "passcode"

    static func load() -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return ""
        }
        return string
    }

    @discardableResult
    static func save(_ passcode: String) -> Bool {
        let digits = passcode.filter(\.isNumber)
        guard digits.count == 4 || digits.count == 6 else { return false }
        let data = Data(digits.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
    }

    static func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    static func isValid(_ passcode: String) -> Bool {
        let digits = passcode.filter(\.isNumber)
        return digits.count == 4 || digits.count == 6
    }
}
