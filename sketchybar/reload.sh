
killall sketchybar 2>/dev/null
sleep 1


aerospace reload-config 2>/dev/null


sketchybar --config ~/.config/sketchybar/sketchybarrc &


sleep 2


if pgrep -x "sketchybar" >/dev/null; then

    ~/.config/sketchybar/plugins/workspace_updater.sh 2>/dev/null &

    if grep -q 'ENABLE_WORKSPACE_ANIMATIONS="true"' ~/.config/sketchybar/helpers/constants.sh 2>/dev/null; then
    fi
else
    echo " failed to start"
fi
