# Windows

Install, update, run as a Windows scheduled task, and uninstall on Windows 10 / 11.

If you're running WSL2, you can follow the [Linux setup](./linux.md) instead; `install.sh` runs unchanged under WSL.

> **Note on `setup.bat`.** The `#6118` hard-stop failures (the 32-bit `set /a` disk-space overflow and the unescaped-parens `if/else` parse error) were fixed in [#6137](https://github.com/zeroclaw-labs/zeroclaw/pull/6137) and ship in **v0.7.4 and later**. Current releases complete normally. One caveat remains: `setup.bat --prebuilt` still checks for `cargo` before reaching the prebuilt branch, so the **manual prebuilt** path (Option 1 below) is the true no-Rust install. Building from source (Option 3) also works.

## Install

### Option 1: Prebuilt binary (recommended)

Download the latest Windows release zip, extract `zeroclaw.exe`, and put it on your `PATH`.

From a PowerShell prompt:

<!-- >>> generated:windows-prebuilt-powershell by `cargo generate installers` - do not edit <<< -->
```powershell
# Installation and PATH setup are idempotent. If zeroclaw is already at the
# latest release and on the user PATH, those steps are skipped; Quickstart
# still runs at the end.
$ver = (Invoke-RestMethod 'https://api.github.com/repos/zeroclaw-labs/zeroclaw/releases/latest').tag_name.TrimStart('v')
$dst = "$env:USERPROFILE\.zeroclaw\bin"
$exe = "$dst\zeroclaw.exe"

$current = if (Test-Path $exe) {
    ((& $exe --version 2>$null) | Select-String -Pattern '\d+\.\d+\.\d+').Matches.Value
} else { '' }

if ($current -ne $ver) {
    $url = "https://github.com/zeroclaw-labs/zeroclaw/releases/download/v$ver/zeroclaw-x86_64-pc-windows-msvc.zip"
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\zeroclaw.zip" -UseBasicParsing
    Expand-Archive -Force -Path "$env:TEMP\zeroclaw.zip" -DestinationPath $dst
}

$environment = [Environment]
$userPath = $environment::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $dst) {
    $environment::SetEnvironmentVariable('Path', "$dst;$userPath", 'User')
}
if (($env:Path -split ';') -notcontains $dst) {
    $env:Path = "$dst;$env:Path"
}

& $exe quickstart
```
<!-- >>> end generated:windows-prebuilt-powershell <<< -->

For the stable behavior shared by the Windows prebuilt and source routes, see the [canonical installation paths](../getting-started/quickstart.md#install). Release availability and the PowerShell download block remain documented here because they depend on live GitHub assets.

The prebuilt zip is self-contained; Visual Studio Build Tools are required only when building from source.

After install, verify:

```powershell
zeroclaw --version    # matches the latest release
```

### Option 2: `setup.bat` (from a release)

```cmd
setup.bat --prebuilt
```

Flags:

| Flag | Behaviour |
|---|---|
| `--prebuilt` | Download prebuilt binary from GitHub Releases (fastest once reached; current script still checks for `cargo` first) |
| `--minimal`  | Build core only (no channels, no hardware) |
| `--dist`     | Build the lean release distribution feature set |
| `--default`  | Build with Cargo's default feature set |
| `--all`      | Build with every registered feature |

> ⚠️ **Known issue (current).** `setup.bat --prebuilt` still checks for `cargo` before it reaches the prebuilt branch, so Option 2 does not honor a no-Rust promise. If you don't have a Rust toolchain, use **Option 1** above.
>
> _Historical (pre-`v0.7.4`)._ Earlier releases had two hard-stop failures and an onboarding-command mismatch reported in [#6118](https://github.com/zeroclaw-labs/zeroclaw/issues/6118): a 32-bit `set /a` disk-space overflow (`Invalid number. Numbers are limited to 32-bits of precision.`), an unescaped-parens `if/else` parse error (`.[0m was unexpected at this time.`), and a final `zeroclaw init` prompt. All were fixed in [#6137](https://github.com/zeroclaw-labs/zeroclaw/pull/6137) (v0.7.4 / 0.7.5 / 0.8.0); current releases print `zeroclaw quickstart` and complete normally.

### Option 3: From source

Requires Rust (`rustup`) and Visual Studio Build Tools:

```cmd
git clone https://github.com/zeroclaw-labs/zeroclaw
cd zeroclaw
cargo install --locked --path .
zeroclaw quickstart
```

### Option 4: Scoop

```cmd
scoop bucket add zeroclaw https://github.com/zeroclaw-labs/scoop-zeroclaw
scoop install zeroclaw
zeroclaw quickstart
```

## System dependencies

Windows builds use the MSVC toolchain. To build from source you need:

- Visual Studio Build Tools (or full Visual Studio) with the "Desktop development with C++" workload
- Rust stable (via `rustup`)

If you're using **Option 1**, you don't need the Rust toolchain; the binary is self-contained. Option 2 (`setup.bat --prebuilt`) is intended to use the same binary path, but the current script still checks for `cargo` before it reaches the prebuilt branch; see the known issue above.

## Running as a service

On Windows, ZeroClaw installs as a **user-scoped scheduled task** named `ZeroClaw Daemon`. There is no Windows Service / LocalSystem option in the current release; the underlying code path always installs a scheduled task, regardless of whether `zeroclaw service install` is run from an elevated or non-elevated shell.

```cmd
zeroclaw service install
zeroclaw service start
```

This creates a task in Task Scheduler (`taskschd.msc`) under your user account that starts on login. Manage it via:

```cmd
zeroclaw service status
zeroclaw service restart
zeroclaw service stop
zeroclaw service logs
```

> **About `--service-init`.** The CLI exposes a `--service-init [auto|systemd|openrc]` flag for cross-platform consistency, but on Windows it is a no-op; the scheduled-task path is always used.

Logs go to `%USERPROFILE%\.zeroclaw\logs\` (specifically, `<config_dir>/logs/` where `<config_dir>` defaults to `%USERPROFILE%\.zeroclaw\`). The scheduled-task wrapper itself, however, lives next to the config file at `%USERPROFILE%\.zeroclaw\zeroclaw-daemon.cmd`. Only the daemon output files (`daemon.stdout.log` / `daemon.stderr.log`) are written under `logs\`.

> **Server / multi-user installs.** Native Windows Service / LocalSystem support is on the roadmap but not yet implemented. For now, on a server box, install ZeroClaw under the account that the agent should run as; the scheduled-task path will start it on that user's login. If you need it to start before any user logs in, use **Task Scheduler → ZeroClaw Daemon → Properties → General → "Run whether user is logged on or not."**

## Update

### Manual (Option 1 path)

Re-run the PowerShell install block from **Option 1** with the new `$ver`. The new zip overwrites the existing `zeroclaw.exe` in place. Then:

```powershell
zeroclaw service restart
```

### `setup.bat`

Re-download the latest release and re-run `setup.bat --prebuilt` (or whichever flag you used originally). Then:

```cmd
zeroclaw service restart
```

### Scoop

```cmd
scoop update zeroclaw
zeroclaw service restart
```

### From source

```cmd
cd C:\path\to\zeroclaw
git pull
cargo install --locked --path . --force
zeroclaw service restart
```

## Uninstall

Stop and remove the scheduled task:

```cmd
zeroclaw service stop
zeroclaw service uninstall
```

Remove the binary:

```cmd
:: Option 1 (manual prebuilt) or setup.bat
rmdir /s /q "%USERPROFILE%\.zeroclaw\bin"

:: Option 3 (cargo install)
del "%USERPROFILE%\.cargo\bin\zeroclaw.exe"

:: Option 4 (Scoop)
scoop uninstall zeroclaw
```

Remove config, workspace, and logs (optional; this deletes conversation history):

```cmd
rmdir /s /q "%USERPROFILE%\.zeroclaw"
```

> The previous version of this doc referenced `%LOCALAPPDATA%\ZeroClaw\`; that path is **not** used by the current release; only `%USERPROFILE%\.zeroclaw\` is.

## Gotchas

- **Long paths.** Some Windows file systems still cap path lengths at 260 characters. Enable long path support if you hit `path too long` errors during a source build:
  ```
  reg add HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1 /f
  ```

- **SmartScreen.** The unsigned binary may trip SmartScreen on first launch from Explorer (double-click). Right-click → Properties → "Unblock" is the standard workaround until we add a signed MSI. Launching from PowerShell or `cmd.exe` typically does not trigger SmartScreen.

- **Task Scheduler stop-at-idle / battery.** By default Windows may terminate scheduled tasks on idle or battery. The installed `ZeroClaw Daemon` task disables these conditions, but if you've installed via an older release you can verify under **Task Scheduler → ZeroClaw Daemon → Properties → Conditions**:
  - "Start the task only if the computer is on AC power": unchecked
  - "Stop if the computer switches to battery power": unchecked
  - "Start the task only if the computer is idle for…": unchecked

- **OpenSSH password auth.** If you're driving Windows over SSH and pubkey isn't accepted, drop your key into `C:\Users\<user>\.ssh\authorized_keys` (regular user) or `C:\ProgramData\ssh\administrators_authorized_keys` (when logged in as a member of `Administrators`).

## Next

- [Service management](./service.md)
- [Quick start](../getting-started/quickstart.md)
- [Operations → Overview](../ops/overview.md)
