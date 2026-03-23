source "$CONFIG_DIR/helpers/constants.sh"


sketchybar --add event aerospace_workspace_change
sketchybar --add event aerospace_window_change
sketchybar --add event space_change
sketchybar --add event display_change

for i in {1..9}; do
  workspace=(
    icon="$i"
    icon.color=$WORKSPACE_ICON_COLOR
    icon.highlight_color=$WORKSPACE_ICON_HIGHLIGHT_COLOR
    icon.font="sketchybar-app-font:Regular:14.0"
    icon.padding_left=6
    icon.padding_right=4
    padding_left=2
    padding_right=2
    label.drawing=off

    background.color=0x40ffffff
    background.padding_left=2
    background.padding_right=2
    background.border_color=0x40ffffff
    background.corner_radius=12
    background.height=26
    background.border_width=1
    background.shadow.drawing=off
    background.shadow.color=0x00000000
    background.shadow.angle=0
    background.shadow.distance=0
    click_script="aerospace workspace $i"
    script="$PLUGIN_DIR/workspace_updater.sh"
    drawing=off
  )

  sketchybar --add item workspace.$i left \
             --set workspace.$i "${workspace[@]}"

  if [ $i -lt 9 ]; then
    sketchybar --add item spacer.$i left \
               --set spacer.$i padding_left=2 padding_right=2 drawing=on \
                                background.drawing=off icon.drawing=off label.drawing=off \
                                width=2
  fi
done


workspace_updater=(
  script="$PLUGIN_DIR/workspace_updater.sh"
  icon.drawing=off
  label.drawing=off
  drawing=off
)

sketchybar --add item workspace_updater left \
           --set workspace_updater "${workspace_updater[@]}" \
           --subscribe workspace_updater aerospace_workspace_change \
                                       aerospace_window_change \
                                       space_change \
                                       display_change

workspace_refresh=(
  script="$PLUGIN_DIR/workspace_updater.sh"
  icon.drawing=off
  label.drawing=off
  drawing=off
  update_freq=30
)

sketchybar --add item workspace_refresh left \
           --set workspace_refresh "${workspace_refresh[@]}"

sketchybar --trigger aerospace_workspace_change
