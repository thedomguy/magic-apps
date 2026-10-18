---
name: ios-run-on-device
description: >-
  Builds, installs, and launches MagicCalculator on a paired iPhone via
  scripts/run-on-device.sh. Use when opening or rebuilding the app on device,
  after Swift/project.yml/asset/xcconfig changes, or when fixing signing,
  pairing, or disk-full build failures. Do not hand-roll xcodebuild for a
  normal device run.
---

# iOS run on device

## Default command

From the repo root:

```bash
MagicCalculator/scripts/run-on-device.sh
```

Optional: `DEVICE_ID=<coredevice id> MagicCalculator/scripts/run-on-device.sh`

The script: finds a paired reachable iPhone → `xcodegen generate` → `xcodebuild` →
`devicectl install` → `devicectl launch`.

**Do not** reinvent list-devices → xcodegen → xcodebuild → install → launch unless
the script is missing or you are extending it.

## When to run

- After any change under `MagicCalculator/` that affects the app binary or config
- When the user says open / rebuild / launch on phone or device
- After editing `Backend.local.xcconfig`

Skip for backend-only or docs-only work.

## Failure playbook

### No reachable paired iPhone

Script exits: `No reachable paired iPhone…`

1. Tell the user to unlock / reconnect the phone.
2. Do **not** boot the simulator unless they agree.
3. Re-run the script after they confirm.

### Signing / provisioning

Look for `Code Sign`, `Provisioning`, `requires a development team` in the log.

1. Confirm `DEVELOPMENT_TEAM` / Automatic signing in `MagicCalculator/project.yml`.
2. Re-run the script (it already passes `-allowProvisioningUpdates`).
3. If still failing, report the exact signing error — don't invent a Simulator workaround as "success".

### Disk full / DerivedData

Symptoms: `No space left on device`, obscure clang/linker failures, or huge DerivedData.

```bash
df -h /
du -sh ~/Library/Developer/Xcode/DerivedData MagicCalculator/build 2>/dev/null
# Safe cleanup of this project's device build dir:
rm -rf MagicCalculator/build
# Only if still tight and user agrees:
# rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

Then re-run the script.

### xcodegen missing

`brew install xcodegen` (or note it's required), then re-run.

## Anti-patterns

- Building for `platform=iOS Simulator` when the user asked to open the app
- Editing `MagicCalculator.xcodeproj` by hand
- Calling `xcodebuild` with a one-off DerivedData path under `/tmp` for routine runs
