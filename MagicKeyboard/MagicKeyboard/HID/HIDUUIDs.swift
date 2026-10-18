import CoreBluetooth
import Foundation

/// Bluetooth SIG UUIDs for HOGP. Service/characteristic *definitions* use the full
/// 128-bit form (iOS rejects short UUIDs there). Advertising can use the 16-bit form
/// so the Local Name still fits in the 31-byte adv packet.
enum HIDUUIDs {
    static let hidService = CBUUID(string: "00001812-0000-1000-8000-00805F9B34FB")
    /// 16-bit form for advertisement payload only.
    static let hidServiceShort = CBUUID(string: "1812")
    static let batteryService = CBUUID(string: "0000180F-0000-1000-8000-00805F9B34FB")
    static let deviceInformationService = CBUUID(string: "0000180A-0000-1000-8000-00805F9B34FB")

    static let hidInformation = CBUUID(string: "00002A4A-0000-1000-8000-00805F9B34FB")
    static let reportMap = CBUUID(string: "00002A4B-0000-1000-8000-00805F9B34FB")
    static let hidControlPoint = CBUUID(string: "00002A4C-0000-1000-8000-00805F9B34FB")
    static let report = CBUUID(string: "00002A4D-0000-1000-8000-00805F9B34FB")
    static let protocolMode = CBUUID(string: "00002A4E-0000-1000-8000-00805F9B34FB")
    static let bootKeyboardInputReport = CBUUID(string: "00002A22-0000-1000-8000-00805F9B34FB")
    static let bootKeyboardOutputReport = CBUUID(string: "00002A32-0000-1000-8000-00805F9B34FB")
    static let reportReference = CBUUID(string: "00002908-0000-1000-8000-00805F9B34FB")

    static let batteryLevel = CBUUID(string: "00002A19-0000-1000-8000-00805F9B34FB")
    static let pnpID = CBUUID(string: "00002A50-0000-1000-8000-00805F9B34FB")
    static let manufacturerName = CBUUID(string: "00002A29-0000-1000-8000-00805F9B34FB")
    static let modelNumber = CBUUID(string: "00002A24-0000-1000-8000-00805F9B34FB")
}

enum HIDConstants {
    /// bcdHID 1.11, country 0, flags: RemoteWake | NormallyConnectable
    static let hidInformationValue = Data([0x11, 0x01, 0x00, 0x03])

    /// Report Protocol (0x01). Apple hosts prefer this; Boot (0x00) stays available via 0x2A22.
    static let reportProtocolMode: UInt8 = 0x01

    /// PnP ID: Vendor ID Source = Bluetooth SIG (1), Vendor = Apple (0x05AC),
    /// Product = 0x0255, Version 1.0.
    static let pnpIDValue = Data([0x01, 0xAC, 0x05, 0x55, 0x02, 0x00, 0x01])

    static let manufacturerNameValue = Data("Apple Inc.".utf8)
    static let modelNumberValue = Data("Magic Keyboard".utf8)

    static let defaultAdvertiseName = "Keyboard"

    /// Keyboard input report ID inside the Report Map / Report Reference.
    static let keyboardReportID: UInt8 = 1
    /// Report Reference value: [reportId, reportType] where type 1 = Input.
    static let keyboardReportReference = Data([keyboardReportID, 0x01])

    /// Keyboard-only report map with Report ID 1 (Report Protocol) — same 8-byte layout as boot.
    static let reportMapData = Data([
        0x05, 0x01, // Usage Page (Generic Desktop)
        0x09, 0x06, // Usage (Keyboard)
        0xA1, 0x01, // Collection (Application)
        0x85, 0x01, //   Report ID (1)
        0x05, 0x07, //   Usage Page (Keyboard/Keypad)
        0x19, 0xE0, //   Usage Minimum (LeftControl)
        0x29, 0xE7, //   Usage Maximum (RightGUI)
        0x15, 0x00, //   Logical Minimum (0)
        0x25, 0x01, //   Logical Maximum (1)
        0x75, 0x01, //   Report Size (1)
        0x95, 0x08, //   Report Count (8)
        0x81, 0x02, //   Input (Data,Var,Abs) — modifiers
        0x95, 0x01, //   Report Count (1)
        0x75, 0x08, //   Report Size (8)
        0x81, 0x01, //   Input (Const) — reserved
        0x95, 0x05, //   Report Count (5)
        0x75, 0x01, //   Report Size (1)
        0x05, 0x08, //   Usage Page (LEDs)
        0x19, 0x01, //   Usage Minimum (NumLock)
        0x29, 0x05, //   Usage Maximum (Kana)
        0x91, 0x02, //   Output (Data,Var,Abs)
        0x95, 0x01, //   Report Count (1)
        0x75, 0x03, //   Report Size (3)
        0x91, 0x01, //   Output (Const)
        0x95, 0x06, //   Report Count (6)
        0x75, 0x08, //   Report Size (8)
        0x15, 0x00, //   Logical Minimum (0)
        0x25, 0x65, //   Logical Maximum (101)
        0x05, 0x07, //   Usage Page (Keyboard/Keypad)
        0x19, 0x00, //   Usage Minimum (0)
        0x29, 0x65, //   Usage Maximum (101)
        0x81, 0x00, //   Input (Data,Array) — 6 key slots
        0xC0        // End Collection
    ])
}
