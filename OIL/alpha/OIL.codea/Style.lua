OIL.Style = {}

-- NOTE:
-- Please do not use noStroke as this will not work

-- Default style used in the absence of one
-- on a render component.
OIL.Style.default = {
    
    -- General
    fill = color(255),
    stroke = color(255),
    strokeWidth = 0,
    rectMode = CENTER,
    
    -- State colours
    fillUnselected = color(77, 142, 216),
    fillSelected = color(188, 206, 225),
    fillHover = color(122, 167, 215),
    
    -- Rounded Rectangle
    radius = 20,
    
    -- Blur
    blur = false,
    blur_amount = 3.0,
    blur_kernel_size = 16,
    blur_downscale = 0.5,
    
    -- Text
    text = "<undefined>",
    fillText = color(255),
    textMode = CENTER,
    textAlign = CENTER,
    fontSize = 20
}

OIL.Style.button = {
    bg = {
        fill = OIL.Style.default.fillUnselected,
        strokeWidth = 1,
        radius = 20
    },
    text = {}
}

-- Custom Style Functions to avoid naming collisions
function fillText(col)
    fill(col)
end
