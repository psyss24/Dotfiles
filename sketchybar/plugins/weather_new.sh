#!/bin/bash

if [ -z "$CONFIG_DIR" ]; then
  CONFIG_DIR="$HOME/.config/sketchybar"
fi

API_KEYS_FILE="$CONFIG_DIR/helpers/api_keys.sh"
if [ -f "$API_KEYS_FILE" ]; then
  source "$API_KEYS_FILE"
fi

source "$CONFIG_DIR/helpers/constants.sh"

NAME="${NAME:-weather}"
LOCATION="${WEATHER_LOCATION:-Derby,UK}"
ICON_FONT="Symbols Nerd Font:Regular:25.0"
ICON_COLOR="$BAR_ICON_COLOR"
LABEL_COLOR="$BAR_LABEL_COLOR"

fallback_wttr() {
  local raw="$(curl -m 4 -s "https://wttr.in/${LOCATION}?format=%t|%C" 2>/dev/null)"
  if [ -z "$raw" ] || [[ "$raw" != *"|"* ]]; then
    sketchybar --set "$NAME" drawing=off
    return 1
  fi

  local temp="$(echo "$raw" | cut -d'|' -f1)"
  local cond="$(echo "$raw" | cut -d'|' -f2)"
  temp="${temp#+}"
  local icon="$(map_weather_icon "$cond")"

  if [ -z "$temp" ] || [ -z "$icon" ]; then
    sketchybar --set "$NAME" drawing=off
    return 1
  fi

  sketchybar --set "$NAME" \
    icon="$icon" \
    icon.font="$ICON_FONT" \
    icon.color="$ICON_COLOR" \
    label="$temp" \
    label.color="$LABEL_COLOR" \
    drawing=on
  return 0
}

map_weather_icon() {
  case "${1,,}" in
    *thunder*|*storm*) echo "" ;;
    *snow*|*sleet*|*flurries*) echo "" ;;
    *rain*|*drizzle*) echo "" ;;
    *cloud*) echo "" ;;
    *overcast*) echo "" ;;
    *mist*|*fog*|*haze*) echo "" ;;
    *clear*|*sun*) echo "" ;;
    *) echo "" ;;
  esac
}

fallback_wttr