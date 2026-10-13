# Unity link

How a magic app (the calculator today, notes later) reaches UnityOS, the control surface on the
Android phone. Every event goes out on **every channel at once**; UnityOS keeps the first copy of
each event `id` and drops the rest, so whichever channel is fastest wins and the others are backup.

| Channel        | Needs                          | Calculator side             | UnityOS side                 |
|----------------|--------------------------------|-----------------------------|------------------------------|
| Bluetooth LE   | Nothing, works fully offline   | GATT peripheral, advertises | Central: scans, subscribes   |
| Local Wi-Fi    | Same network, or the S24's hotspot | WebSocket server + Bonjour | NSD discovery, WebSocket client |
| Internet       | Both online                    | `POST /api/events` (outbox) | SSE `/api/stream` + backfill |

The event JSON is the same everywhere; see [MagicBackend/README.md](../MagicBackend/README.md).

## Auth: one shared secret

Everything hangs off the backend's `MAGIC_KEY`.

```
linkKey = HMAC-SHA256(key: utf8(MAGIC_KEY), message: "unity-link-v1")   // 32 bytes
```

- The calculator derives it from `MAGIC_BACKEND_KEY` (xcconfig). No setup.
- UnityOS signs in once with the 6-digit PIN (`GET /api/link` returns `linkKey` as hex) or with the
  full key (derived on the device, no server needed). It's stored; after that pairing is
  automatic: any device holding the same `linkKey` can open the other's frames, anything else
  fails to decrypt and is ignored.

## Frames (Bluetooth and Wi-Fi)

```
frame = nonce (12 random bytes) ‖ AES-256-GCM(linkKey, nonce, plaintext) ‖ tag (16 bytes)
```

Plaintext is UTF-8 JSON, one message:

| `k`     | Direction          | Body                                                     |
|---------|--------------------|----------------------------------------------------------|
| `hello` | app → UnityOS      | `app` (`"calculator"` / `"notes"`), `name` (device), `v` (1) |
| `event` | app → UnityOS      | `e`: one event, exactly as posted to the backend         |
| `ping`  | app → UnityOS      | Heartbeat, every 2 s over Bluetooth while the app is in front |

On every new Bluetooth subscription or Wi-Fi connection the app sends `hello`, then replays its
last 30 events, so UnityOS catches up after a dropout (kept short so a reconnect doesn't queue
seconds of old frames ahead of live ones on Bluetooth; the internet backfill covers more).
Unknown `k` values are ignored on both sides; that's where commands (UnityOS → app) go later.

## Two apps, one iPhone

The calculator and Notes share the same service UUID and Bonjour type, so **only the app in front
is on the air**: going to the background withdraws its Bluetooth service, stops the heartbeat and
takes its Wi-Fi listener off the network; coming forward puts them back. UnityOS drops a Bluetooth
link after 6 s without a frame (three missed pings) and rescans, finding whichever app took over;
it also resubscribes at once if Android reports the iPhone's services changed. Wi-Fi and the
internet carry events across the switch.

## Bluetooth LE

UUIDs are derived from `linkKey`, so nothing in the advertisement says "magic" and only your own
devices know what to look for:

```
uuid(label) = first 16 bytes of HMAC-SHA256(linkKey, label),
              byte 6 = (b6 & 0x0F) | 0x40, byte 8 = (b8 & 0x3F) | 0x80   // RFC 4122 v4 bits
```

| Label         | What                                                         |
|---------------|--------------------------------------------------------------|
| `ble-service` | Primary service; the only thing advertised (no local name)   |
| `ble-events`  | Notify. Frames, chunked                                      |
| `ble-control` | Write / write without response. Frames, chunked (reserved)   |

Chunking: each notification/write is `header (1 byte) ‖ part`. Header bit 7 set = last part of the
frame. Parts are concatenated in order. Part size = the link's max value length − 1 (UnityOS
requests MTU 517).

## Local Wi-Fi

Bonjour service `_ulink._tcp`, a WebSocket at `/`. Each binary message is one frame. Plain `ws`:
the frames are already sealed.

## Test vectors

`MAGIC_KEY = "test-key"`:

```
linkKey      2cfaa3a6f2d4e2fe8b59e025e4ada71438e650b24087f6fc2b063b1a377aeae0
ble-service  A798CA48-8659-4117-879B-0122F25F3503
ble-events   EAA5B57D-F396-4672-9664-2557DBFCAF3D
ble-control  62D27D57-EE79-48F5-90D9-751A4E28BFC8
```
