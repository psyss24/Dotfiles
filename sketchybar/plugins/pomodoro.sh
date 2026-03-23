#!/bin/bash

if [ -z "$CONFIG_DIR" ]; then
    CONFIG_DIR="$HOME/.config/sketchybar"
fi

source "$CONFIG_DIR/helpers/constants.sh"

WORK_DURATION=1500
SHORT_BREAK=300
LONG_BREAK=900
POMODOROS_UNTIL_LONG=4

STATE_FILE="/tmp/sketchybar_pomodoro_state"
SOUND_ENABLED=true

POMODORO_WORK_COLOR="0xffbf616a"
POMODORO_BREAK_COLOR="0xffa3be8c"
POMODORO_LONG_BREAK_COLOR="0xff81a1c1"
POMODORO_IDLE_COLOR="0xff4c566a"
POMODORO_PAUSED_COLOR="0xffebcb8b"

ICON_IDLE="󰄉"
ICON_WORK="󰔟"
ICON_BREAK="󰒲"
ICON_PAUSED="󰏤"
ICON_COMPLETE="󰸞"

init_state() {
    if [ ! -f "$STATE_FILE" ]; then
        cat > "$STATE_FILE" << EOF
STATE=idle
REMAINING=0
SESSION_TYPE=work
POMODORO_COUNT=0
START_TIME=0
PAUSED_TIME=0
EOF
    fi
}

load_state() {
    if [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
    else
        init_state
        source "$STATE_FILE"
    fi
}

save_state() {
    cat > "$STATE_FILE" << EOF
STATE=$STATE
REMAINING=$REMAINING
SESSION_TYPE=$SESSION_TYPE
POMODORO_COUNT=$POMODORO_COUNT
START_TIME=$START_TIME
PAUSED_TIME=$PAUSED_TIME
EOF
}

format_time() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d" $minutes $secs
}

get_session_duration() {
    case "$SESSION_TYPE" in
        "work") echo $WORK_DURATION ;;
        "short_break") echo $SHORT_BREAK ;;
        "long_break") echo $LONG_BREAK ;;
        *) echo $WORK_DURATION ;;
    esac
}

get_next_session() {
    case "$SESSION_TYPE" in
        "work")
            POMODORO_COUNT=$((POMODORO_COUNT + 1))
            if [ $((POMODORO_COUNT % POMODOROS_UNTIL_LONG)) -eq 0 ]; then
                echo "long_break"
            else
                echo "short_break"
            fi
            ;;
        "short_break"|"long_break")
            echo "work"
            ;;
        *)
            echo "work"
            ;;
    esac
}

play_notification() {
    if [ "$SOUND_ENABLED" = true ]; then
        case "$1" in
            "work_complete")
                afplay /System/Library/Sounds/Glass.aiff 2>/dev/null &
                ;;
            "break_complete")
                afplay /System/Library/Sounds/Purr.aiff 2>/dev/null &
                ;;
            "session_start")
                afplay /System/Library/Sounds/Tink.aiff 2>/dev/null &
                ;;
        esac
    fi
}

send_notification() {
    local title="$1"
    local message="$2"
    osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null &
}

start_session() {
    local session_type="$1"
    SESSION_TYPE="$session_type"
    REMAINING=$(get_session_duration)
    STATE="running"
    START_TIME=$(date +%s)
    PAUSED_TIME=0

    play_notification "session_start"

    case "$session_type" in
        "work")
            send_notification "Pomodoro Timer" "Work session started! Focus for $(format_time $REMAINING)"
            ;;
        "short_break")
            send_notification "Pomodoro Timer" "Take a short break! $(format_time $REMAINING)"
            ;;
        "long_break")
            send_notification "Pomodoro Timer" "Time for a long break! $(format_time $REMAINING)"
            ;;
    esac

    save_state
}

toggle_timer() {
    case "$STATE" in
        "idle")
            start_session "work"
            ;;
        "running")
            STATE="paused"
            PAUSED_TIME=$(date +%s)
            save_state
            ;;
        "paused")
            local pause_duration=$(($(date +%s) - PAUSED_TIME))
            START_TIME=$((START_TIME + pause_duration))
            STATE="running"
            PAUSED_TIME=0
            save_state
            ;;
        "complete")
            local next_session=$(get_next_session)
            start_session "$next_session"
            ;;
    esac
}

reset_timer() {
    STATE="idle"
    REMAINING=0
    SESSION_TYPE="work"
    START_TIME=0
    PAUSED_TIME=0
    save_state
}

update_timer() {
    if [ "$STATE" = "running" ]; then
        local current_time=$(date +%s)
        local elapsed=$((current_time - START_TIME))
        local session_duration=$(get_session_duration)
        REMAINING=$((session_duration - elapsed))

        if [ $REMAINING -le 0 ]; then
            STATE="complete"
            REMAINING=0

            case "$SESSION_TYPE" in
                "work")
                    play_notification "work_complete"
                    send_notification "Pomodoro Complete!" "Great work! Time for a break."
                    ;;
                "short_break"|"long_break")
                    play_notification "break_complete"
                    send_notification "Break Complete!" "Ready to get back to work?"
                    ;;
            esac
        fi

        save_state
    fi
}

get_display_elements() {
    local icon color label border_color

    case "$STATE" in
        "idle")
            icon="$ICON_IDLE"
            color="$POMODORO_IDLE_COLOR"
            label="Ready"
            border_color="0xff434c5e"
            ;;
        "running")
            case "$SESSION_TYPE" in
                "work")
                    icon="$ICON_WORK"
                    color="$POMODORO_WORK_COLOR"
                    border_color="$POMODORO_WORK_COLOR"
                    ;;
                "short_break")
                    icon="$ICON_BREAK"
                    color="$POMODORO_BREAK_COLOR"
                    border_color="$POMODORO_BREAK_COLOR"
                    ;;
                "long_break")
                    icon="$ICON_BREAK"
                    color="$POMODORO_LONG_BREAK_COLOR"
                    border_color="$POMODORO_LONG_BREAK_COLOR"
                    ;;
            esac
            label="$(format_time $REMAINING)"
            ;;
        "paused")
            icon="$ICON_PAUSED"
            color="$POMODORO_PAUSED_COLOR"
            border_color="$POMODORO_PAUSED_COLOR"
            label="$(format_time $REMAINING)"
            ;;
        "complete")
            icon="$ICON_COMPLETE"
            case "$SESSION_TYPE" in
                "work")
                    color="$POMODORO_BREAK_COLOR"
                    border_color="$POMODORO_BREAK_COLOR"
                    label="Break?"
                    ;;
                *)
                    color="$POMODORO_WORK_COLOR"
                    border_color="$POMODORO_WORK_COLOR"
                    label="Work?"
                    ;;
            esac
            ;;
    esac

    echo "$icon|$color|$label|$border_color"
}

update_display() {
    local display_data=$(get_display_elements)
    local icon=$(echo "$display_data" | cut -d'|' -f1)
    local color=$(echo "$display_data" | cut -d'|' -f2)
    local label=$(echo "$display_data" | cut -d'|' -f3)
    local border_color=$(echo "$display_data" | cut -d'|' -f4)

    local drawing="on"

    if [ "$ENABLE_WORKSPACE_ANIMATIONS" = "true" ] && [ "$STATE" != "idle" ]; then
        sketchybar --animate tanh 8 \
                   --set pomodoro \
                         icon="$icon" \
                         icon.color="$color" \
                         label="$label" \
                         drawing="$drawing"
    else
        sketchybar --set pomodoro \
                         icon="$icon" \
                         icon.color="$color" \
                         label="$label" \
                         drawing="$drawing"
    fi
}

show_status() {
    echo "Pomodoro Timer Status:"
    echo "  State: $STATE"
    echo "  Session: $SESSION_TYPE"
    echo "  Remaining: $(format_time $REMAINING)"
    echo "  Pomodoro Count: $POMODORO_COUNT"
    if [ "$STATE" = "running" ]; then
        local session_duration=$(get_session_duration)
        local elapsed=$((session_duration - REMAINING))
        local progress=$((elapsed * 100 / session_duration))
        echo "  Progress: ${progress}%"
    fi
}

handle_action() {
    case "$1" in
        "toggle")
            toggle_timer
            ;;
        "reset")
            reset_timer
            ;;
        "status")
            show_status
            return
            ;;
        "next")
            if [ "$STATE" = "complete" ]; then
                local next_session=$(get_next_session)
                start_session "$next_session"
            fi
            ;;
        *)
            ;;
    esac
}

main() {
    init_state
    load_state

    if [ -n "$1" ]; then
        handle_action "$1"
    fi

    update_timer

    update_display
}

main "$@"
