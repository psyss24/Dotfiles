#!/bin/bash

if [ -z "$CONFIG_DIR" ]; then
    CONFIG_DIR="$HOME/.config/sketchybar"
fi

source "$CONFIG_DIR/helpers/constants.sh"

handle_click() {
    local button="$BUTTON"
    local modifier="$MODIFIER"

    case "$button" in
        "left")
            if [ "$modifier" = "shift" ]; then
                "$CONFIG_DIR/plugins/pomodoro.sh" "status"
            else
                "$CONFIG_DIR/plugins/pomodoro.sh" "toggle"
            fi
            ;;
        "right")
            "$CONFIG_DIR/plugins/pomodoro.sh" "reset"

            if [ "$ENABLE_WORKSPACE_ANIMATIONS" = "true" ]; then
                sketchybar --animate elastic 6 \
                           --set pomodoro icon.color=0xff88c0d0

                (sleep 0.3 && sketchybar --animate tanh 4 \
                                        --set pomodoro icon.color=0xff4c566a) &
            fi
            ;;
        "middle")
            "$CONFIG_DIR/plugins/pomodoro.sh" "next"
            ;;
        *)
            "$CONFIG_DIR/plugins/pomodoro.sh" "toggle"
            ;;
    esac
}

provide_click_feedback() {
    if [ "$ENABLE_WORKSPACE_ANIMATIONS" = "true" ]; then
        sketchybar --animate elastic 4 \
                   --set pomodoro icon.color=0xff88c0d0

        (sleep 0.2 && sketchybar --animate tanh 6 \
                                --set pomodoro icon.color=0xff4c566a) &
    fi
}

main() {
    provide_click_feedback

    handle_click

    "$CONFIG_DIR/plugins/pomodoro.sh"
}

main "$@"
