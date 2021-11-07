-- Contents:
--    console.lua

------------------------------
-- console.lua
------------------------------
do
-- Console Configurable Values
DISPLAY_RES = 128
DISPLAY_COLOR_DEPTH = 2
DISPLAY_MONO = false

-- Notch size
NOTCH = layout.safeArea.top

-- Working variables updated when changing orientati1on
local CONSOLE_SCALE = WIDTH / 144
local CONSOLE_WIDTH = 0
local CONSOLE_HEIGHT = 0
local CONSOLE_XMIN = 0
local CONSOLE_YMIN = 0
local CONSOLE_ART

-- Color depth mask
local DISPLAY_COLOR_MASK = 0xFF << (8 - DISPLAY_COLOR_DEPTH)

-- Console Controls Enum
CONSOLE_A = 1
CONSOLE_B = 2
CONSOLE_UP = 3
CONSOLE_DOWN = 4
CONSOLE_RIGHT = 5
CONSOLE_LEFT = 6
CONSOLE_PAUSE = 7
CONSOLE_POWER = 8
local CONSOLE_BTN_END = 8

-- Button States
RELEASED = 0
PRESSED = 1

-- Button Variables
local buttonArt = {
    asset.btn_a,
    asset.btn_b,
    asset.btn_up,
    asset.btn_down,
    asset.btn_right,
    asset.btn_left,
    asset.btn_pause,
    asset.btn_power,
}
local buttonState = {
    RELEASED,
    RELEASED,
    RELEASED,
    RELEASED,
    RELEASED,
    RELEASED,
    RELEASED,
    RELEASED
}
local buttonSize = {
    { 24, 24 },
    { 24, 24 },
    { 16, 25 },
    { 16, 25 },
    { 25, 16 },
    { 25, 16 },
    { 18, 8 },
    { 12, 12 }
}
local buttonPos = {
    { 0, 0 },
    { 0, 0 },
    { 0, 0 },
    { 0, 0 },
    { 0, 0 },
    { 0, 0 },
    { 0, 0 },
    { 0, 0 },
}
local fb
local app_list = {
    selected = 1,
    apps = nil,
    icon = nil
}

function setup()
    viewer.mode = FULLSCREEN
    fb = image(DISPLAY_RES, DISPLAY_RES)
    noSmooth()
    CartridgeSetup()
end

local function adjustColor()
    if DISPLAY_MONO == false then
        for x = 1, DISPLAY_RES do
            for y = 1, DISPLAY_RES do
                local r, g, b = fb:get(x, y)
                
                r = r & DISPLAY_COLOR_MASK
                g = g & DISPLAY_COLOR_MASK
                b = b & DISPLAY_COLOR_MASK
                
                if r > 0 then r = r | ~DISPLAY_COLOR_MASK end
                if g > 0 then g = g | ~DISPLAY_COLOR_MASK end
                if b > 0 then b = b | ~DISPLAY_COLOR_MASK end
                
                fb:set(x, y, r, g, b)
            end
        end
    elseif DISPLAY_MONO == true then
        for x = 1, DISPLAY_RES do
            for y = 1, DISPLAY_RES do
                local r, g, b = fb:get(x, y)
                local total = math.floor(((r + g + b) / 3)) & DISPLAY_COLOR_MASK
                if total > 0 then total = total | ~DISPLAY_COLOR_MASK end
                fb:set(x, y, total, total, total)
            end
        end
    end
end

local function drawConsole()
    tint(148, 0, 255)
    spriteMode(CORNER)
    sprite(CONSOLE_ART, CONSOLE_XMIN, CONSOLE_YMIN, CONSOLE_WIDTH, CONSOLE_HEIGHT)
    noTint()
    spriteMode(CENTER)
end

local function drawButton(btn)
    local p = buttonPos[btn]
    local l = 0
    if buttonState[btn] == PRESSED then
        tint(124)
    end
    sprite(buttonArt[btn], p[1] * CONSOLE_SCALE + CONSOLE_XMIN, p[2] * CONSOLE_SCALE + CONSOLE_YMIN, buttonSize[btn][1] * CONSOLE_SCALE, buttonSize[btn][2] * CONSOLE_SCALE)
    noTint()
end

local function drawDisplay()
    if CurrentOrientation == PORTRAIT or CurrentOrientation == PORTRAIT_UPSIDE_DOWN then
        local s = DISPLAY_RES * CONSOLE_SCALE
        local y = HEIGHT - NOTCH - ((CONSOLE_HEIGHT / 256) * 72)
        sprite(fb, WIDTH/2, y, s, s)
    else
        local s = DISPLAY_RES * CONSOLE_SCALE
        sprite(fb, WIDTH/2, HEIGHT/2, s, s)
    end
end

local function drawControls()
    spriteMode(CORNER)
    for btn = 1, CONSOLE_BTN_END do
        drawButton(btn)
    end
    spriteMode(CENTER)
end

local function updateConsoleLayout()
    if CurrentOrientation == PORTRAIT or CurrentOrientation == PORTRAIT_UPSIDE_DOWN then
        buttonPos[CONSOLE_A] = { 109, 87 }
        buttonPos[CONSOLE_B] = { 82, 67 }
        buttonPos[CONSOLE_UP] = { 32, 87 }
        buttonPos[CONSOLE_DOWN] = { 32, 58 }
        buttonPos[CONSOLE_LEFT] = { 13, 77 }
        buttonPos[CONSOLE_RIGHT] = { 42, 77 }
        buttonPos[CONSOLE_PAUSE] = { 63, 109 }
        buttonPos[CONSOLE_POWER] = { 66, 11 }
        
        CONSOLE_WIDTH = WIDTH
        CONSOLE_HEIGHT = CONSOLE_WIDTH * (16/9)
        CONSOLE_XMIN = 0
        CONSOLE_YMIN = HEIGHT - NOTCH - CONSOLE_HEIGHT
        
        CONSOLE_ART = asset.console_portrait
    else
        buttonPos[CONSOLE_A] = { 226, 103 }
        buttonPos[CONSOLE_B] = { 199, 83 }
        buttonPos[CONSOLE_UP] = { 24, 105 }
        buttonPos[CONSOLE_DOWN] = { 24, 76 }
        buttonPos[CONSOLE_LEFT] = { 5, 95 }
        buttonPos[CONSOLE_RIGHT] = { 34, 95 }
        buttonPos[CONSOLE_PAUSE] = { 198, 12 }
        buttonPos[CONSOLE_POWER] = { 46, 12 }
        
        CONSOLE_WIDTH = HEIGHT * (16/9)
        CONSOLE_HEIGHT = HEIGHT
        CONSOLE_XMIN = (WIDTH - CONSOLE_WIDTH) / 2
        CONSOLE_YMIN = 0
        
        CONSOLE_ART = asset.console_landscape
    end
end

local frame = 0
function draw()
    background(0)
    
    setContext(fb)
    background(0)
    CartridgeUpdate()
    CartridgeDraw()
    setContext()
    
    -- Render the console
    updateConsoleLayout()
    adjustColor()
    drawConsole()
    drawDisplay()
    drawControls()
end

function ConsoleResetDisplay()
    DISPLAY_COLOR_DEPTH = 2
    DISPLAY_MONO = false
    DISPLAY_COLOR_MASK = 0xFF << (8 - DISPLAY_COLOR_DEPTH)
end

function ConsoleSetColorDepth(cd)
    DISPLAY_COLOR_DEPTH = cd
    DISPLAY_COLOR_MASK = 0xFF << (8 - DISPLAY_COLOR_DEPTH)
end

function ConsoleSetMono(mono)
    DISPLAY_MONO = mono
end

function ConsoleGetFramebuffer()
    return fb
end

function ConsoleButtonState(btn)
    return buttonState[btn]
end

local function overButton(btn, pt) 
    local p = buttonPos[btn]
    local w = buttonSize[btn][1]
    local h = buttonSize[btn][2]
    
    local l = p[1] * CONSOLE_SCALE + CONSOLE_XMIN
    local r = (p[1] + w) * CONSOLE_SCALE + CONSOLE_XMIN
    local t = ((p[2] + h) * CONSOLE_SCALE) + CONSOLE_YMIN
    local b = p[2] * CONSOLE_SCALE + CONSOLE_YMIN
    
    return pt.x >= l and pt.x <= r and pt.y >= b and pt.y <= t
end

local function onButton(btn, state)
    if state ~= buttonState[btn] then
        buttonState[btn] = state
        
        CartridgeOnButton(btn, state)
        
        if btn == CONSOLE_POWER and state == PRESSED then
            close()
        end
    end
end

function touched(touch)
    for btn = 1, CONSOLE_BTN_END do
        local wasOver = overButton(btn, touch.prevPos)
        local over = overButton(btn, touch.pos)
        
        if touch.state == BEGAN then
            if over then
                onButton(btn, 1)
            end
        elseif touch.state == CHANGED then
            if over and wasOver == false then
                onButton(btn, 1)
            elseif wasOver and over == false then
                onButton(btn, 0)
            end
        elseif touch.state == ENDED  then
            if over or wasOver then
                onButton(btn, 0)
            end
        end
    end
end

function sizeChanged( newWidth, newHeight )
    updateConsoleLayout()
end

end
