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

## Custom feature

Hold the **1** key for **5 seconds** → full-screen white **Hello World** (✕ to dismiss).

## Layout

- `Engine/` — math (chaining, repeating `=`, %, C/AC)
- `UI/` — theme, keypad, display
- `Features/HelloWorldView.swift` — easter egg
