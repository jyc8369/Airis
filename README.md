# Airis

**Airis** is an independent personal fork of [ZeroClaw](https://github.com/zeroclaw-labs/zeroclaw), focused on gradual personalization while preserving upstream compatibility.

Airis is not an official ZeroClaw Labs project and is not affiliated with or endorsed by ZeroClaw Labs. The ZeroClaw name and logo are trademarks of ZeroClaw Labs.

## Project status

Airis currently keeps upstream technical identifiers where changing them would create unnecessary merge friction. In particular, the `zeroclaw` executable, Rust crate/package names, and existing configuration paths remain unchanged for now. User-facing project branding uses **Airis**.

The personalization baseline is intentionally minimal:

- canonical project/assistant name: `Airis`
- default conversation language: not fixed
- localized secondary name: optional and not fixed
- provider and model: not fixed
- personality and autonomy policy: not fixed
- internal `zeroclaw` identifiers: retained for upstream compatibility

## Build from source

```bash
git clone https://github.com/jyc8369/Airis.git
cd Airis
cargo build --release
```

The upstream-compatible executable is currently named `zeroclaw`:

```bash
./target/release/zeroclaw quickstart
./target/release/zeroclaw agent -a <alias>
```

Existing configuration remains compatible with the upstream layout, including `~/.zeroclaw/config.toml`.

## Upstream

Airis tracks [zeroclaw-labs/zeroclaw](https://github.com/zeroclaw-labs/zeroclaw) as its upstream project. Until Airis-specific documentation diverges, the upstream repository and the documentation already included in this source tree remain the primary references for runtime features, configuration, architecture, and development.

Changes specific to Airis should be kept isolated where practical so upstream updates remain straightforward to review and merge.

## License and attribution

This fork retains the upstream license and copyright notices included in the repository. The code is distributed under the same dual-license terms as upstream: [MIT](LICENSE-MIT) OR [Apache-2.0](LICENSE-APACHE).

ZeroClaw remains the upstream project. Airis is an independent fork.
