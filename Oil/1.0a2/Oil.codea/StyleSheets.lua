Oil.style_default = {
    -- General settings
    fill = color(128),
    stroke = color(255),
    strokeWidth = 0,
    spacing = 10,
    align = CENTER,
    
    -- Rectangle settings
    radius = 0,
    shadow = false,
    shadowWidth = 10,
    shadowIntensity = 1.0,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 17,
    textAlign = CENTER,
    textFill = color(0),
    text = "<undefined>",
    textWrapWidth = 0,
    
    -- Blur settings
    blur = false,
    blur_once = false,
    blur_amount = 1.0,
    blur_kernel_size = 16,
    blur_downscale = 0.5,
    
    -- Button presets
    fillButtonNormal = color(255),
    fillButtonHover = color(255),
    fillButtonPressed = color(255),
    
    -- Scroll settings
    clipAxis = AXIS_NONE,
    scrollAxis = AXIS_Y,
    bufferTop = 0,
    bufferBottom = 0,
    bufferLeft = 0,
    bufferRight = 0,
    
    -- Text Entry settings
    cursorWidth = 2,
    cursorBlink = true,
    textEntryInset = 5,
    strokeFocus = color(0, 137, 255),
    strokeNoFocus = color(255)
}

Oil.style_Label = {    
    -- Text
    text = "<undefined>",
    textAlign = CENTER,
    textFill = color(255),
    font = "Helvetica",
    fontSize = 17
}

Oil.style_Rect = {
    -- General
    fill = color(200),
    stroke = color(255),
    strokeWidth = 0,
    
    -- Rect
    radius = 0,
    
    -- Blur
    blur = false,
    blur_amount = 1.0,
    blur_kernel_size = 16,
    blur_downscale = 0.5
}

Oil.style_Icon = {
    -- General
    fill = color(255),
    stroke = color(255),
    strokeWidth = 0,
    
    -- Rect
    radius = 0,
    
    -- Blur
    blur = false,
    blur_amount = 1.0,
    blur_kernel_size = 16,
    blur_downscale = 0.5,
}

Oil.style_TextButton = {
    -- General settings
    fill = color(50, 150, 220),
    stroke = color(255),
    strokeWidth = 2,
    
    -- Rectangle settings
    radius = 15,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 17,
    textAlign = CENTER,
    textFill = color(255),
    
    -- Button presets
    fillButtonNormal = color(50, 150, 220),
    fillButtonHover = color(144, 184, 213),
    fillButtonPressed = color(82, 119, 221),
}

Oil.style_EmojiButton = {
    -- General settings
    fill = color(50, 150, 220),
    stroke = color(255),
    strokeWidth = 2,
    
    -- Rectangle settings
    radius = 12,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 32,
    textAlign = CENTER,
    textFill = color(255),
    
    -- Button presets
    fillButtonNormal = color(50, 150, 220),
    fillButtonHover = color(144, 184, 213),
    fillButtonPressed = color(82, 119, 221),
}

Oil.style_IconButton = {
    -- General settings
    fill = color(255),
    strokeWidth = 2,
    
    -- Rectangle settings
    radius = 12,
    
    -- Button presets
    fillButtonNormal = color(255),
    fillButtonHover = color(220),
    fillButtonPressed = color(180),
}

Oil.style_HorizontalStack = {
    spacing = 10,
    align = CENTER
}

Oil.style_VerticalStack = {
    spacing = 10,
    align = CENTER
}

Oil.style_Scroll = {
    clipAxis = AXIS_NONE,
    scrollAxis = AXIS_Y,
    bufferTop = 0,
    bufferBottom = 0,
    bufferLeft = 0,
    bufferRight = 0
}

Oil.style_Switch = {
    fill = color(128),
    fillOn = color(19, 207, 82),
    fillOff = color(128),
    radius = 16
}

Oil.style_SwitchHandle = {
    fill = color(230),
    radius = 14
}

Oil.style_Slider = {
    fill = color(196),
    fillActive = color(0, 118, 255),
    strokeWidth = 0,
    radius = 2
}

Oil.style_SliderHandle = {
    fill = color(230),
    strokeWidth = 1,
    radius = 14,
    shadow = true,
    shadowWidth = 10,
    shadowIntensity = 0.5
}

Oil.style_List = {
    spacing = 10,
    align = TOP
}

Oil.style_Dropdown = {
    -- General settings
    fill = color(50, 150, 220),
    stroke = color(255),
    strokeWidth = 2,
    
    -- Rectangle settings
    radius = 12,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 17,
    textAlign = CENTER,
    textFill = color(255),
    
    -- Button presets
    fillButtonNormal = color(50, 150, 220),
    fillButtonHover = color(144, 184, 213),
    fillButtonPressed = color(82, 119, 221),
}

Oil.style_TextEntry = {
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

Oil.style_Alert = {
    -- General
    fill = color(200),
    stroke = color(255),
    strokeWidth = 0,
    
    -- Rect
    radius = 15,
    
    -- Blur
    blur = false,
    blur_amount = 1.0,
    blur_kernel_size = 16,
    blur_downscale = 0.5
}
