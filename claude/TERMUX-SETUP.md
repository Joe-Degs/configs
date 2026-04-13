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

## Issue 4: hardcoded /tmp/claude paths break sandbox on Termux

### Symptoms

- Commands that take more than a few seconds fail with:

```
EACCES: permission denied, mkdir '/tmp/claude/-data-data-com-termux-files-home/tasks'
```

- `git fetch`, `git push`, and other network-touching commands fail inside Claude Code
- Simple commands like `echo "test"` and `git status` still work (they complete before the sandbox task-tracking kicks in)

### Root cause

Claude Code hardcodes `/tmp/claude` in multiple places inside `cli.js`:

1. The sandbox filesystem allow list includes `/tmp/claude` and `/private/tmp/claude` (macOS), but not the Termux equivalent.
2. The `CLAUDE_TMPDIR` env var controls the `TMPDIR` passed into the sandbox, but the allow list is still hardcoded.
3. A browser bridge helper generates paths like `/tmp/claude-mcp-browser-bridge-<uuid>`.

On Termux, `/tmp` is either nonexistent or not writable. The correct temp directory is `$PREFIX/tmp` (`/data/data/com.termux/files/usr/tmp`).

### Triage steps

1. Check if the error is the sandbox `/tmp` issue:

```bash
grep -c "/tmp/claude" "$(dirname $(which claude))/../lib/node_modules/@anthropic-ai/claude-code/cli.js"
```

If the count is greater than 0 and paths point to `/tmp/claude` (not Termux's tmp), the patch is needed.

2. Confirm Termux tmp is writable:

```bash
touch "$PREFIX/tmp/test-write" && rm "$PREFIX/tmp/test-write" && echo "writable"
```

### Fix

Replace all hardcoded `/tmp/claude` paths with the Termux tmp equivalent:

```bash
CLAUDE_CLI="$(dirname $(which claude))/../lib/node_modules/@anthropic-ai/claude-code/cli.js"
sed -i "s|/tmp/claude|${PREFIX}/tmp/claude|g" "$CLAUDE_CLI"
```

Verify:

```bash
grep -c "${PREFIX}/tmp/claude" "$CLAUDE_CLI"
# Should return 9+ (matching the original hardcoded count)
```

The fix requires restarting Claude Code since the running process already has the old paths in memory.

### Persistence

Like the ripgrep fix, this breaks on Claude Code updates. The quick setup script below handles both.

### Related GitHub issues

- [#15637](https://github.com/anthropics/claude-code/issues/15637) - Hardcoded /tmp/claude paths break on Termux
- [#15700](https://github.com/anthropics/claude-code/issues/15700) - Background tasks ignore $TMPDIR
- [#17366](https://github.com/anthropics/claude-code/issues/17366) - EACCES permission denied on Android/Termux
- [#18679](https://github.com/anthropics/claude-code/issues/18679) - Feature request for CLAUDE_TMPDIR env var

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

5. No /tmp/claude sandbox errors (run a long command like `git fetch`):

```bash
git -C "$OBSIDIAN_VAULT_PATH" fetch origin
```

---

## Quick setup script

Run after each Claude Code update:

```bash
#!/data/data/com.termux/files/usr/bin/bash
# fix-claude-termux.sh

set -e

CLAUDE_PKG="$(dirname $(which claude))/../lib/node_modules/@anthropic-ai/claude-code"
RG_SRC="/data/data/com.termux/files/usr/bin/rg"
RG_DST="${CLAUDE_PKG}/vendor/ripgrep/arm64-android"
CLAUDE_CLI="${CLAUDE_PKG}/cli.js"
TERMUX_TMP="${PREFIX}/tmp"

echo "Applying Claude Code Termux fixes..."

# Fix 1: ripgrep symlink
if [[ ! -x "$RG_SRC" ]]; then
    echo "ripgrep not found. Install with: pkg install ripgrep"
    exit 1
fi

mkdir -p "$RG_DST"
ln -sf "$RG_SRC" "$RG_DST/rg"
echo "  ripgrep: symlinked ($(rg --version | head -1))"

# Fix 2: /tmp/claude sandbox paths
if grep -q '"/tmp/claude"' "$CLAUDE_CLI" 2>/dev/null; then
    sed -i "s|/tmp/claude|${TERMUX_TMP}/claude|g" "$CLAUDE_CLI"
    echo "  sandbox: patched /tmp/claude -> ${TERMUX_TMP}/claude"
else
    echo "  sandbox: already patched"
fi

echo "Done. Restart Claude Code for changes to take effect."
```

Save as `~/bin/fix-claude-termux.sh` and run after updates.

---

## Date

Initial documentation: 2026-01-05
Updated: 2026-01-29 (added issue 4: /tmp/claude sandbox paths)
