#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: setup-profile.sh <profile-name>

Creates ~/.local/bin/oc-<profile-name>.

The launcher uses profile-scoped XDG data/state/cache directories so auth and
session storage are isolated, while sharing the existing ~/.config/opencode
configuration through a symlink.
EOF
}

profile_name="${1:-}"

if [[ -z "$profile_name" ]]; then
  usage
  exit 1
fi

if [[ ! "$profile_name" =~ ^[a-z0-9][a-z0-9._-]*$ ]]; then
  printf "error: invalid profile name '%s'\n" "$profile_name" >&2
  printf "allowed: lowercase letters, numbers, dot, underscore, dash\n" >&2
  exit 1
fi

shared_config="${OPENCODE_SHARED_CONFIG:-$HOME/.config/opencode}"

if [[ ! -d "$shared_config" ]]; then
  printf "error: shared config directory does not exist: %s\n" "$shared_config" >&2
  exit 1
fi

profile_config_home="${XDG_CONFIG_HOME_BASE:-$HOME/.config/opencode-profiles}/$profile_name"
profile_data_home="${XDG_DATA_HOME_BASE:-$HOME/.local/share/opencode-profiles}/$profile_name"
profile_state_home="${XDG_STATE_HOME_BASE:-$HOME/.local/state/opencode-profiles}/$profile_name"
profile_cache_home="${XDG_CACHE_HOME_BASE:-$HOME/.cache/opencode-profiles}/$profile_name"
launcher_dir="${OPENCODE_PROFILE_BIN_DIR:-$HOME/.local/bin}"
launcher_path="$launcher_dir/oc-$profile_name"
config_link="$profile_config_home/opencode"

mkdir -p "$profile_config_home" "$profile_data_home" "$profile_state_home" "$profile_cache_home" "$launcher_dir"

if [[ -e "$config_link" && ! -L "$config_link" ]]; then
  printf "error: %s exists and is not a symlink\n" "$config_link" >&2
  exit 1
fi

if [[ ! -e "$config_link" ]]; then
  ln -s "$shared_config" "$config_link"
fi

cat > "$launcher_path" <<EOF
#!/usr/bin/env bash

set -euo pipefail

PROFILE_NAME="$profile_name"
PROFILE_CONFIG_HOME="\${XDG_CONFIG_HOME_BASE:-\$HOME/.config/opencode-profiles}/\$PROFILE_NAME"
PROFILE_DATA_HOME="\${XDG_DATA_HOME_BASE:-\$HOME/.local/share/opencode-profiles}/\$PROFILE_NAME"
PROFILE_STATE_HOME="\${XDG_STATE_HOME_BASE:-\$HOME/.local/state/opencode-profiles}/\$PROFILE_NAME"
PROFILE_CACHE_HOME="\${XDG_CACHE_HOME_BASE:-\$HOME/.cache/opencode-profiles}/\$PROFILE_NAME"
SHARED_CONFIG="\${OPENCODE_SHARED_CONFIG:-\$HOME/.config/opencode}"

mkdir -p "\$PROFILE_CONFIG_HOME" "\$PROFILE_DATA_HOME" "\$PROFILE_STATE_HOME" "\$PROFILE_CACHE_HOME"

if [[ -e "\$PROFILE_CONFIG_HOME/opencode" && ! -L "\$PROFILE_CONFIG_HOME/opencode" ]]; then
  printf "error: %s exists and is not a symlink\n" "\$PROFILE_CONFIG_HOME/opencode" >&2
  exit 1
fi

if [[ ! -e "\$PROFILE_CONFIG_HOME/opencode" ]]; then
  ln -s "\$SHARED_CONFIG" "\$PROFILE_CONFIG_HOME/opencode"
fi

XDG_CONFIG_HOME="\$PROFILE_CONFIG_HOME" \
XDG_DATA_HOME="\$PROFILE_DATA_HOME" \
XDG_STATE_HOME="\$PROFILE_STATE_HOME" \
XDG_CACHE_HOME="\$PROFILE_CACHE_HOME" \
exec opencode "\$@"
EOF

chmod +x "$launcher_path"

printf "created launcher: %s\n" "$launcher_path"
printf "shared config: %s\n" "$shared_config"
printf "profile data: %s\n" "$profile_data_home/opencode"
printf "run: oc-%s\n" "$profile_name"
printf "first-time auth: oc-%s providers login --provider openai\n" "$profile_name"
