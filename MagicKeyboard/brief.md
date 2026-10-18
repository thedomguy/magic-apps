❯ Let's do this then. Since at the beginning, Opus 5.5 had discarded it due to a security flag that was a policy violation, which was due to…
that footing; do not add discovery of un-paired devices, code iteration, or any
data read-back.

## Already confirmed (do not re-verify)
- Target feasibility: on iPhone 12 / iOS 26, a bonded Bluetooth keyboard
  (Keychron) wakes the Lock Screen and enters the passcode flawlessly. V1 is
  viable. We are simply being that keyboard.
- Reference for the transport mechanism: github.com/jqssun/darwin-bt-remote
  (iOS = CoreBluetooth HID-over-GATT peripheral).

## V1 scope
IN:
- Device A (always an iPhone) advertises as a BLE HID keyboard (HOGP) and bonds
  with the spectator's iPhone in a setup flow.
- Trigger on Device A only (nothing is done on the target except receiving
  keystrokes): press 1 = wake the target's Lock Screen; press 2 = type the
  stored 4- or 6-digit passcode, then submit.
- Secretive UX: an innocuous "Clock" facade; a hidden gesture reveals the
  control surface (pairing status, PIN entry, Wake/Fire).
OUT (later phases): already-unlocked-phone typing (V2), non-Apple targets /
Android S24 (V3), Apple Watch companion trigger.

## Architecture & pinned technical decisions
Transport — CoreBluetooth `CBPeripheralManager` exposing:
- HID service 0x1812 with: HID Information (0x2A4A), Report Map (0x2A4B),
  HID Control Point (0x2A4C), Protocol Mode (0x2A4E, default Boot), and the
  **Boot Keyboard Input Report (0x2A22)** as the send characteristic
  (read+notify). Use Boot Protocol: CoreBluetooth cannot attach a Report
  Reference descriptor (0x2908) to a custom report char, so 0x2A22 is the
  reliable path and needs none.
- Device Information 0x180A (PnP ID 0x2A50; USB vendor 0x05AC to present as an
  Apple keyboard) and Battery 0x180F (0x2A19) — hosts expect both.
- Advertise the HID service UUID + a keyboard-ish local name. Mark the input
  report `.readEncryptionRequired` so iOS forces bonding on subscribe.
Payload — 8-byte boot report `[modifiers, reserved, k1..k6]`:
- Digits: '1'–'9' = 0x1E–0x26, '0' = 0x27, Return = 0x28.
- Each keystroke = key-down report then all-zero release, ~30–40 ms apart, or
  digits drop. A fixed 4/6-digit field auto-submits; append Return otherwise.
- Wake = a modifier-only tap (e.g. Left-Shift bit down then release): wakes the
  screen and raises passcode entry without inserting a character.
- Handle the known failure modes: Lock Screen notifications can swallow the
  passcode field; stale bonds need a full re-pair (surface a re-pair control).
Trigger — volume-button capture via AVAudioSession `outputVolume` KVO (the
"Spirit X" pattern), resetting system volume to mid-range after each event to
keep headroom; plus on-screen Wake/Fire buttons as the reliable test path.
Store — the passcode in Keychain. Facade — SwiftUI Clock; hidden reveal gesture.

## Repo conventions (mirror MagicCalculator exactly)
- Plain directory in the monorepo for now (not yet a sub
- XcodeGen `project.yml`; team 3F753GDA4W; bundle com.rahulbhatt.MagicKeyboard;
  portrait-only; deployment target iOS 17; display name
- `scripts/run-on-device.sh` adapted from MagicCalculator (regenerate, build,
  install, launch on the first reachable paired iPhone).

## Definition of done for V1
- `xcodegen generate` + build succeeds; `scripts/run-on-device.sh` installs and
  launches on the iPhone (per repo rule: every build end
  the phone). If no iPhone is reachable or signing fails, say so plainly.
- The first on-device test IS the real test: from Device
  then Wake + type a known passcode into its Lock Screen and confirm entry.
- Report what works and what doesn't honestly; HOGP bond
  likely need on-device iteration — plan for that, don't claim success blind.
