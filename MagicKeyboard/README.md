# MagicKeyboard

A performance prop: the performer's iPhone presents itself as a standard Bluetooth
HID keyboard (HID-over-GATT). Once a target phone is deliberately bonded to it, a
trigger on the performer's phone wakes the target's Lock Screen and types a
passcode the spectator freely shared — a hands-free illusion. It only ever sends
keystrokes the operator entered by hand; it never reads from or guesses anything.

See `reports/V1-brief.md` for the full design and the pinned technical decisions.

## Build & run

```bash
scripts/run-on-device.sh          # first reachable paired iPhone
DEVICE_ID=<coredevice id> scripts/run-on-device.sh
```

Regenerates the Xcode project (XcodeGen — edit `project.yml`, never the
`.xcodeproj`), builds, installs, and launches on the phone.

First install needs an Xcode Apple ID session for team `3F753GDA4W` so a
Development profile for `com.rahulbhatt.MagicKeyboard` can be created: open
`MagicKeyboard.xcodeproj` once in Xcode → Signing & Capabilities → ensure
Automatic + your Personal Team, then re-run the script.

## Layout

- `MagicKeyboard/HID/` — HOGP keyboard peripheral, report map, keycodes.
- `MagicKeyboard/Store/` — Keychain passcode store.
- `MagicKeyboard/Control/` + `Backstage/` — control buttons and Settings.

## On-device check (V1)

1. Long-press top-left of the Clock → Backstage.
2. On the target phone: Settings → Bluetooth → pair **Keyboard**.
3. Status should read Ready. Enter a known 4/6-digit passcode.
4. Lock the target → Wake → Keypad → Fire (or Auto).
