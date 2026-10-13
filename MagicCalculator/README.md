# Magic Calc

SwiftUI iOS Calculator replica (Basic mode) inspired by Apple’s Calculator look and behavior.

## Open & run

```bash
open MagicCalculator.xcodeproj
```

In Xcode: pick an iPhone simulator → Run.

Or from CLI:

```bash
xcodebuild -scheme MagicCalculator \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' \
  build
```

## Behind the scenes

- **Hold `=` for 3 s** → backstage menu (its own screens on top of the calculator; swipe from the
  left edge to go back). Only item for now: **Profile configuration**.
- **Hold `1`–`9` for 1.5 s** → loads that slot's profile, clears the calculator and flashes the
  field config once (`Card Suit | Card Value | Target Position | 3`). **Hold `0`** turns capture off.

### Profiles

A profile is an ordered list of fields (label + digit count), bound to a key 1–9. Profile 1 ships
as "Any number": one 10-digit field.

- **One field** – digits accumulate across every number typed (`98 + 7654 + 3210`); the capture
  is reported the moment all digits are in.
- **Several fields** – each number typed is one field (`3 × 12 × 7`); reported when the last field
  reaches its digit count, or on `=`.

`=` before completion still reports what was captured, flagged `complete: false`.

### Peek broadcast

While a profile is active, every action is broadcast live to
[magic-app-backend](../MagicBackend) (submodule) for the peek app: profile loaded, each number
(sent when the operator after it is pressed), each operator, the field capture, and `=` with the
result. One calculation is one session; `=` or AC ends it. Hold `0` turns capture off and stops
the broadcast.

Point the app at the backend in `Config/Backend.local.xcconfig` (copy the `.example`; it's
git-ignored because it holds the key). Defaults to `http://localhost:8787`, which works from the
simulator. Events queue on disk, in order, and retry when offline.

### Unity link

The same events also go straight to [UnityOS](../UnityOS) on the Android phone over Bluetooth LE
and local Wi-Fi (Bonjour `_ulink._tcp`), sealed with a key derived from `MAGIC_BACKEND_KEY`, so
the peek works with no internet at all. First launch asks for Bluetooth and Local Network access:
allow both before a performance. Status is in the backstage menu. Protocol:
[docs/unity-link.md](../docs/unity-link.md).

## Layout

- `Engine/` — math (precedence, repeating `=`, %, C/AC) and keyed-in number events
- `UI/` — theme, keypad, display, toolbar, history
- `Profiles/` — profile model, store, capture rules
- `Sync/` — action broadcaster, event model, ordered outbox uploader
- `Link/` — Unity link: Bluetooth LE peripheral, Wi-Fi WebSocket server, sealing
- `Backstage/` — hidden menu and profile editor
