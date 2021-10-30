
local project_selected = nil
local strip = false

local function TextDropdown(x, y, w, h, default, options, cb)
    local dd = Oil.Dropdown(x, y, w, h, default)
    
    local handler = function(node, event)
        if event.type == "tap" and node:covers(event.pos) then
            local val = node:get_style("text")
            dd:add_style("text", val)
            dd:transition(false)
            cb(val)
            return true
        end
        return false
    end
        
    for i,item in ipairs(options) do
        if i > 1 then
            dd:add_child(
                -- 1 pixel line
                Oil.Rect(0.5, 0, 100, 1.0001)
                :add_style("fill", color(255))
            )
        end
        dd:add_child(
            -- Label
            Oil.Label(0, 0, 1.0, 20, item)
            :add_handler(handler)
        )
    end
    
    return dd
end

local function LabelledSwitch(x, y, w, h, label, callback, default)
    return Oil.Node(x, y, w, h)
    :add_children(
        Oil.Switch(0, 0.5, callback, default),
        Oil.Label(60, 0.5, 100, 32, label, LEFT)
    )
end

function setup()
    Oil.setup()
    
    local projects = {}
    for _,item in ipairs(asset.documents.all) do
        local name = item.name:match("(.*)%.codea$")
        if name and name:match("(DIST)") == nil and name:match("(BIN)") == nil then
            table.insert(projects, name)
        end
    end
    
    Oil.root:add_renderer(Oil.RectRenderer)
    :add_style("fill", color(64))
    
    Oil.Label(0.5, -(15 + layout.safeArea.top), 1.0, 30, "Project Compiler")
    :add_style({
        textFill = color(0, 182, 255),
        fontSize = 24,
        font = "HelveticaNeue-Bold"
    })
    
    -- 1 pixel line
    Oil.Rect(5, -(48 + layout.safeArea.top), -5, 1.0001)
    :add_style("fill", color(255))
    
    Oil.List(10, -(49 + layout.safeArea.top), -10)
    :add_children(
        Oil.Label(0, 0, 1.0, 25, "Project:", LEFT),
        TextDropdown(0, 0, 1.0, 30, "Select Project", projects, function(name)
            project_selected = name
        end),
    
        LabelledSwitch(0.5, 0, 200, 30, "Strip Source Code", function(v)
            strip = v
        end, strip),
    
        Oil.TextButton(0.5, 0, 170, 30, "Compile", function(bttn)
            -- Check a project is actually selected
            if project_selected == nil then
                bttn:add_style("text", "Select a project!")
                tween(1.2, {}, {}, nil, function()
                    bttn:add_style("text", "Compile")
                end)
                return
            end
        
            -- Compress the project
            bttn:add_style("text", "Compiling...")
            tween(0.1, {}, {}, nil, function()
                CompileProject(project_selected, strip)
                bttn:add_style("text", "Compile")
            end)
        end)
    )
end

function draw()
    Oil.beginDraw()
    Oil.endDraw()
end

function sizeChanged(w, h)
    Oil.sizeChanged(w, h)
end

function hover(g)
    Oil.hover(g)
end

function scroll(g)
    Oil.scroll(g)
end

function touched(t)
    Oil.touch(t)
end

function keyboard(k)
    Oil.keyboard(k)
end
