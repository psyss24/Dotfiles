if [ -z "$CONFIG_DIR" ]; then
  CONFIG_DIR="$HOME/.config/sketchybar"
fi

source "$CONFIG_DIR/helpers/constants.sh"

weather=(
  icon=""
  icon.font="Symbols Nerd Font:Regular:15.0"
  icon.color=$BAR_ICON_COLOR
    icon.font="Symbols Nerd Font:Regular:20.0"
    icon.color=$BAR_ICON_COLOR
    icon.padding_left=8
    icon.padding_right=2
  label.font.family="$BAR_FONT_FAMILY"
  label.font.style="Semibold"
  label.font.size=13.0
  label.color=$BAR_LABEL_COLOR
  label.padding_left=2
  label.padding_right=6
  background.drawing=off
  padding_left=2
  padding_right=2
  script="$PLUGIN_DIR/weather_new.sh"
  update_freq=900
  updates=on
)

sketchybar --add item weather right \
           --set weather "${weather[@]}"
