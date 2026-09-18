# ZeroClaw Development Environment

Development is host-native. The repository's normal Rust toolchain and scripts
are the source of truth.

## Prerequisites

- Rust toolchain compatible with the workspace MSRV
- Git
- platform build dependencies required by the features you enable

## Common checks

From the repository root:

```bash
cargo fmt --all -- --check
cargo check --locked
```

Useful optional gates include:

```bash
./scripts/ci/rust_quality_gate.sh
./scripts/ci/docs_quality_gate.sh
./scripts/ci/docs_links_gate.sh
```

Run targeted tests directly with Cargo:

```bash
cargo test --locked
cargo test --locked -p zeroclaw-runtime
cargo test --locked -p zeroclaw-config
```

## Local configuration

`dev/config.template.toml` is a host-oriented example configuration. Copy it
to a temporary workspace or adapt the relevant sections to your normal Airis
configuration.

`dev/config.harness-test.toml` is intended for the gateway harness tests in
`dev/test-harness.sh`.

## Gateway harness

Start the gateway on the configured host/port, then run:

```bash
./dev/test-harness.sh
```

The script uses `ZEROCLAW_GATEWAY_URL`, `ZEROCLAW_WS_URL`, and
`ZEROCLAW_WORKSPACE_DIR` when provided.

## Tauri development

The existing Tauri helper remains available:

```bash
./dev/run-tauri-dev.sh
```

Other product surfaces and development helpers are unchanged.
