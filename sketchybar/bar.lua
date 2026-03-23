local colors = require("colors")

sbar.bar({
    topmost = "window",
    height = 36,
    color = colors.bar.bg,
    padding_right = 8,
    padding_left = 8,
    margin = 8,
    corner_radius = 12,
    y_offset = 6,
    border_color = colors.bar.border,
    border_width = 2,
    blur_radius = 12,
    position = "top",
    sticky = true,
    shadow = true,
    display = "all",
})
