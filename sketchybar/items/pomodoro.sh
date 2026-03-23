#!/bin/bash

source "$CONFIG_DIR/helpers/constants.sh"

POMODORO_WORK_COLOR="0xffbf616a"
POMODORO_BREAK_COLOR="0xffa3be8c"
POMODORO_LONG_BREAK_COLOR="0xff81a1c1"
POMODORO_IDLE_COLOR="0xff4c566a"
POMODORO_PAUSED_COLOR="0xffebcb8b"

pomodoro=(
  icon="󰄉"
  icon.drawing=on
  icon.font.size=15.0
  icon.color=$POMODORO_IDLE_COLOR
  icon.padding_left=8
  icon.padding_right=6
  label.drawing=on
  label.font.family="$BAR_FONT_FAMILY"
  label.font.size=12.0
  label.font.style="Medium"
  label.color=$BAR_LABEL_COLOR
  label.padding_right=8
  label.max_chars=8
  background.drawing=off
  padding_left=2
  padding_right=2
  click_script="$PLUGIN_DIR/pomodoro_click.sh"
  script="$PLUGIN_DIR/pomodoro.sh"
  update_freq=1
  updates=on
  drawing=on
)

sketchybar --add item pomodoro right \
           --set pomodoro "${pomodoro[@]}" \
           --subscribe pomodoro mouse.clicked
