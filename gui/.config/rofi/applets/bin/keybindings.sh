#!/usr/bin/env bash

#
# Rofi Keybindings Menu
# Displays all Hyprland keyboard shortcuts in a searchable menu
#

set -euo pipefail

# Configuration
KEYBINDINGS_FILE="$HOME/.config/rofi/applets/data/keybindings.txt"
ROFI_CONFIG="$HOME/.config/rofi/applets/config.rasi"

# Check dependencies
check_deps() {
    if ! command -v rofi &>/dev/null; then
        notify-send -u critical "Error" "rofi is not installed"
        exit 1
    fi
}

# Show keybindings in rofi menu
show_menu() {
    if [[ ! -f "$KEYBINDINGS_FILE" ]]; then
        notify-send -u critical "Error" "Keybindings file not found: $KEYBINDINGS_FILE"
        exit 1
    fi

    # Display keybindings (filter empty lines, keep section headers)
    grep -v '^$' "$KEYBINDINGS_FILE" | rofi \
        -theme-str "window {width: 650px;}" \
        -theme-str "listview {columns: 1; lines: 25; scrollbar: true;}" \
        -theme-str 'textbox-prompt-colon {str: "󰌌";}' \
        -theme-str 'element {padding: 6px 12px;}' \
        -theme-str 'element-text {font: "monospace 10";}' \
        -dmenu \
        -i \
        -p "Keybindings" \
        -mesg "Type to search | Esc to close" \
        -theme "$ROFI_CONFIG"
}

# Main
main() {
    check_deps
    show_menu
}

main "$@"
