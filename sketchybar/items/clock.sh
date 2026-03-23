#!/bin/bash

clock=(
  icon="󰥔"
  icon.drawing=on
  icon.font.size=15.0
  icon.color=$BAR_ICON_COLOR
  icon.padding_left=6
  icon.padding_right=4
  label.font.family="$BAR_FONT_FAMILY"
  label.font.size=13.0
  label.font.style="Medium"
  label.color=$BAR_LABEL_COLOR
  label.padding_left=2
  background.drawing=off
  update_freq=30
  script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right    \
           --set clock "${clock[@]}" \
           --subscribe clock system_woke
