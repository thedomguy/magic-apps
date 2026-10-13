# magic-apps

- `MagicCalculator/` — submodule, `thedomguy/magic-calculator`. SwiftUI iOS app (XcodeGen: edit
  `project.yml`, never the `.xcodeproj` by hand). Commit and push inside it first, then commit the
  bumped pointer here.
- `MagicBackend/` — submodule, `thedomguy/magic-app-backend`. Same commit-inside-first rule.
- `UnityOS/` — submodule, `thedomguy/unity-os`. Android control surface (Kotlin/Compose) for the
  Galaxy S24 Ultra; same commit-inside-first rule.
- `MagicNotes/` — submodule, `thedomguy/magic-notes`. Apple Notes replica (SwiftUI + UIKit editor,
  XcodeGen). Blueprint: `reports/Apple Notes replica guide.md`. Rebuild with
  `MagicNotes/scripts/run-on-device.sh`, same rule as the calculator.
- `docs/unity-link.md` — how the apps reach UnityOS (Bluetooth LE, local Wi-Fi, internet). Change
  both sides together.

## Rules

Cursor always-on rules live in `.cursor/rules/` (iOS workflow, backend/submodule/xcconfig,
prefer-physical-device). Same expectations apply in Claude Code sessions.

- **Always rebuild and open the app on the iPhone after any change that affects it** (Swift sources,
  `project.yml`, assets, `Config/*.xcconfig`) — don't wait to be asked. Run:

  ```bash
  MagicCalculator/scripts/run-on-device.sh
  ```

  It regenerates the project, builds, installs and launches on the first reachable paired iPhone
  (override with `DEVICE_ID=<coredevice id>`). Every new build ends with the app open on the phone.
  If no iPhone is reachable, or signing fails, say so plainly instead of skipping it silently.
  Backend-only or docs-only changes don't need this.
- **Same for UnityOS on the S24** after any change under `UnityOS/app/`: run
  `UnityOS/scripts/run-on-device.sh` (wireless adb). If the phone isn't reachable, say so and give
  the APK path.

## Skills

Project skills (read before reinventing these flows):

| Skill | Path | Use when |
|-------|------|----------|
| `ios-run-on-device` | `.cursor/skills/ios-run-on-device/` | Open/rebuild on iPhone; signing/disk/pairing failures |
| `swiftui-visual-parity` | `.cursor/skills/swiftui-visual-parity/` | Reference screenshot padding/inset match |
| `magic-backend-deploy` | `.cursor/skills/magic-backend-deploy/` | Backend ship, Peak empty, submodule deploy smoke |
| `swiftui-liquid-glass` | `.agents/skills/swiftui-liquid-glass/` | iOS 26+ Liquid Glass UI only |
