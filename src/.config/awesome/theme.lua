local themedir = require("gears.filesystem").get_themes_dir()

return {
    fullscreen_hide_border = true,
    maximized_hide_border = true,

    layout_max = themedir .. "zenburn/layouts/max.png",
    layout_tile = themedir .. "zenburn/layouts/tile.png",

    hotkeys_border_width = 0,
    hotkeys_modifiers_fg = "#80b0ff",
    hotkeys_font = "monospace 10",
    hotkeys_description_font = "monospace 10",
    hotkeys_group_margin = 24,

    notification_icon_size = 32,
    wibar_height = 24,

    font = "sans 11",
    battery_font = "monospace 8",
    taglist_font = "monospace 12",
    textclock_font = "monospace 10",

    bg_normal = "#101014",
    bg_focus = "#202428",
    bg_urgent = "#205080",
    bg_minimize = "#101014",
    taglist_fg_normal = "#b8b8b8",
    taglist_fg_empty = "#585858",
    tasklist_bg_focus = "#101014",

    fg_normal = "#c8c8c8",
    fg_focus = "#d8d8d8",
    fg_urgent = "#f0f0f0",
    fg_minimize = "#606060",
    tasklist_fg_normal = "#a0a0a0",
    tasklist_fg_focus = "#c8c8c8",

    border_width = 2,
    border_normal = "#586068",
    border_focus = "#0074b8",

    calendar_start_sunday = true,
    calendar_long_weekdays = true,
    calendar_month_bg_color = "#101014",
    calendar_month_padding = 8,
    calendar_month_border_width = 0,
    calendar_header_bg_color = "#101014",
    calendar_header_fg_color = "#80c0ff",
    calendar_header_padding = 4,
    calendar_header_border_width = 0,
    calendar_weekday_bg_color = "#101014",
    calendar_weekday_fg_color = "#60f0a0",
    calendar_weekday_border_width = 0,
    calendar_normal_bg_color = "#101014",
    calendar_normal_fg_color = "#b0d8e8",
    calendar_normal_border_width = 0,
    calendar_focus_fg_color = "#ffe840",
    calendar_focus_bg_color = "#101014",
    calendar_focus_border_width = 0,

    wallpaper = os.getenv("HOME") .. "/.config/wallpaper.png",
}
