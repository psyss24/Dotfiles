#!/bin/bash

source "$CONFIG_DIR/helpers/constants.sh"

check_dnd_status() {
    local dnd_active=false

    local cc_dnd_visible=$(defaults read ~/Library/Preferences/com.apple.controlcenter.plist "NSStatusItem Visible DoNotDisturb" 2>/dev/null)
    if [ "$cc_dnd_visible" = "1" ]; then
        dnd_active=true
    fi

    if ! $dnd_active; then
        local focus_status=$(shortcuts run "Get My Focus Status" 2>/dev/null | grep -i "on\|active\|enabled" | head -1)
        if [ -n "$focus_status" ]; then
            dnd_active=true
        fi
    fi

    if ! $dnd_active; then
        local nc_dnd=$(defaults read ~/Library/Preferences/com.apple.ncprefs.plist dndDisplaySleep 2>/dev/null)
        if [ "$nc_dnd" = "1" ]; then
            dnd_active=true
        fi
    fi

    if ! $dnd_active; then
        local menubar_check=$(osascript -e '
        tell application "System Events"
            try
                tell process "ControlCenter"
                    set menuBarItems to menu bar items of menu bar 1
                    repeat with anItem in menuBarItems
                        if description of anItem contains "Do Not Disturb" or description of anItem contains "Focus" then
                            return "1"
                        end if
                    end repeat
                    return "0"
                end tell
            on error
                return "0"
            end try
        end tell' 2>/dev/null)

        if [ "$menubar_check" = "1" ]; then
            dnd_active=true
        fi
    fi

    echo $dnd_active
}

update_dnd_widget() {
    local dnd_active=$(check_dnd_status)

    if [ "$dnd_active" = "true" ]; then
        sketchybar --set dnd \
                         drawing=on \
                         icon="󰂛" \
                         icon.color=0xffb48ead
    else
        sketchybar --set dnd drawing=off
    fi
}

handle_click() {
    case "$BUTTON" in
        "left")
            open -b com.apple.controlcenter
            ;;
        "right")
            open "x-apple.systempreferences:com.apple.preference.notifications"
            ;;
    esac
}

case "$SENDER" in
    "mouse.clicked")
        handle_click
        ;;
    *)
        update_dnd_widget
        ;;
esac
