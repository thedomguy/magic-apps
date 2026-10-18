---
name: swiftui-visual-parity
description: >-
  Diagnoses and fixes SwiftUI layout/safe-area mismatches against a reference
  screenshot (especially MagicCalculator keypad padding and bottom inset). Use
  when the user attaches reference vs app images, reports padding/inset issues,
  or asks to match the stock iOS Calculator layout. Simulator is allowed for
  capture only — not for user-facing app opens.
---

# SwiftUI visual parity

## When this applies

- User provides a reference screenshot (stock Calculator) and/or our app screenshot
- Complaints about bottom inset, side margins, keypad gaps, or “doesn't match”
- Iterating pixel layout after theme/token tweaks

For **opening the app to try it**, use `ios-run-on-device` instead.

## SwiftUI safe-area checklist (not React Native)

1. Prefer `safeAreaPadding` / `safeAreaInset` over hard-coded home-indicator guesses.
2. Backgrounds that should bleed edge-to-edge: `.ignoresSafeArea()` on the fill only —
   keep interactive controls inside the safe area.
3. Bottom chrome (keypad row with `0` / `=`): must clear the home indicator. In this app,
   `ContentView` uses `.safeAreaPadding(.bottom, CalculatorTheme.bottomSafePadding)`.
4. Tune tokens in `MagicCalculator/UI/CalculatorTheme.swift` (`sideMargin`,
   `bottomSafePadding`, key spacing) before scattering one-off paddings.
5. Do **not** apply the personal `bottom-inset` React Native skill here.

## Capture loop (simulator OK)

Only for measurement — ask once if no prior sim permission this chat:

```bash
cd MagicCalculator
xcodegen generate --quiet
# Boot a phone-sized sim if needed, then:
xcodebuild -scheme MagicCalculator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath build/sim -quiet build
xcrun simctl install booted build/sim/Build/Products/Debug-iphonesimulator/MagicCalculator.app
xcrun simctl launch booted com.rahulbhatt.MagicCalculator
xcrun simctl io booted screenshot /tmp/magic-calc-screen.png
```

Compare against the user's reference (or `/tmp/magic-calc-ref.png`).

## Measure

Use the helper (no extra deps):

```bash
python3 .cursor/skills/swiftui-visual-parity/scripts/measure_margins.py \
  /tmp/magic-calc-screen.png \
  --ref /tmp/magic-calc-ref.png
```

It reports approximate bottom/side content margins in pixels. Convert with
`pt ≈ px / scale` (3× on most modern iPhones).

## Fix → verify

1. Adjust `CalculatorTheme` tokens or the specific view's padding.
2. Re-capture and re-measure until margins are within ~2pt of the reference.
3. When the user needs to **use** the build, run `MagicCalculator/scripts/run-on-device.sh`.
4. Offer to shut down any simulator you started.

## Anti-patterns

- Long Python one-offs reinvented each session — use `scripts/measure_margins.py`
- Treating simulator install as satisfying “open on my phone”
- Copying React Native `useSafeAreaInsets` patterns into SwiftUI
