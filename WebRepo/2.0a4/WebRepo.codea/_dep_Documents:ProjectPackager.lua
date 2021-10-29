-- Contents:
--    Main.lua
--    Compiler.lua

------------------------------
-- Main.lua
------------------------------
do

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

end
------------------------------
-- Compiler.lua
------------------------------
do
-- Compiler

local function get_project_asset(project_name)
    local project_asset = asset.documents[project_name .. ".codea"]
    local subfolder, project = project_name:match("(.-):(.*)")
    if subfolder and project_asset == nil then
        if subfolder == "Documents" then
            return asset.documents[project .. ".codea"], project
        else
            return asset.documents[subfolder][project .. ".codea"], project
        end
    end
    return project_asset, project_name
end

-- Recursively adds all dependencies of the specified project to
-- the 'sources' table, not including those already present
function GetDependencySources(project_name, sources)
    sources = sources or {}
    
    -- Get the project asset from the project subfolder:name combo
    local project_asset, project_name = get_project_asset(project_name)
    
    -- Ignore if the project cannot be found
    if project_asset == nil then
        error("Failed to get dependency sources for project: " .. project_name .. "\n\nProject does not exist!\n\n")
    else
        -- Get project plist
        local plist = readText(project_asset .. "Info.plist")
        
        -- Get every dependency used by the project
        local deps = plist:match("<key>Dependencies</key>.-<array>(.-)</array>")
        
        -- Add every dependency to sources
        if deps then
            for dep in deps:gmatch("<string>(.-)</string>") do
                GetSources(dep, sources)
            end
        end
    end
    
    return sources
end
    
-- Recursively adds all sources (including dependencies) of the
-- specified project to the 'sources' table, not including those
-- already present.
function GetSources(project_name, sources)
    sources = sources or {}
    
    -- Get the project asset from the project subfolder:name combo
    local project_asset,_ = get_project_asset(project_name)
    
    -- Already added? do nothing.
    if sources[project_name] ~= nil then
        return sources
    end
    
    -- We are 'loaded' now!
    local source_table = {
        name = project_name,
        src = "",
        tabs = {}
    }
    sources[project_name] = source_table
    
    -- Ignore if the project cannot be found
    if project_asset == nil then
        error("Failed to get sources for project: " .. project_name .. "\n\nProject does not exist!\n\n")
    else
        -- Get dependencies
        GetDependencySources(project_name, sources)
        
        -- Get project plist
        local plist = readText(project_asset .. "Info.plist")
        
        -- Get every tab used in the project
        tabs = plist:match("<key>Buffer Order</key>.-<array>(.-)</array>")
        
        -- Merge every tab into an uber source string
        local src = ""
        for tab in tabs:gmatch("<string>(.-)</string>") do
            
            -- Get the tab source
            local tab_src = readText(project_asset .. tab .. ".lua")
            
            -- Add tab
            source_table.tabs[tab .. ".lua"] = true
            table.insert(source_table.tabs, tab .. ".lua")
            
            -- Use do & end to enforce tab local scopes
            src = src .. string.format(
[[
------------------------------
-- %s
------------------------------
do
%s
end
]], tab .. ".lua", tab_src)
        end
        
        -- Add source header (list of included tabs)
        header = "-- Contents:\n"
        for _,tab in ipairs(source_table.tabs) do
            header = header .. "--    " .. tab .. "\n"
        end
        src = header .. "\n" .. src 
        
        -- Add the source
        source_table.src = src
    end
    
    -- Insert indexed source table so dependencies come first
    table.insert(sources, source_table)
    
    return sources
end

function CompileProject(project_name, strip)
    
    -- Get all sources relevant to the project
    local sources = GetSources(project_name)
    
    local load_bin_src = [[
-- Loads and executes a binary lua file
local function load_bin(name)
    local f = io.open((asset .. name .. ".bin").path, "rb")
    load(f:read("*a"))()
    f:close()
end

]]
    
    local output_name = "(DIST)" .. project_name
    if strip then
        output_name = "(BIN)" .. project_name
    end
    
    -- Save the compiled uber source to disk
    if hasProject(output_name) then
        deleteProject(output_name)
    end
    createProject(output_name)
    
    -- Copy non-source files to the output project
    local project_source = sources[#sources]
    for _,e in ipairs(asset.documents[project_name .. ".codea"].all) do
        local name = e.name
        
        -- Only if this wasn't part of the project source code
        if project_source.tabs[name] ~= true then
            -- Read
            local file = io.open(e.path, "rb")
            local content = file:read("*a")
            file:close()
                
            -- Write copy
            file = io.open((asset.documents).path .. "/".. output_name .. ".codea/" .. e.name, "wb")
            file:write(content)
            file:close()
        end
    end
    
    -- Separate binary files so generate the loader tab
    local main_tab_src = load_bin_src
        
    for i, s in ipairs(sources) do
        -- Compile source
        local uber_bin = string.dump(load(s.src), strip)
                
        -- Add binary file
        local file = io.open((asset.documents).path .. "/".. output_name .. ".codea/" .. s.name .. ".bin", "wb")
        file:write(uber_bin)
        file:close()
                
        -- Add load line to dependency tab
        main_tab_src = main_tab_src .. "load_bin(\"" .. s.name ..  "\")\n"
    end

    -- Save Main tab
    saveProjectTab(output_name .. ":Main", main_tab_src)
end

-- Pack dependencies into the project to load automatically
-- and remove them from Info.plist
function IncludeDependencies(project_name)
    -- Gen uber source
    local sources = GetDependencySources(project_name)

    -- Do we need to do anything?
    if #sources == 0 then
        return
    end
    
    local buffers_str = ""
    for i, s in ipairs(sources) do
        buffers_str = buffers_str .. "\t\t<string>_dep_" .. s.name .. "</string>\n"
                
        -- Add source file
        saveText(asset.documents[project_name .. ".codea"] .. "_dep_" .. s.name .. ".lua", s.src)
    end
    
    -- Remove the dependencies from the plist & add uber file
    local plist = readText(asset.documents[project_name .. ".codea"] .. "Info.plist")
    plist = plist:gsub("<key>Dependencies</key>.-</array>.-\n", "")
    plist = plist:gsub("<key>Buffer Order</key>.-<array>\n", "<key>Buffer Order</key>\n\t<array>\n" .. buffers_str)
    saveText(asset.documents[project_name .. ".codea"] .. "Info.plist", plist)
end


end
