#!/bin/sh

battery=(
  icon.drawing=on
  icon.font.size=16.0
  icon.color=$BAR_ICON_COLOR
  icon.padding_left=6
  icon.padding_right=4
  label.font.family="$BAR_FONT_FAMILY"
  label.font.size=13.0
  label.font.style="Medium"
  label.color=$BAR_LABEL_COLOR
  label.padding_left=2
  background.drawing=off
  script="$PLUGIN_DIR/battery.sh"
  update_freq=120
  updates=on
)

sketchybar --add item battery right \
           --set battery "${battery[@]}"\
           --subscribe battery power_source_change system_woke
