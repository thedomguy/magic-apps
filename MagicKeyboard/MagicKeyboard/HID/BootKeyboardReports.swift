import Foundation

/// USB HID usage page 0x07 keycodes used by V1 (digits + Return).
enum BootKeycode: UInt8 {
    case digit1 = 0x1E
    case digit2 = 0x1F
    case digit3 = 0x20
    case digit4 = 0x21
    case digit5 = 0x22
    case digit6 = 0x23
    case digit7 = 0x24
    case digit8 = 0x25
    case digit9 = 0x26
    case digit0 = 0x27
    case `return` = 0x28
    case backspace = 0x2A

    static func digit(_ character: Character) -> BootKeycode? {
        switch character {
        case "1": return .digit1
        case "2": return .digit2
        case "3": return .digit3
        case "4": return .digit4
        case "5": return .digit5
        case "6": return .digit6
        case "7": return .digit7
        case "8": return .digit8
        case "9": return .digit9
        case "0": return .digit0
        default: return nil
        }
    }
}

struct BootModifiers: OptionSet {
    let rawValue: UInt8
    static let leftShift = BootModifiers(rawValue: 1 << 1)
}

/// 8-byte boot keyboard input report: `[modifiers, reserved, k1…k6]`.
struct BootKeyboardReport: Equatable {
    var modifiers: BootModifiers = []
    var keys: [BootKeycode] = []

    static let release = BootKeyboardReport()

    var data: Data {
        var bytes = [UInt8](repeating: 0, count: 8)
        bytes[0] = modifiers.rawValue
        for (index, key) in keys.prefix(6).enumerated() {
            bytes[2 + index] = key.rawValue
        }
        return Data(bytes)
    }

    static func keyDown(_ key: BootKeycode, modifiers: BootModifiers = []) -> BootKeyboardReport {
        BootKeyboardReport(modifiers: modifiers, keys: [key])
    }

    /// Modifier-only tap used to wake the Lock Screen without inserting a character.
    static func wakeTap() -> BootKeyboardReport {
        BootKeyboardReport(modifiers: .leftShift, keys: [])
    }
}
