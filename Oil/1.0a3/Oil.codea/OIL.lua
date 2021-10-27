Oil = {}

-- New global values
TOP = "top"
BOTTOM = "bottom"

-- Axis types
AXIS_NONE = 0
AXIS_X =  1
AXIS_Y =  2
AXIS_XY = 3

function Oil.setup()
    -- Create framebuffer
    Oil.fb = image(WIDTH, HEIGHT)
    
    -- Init root node
    Oil.root = Oil.Node(0, 0, WIDTH, HEIGHT)
    Oil.root.style_default = Oil.style_default
    Oil.root:set_debug_name("root")
end

function Oil.beginDraw()
    setContext(Oil.fb)
end

function Oil.endDraw()
    -- Update touches
    update_touches()
    
    -- Update nodes
    Oil.root:update()
    Oil.root:post_update()
    
    -- Draw nodes
    setContext(Oil.fb)
    Oil.root:draw()
    setContext()
    
    -- Blit to screen
    ortho(0, WIDTH, 0, HEIGHT)
    spriteMode(CORNER)
    sprite(Oil.fb, 0, 0)
end

function Oil.sizeChanged(w, h)
    if Oil.root == nil then
        return
    end
    
    -- Regenerate framebuffer
    Oil.fb = image(w, h)
    
    -- Resize root node
    Oil.root.w = w
    Oil.root.h = h 
end



-- Clip management
local clip_stack = {}
function Oil.clip(x, y, w, h)
    clip(x, y, w, h)
    table.insert(clip_stack, vec4(x, y, w, h))
end

function Oil.clipPop()
    table.remove(clip_stack)
    
    -- Re-apply clip
    local len = #clip_stack
    if len > 0 then
        local c = clip_stack[len]
        clip(c.x, c.y, c.z, c.w)
    else
        clip()
    end
end
