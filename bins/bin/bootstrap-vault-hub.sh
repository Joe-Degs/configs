#!/bin/bash
# Usage: bootstrap-vault-hub.sh
#
# Sets up this machine as the Obsidian vault hub: Claude Code, herdr, the vault clone,
# the stowed config, and the boot service. Idempotent, safe to rerun after an update.
#
# Two steps cannot be automated and are printed at the end: `claude auth login` and
# accepting the workspace trust dialog. Remote Control does not work without both.

set -euo pipefail

DOTFILES="${DOTFILES_PATH:-$HOME/.dotfiles}"
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}"
VAULT_REMOTE="git@github.com:Joe-Degs/Obsidian"
HERDR_REPO="herdrdev/herdr"
HERDR_BIN="$HOME/.local/bin/herdr"
ENV_FILE="$HOME/.config/vault-hub.env"
GIT_NAME="Joseph Attah"
GIT_EMAIL="npedev8660@gmail.com"
STOW_PACKAGES=(bins claude shell vaulthub)

info() { echo "==> $*"; }
die()  { echo "bootstrap-vault-hub: $*" >&2; exit 1; }

case "$(uname -s)" in
  Linux) ;;
  *) die "this bootstraps the Linux hub only, not $(uname -s)" ;;
esac

# npm's prefix here is ~/.local, and this script moves ~/.bashrc aside while stowing,
# so it cannot rely on the shell config for PATH.
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

for cmd in git curl stow jq npm loginctl systemctl; do
  command -v "$cmd" >/dev/null || die "missing dependency: $cmd"
done

[[ -d "$DOTFILES" ]] || die "dotfiles not found at $DOTFILES"

info "checking GitHub ssh auth"
# Not a pipeline on purpose: `ssh -T git@github.com` exits 1 even when the key is
# accepted, and pipefail would turn that into a false negative.
gh_auth=$(ssh -o BatchMode=yes -T git@github.com 2>&1 || true)
if [[ "$gh_auth" != *"successfully authenticated"* ]]; then
  die "ssh to GitHub failed.
  Generate a key and add the public half at https://github.com/settings/keys:
    ssh-keygen -t ed25519 -C \"\$(whoami)@\$(hostname)\" -f ~/.ssh/id_ed25519 -N \"\"
    cat ~/.ssh/id_ed25519.pub"
fi

info "setting git identity"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

info "installing claude code"
if command -v claude >/dev/null; then
  echo "    already installed: $(claude --version 2>/dev/null || echo unknown)"
else
  npm install -g @anthropic-ai/claude-code
fi

info "installing herdr"
mkdir -p "$HOME/.local/bin"
HERDR_TAG=$(curl -fsSL "https://api.github.com/repos/${HERDR_REPO}/releases/latest" \
  | jq -r '.tag_name')
[[ -n "$HERDR_TAG" && "$HERDR_TAG" != "null" ]] || die "could not resolve latest herdr release"
if [[ -x "$HERDR_BIN" ]] && "$HERDR_BIN" --version 2>/dev/null | grep -q "${HERDR_TAG#v}"; then
  echo "    already at $HERDR_TAG"
else
  curl -fsSL -o "$HERDR_BIN" \
    "https://github.com/${HERDR_REPO}/releases/download/${HERDR_TAG}/herdr-linux-aarch64"
  chmod +x "$HERDR_BIN"
  echo "    installed $HERDR_TAG"
fi

info "stowing ${STOW_PACKAGES[*]}"
for pkg in "${STOW_PACKAGES[@]}"; do
  [[ -d "$DOTFILES/$pkg" ]] || die "stow package not found: $DOTFILES/$pkg"
done
# Order matters. Unstow first: stow "folds" a whole package directory into a single
# symlink (~/.claude -> the repo) when the target does not exist yet, and both mkdir and
# mv follow a folded symlink straight into version control. Unfold before touching
# anything underneath.
for pkg in "${STOW_PACKAGES[@]}"; do
  stow -D -d "$DOTFILES" -t "$HOME" "$pkg" 2>/dev/null || true
done

# Now real directories can be created safely, which stops stow re-folding them. Without
# this, ~/.config/systemd becomes a symlink into the repo and `systemctl --user enable`
# writes default.target.wants/ straight into version control.
while IFS= read -r dir; do
  mkdir -p "$HOME/$dir"
done < <(cd "$DOTFILES" && for pkg in "${STOW_PACKAGES[@]}"; do
           find "$pkg" -mindepth 2 -type d -printf '%P\n'
         done)

# stow refuses to touch anything it does not own: real files (~/.bashrc) and hand-made
# absolute symlinks (~/.tmux.conf -> /home/joe/.dotfiles/...) both abort the whole run.
# Back up rather than --adopt: --adopt would pull this machine's copy into the repo and
# push it to every other machine.
while IFS= read -r target; do
  path="$HOME/$target"
  [[ -e "$path" || -L "$path" ]] || continue

  # Resolve the whole path, not just the leaf. A real file under a symlinked ancestor
  # lives in the repo, and renaming it would mangle version control.
  resolved=$(readlink -f "$path" 2>/dev/null || true)
  if [[ -n "$resolved" && "$resolved" == "$DOTFILES"/* ]]; then
    [[ -L "$path" ]] && rm "$path"
    continue
  fi

  backup="${path}.pre-stow"
  [[ -e "$backup" ]] && backup="${path}.pre-stow.$(date +%Y%m%d%H%M%S)"
  info "backing up ~/$target to ${backup#"$HOME"/}"
  mv "$path" "$backup"
done < <(cd "$DOTFILES" && for pkg in "${STOW_PACKAGES[@]}"; do
           find "$pkg" -type f -printf '%P\n'
         done)
stow -d "$DOTFILES" -t "$HOME" "${STOW_PACKAGES[@]}"

info "checking the herdr claude integration"
# The hook script and its SessionStart entry are both version-controlled, so the
# installer has nothing to add. Running it anyway appends a duplicate hook with a
# hardcoded /home/joe path, because it does not recognize the portable entry as its own.
if [[ -f "$HOME/.claude/hooks/herdr-agent-state.sh" ]]; then
  echo "    already present, skipping installer"
else
  "$HERDR_BIN" integration install claude || echo "    integration install skipped"
fi

info "cloning the vault"
if [[ -d "$VAULT/.git" ]]; then
  echo "    already cloned at $VAULT"
else
  mkdir -p "$(dirname "$VAULT")"
  git clone "$VAULT_REMOTE" "$VAULT"
fi

info "writing $ENV_FILE"
mkdir -p "$HOME/.config/environment.d"
cat > "$ENV_FILE" <<EOF
OBSIDIAN_VAULT_PATH=$VAULT
DOTFILES_PATH=$DOTFILES
EOF
ln -sf "$ENV_FILE" "$HOME/.config/environment.d/vault-hub.conf"

info "enabling linger so user units start at boot"
loginctl enable-linger "$(whoami)"

info "enabling herdr-vault.service"
systemctl --user daemon-reload
systemctl --user enable --now herdr-vault.service

cat <<'EOF'

==> bootstrap done. Two steps left that need you at a prompt:

  1. sign in to claude.ai (Remote Control rejects API keys):
       unset ANTHROPIC_API_KEY
       claude auth login

  2. accept the workspace trust dialog from inside the vault
     (the dialog never saves trust for a home directory):
       cd "$OBSIDIAN_VAULT_PATH" && claude

  Then confirm none of these are set, since each silently disables Remote Control:
    DISABLE_TELEMETRY  DO_NOT_TRACK  CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
    DISABLE_GROWTHBOOK  ANTHROPIC_BASE_URL

  Attach with:  herdr
EOF
