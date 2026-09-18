# Running Python Skills

ZeroClaw can run Python skills through the host Python environment. For repeatable
dependencies, prefer a reviewed project-local virtual environment or another setup
step outside the agent turn.

The default configuration is intentionally conservative. It blocks many copy-paste
Python patterns until you explicitly allow the interpreter and choose the sandbox
policy for the active risk profile.

This page covers Python scripts invoked through the built-in shell tool. If a
`SKILL.toml` defines its own `[[tools]]` entry with `kind = "shell"` or
`kind = "script"`, that skill tool executes as a host subprocess under shell policy.

## The Three Layers

Python skill execution is controlled by three separate layers.

| Layer | Config surface | What it decides |
|---|---|---|
| Skill audit | `[skills].allow_scripts` | Whether shell-like helper files can load from a skill package. Python `.py` helpers are allowed by default. |
| Shell policy | `[risk_profiles.<alias>].allowed_commands` | Whether the shell tool may invoke `python`, `python3`, `pip`, or another executable. |
| Execution boundary | `[risk_profiles.<alias>].sandbox_*` and `[runtime]` | Where the allowed command actually runs, and what filesystem, network, and resource limits apply. |

Python helper files do not require `allow_scripts = true`. Enable shell-like helper files only after you have reviewed the skill source, and allow the interpreter (`python`, `python3`, `pip`) in the risk profile's `allowed_commands`. `allowed_commands` is a strict executable allowlist when it is non-empty. The shell policy still checks destructive patterns and interpreter argument risks on top of that allowlist.

Prefer installing Python packages in a reviewed local virtual environment or another setup step outside the agent turn. Add `pip` to a trusted profile only when runtime package installation is an intentional part of that deployment.

## What Stays Blocked

ZeroClaw deliberately blocks inline interpreter execution such as:

<div class="os-tabs-src">

#### sh

```sh
python3 -c 'print("hello")'
python3 -m http.server
python3 -m pip install requests
node -e 'console.log(process.env)'
```

</div>

For Python skills, put code in an auditable script file and run that file:

<div class="os-tabs-src">

#### sh

```sh
python3 skills/portfolio/run.py
```

</div>

This makes the executable file reviewable by the skill audit path and avoids turning a shell command string into an arbitrary code container.

Environment-variable prefixes such as `PYTHONPATH=... python3 script.py` are also policy-sensitive. Prefer a wrapper script, a project-local virtual environment, or explicit configuration inside the script when you need stable runtime environment setup.

## Pattern A: Trusted Native Python

Use native execution when the skills are trusted and you want them to use the host's Python installation, packages, filesystem permissions, and network.

This is appropriate for local development, a single-user workstation, or a home lab where you wrote the skill. It removes OS-level sandboxing for tool runs under that profile, so normal user permissions and ZeroClaw policy checks are the remaining guardrails.

Do not use this pattern for unreviewed third-party skills or multi-tenant deployments.

## Choosing a Pattern

- Use trusted native Python when you wrote or reviewed the skills and want the lowest latency on a single-user host.
- Use a project-local virtual environment and pinned dependencies when you need repeatable Python environments.
- Use stricter risk profiles, narrower command allowlists, and the supported OS sandbox backends for higher-risk skill sources.

## See Also

- [Skills](./skills.md)
- [Autonomy levels](../security/autonomy.md)
- [Sandboxing](../security/sandboxing.md)
