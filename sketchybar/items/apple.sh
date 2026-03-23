#!/bin/bash

POPUP_OFF='sketchybar --set apple.logo popup.drawing=off'
POPUP_CLICK_SCRIPT='sketchybar --set $NAME popup.drawing=toggle'

apple_logo=(
  icon="󰀵"
  icon.color=0xffffffff
  icon.font.style="Bold"
  icon.font.size="20"
  icon.padding_left=10
  icon.padding_right=10
  icon.y_offset=1
  label.drawing=off
  background.drawing=on
  background.color=0x40ffffff
  background.corner_radius=12
  background.height=26
  background.border_width=1
  background.border_color=0x40ffffff
  background.shadow.drawing=off
  background.shadow.color=0x00000000
  background.shadow.angle=0
  background.shadow.distance=0
  click_script="$POPUP_CLICK_SCRIPT"
  popup.height=35
)

apple_prefs=(
  icon=""
  label="Preferences"
  click_script="open -a 'System Preferences'; $POPUP_OFF"
  padding_left=10
  padding_right=10
)

apple_activity=(
  icon=""
  label="Activity"
  click_script="open -a 'Activity Monitor'; $POPUP_OFF"
  padding_left=10
  padding_right=10
)

apple_lock=(
  icon="󰌾"
  label="Lock Screen"
  click_script="pmset displaysleepnow; $POPUP_OFF"
  padding_left=10
  padding_right=10
)

sketchybar --add item apple.logo left                  \
           --set apple.logo "${apple_logo[@]}"         \
                                                       \
           --add item apple.prefs popup.apple.logo     \
           --set apple.prefs "${apple_prefs[@]}"       \
                                                       \
           --add item apple.activity popup.apple.logo  \
           --set apple.activity "${apple_activity[@]}" \
                                                       \
           --add item apple.lock popup.apple.logo      \
           --set apple.lock "${apple_lock[@]}"
