#!/bin/sh

volume_slider=(
    script="$PLUGIN_DIR/volume.sh"
    updates=on
    label.drawing=off
    icon.drawing=off
    slider.highlight_color=$VOLUME_SLIDER_HIGHLIGHT_COLOR
    slider.background.height=6
    slider.background.corner_radius=3
    slider.background.color=$VOLUME_SLIDER_BG_COLOR
    slider.knob="󰄯"
    slider.knob.drawing=on
    slider.knob.color=$VOLUME_SLIDER_KNOB_COLOR
    slider.width=0
)

volume_icon=(
    click_script="$PLUGIN_DIR/volume_click.sh"
    icon="󰕾"
    icon.font.size=16.0
    icon.color=$BAR_ICON_COLOR
    icon.padding_left=8
    icon.padding_right=8
    label.font.family="$BAR_FONT_FAMILY"
    label.font.size=13.0
    label.font.style="Medium"
    label.color=$BAR_LABEL_COLOR
    label.drawing=off
    background.drawing=off
)

sketchybar --add slider volume right            \
           --set volume "${volume_slider[@]}"   \
           --subscribe volume volume_change     \
                              mouse.clicked     \
           --add item volume_icon right         \
           --set volume_icon "${volume_icon[@]}"

sketchybar --trigger volume_change
