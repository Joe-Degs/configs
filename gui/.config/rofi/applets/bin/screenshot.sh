#!/usr/bin/env bash

#
# Wayland Screenshot & Recording Tool
# Dependencies: rofi, grim, slurp, wl-clipboard, wf-recorder, jq, libnotify
#

set -euo pipefail

# Configuration
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
RECORDING_PID_FILE="/tmp/screen-record.pid"
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)

# Source rofi theme (modify path as needed)
ROFI_THEME="$HOME/.config/rofi/applets/shared/theme.bash"
ROFI_CONFIG="$HOME/.config/rofi/applets/config.rasi"

# Ensure dependencies are installed
declare -a DEPS=("rofi" "grim" "slurp" "wl-copy" "wf-recorder" "jq" "notify-send")

check_deps() {
    local missing_deps=()
    for dep in "${DEPS[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        notify-send -u critical "Missing Dependencies" \
            "Please install: ${missing_deps[*]}"
        exit 1
    fi
}

# Directory setup
setup_dirs() {
    if [[ ! -d "$SCREENSHOT_DIR" ]]; then
        mkdir -p "$SCREENSHOT_DIR"
    fi
}

# Notification handling
notify() {
    local title="$1"
    local message="$2"
    local urgency="${3:-low}"
    notify-send -u "$urgency" "$title" "$message"
}

# Clipboard handling
copy_to_clipboard() {
    local file="$1"
    local mime_type
    
    case "${file,,}" in
        *.png)  mime_type="image/png" ;;
        *.jpg|*.jpeg) mime_type="image/jpeg" ;;
        *.mp4)  mime_type="video/mp4" ;;
        *)      mime_type="application/octet-stream" ;;
    esac
    
    wl-copy --type "$mime_type" < "$file"
    notify "Clipboard" "Content copied to clipboard"
}

# Recording state management
is_recording() {
    [ -f "$RECORDING_PID_FILE" ] && kill -0 "$(cat "$RECORDING_PID_FILE")" 2>/dev/null
}

# Screenshot functions
take_screenshot() {
    local output="$SCREENSHOT_DIR/Screenshot_${TIMESTAMP}.png"
    grim - | tee "$output" | wl-copy --type image/png
    notify "Screenshot" "Full screen captured"
    return 0
}

take_area_screenshot() {
    local output="$SCREENSHOT_DIR/Screenshot_${TIMESTAMP}.png"
    slurp | grim -g - - | tee "$output" | wl-copy --type image/png
    if [ -f "$output" ]; then
        notify "Screenshot" "Area captured"
        return 0
    fi
    return 1
}

take_window_screenshot() {
    local output="$SCREENSHOT_DIR/Screenshot_${TIMESTAMP}.png"
    local geometry
    
    geometry=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    if [ -n "$geometry" ]; then
        grim -g "$geometry" - | tee "$output" | wl-copy --type image/png
        notify "Screenshot" "Window captured"
        return 0
    fi
    notify "Error" "No active window found" "critical"
    return 1
}

take_delayed_screenshot() {
    local delay="$1"
    local output="$SCREENSHOT_DIR/Screenshot_${TIMESTAMP}.png"
    
    for ((i=delay; i>0; i--)); do
        notify "Screenshot" "Taking shot in $i seconds"
        sleep 1
    done
    
    grim - | tee "$output" | wl-copy --type image/png
    notify "Screenshot" "Delayed capture complete"
}

# Screen recording functions
start_recording() {
    if is_recording; then
        notify "Recording" "Already recording!" "critical"
        return 1
    fi
    
    local output="$SCREENSHOT_DIR/Recording_${TIMESTAMP}.mp4"
    wf-recorder -f "$output" &
    echo $! > "$RECORDING_PID_FILE"
    notify "Recording" "Screen recording started\nUse Stop Recording to finish"
}

start_area_recording() {
    if is_recording; then
        notify "Recording" "Already recording!" "critical"
        return 1
    fi
    
    local output="$SCREENSHOT_DIR/Recording_${TIMESTAMP}.mp4"
    local geometry
    
    notify "Recording" "Select area to record"
    geometry=$(slurp)
    if [ -n "$geometry" ]; then
        wf-recorder -g "$geometry" -f "$output" &
        echo $! > "$RECORDING_PID_FILE"
        notify "Recording" "Area recording started\nUse Stop Recording to finish"
    else
        notify "Recording" "Cancelled - no area selected"
        return 1
    fi
}

stop_recording() {
    if ! is_recording; then
        notify "Recording" "No active recording found"
        return 1
    fi
    
    local pid
    pid=$(cat "$RECORDING_PID_FILE")
    kill -SIGINT "$pid" 2>/dev/null
    rm -f "$RECORDING_PID_FILE"
    notify "Recording" "Recording stopped and saved"
    
    # Copy last recording to clipboard
    local latest
    latest=$(find "$SCREENSHOT_DIR" -name "Recording_*.mp4" -type f -print0 | xargs -0 ls -t | head -n1)
    if [ -n "$latest" ]; then
        copy_to_clipboard "$latest"
    fi
}

# Rofi menu handling
get_icon_theme() {
    if [ -f "$ROFI_THEME" ]; then
        source "$ROFI_THEME"
    fi
    
    # Default to NO if theme file not found
    echo "${ROFI_ICON_THEME:-NO}"
}

setup_menu_options() {
    local icon_theme
    icon_theme=$(get_icon_theme)
    
    if [[ "$icon_theme" == "NO" ]]; then
        OPTIONS=(
            "󰹑  Capture Desktop"
            "󰆞  Capture Area"
            "󰖲  Capture Window"
            "󰔝  Capture in 5s"
            "󰔜  Capture in 10s"
            "󰻃  Record Screen"
            "󰻃  Record Area"
            "⏹  Stop Recording"
        )
    else
        OPTIONS=(
            "󰹑"
            "󰆞"
            "󰖲"
            "󰔝"
            "󰔜"
            "󰻃"
            "󰻃"
            "⏹"
        )
    fi
}

show_rofi_menu() {
    local recording_status
    if is_recording; then
        recording_status="⚠️ Recording in progress"
    else
        recording_status="DIR: $SCREENSHOT_DIR"
    fi
    
    printf '%s\n' "${OPTIONS[@]}" | rofi \
        -theme-str "window {width: 400px;}" \
        -theme-str "listview {columns: 1; lines: 8;}" \
        -theme-str 'textbox-prompt-colon {str: "";}'  \
        -dmenu \
        -p "📸 Screen Capture" \
        -mesg "$recording_status" \
        -markup-rows \
        -theme "$ROFI_CONFIG"
}

close_rofi() {
    if pgrep -x "rofi" > /dev/null; then
        pkill rofi
        sleep 0.2  # Small delay to ensure rofi is closed
    fi
}

# Main command execution
execute_command() {
    close_rofi
    
    case "$1" in
        *"Capture Desktop"*|"󰹑")
            take_screenshot ;;
        *"Capture Area"*|"󰆞")
            take_area_screenshot ;;
        *"Capture Window"*|"󰖲")
            take_window_screenshot ;;
        *"Capture in 5s"*|"󰔝")
            take_delayed_screenshot 5 ;;
        *"Capture in 10s"*|"󰔜")
            take_delayed_screenshot 10 ;;
        *"Record Screen"*|"󰻃")
            start_recording ;;
        *"Record Area"*)
            start_area_recording ;;
        *"Stop Recording"*|"⏹")
            stop_recording ;;
        *)
            notify "Error" "Invalid option selected" "critical"
            return 1 ;;
    esac
}

# Print usage information
print_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTION]
Screenshot and recording utility for Hyprland/Wayland

Options:
    -h, --help              Show this help message
    --fullscreen           Take a full screen screenshot
    --area                 Take an area screenshot
    --window              Take active window screenshot
    --delay-5             Take screenshot with 5s delay
    --delay-10            Take screenshot with 10s delay
    --record-screen       Start full screen recording
    --record-area         Start area recording
    --stop-recording      Stop current recording
    
Without options, launches the interactive rofi menu.
EOF
}

# Parse command line arguments
parse_args() {
    case "$1" in
        -h|--help)
            print_usage
            exit 0
            ;;
        --fullscreen)
            take_screenshot
            ;;
        --area)
            take_area_screenshot
            ;;
        --window)
            take_window_screenshot
            ;;
        --delay-5)
            take_delayed_screenshot 5
            ;;
        --delay-10)
            take_delayed_screenshot 10
            ;;
        --record-screen)
            start_recording
            ;;
        --record-area)
            start_area_recording
            ;;
        --stop-recording)
            stop_recording
            ;;
        "")
            # No arguments - launch interactive menu
            return 0
            ;;
        *)
            echo "Error: Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
    exit 0
}

# Main function
main() {
    check_deps
    setup_dirs
    
    # Handle command line arguments if present
    if [ $# -gt 0 ]; then
        parse_args "$1"
        exit $?
    fi
    
    # Otherwise, show interactive menu
    setup_menu_options
    local choice
    choice=$(show_rofi_menu)
    
    if [ -n "$choice" ]; then
        execute_command "$choice"
    fi
}

# Run main function with all arguments
main "$@"