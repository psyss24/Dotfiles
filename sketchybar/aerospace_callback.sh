#!/bin/bash

if [ -z "$CONFIG_DIR" ]; then
    export CONFIG_DIR="$HOME/.config/sketchybar"
fi

source "$CONFIG_DIR/helpers/constants.sh"

log_callback() {
    if [ "$DEBUG_AEROSPACE_CALLBACKS" = "true" ]; then
        echo "[$(date '+%H:%M:%S.%3N')] $1" >> /tmp/sketchybar_aerospace_callback.log
    fi
}

get_workspace_with_retry() {
    local max_attempts=8
    local attempt=1
    local workspace=""
    local delay=0.02

    while [ $attempt -le $max_attempts ]; do
        workspace=$(aerospace list-workspaces --focused 2>/dev/null)

        if [ -n "$workspace" ] && [ "$workspace" != "" ] && [ "$workspace" -ge 1 ] && [ "$workspace" -le 9 ]; then
            local all_workspaces=$(aerospace list-workspaces --all 2>/dev/null)
            if echo "$all_workspaces" | grep -q "^$workspace$"; then
                log_callback "Successfully detected workspace $workspace on attempt $attempt"
                echo "$workspace"
                return 0
            fi
        fi

        sleep $delay
        delay=$(echo "$delay * 1.3" | bc 2>/dev/null || echo "0.05")
        attempt=$((attempt + 1))
    done

    log_callback "Failed to detect workspace after $max_attempts attempts"
    echo ""
    return 1
}

update_workspace_immediate() {
    log_callback "Aerospace callback triggered"

    local current_workspace=$(get_workspace_with_retry)

    if [ -z "$current_workspace" ]; then
        log_callback "No workspace detected, falling back to event trigger"
        sketchybar --trigger aerospace_workspace_change
        return 1
    fi

    log_callback "Updating for workspace $current_workspace"

    local all_workspaces=$(aerospace list-workspaces --all 2>/dev/null)

    if [ -z "$all_workspaces" ]; then
        log_callback "No workspaces list available"
        return 1
    fi

    for i in {1..9}; do
        local workspace_exists=false
        if echo "$all_workspaces" | grep -q "^$i$"; then
            workspace_exists=true
        fi

        local apps=""
        local icon_strip=""
        local show_workspace=false

        if [ "$workspace_exists" = true ]; then
            apps=$(aerospace list-windows --workspace $i 2>/dev/null | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}' | grep -v "^$")

            if [ -n "$apps" ]; then
                while IFS= read -r app; do
                    if [ -n "$app" ]; then
                        icon_strip+=" $($CONFIG_DIR/helpers/icon_map_fn.sh "$app")"
                    fi
                done <<< "$apps"
                show_workspace=true
            else
                icon_strip=" —"
                if [ "$i" = "1" ]; then
                    show_workspace=true
                else
                    show_workspace=false
                fi
            fi
        else
            icon_strip=" —"
            show_workspace=false
        fi

        local is_active=false
        if [ "$i" = "$current_workspace" ]; then
            is_active=true
        fi

        if [ "$ENABLE_WORKSPACE_ANIMATIONS" = "true" ]; then
            if [ "$is_active" = true ]; then
                sketchybar --animate elastic $ANIMATION_DURATION_NORMAL \
                           --set workspace.$i \
                                 icon.highlight=on \
                                 label.highlight=on \
                                 label="$icon_strip" \
                                 background.border_color=0xff5E81AC \
                                 drawing=$([ "$show_workspace" = true ] && echo "on" || echo "off")
            else
                sketchybar --animate tanh $ANIMATION_DURATION_FAST \
                           --set workspace.$i \
                                 icon.highlight=off \
                                 label.highlight=off \
                                 label="$icon_strip" \
                                 background.border_color=0xff434C5E \
                                 drawing=$([ "$show_workspace" = true ] && echo "on" || echo "off")
            fi
        else
            sketchybar --set workspace.$i \
                             icon.highlight=$([ "$is_active" = true ] && echo "on" || echo "off") \
                             label.highlight=$([ "$is_active" = true ] && echo "on" || echo "off") \
                             label="$icon_strip" \
                             background.border_color=$([ "$is_active" = true ] && echo "0xff5E81AC" || echo "0xff434C5E") \
                             drawing=$([ "$show_workspace" = true ] && echo "on" || echo "off")
        fi
    done

    if [ "$ENABLE_WORKSPACE_ANIMATIONS" = "true" ]; then
        sketchybar --animate sin $ANIMATION_DURATION_FAST \
                   --set workspace_separator icon.color=0xff88c0d0

        (sleep 0.3 && sketchybar --animate sin $ANIMATION_DURATION_SLOW \
                                --set workspace_separator icon.color=0xff4c566a) &
    fi

    log_callback "Workspace update completed for workspace $current_workspace"
    return 0
}

trigger_fallback_update() {
    log_callback "Triggering fallback event update"
    sketchybar --trigger aerospace_workspace_change
}

main() {
    if ! update_workspace_immediate; then
        trigger_fallback_update
    fi

    (sleep 0.1 && trigger_fallback_update) &
}

main "$@"
