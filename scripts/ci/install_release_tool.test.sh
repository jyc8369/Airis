#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
installer="${root_dir}/scripts/ci/install_release_tool.sh"

assert_manifest() {
  local os="$1"
  local arch="$2"
  local expected_asset="$3"
  local expected_primary_binary="$4"
  local expected_sha256="$5"
  local expected_url="$6"
  local manifest

  manifest="$(
    ZEROCLAW_RELEASE_TOOL_OS="$os" \
      ZEROCLAW_RELEASE_TOOL_ARCH="$arch" \
      bash "$installer" tauri-cli --print-manifest
  )"

  grep -Fxq "tool=tauri-cli" <<<"$manifest"
  grep -Fxq "version=2.11.4" <<<"$manifest"
  grep -Fxq "asset=${expected_asset}" <<<"$manifest"
  grep -Fxq "primary_binary=${expected_primary_binary}" <<<"$manifest"
  grep -Fxq "sha256=${expected_sha256}" <<<"$manifest"
  grep -Fxq "url=${expected_url}" <<<"$manifest"
}

assert_manifest Linux X64 \
  cargo-tauri-x86_64-unknown-linux-gnu.tgz \
  cargo-tauri \
  6864602a34292aa6f2ad40ae019eebe5c1064d6c623fe20696a8a8974067e60b \
  https://github.com/tauri-apps/tauri/releases/download/tauri-cli-v2.11.4/cargo-tauri-x86_64-unknown-linux-gnu.tgz

assert_manifest macOS X64 \
  cargo-tauri-x86_64-apple-darwin.zip \
  cargo-tauri \
  f10dfcc103ccb79248ca27cb9aff7b8a65499d1b0df79fe0465e8aa0a8e7cbef \
  https://github.com/tauri-apps/tauri/releases/download/tauri-cli-v2.11.4/cargo-tauri-x86_64-apple-darwin.zip

assert_manifest macOS ARM64 \
  cargo-tauri-aarch64-apple-darwin.zip \
  cargo-tauri \
  82bdcb9ae7f407882321680ae50750f11623fae22445f8b00b096e10f815d604 \
  https://github.com/tauri-apps/tauri/releases/download/tauri-cli-v2.11.4/cargo-tauri-aarch64-apple-darwin.zip

assert_manifest Windows X64 \
  cargo-tauri-x86_64-pc-windows-msvc.zip \
  cargo-tauri.exe \
  0743e30a661a35d63339b24cf63828f97ba5389a1d7f13b368a542794dd0a3f3 \
  https://github.com/tauri-apps/tauri/releases/download/tauri-cli-v2.11.4/cargo-tauri-x86_64-pc-windows-msvc.zip

if bash "$installer" unknown-tool --print-manifest >/dev/null 2>&1; then
  echo "expected an unknown release tool to fail closed" >&2
  exit 1
fi

echo "release tool manifest tests passed"
