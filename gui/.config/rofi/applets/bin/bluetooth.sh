#!/bin/bash

# Load shared theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$HOME/.config/rofi/applets/config.rasi"

# Theme Elements
prompt='Bluetooth'
mesg="Control bluetooth devices and connections"

# Layout
list_col='1'
list_row='5'
win_width='400px'

# Get theme layout
layout=""

# Icons
BLUETOOTH_ON="󰂯"
BLUETOOTH_OFF="󰂲"
BLUETOOTH_CONNECTED="󰂱"
BLUETOOTH_PAIRED="󰂰"
SETTINGS_ICON="󰒓"
SCAN_ICON="󰜎"

# Rofi CMD
rofi_cmd() {
    rofi -theme-str "window {width: $win_width;}" \
        -theme-str "listview {columns: $list_col; lines: $list_row;}" \
        -theme-str 'textbox-prompt-colon {str: "";}' \
        -dmenu \
        -p "$prompt" \
        -mesg "$mesg" \
        -markup-rows \
        -theme ${theme} \
        ${1}
}

# Format device display
format_device() {
    if [ "$layout" == 'NO' ]; then
        echo " $1"
    else
        local mac="$2"
        local icon="$BLUETOOTH_OFF"
        
        if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
            icon="$BLUETOOTH_CONNECTED"
        elif bluetoothctl info "$mac" | grep -q "Paired: yes"; then
            icon="$BLUETOOTH_PAIRED"
        fi
        
        echo "$icon $1"
    fi
}

# Get lists of devices
get_quick_devices() {
    local devices=""
    while IFS= read -r line; do
        if [ ! -z "$line" ]; then
            local mac=$(echo "$line" | cut -d ' ' -f 2)
            local name=$(echo "$line" | cut -d ' ' -f 3-)
            if bluetoothctl info "$mac" | grep -q "Paired: yes"; then
                devices="$devices$(format_device "$name" "$mac")\n"
            fi
        fi
    done < <(bluetoothctl devices)
    echo -e "$devices"
}

# Device action menu
show_device_menu() {
    local device_name="$1"
    local mac="$2"
    local connected=false
    local trusted=false
    
    # Get device status
    if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        connected=true
    fi
    if bluetoothctl info "$mac" | grep -q "Trusted: yes"; then
        trusted=true
    fi
    
    # Set options based on current state
    if [ "$layout" == 'NO' ]; then
        [ "$connected" = true ] && connect_opt=" Disconnect" || connect_opt=" Connect"
        [ "$trusted" = true ] && trust_opt=" Untrust" || trust_opt=" Trust"
        remove_opt=" Remove Device"
    else
        [ "$connected" = true ] && connect_opt="$BLUETOOTH_CONNECTED Disconnect" || connect_opt="$BLUETOOTH_OFF Connect"
        [ "$trusted" = true ] && trust_opt="$SETTINGS_ICON Untrust" || trust_opt="$SETTINGS_ICON Trust"
        remove_opt="$BLUETOOTH_OFF Remove Device"
    fi
    
    # Show device menu
    local chosen=$(echo -e "$connect_opt\n$trust_opt\n$remove_opt\nBack" | \
        rofi_cmd "-mesg \"$device_name\"")
    
    case "$chosen" in
        *"Connect")
            bluetoothctl connect "$mac"
            sleep 1
            show_device_menu "$device_name" "$mac"
            ;;
        *"Disconnect")
            bluetoothctl disconnect "$mac"
            sleep 1
            show_device_menu "$device_name" "$mac"
            ;;
        *"Trust")
            bluetoothctl trust "$mac"
            show_device_menu "$device_name" "$mac"
            ;;
        *"Untrust")
            bluetoothctl untrust "$mac"
            show_device_menu "$device_name" "$mac"
            ;;
        *"Remove"*)
            bluetoothctl remove "$mac"
            get_options
            chosen="$(run_rofi)"
            handle_action "${chosen}"
            ;;
        "Back")
            get_options
            chosen="$(run_rofi)"
            handle_action "${chosen}"
            ;;
    esac
}

# Get main menu options
get_options() {
    if [ "$layout" == 'NO' ]; then
        option_1=" Toggle Bluetooth"
        option_2=" Quick Connect"
        option_3=" Open Manager"
        option_4=" Settings"
    else
        if bluetoothctl show | grep -q "Powered: yes"; then
            option_1="$BLUETOOTH_ON Toggle Bluetooth"
        else
            option_1="$BLUETOOTH_OFF Toggle Bluetooth"
        fi
        
        option_2="$BLUETOOTH_CONNECTED Quick Connect"
        option_3="$SCAN_ICON Open Manager"
        option_4="$SETTINGS_ICON Settings"
    fi
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$option_1\n$option_2\n$option_3\n$option_4" | rofi_cmd
}

# Settings menu
show_settings() {
    if [ "$layout" == 'NO' ]; then
        option_1=" Discoverable: $(bluetoothctl show | grep -q "Discoverable: yes" && echo "on" || echo "off")"
        option_2=" Pairable: $(bluetoothctl show | grep -q "Pairable: yes" && echo "on" || echo "off")"
    else
        option_1="$SETTINGS_ICON Discoverable: $(bluetoothctl show | grep -q "Discoverable: yes" && echo "on" || echo "off")"
        option_2="$SETTINGS_ICON Pairable: $(bluetoothctl show | grep -q "Pairable: yes" && echo "on" || echo "off")"
    fi
    
    local chosen=$(echo -e "$option_1\n$option_2\nBack" | rofi_cmd)
    
    case "$chosen" in
        *"Discoverable"*)
            bluetoothctl show | grep -q "Discoverable: yes" && \
                bluetoothctl discoverable off || bluetoothctl discoverable on
            show_settings
            ;;
        *"Pairable"*)
            bluetoothctl show | grep -q "Pairable: yes" && \
                bluetoothctl pairable off || bluetoothctl pairable on
            show_settings
            ;;
        "Back")
            get_options
            chosen="$(run_rofi)"
            handle_action "${chosen}"
            ;;
    esac
}

# Handle main menu actions
handle_action() {
    case "$1" in
        *"Toggle Bluetooth"*)
            if bluetoothctl show | grep -q "Powered: yes"; then
                bluetoothctl power off
            else
                if rfkill list bluetooth | grep -q 'blocked: yes'; then
                    rfkill unblock bluetooth && sleep 3
                fi
                bluetoothctl power on
            fi
            get_options
            chosen="$(run_rofi)"
            handle_action "${chosen}"
            ;;
        *"Quick Connect"*)
            local devices="$(get_quick_devices)"
            if [ -z "$devices" ]; then
                mesg="No paired devices. Use Bluetooth Manager to pair new devices."
                get_options
                chosen="$(run_rofi)"
                handle_action "${chosen}"
                return
            fi
            
            local chosen=$(echo -e "${devices}Back\n" | rofi_cmd)
            if [[ "$chosen" == "Back" ]]; then
                get_options
                chosen="$(run_rofi)"
                handle_action "${chosen}"
            elif [ ! -z "$chosen" ]; then
                local name=$(echo "$chosen" | sed 's/^[^ ]* //')
                local mac=$(bluetoothctl devices | grep "$name" | cut -d ' ' -f 2)
                show_device_menu "$name" "$mac"
            fi
            ;;
        *"Open Manager"*)
            blueman-manager &
            exit 0
            ;;
        *"Settings"*)
            show_settings
            ;;
        *)
            exit 0
            ;;
    esac
}

# Main execution
get_options
chosen="$(run_rofi)"
handle_action "${chosen}"