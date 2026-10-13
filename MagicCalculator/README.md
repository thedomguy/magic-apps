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

- **One field** – digits accumulate across every number typed (`98 + 7654 + 3210`); the entry is
  sent the moment all digits are in.
- **Several fields** – each number typed is one field (`3 × 12 × 7`); sent when the last field
  reaches its digit count, or on `=`.

`=` before completion still sends what was captured, flagged `complete: false`.

### Backend

Entries post to [magic-app-backend](../MagicBackend) (submodule). Point the app at it in
`Config/Backend.local.xcconfig` (copy the `.example`; it's git-ignored because it holds the key).
Defaults to `http://localhost:8787`, which works from the simulator. Entries queue on disk and
retry when offline.

## Layout

- `Engine/` — math (precedence, repeating `=`, %, C/AC) and keyed-in number events
- `UI/` — theme, keypad, display, toolbar, history
- `Profiles/` — profile model, store, capture rules
- `Sync/` — outbox uploader
- `Backstage/` — hidden menu and profile editor
