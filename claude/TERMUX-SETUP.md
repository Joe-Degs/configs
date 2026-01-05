# Claude Code on Termux: known issues and fixes

This document covers issues encountered running Claude Code on Android via Termux, along with triage steps and fixes.

## Environment

- Platform: Android (Termux)
- Architecture: arm64 (aarch64)
- Claude Code version: 2.0.76+
- Node.js: installed via Termux pkg

## Issue 1: missing ripgrep binary for arm64-android

### Symptoms

- Agent definitions fail to load
- Custom agents in `~/.claude/agents/` not recognized
- Grep/search operations may fail silently
- Debug log shows:

```
Error loading agent definitions: spawn /data/data/com.termux/files/usr/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-android/rg ENOENT
```

### Root cause

Claude Code bundles ripgrep binaries for specific platforms:

```
vendor/ripgrep/
├── arm64-darwin/rg
├── arm64-linux/rg
├── x64-darwin/rg
├── x64-linux/rg
└── x64-win32/rg.exe
```

Termux on Android identifies as `arm64-android`, but no binary exists for this platform. The code attempts to spawn a non-existent file.

### Triage steps

1. Check debug logs:

```bash
grep -i "rg ENOENT" ~/.claude/debug/latest
```

2. Verify the missing directory:

```bash
ls ~/.../vendor/ripgrep/
# Should show arm64-darwin, arm64-linux, etc. but NOT arm64-android
```

3. Confirm system ripgrep is available:

```bash
which rg && rg --version
```

### Fix

Create the missing directory and symlink to Termux's ripgrep:

```bash
CLAUDE_RG_DIR="/data/data/com.termux/files/usr/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-android"
mkdir -p "$CLAUDE_RG_DIR"
ln -sf /data/data/com.termux/files/usr/bin/rg "$CLAUDE_RG_DIR/rg"
```

### Persistence

The symlink breaks on Claude Code updates. Add to `~/.bashrc` or `~/.zshrc`:

```bash
claude-fix-rg() {
    local rg_dir="/data/data/com.termux/files/usr/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-android"
    if [[ ! -x "$rg_dir/rg" ]]; then
        mkdir -p "$rg_dir" 2>/dev/null
        ln -sf /data/data/com.termux/files/usr/bin/rg "$rg_dir/rg" 2>/dev/null
        echo "Fixed Claude Code ripgrep symlink"
    fi
}

# Run on shell startup
claude-fix-rg
```

Or create a post-install hook if using a package manager wrapper.

### Related GitHub issues

- [#9435](https://github.com/anthropics/claude-code/issues/9435) - Custom Slash Commands Not Loading on Termux
- [#8760](https://github.com/anthropics/claude-code/issues/8760) - ripgrep ENOENT on Termux
- [#12160](https://github.com/anthropics/claude-code/issues/12160) - Android/ARM64 crashes

---

## Issue 2: skill descriptions showing incorrectly

### Symptoms

Skills load but descriptions appear truncated in the available skills list, showing `| (user)` instead of the full description.

### Root cause

YAML multiline syntax (`description: |`) in SKILL.md frontmatter may not parse correctly in all contexts.

### Triage steps

1. Check if skills are loading:

```bash
grep "Loaded.*skills" ~/.claude/debug/latest
```

2. Look for skill count:

```
Loaded 2 unique skills (managed: 0, user: 2, project: 0, legacy commands: 0)
```

3. Verify skills appear in tool list:

```bash
grep "Skills and commands included" ~/.claude/debug/latest
```

### Fix

Keep descriptions on a single line in SKILL.md frontmatter:

```yaml
---
name: my-skill
description: Brief description on one line (max 1024 chars)
---
```

Instead of:

```yaml
---
name: my-skill
description: |
  Multi-line description
  that might not parse correctly
---
```

---

## Issue 3: commands showing as "legacy commands: 0"

### Symptoms

Debug log shows `legacy commands: 0` but commands still work.

### Explanation

This is not actually an issue. The "legacy commands" metric refers to an older command format. Current commands in `~/.claude/commands/*.md` load through a different mechanism and appear in the skills system.

### Verification

Run `/help` in Claude Code---your custom commands should appear listed under custom skills/commands.

---

## Verification checklist

After applying fixes, verify:

1. Ripgrep symlink exists and is executable:

```bash
ls -la /data/data/com.termux/files/usr/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-android/rg
```

2. No ENOENT errors in fresh session:

```bash
claude --debug 2>&1 | grep -i "ENOENT"
```

3. Agents load correctly:

```bash
grep "agent" ~/.claude/debug/latest | grep -v error
```

4. Skills recognized:

```bash
grep "Loaded.*skills" ~/.claude/debug/latest
```

---

## Quick setup script

Run after each Claude Code update:

```bash
#!/data/data/com.termux/files/usr/bin/bash
# fix-claude-termux.sh

set -e

RG_SRC="/data/data/com.termux/files/usr/bin/rg"
RG_DST="/data/data/com.termux/files/usr/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-android"

# Check ripgrep installed
if [[ ! -x "$RG_SRC" ]]; then
    echo "ripgrep not found. Install with: pkg install ripgrep"
    exit 1
fi

# Create symlink
mkdir -p "$RG_DST"
ln -sf "$RG_SRC" "$RG_DST/rg"

echo "Claude Code Termux fix applied"
echo "ripgrep: $(rg --version | head -1)"
```

Save as `~/bin/fix-claude-termux.sh` and run after updates.

---

## Date

Initial documentation: 2026-01-05
