
local style_background_dark = {
    fill = color(0)
}

local style_background_light = {
    fill = color(255)
}
    
local style_button_dark = {
    fill = color(48),
    fillButtonNormal = color(48),
    fillButtonHover = color(96),
    fillButtonPressed = color(128),
    
    -- Text settings
    font = "Arial-BoldMT",
    fontSize = 17,
    textAlign = CENTER,
    textFill = color(0, 137, 255),
    
    radius = 15
}

local style_button_light = {
    fill = color(230),
    fillButtonNormal = color(230),
    fillButtonHover = color(196),
    fillButtonPressed = color(128),
    
    -- Text settings
    font = "Arial-BoldMT",
    fontSize = 17,
    textAlign = CENTER,
    textFill = color(0, 137, 255),
    
    radius = 15
}

local style_news_dark = {
    radius = 16,
    fill = color(196)
}

local style_news_light = {
    radius = 16,
    shadow = true,
    shadowWidth = 12,
    shadowIntensity = 0.4,
    fill = color(196)
}

local style_news_internal_dark = {
    textFill = color(255),
    fill = color(32),
    fontSize = 20
}

local style_news_internal_light = {
    textFill = color(0),
    fill = color(210),
    fontSize = 20
}

local style_news_internal_alt_dark = {
    textFill = color(196),
    fill = color(32),
    fontSize = 20
}

local style_news_internal_alt_light = {
    textFill = color(128),
    fill = color(210),
    fontSize = 20
}

local style_divider_dark = {
    fill = color(128)
}

local style_divider_light = {
    fill = color(196)
}

local style_tab_bar_dark = {
    fill = color(32, 96)
}

local style_tab_bar_light = {
    fill = color(96, 64)
}

local style_app_window_dark = {
    fill = color(32)
}

local style_app_window_light = {
    fill = color(255)
}

local style_dropdown_dark = {
    fill = color(64),
    strokeWidth = 0,
    
    -- Rectangle settings
    radius = 15,
    
    -- Text settings
    font = "Arial-BoldMT",
    fontSize = 17,
    textAlign = CENTER,
    textFill = color(255),
    
    -- Button presets
    fillButtonNormal = color(64),
    fillButtonHover = color(144, 184, 213),
    fillButtonPressed = color(82, 119, 221),
}

local style_dropdown_light = {
    fill = color(230),
    strokeWidth = 0,
    radius = 15,
    
    -- Text settings
    font = "Arial-BoldMT",
    fontSize = 17,
    textAlign = CENTER,
    textFill = color(0, 137, 255),
    
    -- Button presets
    fillButtonNormal = color(230),
    fillButtonHover = color(96),
    fillButtonPressed = color(128),
}

local style_text_entry_dark = {
    -- General settings
    fill = color(32),
    stroke = color(105, 133, 156),
    strokeWidth = 3,
    
    -- Rectangle settings
    radius = 8,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 20,
    textFill = color(223),
    
    -- Scroll settings
    clipAxis = AXIS_Y,
    
    -- Text Entry settings
    cursorWidth = 2,
    cursorBlink = true,
    textEntryInset = 7,
    strokeFocus = color(0, 137, 255),
    strokeNoFocus = color(105, 133, 156)
}

local style_text_entry_light = {
    -- General settings
    fill = color(210),
    stroke = color(105, 133, 156),
    strokeWidth = 3,
    
    -- Rectangle settings
    radius = 8,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 20,
    textFill = color(32),
    
    -- Scroll settings
    clipAxis = AXIS_Y,
    
    -- Text Entry settings
    cursorWidth = 2,
    cursorBlink = true,
    textEntryInset = 7,
    strokeFocus = color(0, 137, 255),
    strokeNoFocus = color(105, 133, 156)
}

local style_alert_dark = {
    -- General settings
    fill = color(64),
    stroke = color(105, 133, 156),
    strokeWidth = 3,
    
    -- Rectangle settings
    radius = 20,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 20,
    textFill = color(255)
}

local style_alert_light = {
    -- General settings
    fill = color(255),
    stroke = color(105, 133, 156),
    strokeWidth = 3,
    
    -- Rectangle settings
    radius = 20,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 20,
    textFill = color(32)
}

theme_light = {
    background = style_background_light,
    button = style_button_light,
    news = style_news_light,
    news_internal = style_news_internal_light,
    news_internal_alt = style_news_internal_alt_light,
    divider = style_divider_light,
    tab_bar = style_tab_bar_light,
    app_window = style_app_window_light,
    dropdown = style_dropdown_light,
    text_entry = style_text_entry_light,
    alert = style_alert_light
}

theme_dark = {
    background = style_background_dark,
    button = style_button_dark,
    news = style_news_dark,
    news_internal = style_news_internal_dark,
    news_internal_alt = style_news_internal_alt_dark,
    divider = style_divider_dark,
    tab_bar = style_tab_bar_dark,
    app_window = style_app_window_dark,
    dropdown = style_dropdown_dark,
    text_entry = style_text_entry_dark,
    alert = style_alert_dark
}