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

for cmd in git curl stow jq npm loginctl systemctl; do
  command -v "$cmd" >/dev/null || die "missing dependency: $cmd"
done

[[ -d "$DOTFILES" ]] || die "dotfiles not found at $DOTFILES"

info "checking GitHub ssh auth"
if ! ssh -o BatchMode=yes -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
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

info "installing the herdr claude integration"
"$HERDR_BIN" integration install claude || echo "    integration install skipped"

info "stowing ${STOW_PACKAGES[*]}"
for pkg in "${STOW_PACKAGES[@]}"; do
  [[ -d "$DOTFILES/$pkg" ]] || die "stow package not found: $DOTFILES/$pkg"
done
# stow refuses to clobber real files, which is how ~/.bashrc silently blocked the shell
# package before. Back up rather than --adopt: --adopt would pull this machine's bashrc
# into the repo and push it to every other machine.
while IFS= read -r target; do
  [[ -e "$HOME/$target" && ! -L "$HOME/$target" ]] || continue
  info "backing up ~/$target to ~/${target}.pre-stow"
  mv "$HOME/$target" "$HOME/${target}.pre-stow"
done < <(cd "$DOTFILES" && for pkg in "${STOW_PACKAGES[@]}"; do
           find "$pkg" -type f -printf '%P\n'
         done)
stow -d "$DOTFILES" -t "$HOME" "${STOW_PACKAGES[@]}"

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
