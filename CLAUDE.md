# magic-apps

- `MagicCalculator/` — SwiftUI iOS app (XcodeGen: edit `project.yml`, never the `.xcodeproj` by hand).
- `MagicBackend/` — submodule, `thedomguy/magic-app-backend`. Commit and push inside it first, then
  commit the bumped pointer here.
- `UnityOS/` — Android control surface (Kotlin/Compose) for the Galaxy S24 Ultra; its own repo,
  same commit-inside-first rule as `MagicBackend/`.
- `docs/unity-link.md` — how the apps reach UnityOS (Bluetooth LE, local Wi-Fi, internet). Change
  both sides together.

## Rules

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
