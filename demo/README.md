# ZeroClaw ESP32 Smart Room Demo

Simulated ESP32 + ZeroClaw agent + browser visualization. Hardware-free and host-native.

## Requirements

- Rust toolchain
- `socat`
- an OpenRouter API key
- optional Telegram bot token for channel testing

On macOS:

```bash
brew install socat
```

## Setup

```bash
cp demo/.env.template demo/.env
$EDITOR demo/.env

mkdir -p demo/data/config
cp -n demo/zeroclaw.toml.example demo/data/config/config.toml || true
```

Keep secrets in `demo/.env`. The host scripts inject them at runtime rather than
persisting them into `config.toml`.

## Run

Terminal 1 — simulator and visualizer:

```bash
./demo/run-sim-host.sh
```

Wait for `frontend ready: http://127.0.0.1:8080`, then open that URL.

Terminal 2 — channel agent:

```bash
./demo/run-agent-host.sh
```

For Telegram, send the one-time `/bind <code>` shown by the agent, then paste
the system primer from `demo/PROMPTS.md` and use natural-language commands.

The smart-room tools communicate with the simulator over the local PTY and the
browser visualization updates live.

## Public URL via ngrok

```bash
brew install ngrok
ngrok config add-authtoken <TOKEN>
ngrok http 8080
```

## Files

```text
demo/
├── README.md
├── PROMPTS.md
├── zeroclaw.toml.example
├── .env.template
├── run-sim-host.sh
└── run-agent-host.sh
```

The simulator and visualizer live in
`crates/zeroclaw-hardware/examples/esp32_sim.{rs,html}`.

## Troubleshooting

**`/tmp/zc-sim-esp32` not found** — the simulator may still be starting or
`socat` may be missing. Check the simulator terminal first.

**Agent replies in prose instead of calling tools** — make sure the system
primer from `demo/PROMPTS.md` is sent before the first user turn.

**Agent does not see smart-room tools** — verify the demo configuration uses
`board = "esp32-sim"` (or `"esp32"`) under `[peripherals.boards]`.

**Telegram shows approval prompts for normal chat** — keep
`risk_profiles.default.allowed_tools` restricted to the smart-room tools used by
this demo.

## Notes

- Demo shell scripts are intentionally English-only.
- This harness is for development and demonstration, not production deployment.
