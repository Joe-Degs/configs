# Hyprland Dotfiles

Personal dotfiles for Arch Linux with Hyprland window manager, managed with GNU Stow.

## Overview

This setup includes:
- **Hyprland** - Wayland compositor/window manager
- **Waybar** - Status bar
- **Rofi** - Application launcher and menus
- **Ghostty/Alacritty** - Terminal emulators
- **Dunst** - Notification daemon
- **Neovim** - Editor
- **Tmux** - Terminal multiplexer

## Quick Install

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

### Install Options

```bash
./install.sh                 # Full installation
./install.sh --skip-packages # Stow only (skip package installation)
./install.sh --update        # Re-stow all packages
./install.sh --help          # Show help
```

## Requirements

### Pacman Packages
```
hyprland hyprpaper hyprlock hypridle waybar rofi-wayland dunst libnotify
alacritty wireplumber pipewire pipewire-pulse playerctl grim slurp
wl-clipboard wf-recorder jq neovim thunar firefox tmux stow git
ttf-fira-sans ttf-font-awesome noto-fonts-emoji
```

### AUR Packages
```
ghostty-git papirus-icon-theme
```

## Repository Structure

```
~/.dotfiles/
├── gui/                    # GUI application configs
│   └── .config/
│       ├── hypr/           # Hyprland (modular config)
│       ├── waybar/         # Status bar
│       ├── rofi/           # Launcher and menus
│       ├── ghostty/        # Ghostty terminal
│       ├── alacritty/      # Alacritty terminal
│       └── dunst/          # Notifications
├── editor/                 # Editor configs
│   └── .config/nvim/       # Neovim
├── shell/                  # Shell configs
│   ├── .bashrc
│   ├── .aliases
│   ├── .tmux.conf
│   └── .vimrc
├── bins/                   # Custom scripts
│   └── bin/
├── claude/                 # Claude Code config
│   └── .claude/
├── opencode/               # OpenCode agents only
│   └── .config/opencode/agents/
├── install.sh              # Installation script
└── README.md               # This file
```

## Stow Packages

| Package | Contents | Symlinks To |
|---------|----------|-------------|
| `gui` | Hyprland, Waybar, Rofi, terminals, dunst | `~/.config/` |
| `editor` | Neovim configuration | `~/.config/nvim/` |
| `shell` | Bash, tmux, vim configs | `~/` |
| `bins` | Custom utility scripts | `~/bin/` |
| `claude` | Claude Code configuration | `~/.claude/` |

### Manual Stow Commands

```bash
cd ~/.dotfiles
stow gui        # Symlink GUI configs
stow editor     # Symlink Neovim config
stow shell      # Symlink shell configs
stow bins       # Symlink custom scripts
stow claude     # Symlink Claude Code config

OpenCode agents are manual for now:

```bash
rm -f ~/.config/opencode/agents
ln -s ~/.dotfiles/opencode/.config/opencode/agents ~/.config/opencode/agents
```

stow -D gui     # Remove GUI symlinks
stow -R gui     # Restow (remove + re-add)
```

## Keybindings

Press `SUPER + /` to view keybindings in a searchable Rofi menu.

### Window Management

| Keybinding | Action |
|------------|--------|
| `SUPER + Return` | Launch terminal (Ghostty) |
| `SUPER + SHIFT + Return` | Launch floating terminal (Alacritty) |
| `SUPER + Q` | Close active window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + T` | Toggle floating mode |
| `SUPER + P` | Toggle pseudo-tiling |
| `SUPER + S` | Toggle split direction |
| `SUPER + CTRL + M` | Exit Hyprland |

### Applications

| Keybinding | Action |
|------------|--------|
| `SUPER + Space` | Application launcher (Rofi) |
| `SUPER + B` | Open browser (Firefox) |
| `SUPER + E` | Open file manager |
| `SUPER + /` | Show keybindings menu |

### Focus Navigation (Vim-style)

| Keybinding | Action |
|------------|--------|
| `SUPER + H` | Move focus left |
| `SUPER + J` | Move focus down |
| `SUPER + K` | Move focus up |
| `SUPER + L` | Move focus right |
| `ALT + Tab` | Cycle through windows |

### Workspaces

| Keybinding | Action |
|------------|--------|
| `SUPER + 1-9` | Switch to workspace 1-9 |
| `SUPER + 0` | Switch to workspace 10 |
| `SUPER + SHIFT + 1-9` | Move window to workspace 1-9 |
| `SUPER + SHIFT + 0` | Move window to workspace 10 |
| `SUPER + Mouse Scroll` | Scroll through workspaces |

### Mouse Actions

| Keybinding | Action |
|------------|--------|
| `SUPER + Left Click` | Move window (drag) |
| `SUPER + Right Click` | Resize window (drag) |

### Screenshots & Recording

| Keybinding | Action |
|------------|--------|
| `Print` | Screenshot menu |
| `SHIFT + Print` | Full screen capture to clipboard |

### Audio Controls

| Keybinding | Action |
|------------|--------|
| `Volume Up` | Increase volume 5% |
| `Volume Down` | Decrease volume 5% |
| `Mic Mute` | Toggle microphone mute |
| `Play/Pause` | Toggle media playback |
| `Prev/Next` | Previous/next track |

### Brightness

| Keybinding | Action |
|------------|--------|
| `Brightness Up` | Increase brightness |
| `Brightness Down` | Decrease brightness |

### Power & System

| Keybinding | Action |
|------------|--------|
| `SUPER + SHIFT + L` | Lock screen |
| `Power Button` | Power menu |
| `Lid Close` | Suspend and lock |

### Utilities

| Keybinding | Action |
|------------|--------|
| `SUPER + Z` | Toggle Do Not Disturb |
| `SUPER + SHIFT + B` | Reload Waybar |
| `SUPER + SHIFT + W` | Reload wallpaper |
| `SUPER + CTRL + W` | Reload Hyprpaper |

## Configuration Details

### Hyprland

Hyprland uses a modular configuration structure:

```
~/.config/hypr/
├── hyprland.conf       # Main config (sources others)
├── hyprlock.conf       # Lock screen config
├── hypridle.conf       # Idle timeout config
├── hyprpaper.conf      # Wallpaper config
└── conf/
    ├── animations.conf
    ├── autostart.conf
    ├── binds.conf      # Keybindings
    ├── decoration.conf
    ├── general.conf
    ├── input.conf
    ├── monitor.conf
    ├── windowrules.conf
    └── ...
```

Reload config: `hyprctl reload`

### Rofi

Rofi includes multiple applets and themes:

- **Launcher** (`SUPER + Space`) - Application launcher
- **Power Menu** (`Power Button`) - Shutdown, reboot, lock, suspend
- **Screenshot Menu** (`Print`) - Capture and recording options
- **Keybindings** (`SUPER + /`) - Searchable keybindings list

Theme files are in `~/.config/rofi/colors/` (dracula, nord, catppuccin, etc.)

### Waybar

Modules configured in `~/.config/waybar/`:
- `config` - Module layout and settings
- `modules.json` - Module definitions
- `style.css` - Styling

Reload: `~/bin/reload-waybar`

### Custom Scripts

Located in `~/bin/`:

| Script | Purpose |
|--------|---------|
| `adjust-brightness` | Brightness control |
| `browser` | Launch browser |
| `dnd-toggle` | Do Not Disturb toggle |
| `filemanager` | Launch file manager |
| `lockscreen` | Lock screen |
| `media` | Media controls |
| `reload-waybar` | Restart waybar |
| `reload-wallpaper` | Reload wallpaper |
| `reload-hyprpaper` | Reload hyprpaper |

## Making Changes Safely

### Golden Rules

1. **Always edit files in `~/.dotfiles/`**, not the symlinked files in `~/.config/`
2. **Test changes** before committing
3. **Use git branches** for experimental changes
4. **Commit frequently** with descriptive messages

### Workflow

```bash
cd ~/.dotfiles

# Make your changes to files in the repo
nvim gui/.config/hypr/conf/binds.conf

# Test the changes
hyprctl reload

# If it works, commit
git add -A
git commit -m "update: add new keybinding for xyz"
```

### After Adding New Files

If you add new files to a stow package, re-stow it:

```bash
cd ~/.dotfiles
stow -R gui  # Restow the gui package
```

## Git Backup Workflow

### Daily Workflow

```bash
cd ~/.dotfiles

# Check what changed
git status
git diff

# Commit changes
git add -A
git commit -m "update: describe your changes"
git push
```

### Experimental Changes

```bash
# Create experiment branch
git checkout -b experiment/new-theme

# Make changes, test...

# If successful, merge to master
git checkout master
git merge experiment/new-theme
git branch -d experiment/new-theme

# If failed, discard branch
git checkout master
git branch -D experiment/new-theme
```

### Recovery

```bash
# View history
git log --oneline

# Restore single file from previous commit
git checkout <commit-hash> -- path/to/file

# Restore entire previous state (CAUTION: loses uncommitted changes)
git reset --hard <commit-hash>

# Undo last commit but keep changes
git reset --soft HEAD~1

# See what a file looked like at a commit
git show <commit-hash>:path/to/file
```

## Troubleshooting

### Waybar not showing
```bash
# Check if waybar is running
pgrep waybar

# Restart waybar
~/bin/reload-waybar

# Check autostart
cat ~/.config/hypr/conf/autostart.conf
```

### Keybindings not working
```bash
# Reload Hyprland config
hyprctl reload

# Check for syntax errors
hyprctl -j getoption general:border_size
```

### Rofi style issues
```bash
# Test rofi directly
rofi -show drun

# Check theme file exists
ls ~/.config/rofi/applets/config.rasi
```

### Stow conflicts
```bash
# Check what's conflicting
stow -n gui  # Dry run

# Remove existing files manually, then stow
rm ~/.config/hypr/hyprland.conf
stow gui
```

### Screenshots not saving
```bash
# Check directory exists
mkdir -p ~/Pictures/Screenshots

# Test grim directly
grim ~/Pictures/Screenshots/test.png
```

## Credits

- Rofi themes based on [adi1090x/rofi](https://github.com/adi1090x/rofi)
- Various community dotfiles for inspiration
