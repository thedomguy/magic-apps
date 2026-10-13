# magic-apps

- `MagicCalculator/` — SwiftUI iOS app (XcodeGen: edit `project.yml`, never the `.xcodeproj` by hand).
- `MagicBackend/` — submodule, `thedomguy/magic-app-backend`. Commit and push inside it first, then
  commit the bumped pointer here.

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
