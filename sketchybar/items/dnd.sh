#!/bin/bash

source "$CONFIG_DIR/helpers/constants.sh"

dnd=(
  icon="󰂛"
  icon.drawing=on
  icon.font.size=16.0
  icon.color=0xffb48ead
  icon.padding_left=8
  icon.padding_right=8
  label.drawing=off
  background.drawing=off
  background.color=$TRANSPARENT
  background.corner_radius=0
  background.height=0
  background.border_width=0
  background.shadow.drawing=off
  padding_left=0
  padding_right=0
  script="$PLUGIN_DIR/dnd.sh"
  update_freq=10
  updates=on
  drawing=off
  click_script="$PLUGIN_DIR/dnd.sh"
)

sketchybar --add item dnd right \
           --set dnd "${dnd[@]}" \
           --subscribe dnd mouse.clicked
