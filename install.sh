#!/usr/bin/env bash
#
# Dotfiles Installation Script
# Installs packages and symlinks configuration files using GNU Stow
# Supports both desktop (Hyprland) and server installations
#

set -euo pipefail

# Configuration
DOTFILES_DIR="$HOME/.dotfiles"
LOG_FILE="$DOTFILES_DIR/install.log"
INSTALL_MODE=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging
log_info()    { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1" | tee -a "$LOG_FILE"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }

# =============================================================================
# Package Lists
# =============================================================================

# Base packages for both desktop and server
BASE_PACKAGES=(
    "stow"
    "git"
    "jq"
    "fzf"
    "ripgrep"
    "fd"
    "neovim"
    "tmux"
)

# Desktop-only packages
DESKTOP_PACKAGES=(
    # Hyprland
    "hyprland"
    "hyprpaper"
    "hyprlock"
    "hypridle"
    # Bar and launcher
    "waybar"
    "rofi"
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
    # Fonts
    "ttf-fira-sans"
    "woff2-font-awesome"
    "noto-fonts-emoji"
    "ttf-meslo-nerd"
    "ttf-jetbrains-mono-nerd"
    "ttf-iosevka-nerd"
    "ttf-cascadia-mono-nerd"
    # Icons
    "papirus-icon-theme"
    # File manager
    "thunar"
    # Browser
    "firefox"
)

# Desktop AUR packages
DESKTOP_AUR_PACKAGES=(
    "ghostty-git"
    "ttf-icomoon-feather"
    "arch-update"
)

# Server AUR packages (placeholder for future)
SERVER_AUR_PACKAGES=()

# =============================================================================
# Helper Functions
# =============================================================================

check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        log_error "This script is designed for Arch Linux"
        exit 1
    fi
}

command_exists() {
    command -v "$1" &>/dev/null
}

# Install yay (AUR helper)
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
    local packages=("$@")
    local to_install=()

    for pkg in "${packages[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_info "Installing: ${to_install[*]}"
        sudo pacman -S --needed --noconfirm "${to_install[@]}"
        log_success "Pacman packages installed"
    else
        log_info "All pacman packages already installed"
    fi
}

# Install AUR packages
install_aur_packages() {
    local packages=("$@")
    local to_install=()

    for pkg in "${packages[@]}"; do
        if ! yay -Qi "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_info "Installing AUR: ${to_install[*]}"
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
    )

    # Desktop-specific directories
    if [[ "$INSTALL_MODE" == "desktop" ]]; then
        dirs+=(
            "$HOME/Pictures/Screenshots"
            "$HOME/Pictures/wallpapers"
        )
    fi

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
    done

    log_success "Directories created"
}

# Backup existing configs
backup_existing() {
    local stow_packages=("$@")
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    local needs_backup=false

    for pkg in "${stow_packages[@]}"; do
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

        # Common backups
        [[ -d "$HOME/.config/nvim" ]] && cp -r "$HOME/.config/nvim" "$backup_dir/" 2>/dev/null || true
        [[ -f "$HOME/.bashrc" ]] && cp "$HOME/.bashrc" "$backup_dir/" 2>/dev/null || true
        [[ -f "$HOME/.tmux.conf" ]] && cp "$HOME/.tmux.conf" "$backup_dir/" 2>/dev/null || true

        # Desktop-specific backups
        if [[ "$INSTALL_MODE" == "desktop" ]]; then
            [[ -d "$HOME/.config/hypr" ]] && cp -r "$HOME/.config/hypr" "$backup_dir/" 2>/dev/null || true
            [[ -d "$HOME/.config/waybar" ]] && cp -r "$HOME/.config/waybar" "$backup_dir/" 2>/dev/null || true
            [[ -d "$HOME/.config/rofi" ]] && cp -r "$HOME/.config/rofi" "$backup_dir/" 2>/dev/null || true
        fi

        log_success "Backup created"
    fi
}

# Run stow for specified packages
run_stow() {
    local packages=("$@")

    log_info "Running stow..."
    cd "$DOTFILES_DIR"

    for pkg in "${packages[@]}"; do
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

    if [[ "$INSTALL_MODE" == "desktop" ]]; then
        chmod +x "$HOME/.config/rofi/"*.sh 2>/dev/null || true
        chmod +x "$HOME/.config/rofi/applets/bin/"*.sh 2>/dev/null || true
    fi

    log_success "Scripts made executable"
}

# Desktop-specific post-install
setup_desktop() {
    log_info "Running desktop post-install..."

    # Rebuild font cache
    log_info "Rebuilding font cache..."
    fc-cache -fv >/dev/null 2>&1
    log_success "Font cache rebuilt"

    # Enable arch-update timer
    if command_exists arch-update; then
        log_info "Enabling arch-update timer..."
        systemctl --user enable --now arch-update.timer 2>/dev/null || true
        log_success "arch-update timer enabled"
    fi

    # Set GTK icon theme
    if command_exists gsettings; then
        log_info "Setting GTK icon theme..."
        gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
        log_success "GTK icon theme set"
    fi
}

# =============================================================================
# Installation Modes
# =============================================================================

install_desktop() {
    log_info "Installing desktop environment..."
    echo ""

    local stow_packages=("gui" "editor" "shell" "bins")
    local all_packages=("${BASE_PACKAGES[@]}" "${DESKTOP_PACKAGES[@]}")

    install_yay
    install_pacman_packages "${all_packages[@]}"

    if [[ ${#DESKTOP_AUR_PACKAGES[@]} -gt 0 ]]; then
        install_aur_packages "${DESKTOP_AUR_PACKAGES[@]}"
    fi

    setup_directories
    backup_existing "${stow_packages[@]}"
    setup_tmux
    run_stow "${stow_packages[@]}"
    make_executable
    setup_desktop
}

install_server() {
    log_info "Installing server environment..."
    echo ""

    local stow_packages=("editor" "shell" "bins")

    install_yay
    install_pacman_packages "${BASE_PACKAGES[@]}"

    if [[ ${#SERVER_AUR_PACKAGES[@]} -gt 0 ]]; then
        install_aur_packages "${SERVER_AUR_PACKAGES[@]}"
    fi

    setup_directories
    backup_existing "${stow_packages[@]}"
    setup_tmux
    run_stow "${stow_packages[@]}"
    make_executable
}

# =============================================================================
# Output Functions
# =============================================================================

print_desktop_summary() {
    echo ""
    echo "============================================"
    echo -e "${GREEN}Desktop Installation Complete!${NC}"
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

print_server_summary() {
    echo ""
    echo "============================================"
    echo -e "${GREEN}Server Installation Complete!${NC}"
    echo "============================================"
    echo ""
    echo "Installed:"
    echo "  - Shell utilities (fzf, ripgrep, fd, jq)"
    echo "  - Neovim editor"
    echo "  - Tmux (run 'prefix + I' to install plugins)"
    echo ""
    echo "Log file: $LOG_FILE"
    echo ""
}

print_help() {
    cat <<EOF
Dotfiles Installation Script

Usage: $0 <MODE> [OPTIONS]

${CYAN}Modes (required):${NC}
  --desktop        Full desktop installation (Hyprland, fonts, GUI apps)
  --server         Minimal server installation (shell tools, editor, tmux)

${CYAN}Options:${NC}
  --skip-packages  Skip package installation (stow only)
  --update         Update stow links only (no packages, no backup)
  --help, -h       Show this help message

${CYAN}Examples:${NC}
  $0 --desktop              Full desktop setup
  $0 --server               Server setup
  $0 --desktop --update     Re-stow desktop configs only
  $0 --server --update      Re-stow server configs only

${CYAN}Desktop includes:${NC}
  Hyprland, Waybar, Rofi, Dunst, Alacritty, Ghostty
  Fonts (Meslo, JetBrains, Iosevka, Font Awesome, Emoji)
  Papirus icons, Firefox, Thunar, arch-update

${CYAN}Server includes:${NC}
  Git, Neovim, Tmux, fzf, ripgrep, fd, jq
EOF
}

# =============================================================================
# Main
# =============================================================================

main() {
    local skip_packages=false
    local update_only=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --desktop)
                INSTALL_MODE="desktop"
                ;;
            --server)
                INSTALL_MODE="server"
                ;;
            --skip-packages)
                skip_packages=true
                ;;
            --update)
                update_only=true
                ;;
            --help|-h)
                print_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo ""
                print_help
                exit 1
                ;;
        esac
        shift
    done

    # Require mode
    if [[ -z "$INSTALL_MODE" ]]; then
        log_error "Installation mode required. Use --desktop or --server"
        echo ""
        print_help
        exit 1
    fi

    # Header
    echo "============================================"
    echo -e "Dotfiles Installation Script ${CYAN}[$INSTALL_MODE]${NC}"
    echo "============================================"
    echo ""

    # Initialize log
    echo "Installation started at $(date) [mode: $INSTALL_MODE]" > "$LOG_FILE"

    check_arch

    # Determine stow packages based on mode
    local stow_packages
    if [[ "$INSTALL_MODE" == "desktop" ]]; then
        stow_packages=("gui" "editor" "shell" "bins")
    else
        stow_packages=("editor" "shell" "bins")
    fi

    # Handle update-only mode
    if $update_only; then
        run_stow "${stow_packages[@]}"
        make_executable
        log_success "Stow links updated!"
        exit 0
    fi

    # Handle skip-packages mode
    if $skip_packages; then
        setup_directories
        backup_existing "${stow_packages[@]}"
        setup_tmux
        run_stow "${stow_packages[@]}"
        make_executable

        if [[ "$INSTALL_MODE" == "desktop" ]]; then
            print_desktop_summary
        else
            print_server_summary
        fi

        log_success "Done!"
        exit 0
    fi

    # Full installation
    if [[ "$INSTALL_MODE" == "desktop" ]]; then
        install_desktop
        print_desktop_summary
    else
        install_server
        print_server_summary
    fi

    log_success "Done!"
}

main "$@"
