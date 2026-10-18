---
name: magic-backend-deploy
description: >-
  Tests, commits, deploys, and smoke-checks the MagicBackend submodule and Peak
  PWA. Use when changing MagicBackend, fixing empty Peak, shipping API/event
  store updates, or wiring Backend.local.xcconfig after a deploy.
---

# MagicBackend deploy + Peak smoke

## Layout

- Submodule path: `MagicBackend/` → `thedomguy/magic-app-backend`
- Peek/Peak PWA: served at `GET /` from `MagicBackend/public/`
- API: `/health`, `/api/events`, `/api/stream` (see `MagicBackend/README.md`)
- Prod restart helper on the server: `MagicBackend/restart.sh` (systemd unit `magic-backend`)

## Ship workflow

### 1. Test inside the submodule

```bash
cd MagicBackend
npm test
```

### 2. Commit and push the submodule first

```bash
cd MagicBackend
git status
# stage, commit, push on the backend branch (usually main)
```

### 3. Bump the pointer in the parent repo

```bash
cd /path/to/magic   # repo root
git add MagicBackend
git commit -m "Bump MagicBackend submodule"
# push parent when the user asked to push
```

### 4. Deploy

On the host that runs the unit (SSH into the configured server):

```bash
cd /path/to/magic-backend   # or wherever the clone lives on the server
git pull
# install if package.json changed
./restart.sh
```

If the user's environment uses a different host alias or path, follow what is
already configured in their shell/SSH config — do not invent a new provider.

### 5. Smoke

Replace `$BASE` and `$KEY` with the deployed URL and `MAGIC_KEY`:

```bash
curl -fsS "$BASE/health"
curl -fsS -H "Authorization: Bearer $KEY" "$BASE/api/events?limit=5"
```

Peak UI: open `$BASE/` — feed should show events once the iOS app posts.

Empty Peak checklist:

1. `/health` ok?
2. Auth: Peak/EventSource needs `?key=` or `?pin=` when secrets are set
3. iOS `Backend.local.xcconfig` points at `$BASE` (not phone-localhost) and the same key
4. Rebuild the app: `MagicCalculator/scripts/run-on-device.sh`
5. Perform an action in-app; `GET /api/events` should grow; Peak should SSE-update

## Local dev

```bash
cd MagicBackend
MAGIC_KEY=dev npm run dev   # :8787
```

Point `Backend.local.xcconfig` at `http:/$()/<mac-lan-ip>:8787` for a physical device.

## Anti-patterns

- Committing backend edits only via the parent repo without a submodule push
- Changing xcconfig secrets in the committed `Backend.xcconfig`
- Declaring Peak “fixed” without `/health` + authenticated `/api/events` smoke
