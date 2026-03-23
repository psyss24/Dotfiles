#!/bin/sh

source "$CONFIG_DIR/helpers/constants.sh"

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

if [[ "$CHARGING" != "" ]]; then
  case "${PERCENTAGE}" in
    9[0-9]|100) ICON="󰂅"
    ;;
    8[0-9]) ICON="󰂋"
    ;;
    7[0-9]) ICON="󰂊"
    ;;
    6[0-9]) ICON="󰢞"
    ;;
    5[0-9]) ICON="󰂉"
    ;;
    4[0-9]) ICON="󰢝"
    ;;
    3[0-9]) ICON="󰂈"
    ;;
    2[0-9]) ICON="󰂇"
    ;;
    1[0-9]) ICON="󰂆"
    ;;
    *) ICON="󰢜"
  esac
else
  case "${PERCENTAGE}" in
    9[0-9]|100) ICON="󰁹"
    ;;
    8[0-9]) ICON="󰂂"
    ;;
    7[0-9]) ICON="󰂁"
    ;;
    6[0-9]) ICON="󰂀"
    ;;
    5[0-9]) ICON="󰁿"
    ;;
    4[0-9]) ICON="󰁾"
    ;;
    3[0-9]) ICON="󰁽"
    ;;
    2[0-9]) ICON="󰁼"
    ;;
    1[0-9]) ICON="󰁻"
    ;;
    *) ICON="󰁺"
  esac
fi

if [[ "$CHARGING" != "" ]]; then
  ICON_COLOR=$BATTERY_GREEN
else
  if [ "$PERCENTAGE" -ge 50 ]; then
    ICON_COLOR=$BATTERY_GREEN
  elif [ "$PERCENTAGE" -ge 30 ]; then
    ICON_COLOR=$BATTERY_YELLOW
  else
    ICON_COLOR=$BATTERY_RED
  fi
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$ICON_COLOR" label="${PERCENTAGE}%"
