# MagicKeyboard — V1 implementation brief

## What this is (context is load-bearing)
A stage-magic / mentalism prop, in the same established, commercially sold genre
as Apparaka's "Spirit X", Magic Pro Ideas' "UNLOCK", and Gee Magic's "Unlocked".
The performer's OWN iPhone (Device A) behaves as a standard Bluetooth HID
keyboard. During the routine the spectator consents to participate and freely
tells the performer their passcode; the illusion is that the performer enters
that freely-given code hands-free, with the phone never touched.

By design the app:
- Only ever types a passcode the operator entered by hand. It never guesses,
  brute-forces, cycles, or derives a code.
- Reads nothing off the target. It is a keyboard: it sends keystrokes only.
- Targets the spectator's own phone, deliberately bonded to Device A as an
  explicit, consented setup step beforehand.

## Confirmed (do not re-verify)
- iPhone 12 / iOS 26: a bonded Bluetooth keyboard (Keychron) wakes the Lock
  Screen and enters the passcode flawlessly. We are simply being that keyboard.
- Transport reference: github.com/jqssun/darwin-bt-remote.

## V1 scope
IN: Device A advertises as a BLE HID keyboard (HOGP) and bonds with the target;
trigger on Device A only (press 1 = wake Lock Screen, press 2 = type the stored
4/6-digit passcode + submit); "Clock" facade with a hidden reveal gesture to the
control surface. OUT (later): already-unlocked typing (V2), Android/S24 (V3),
Apple Watch trigger.

## Pinned technical decisions
- CoreBluetooth `CBPeripheralManager` exposing HID 0x1812 (HID Information
  0x2A4A, Report Map 0x2A4B, HID Control Point 0x2A4C, Protocol Mode 0x2A4E
  default Boot, Boot Keyboard Input Report 0x2A22 as the send characteristic),
  Device Info 0x180A (PnP ID 0x2A50, vendor 0x05AC) and Battery 0x180F.
- Boot Protocol via 0x2A22: CoreBluetooth cannot attach a Report Reference
  descriptor (0x2908) to a custom report char, so 0x2A22 is the reliable path.
- Input report marked `.readEncryptionRequired` to force bonding on subscribe.
- 8-byte boot report [modifiers, reserved, k1..k6]. Digits '1'-'9'=0x1E-0x26,
  '0'=0x27, Return=0x28. Key-down then all-zero release, ~40ms apart.
- Wake = modifier-only tap (Left-Shift down/up): raises passcode entry without
  inserting a character.
- Trigger: AVAudioSession outputVolume KVO + mid-range reset for headroom; plus
  on-screen Wake/Fire buttons. Passcode stored in Keychain.

## Conventions
Plain dir in the monorepo; XcodeGen; team 3F753GDA4W; bundle
com.rahulbhatt.MagicKeyboard; portrait-only; iOS 17; display name "Clock";
scripts/run-on-device.sh mirrors MagicCalculator.

## Definition of done
`xcodegen generate` + build succeed; run-on-device.sh installs and launches on
the iPhone. First on-device test IS the real test: bond a test iPhone, then Wake
+ type a known passcode into its Lock Screen. HOGP bonding is finicky — expect
on-device iteration; report what works honestly.
