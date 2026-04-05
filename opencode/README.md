# OpenCode setup

This package keeps shared OpenCode config and custom agents in one place, while
letting you create isolated auth/runtime profiles.

## shared config

Current `~/.config/opencode` layout:

- symlinked: `agents`, `commands`, `plugins`, `settings.json`, `settings.local.json`, `skills`
- local (not symlinked): `opencode.json`, `providers/`, `package.json`, `bun.lock`, `node_modules/`, `skills.bak-*`

The profile launcher keeps this same shared config by symlinking profile config
to `~/.config/opencode`.

## create a profile launcher

```bash
./opencode/scripts/setup-profile.sh golly
```

This creates `~/.local/bin/oc-golly`.

## use the profile

```bash
oc-golly
oc-golly providers login --provider openai
```

Each profile gets isolated data at:

- `~/.local/share/opencode-profiles/<name>/opencode`
- `~/.local/state/opencode-profiles/<name>/opencode`
- `~/.cache/opencode-profiles/<name>/opencode`

So auth/session storage is separate per profile, while commands/skills/agents
stay shared.
