return {
    black = 0xff2e3440,
    white = 0xffeceff4,
    red = 0xffbf616a,
    green = 0xffa3be8c,
    blue = 0xff81a1c1,
    yellow = 0xffebcb8b,
    orange = 0xffd08770,
    magenta = 0xffb48ead,
    purple = 0xff8875b8,
    cyan = 0xff88c0d0,
    grey = 0xff4c566a,
    dirty_white = 0xffd8dee9,
    dark_grey = 0xff3b4252,
    transparent = 0x00000000,

    nord0 = 0xff2e3440,
    nord1 = 0xff3b4252,
    nord2 = 0xff434c5e,
    nord3 = 0xff4c566a,

    nord4 = 0xffd8dee9,
    nord5 = 0xffe5e9f0,
    nord6 = 0xffeceff4,

    nord7 = 0xff8fbcbb,
    nord8 = 0xff88c0d0,
    nord9 = 0xff81a1c1,
    nord10 = 0xff5e81ac,

    nord11 = 0xffbf616a,
    nord12 = 0xffd08770,
    nord13 = 0xffebcb8b,
    nord14 = 0xffa3be8c,
    nord15 = 0xffb48ead,

    bar = {
        bg = 0xf02e3440,
        border = 0xff434c5e,
    },

    popup = {
        bg = 0xd03b4252,
        border = 0xff5e81ac,
    },

    spaces = {
        active = 0xff88c0d0,
        inactive = 0xff4c566a,
        background = 0xff3b4252,
    },

    bg1 = 0x443b4252,
    bg2 = 0xff434c5e,

    text = {
        primary = 0xffeceff4,
        secondary = 0xffd8dee9,
        tertiary = 0xff4c566a,
    },

    status = {
        good = 0xffa3be8c,
        warning = 0xffebcb8b,
        error = 0xffbf616a,
        info = 0xff81a1c1,
    },

    with_alpha = function(color, alpha)
        if alpha > 1.0 or alpha < 0.0 then return color end
        return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
    end,

    interpolate = function(color1, color2, factor)
        if factor <= 0 then return color1 end
        if factor >= 1 then return color2 end

        local r1 = (color1 >> 16) & 0xff
        local g1 = (color1 >> 8) & 0xff
        local b1 = color1 & 0xff

        local r2 = (color2 >> 16) & 0xff
        local g2 = (color2 >> 8) & 0xff
        local b2 = color2 & 0xff

        local r = math.floor(r1 + (r2 - r1) * factor)
        local g = math.floor(g1 + (g2 - g1) * factor)
        local b = math.floor(b1 + (b2 - b1) * factor)

        return 0xff000000 | (r << 16) | (g << 8) | b
    end,
}
