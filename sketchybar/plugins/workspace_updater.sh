if [ -z "$CONFIG_DIR" ]; then
    CONFIG_DIR="$HOME/.config/sketchybar"
fi

source "$CONFIG_DIR/helpers/constants.sh"

animate_workspace_highlight() {
    local workspace_id="$1"
    local is_active="$2"

    if [ "$ENABLE_WORKSPACE_ANIMATIONS" != "true" ]; then
        return
    fi

    if [ "$is_active" = "true" ]; then

        sketchybar --animate elastic $ANIMATION_DURATION_NORMAL \
                   --set workspace.$workspace_id \
                         icon.highlight=on \
                         label.highlight=on \
                         background.border_color=$WORKSPACE_ITEM_BORDER_HIGHLIGHT_COLOR
    else

        sketchybar --animate tanh $ANIMATION_DURATION_FAST \
                   --set workspace.$workspace_id \
                         icon.highlight=off \
                         label.highlight=off \
                         background.border_color=$WORKSPACE_ITEM_BORDER_COLOR
    fi
}

animate_app_icons() {
    local workspace_id="$1"
    local icon_strip="$2"


    local workspace_numeral=""
    case $workspace_id in
        1) workspace_numeral="I" ;;
        2) workspace_numeral="II" ;;
        3) workspace_numeral="III" ;;
        4) workspace_numeral="IV" ;;
        5) workspace_numeral="V" ;;
        6) workspace_numeral="VI" ;;
        7) workspace_numeral="VII" ;;
        8) workspace_numeral="VIII" ;;
        9) workspace_numeral="IX" ;;
        *) workspace_numeral="$workspace_id" ;;
    esac

    if [ "$ENABLE_WORKSPACE_ANIMATIONS" != "true" ]; then
        sketchybar --set workspace.$workspace_id \
                           icon="$workspace_numeral $icon_strip" \
                           icon.font="sketchybar-app-font:Regular:14.0" \
                           icon.padding_right=10 \
                           drawing=on
        return
    fi


    sketchybar --animate tanh $ANIMATION_DURATION_FAST \
               --set workspace.$workspace_id \
                     icon="$workspace_numeral $icon_strip" \
                     icon.font="sketchybar-app-font:Regular:14.0" \
                     icon.padding_right=10
}

animate_workspace_visibility() {
    local workspace_id="$1"
    local should_show="$2"

    if [ "$ENABLE_WORKSPACE_ANIMATIONS" != "true" ]; then
        if [ "$should_show" = "true" ]; then
            sketchybar --set workspace.$workspace_id drawing=on
        else
            sketchybar --set workspace.$workspace_id drawing=off
        fi
        return
    fi

    if [ "$should_show" = "true" ]; then

        sketchybar --set workspace.$workspace_id drawing=on
        sketchybar --animate sin $ANIMATION_DURATION_NORMAL \
                   --set workspace.$workspace_id \
                         icon.color=$WORKSPACE_ICON_COLOR \
                         label.color=$WORKSPACE_LABEL_COLOR
    else
        sketchybar --animate sin $ANIMATION_DURATION_FAST \
                   --set workspace.$workspace_id drawing=off
    fi
}


animate_workspace_transition() {
    local old_workspace="$1"
    local new_workspace="$2"

    if [ "$ENABLE_WORKSPACE_ANIMATIONS" != "true" ]; then
        return
    fi


    sketchybar --animate sin $ANIMATION_DURATION_FAST \
               --set workspace_separator icon.color=0xff88c0d0


    (sleep 0.3 && sketchybar --animate sin $ANIMATION_DURATION_SLOW \
                            --set workspace_separator icon.color=0xff4c566a) &
}

update_workspaces() {

    get_current_workspace_with_retry() {
        local max_attempts=5
        local attempt=1
        local workspace=""

        while [ $attempt -le $max_attempts ]; do
            workspace=$(aerospace list-workspaces --focused 2>/dev/null)


            if [ -n "$workspace" ] && [ "$workspace" != "" ]; then
                local all_workspaces=$(aerospace list-workspaces --all 2>/dev/null)
                if echo "$all_workspaces" | grep -q "^$workspace$"; then
                    echo "$workspace"
                    return 0
                fi
            fi


            sleep 0.05
            attempt=$((attempt + 1))
        done


        echo "$workspace"
        return 1
    }


    CURRENT_WORKSPACE=$(get_current_workspace_with_retry)


    ALL_WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null)


    if [ -z "$ALL_WORKSPACES" ]; then
        return
    fi


    for i in {1..9}; do

        if echo "$ALL_WORKSPACES" | grep -q "^$i$"; then
            WORKSPACE_EXISTS=true
        else
            WORKSPACE_EXISTS=false
        fi

        
        if [ "$WORKSPACE_EXISTS" = "true" ]; then
            
            APPS=$(aerospace list-windows --workspace $i 2>/dev/null | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
        else
            APPS=""
        fi

        
        ICON_STRIP=""
        if [ -n "$APPS" ] && [ "$APPS" != "" ]; then

            while IFS= read -r app; do
                if [ -n "$app" ]; then
                    ICON_STRIP+=" $($CONFIG_DIR/helpers/icon_map_fn.sh "$app")"
                fi
            done <<< "$APPS"
            SHOW_WORKSPACE=true
        else

            ICON_STRIP=" —"

            if [ "$i" = "1" ]; then
                SHOW_WORKSPACE=true
            else
                SHOW_WORKSPACE=false
            fi
        fi

        if [ "$i" = "$CURRENT_WORKSPACE" ]; then
            HIGHLIGHT="on"
            BORDER_COLOR=$WORKSPACE_ITEM_BORDER_HIGHLIGHT_COLOR
        else
            HIGHLIGHT="off"
            BORDER_COLOR=$WORKSPACE_ITEM_BORDER_COLOR
        fi

        if [ "$SHOW_WORKSPACE" = "true" ]; then
            DRAWING="on"
        else
            DRAWING="off"
        fi



        animate_app_icons "$i" "$ICON_STRIP"


        if [ "$i" = "$CURRENT_WORKSPACE" ]; then
            animate_workspace_highlight "$i" "true"
        else
            animate_workspace_highlight "$i" "false"
        fi


        animate_workspace_visibility "$i" "$SHOW_WORKSPACE"
    done


    if [ -n "$CURRENT_WORKSPACE" ] && [ "$CURRENT_WORKSPACE" != "${LAST_WORKSPACE:-}" ]; then
        animate_workspace_transition "${LAST_WORKSPACE:-}" "$CURRENT_WORKSPACE"
        export LAST_WORKSPACE="$CURRENT_WORKSPACE"
    fi
}

case "$SENDER" in
    "aerospace_workspace_change"|"aerospace_window_change")
        
        sleep 0.1
        update_workspaces
        ;;
    "forced")

        update_workspaces
        ;;
    "disable_animations")

        export ENABLE_WORKSPACE_ANIMATIONS="false"
        update_workspaces
        ;;
    *)
        
        sleep 0.05
        update_workspaces
        ;;
esac

