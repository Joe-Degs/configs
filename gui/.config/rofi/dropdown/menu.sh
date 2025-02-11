#!/bin/bash

# Function to handle menu selections
handle_menu() {
    case "$1" in
        "󰎆 Terminal")
            alacritty ;;
        "󰈹 Browser")
            firefox ;;
        " Files")
            thunar ;;
        "󰒋 Editor")
            code ;;
        " Settings")
            gnome-control-center ;;
    esac
}

# If no argument is passed, show menu
if [ -z "$1" ]; then
    echo -e "󰎆 Terminal"
    echo -e "󰈹 Browser"
    echo -e " Files"
    echo -e "󰒋 Editor"
    echo -e " Settings"
else
    handle_menu "$1"
fi