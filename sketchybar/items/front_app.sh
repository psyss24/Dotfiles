#!/bin/sh

source "$CONFIG_DIR/helpers/constants.sh"

front_app=(
  icon.drawing=on
  icon.font="sketchybar-app-font:Regular:16.0"
  icon.padding_left=8
  icon.padding_right=6
  icon.color=$BAR_ICON_COLOR_HIGHLIGHT
  label.font.family="$BAR_FONT_FAMILY"
  label.font.size=13.0
  label.font.style="Semibold"
  label.color=$BAR_LABEL_COLOR_HIGHLIGHT
  label.padding_right=12
  label.max_chars=35
  display=active
  background.color=0x40ffffff
  background.corner_radius=12
  background.height=26
  background.border_width=1
  background.border_color=0x40ffffff
  background.shadow.drawing=off
  background.shadow.color=0x00000000
  background.shadow.angle=0
  background.shadow.distance=0
  padding_left=1
  padding_right=2
  script="$PLUGIN_DIR/front_app.sh"
  updates=on
)

sketchybar --add item front_app left \
           --set front_app "${front_app[@]}" \
           --subscribe front_app front_app_switched
