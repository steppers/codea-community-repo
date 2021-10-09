-- OIL, Ordinary Interface Library
OIL = {}
OIL.version = "1.0"
OIL.root = nil
OIL.ready = false

local input_focus = nil

function OIL.setup()
    OIL.ready = true
    OIL.fb = image(WIDTH, HEIGHT)
    
    -- Fullscreen root element
    OIL.root = OIL.Element{ name = "root", x = 0, y = 0, w = WIDTH, h = HEIGHT, id = "root" }
end

function OIL.draw()
    -- Draw to OIL Framebuffer so we can access it for blur effects
    setContext(OIL.fb)

    local pm = projectionMatrix()
    OIL.root:draw()
    
    -- Blit OIL framebuffer to screen
    setContext()
    projectionMatrix(pm)
    spriteMode(CORNER)
    sprite(OIL.fb, 0, 0, WIDTH, HEIGHT)
end

function OIL.sizeChanged(new_width, new_height)
    
    -- If OIL hasn't been initialised yet ignore
    -- this
    if not OIL.ready then
        return
    end
            
    -- Update backbuffer size
    OIL.fb = image(new_width, new_height)
    
    -- Update root element size
    OIL.root.w = new_width
    OIL.root.h = new_height
end

-- Returns true if the event has been handled
function OIL.handle_event(event)
    
    -- If OIL hasn't been initialised yet ignore
    -- this
    if not OIL.ready then
        return
    end
    
    -- Let the current focus take priority
    if input_focus and input_focus:handle_event(event) then
        return
    end
    
    -- Call the root element's handler
    input_focus = OIL.root:handle_event(event)
end
