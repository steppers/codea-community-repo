OIL.Style = {}

function OIL.Style.clone(original)
    local t = {}
    for k,v in pairs(original) do
        t[k] = v
    end
    return t
end

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
    scale = 1.0,
    
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

OIL.Style.toggle = {
    bg = {
        fill = color(240),
        fillToggleOff = color(240),
        fillToggleOn = color(77, 176, 233),
        radius = 18,
        scale = 1.0
    },
    handle = {
        fill = color(255),
        stroke = color(220),
        strokeWidth = 2
    }
}

OIL.Style.slider = {
    bar = {
        fill = color(96),
    },
    handle = {
        fill = color(255),
        fillDragging = color(77, 176, 233),
        fillNotDragging = color(255),
        stroke = color(220),
        radius = 16,
        strokeWidth = 2
    }
}

-- Custom Style Functions to avoid naming collisions
function fillText(col)
    fill(col)
end
