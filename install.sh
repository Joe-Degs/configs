#!/usr/bin/env bash
#
# Dotfiles Installation Script
# Installs packages and symlinks configuration files using GNU Stow
#

set -euo pipefail

# Configuration
DOTFILES_DIR="$HOME/.dotfiles"
LOG_FILE="$DOTFILES_DIR/install.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
log_info()    { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1" | tee -a "$LOG_FILE"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }

# Package lists
PACMAN_PACKAGES=(
    # Core
    "stow"
    "git"
    # Hyprland
    "hyprland"
    "hyprpaper"
    "hyprlock"
    "hypridle"
    # Bar and launcher
    "waybar"
    "rofi-wayland"
    # Notifications
    "dunst"
    "libnotify"
    # Terminals
    "alacritty"
    # Audio
    "wireplumber"
    "pipewire"
    "pipewire-pulse"
    "playerctl"
    # Screenshots
    "grim"
    "slurp"
    "wl-clipboard"
    "wf-recorder"
    # Utilities
    "jq"
    "fzf"
    "ripgrep"
    "fd"
    # Fonts
    "ttf-fira-sans"
    "ttf-font-awesome"
    "noto-fonts-emoji"
    # Editor
    "neovim"
    # File manager
    "thunar"
    # Browser
    "firefox"
    # Shell
    "tmux"
)

AUR_PACKAGES=(
    "ghostty-git"
    "papirus-icon-theme"
)

STOW_PACKAGES=("gui" "editor" "shell" "bins")

# Check Arch Linux
check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        log_error "This script is designed for Arch Linux"
        exit 1
    fi
}

command_exists() {
    command -v "$1" &>/dev/null
}

# Install yay
install_yay() {
    if command_exists yay; then
        log_info "yay already installed"
        return
    fi

    log_info "Installing yay..."
    local temp_dir
    temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
    (cd "$temp_dir/yay" && makepkg -si --noconfirm)
    rm -rf "$temp_dir"
    log_success "yay installed"
}

# Install pacman packages
install_pacman_packages() {
    log_info "Installing pacman packages..."
    local to_install=()

    for pkg in "${PACMAN_PACKAGES[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        sudo pacman -S --needed --noconfirm "${to_install[@]}"
        log_success "Pacman packages installed"
    else
        log_info "All pacman packages already installed"
    fi
}

# Install AUR packages
install_aur_packages() {
    log_info "Installing AUR packages..."
    local to_install=()

    for pkg in "${AUR_PACKAGES[@]}"; do
        if ! yay -Qi "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        yay -S --needed --noconfirm "${to_install[@]}"
        log_success "AUR packages installed"
    else
        log_info "All AUR packages already installed"
    fi
}

# Create directories
setup_directories() {
    log_info "Creating directories..."

    local dirs=(
        "$HOME/.config"
        "$HOME/bin"
        "$HOME/.local/bin"
        "$HOME/Pictures/Screenshots"
        "$HOME/Pictures/wallpapers"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
    done

    log_success "Directories created"
}

# Backup existing configs
backup_existing() {
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    local needs_backup=false

    # Check for stow conflicts
    for pkg in "${STOW_PACKAGES[@]}"; do
        if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
            if stow -n -d "$DOTFILES_DIR" -t "$HOME" "$pkg" 2>&1 | grep -q "existing target"; then
                needs_backup=true
                break
            fi
        fi
    done

    if $needs_backup; then
        log_warn "Existing configs found, backing up to $backup_dir"
        mkdir -p "$backup_dir"

        # Backup common locations
        [[ -d "$HOME/.config/hypr" ]] && cp -r "$HOME/.config/hypr" "$backup_dir/" 2>/dev/null || true
        [[ -d "$HOME/.config/waybar" ]] && cp -r "$HOME/.config/waybar" "$backup_dir/" 2>/dev/null || true
        [[ -d "$HOME/.config/rofi" ]] && cp -r "$HOME/.config/rofi" "$backup_dir/" 2>/dev/null || true
        [[ -d "$HOME/.config/nvim" ]] && cp -r "$HOME/.config/nvim" "$backup_dir/" 2>/dev/null || true
        [[ -f "$HOME/.bashrc" ]] && cp "$HOME/.bashrc" "$backup_dir/" 2>/dev/null || true
        [[ -f "$HOME/.tmux.conf" ]] && cp "$HOME/.tmux.conf" "$backup_dir/" 2>/dev/null || true

        log_success "Backup created"
    fi
}

# Run stow
run_stow() {
    log_info "Running stow..."

    cd "$DOTFILES_DIR"

    for pkg in "${STOW_PACKAGES[@]}"; do
        if [[ -d "$pkg" ]]; then
            log_info "Stowing $pkg..."
            stow -D "$pkg" 2>/dev/null || true
            if stow "$pkg"; then
                log_success "Stowed $pkg"
            else
                log_error "Failed to stow $pkg"
            fi
        else
            log_warn "Package $pkg not found"
        fi
    done
}

# Setup tmux plugin manager
setup_tmux() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ ! -d "$tpm_dir" ]]; then
        log_info "Installing tmux plugin manager..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        log_success "TPM installed"
    fi
}

# Make scripts executable
make_executable() {
    log_info "Making scripts executable..."

    chmod +x "$HOME/bin/"* 2>/dev/null || true
    chmod +x "$HOME/.config/rofi/"*.sh 2>/dev/null || true
    chmod +x "$HOME/.config/rofi/applets/bin/"*.sh 2>/dev/null || true

    log_success "Scripts made executable"
}

# Print summary
print_summary() {
    echo ""
    echo "============================================"
    echo -e "${GREEN}Installation Complete!${NC}"
    echo "============================================"
    echo ""
    echo "Next steps:"
    echo "  1. Log out and select Hyprland as your session"
    echo "  2. Press SUPER + / to view keybindings"
    echo "  3. Add wallpapers to ~/Pictures/wallpapers/"
    echo ""
    echo "Useful commands:"
    echo "  hyprctl reload        Reload Hyprland config"
    echo "  ~/bin/reload-waybar   Restart waybar"
    echo ""
    echo "Log file: $LOG_FILE"
    echo ""
}

# Print help
print_help() {
    cat <<EOF
Dotfiles Installation Script

Usage: $0 [OPTIONS]

Options:
  --skip-packages    Skip package installation (stow only)
  --update           Update stow links only (no packages, no backup)
  --help, -h         Show this help message

Examples:
  $0                 Full installation
  $0 --skip-packages Stow configs without installing packages
  $0 --update        Re-stow all packages
EOF
}

# Main
main() {
    echo "============================================"
    echo "Dotfiles Installation Script"
    echo "============================================"
    echo ""

    # Initialize log
    echo "Installation started at $(date)" > "$LOG_FILE"

    # Parse arguments
    local skip_packages=false
    local update_only=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-packages) skip_packages=true ;;
            --update) update_only=true ;;
            --help|-h)
                print_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
        shift
    done

    check_arch

    if ! $update_only; then
        if ! $skip_packages; then
            install_yay
            install_pacman_packages
            install_aur_packages
        fi

        setup_directories
        backup_existing
        setup_tmux
    fi

    run_stow
    make_executable
    print_summary

    log_success "Done!"
}

main "$@"
