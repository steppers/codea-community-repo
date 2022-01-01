-- AirCode 2.0

local server = nil

local proj_env = nil
local function load_project(project)
    proj_env = setmetatable({}, {
        __index = _G
    })
    
    -- Forward undefined _G access to the loaded project
    setmetatable(_G, {
        __index = function(t, k)
            return rawget(proj_env, k)
        end
    })
    
    -- Setup asset access
    proj_env.asset = setmetatable({}, {
        __index = function(t, k)
            return asset.documents[project .. ".codea"][k]
        end
    })
    proj_env.asset.documents = asset.documents
    
    -- Setup local data access
    function proj_env.readLocalData(key, default)
        local plist = readText(asset.documents[project .. ".codea"] .. "/Data.plist")
        if not plist then return default end
        local typ, v = plist:match("<key>" .. key .. "</key>.-<(.-)>(.-)</")
        print(typ,":",v)
    end
    
    saveLocalData("Test", 231890)
    
    
    -- Load the project
    local proj = project:gsub("/", ":")
    local tabs = listProjectTabs(proj)
    for _,tab in ipairs(tabs) do
        local src = readText(asset.documents .. project .. ".codea/" .. tab .. ".lua")
        local fn, err = load(src, tab, "t", proj_env)
        if fn == nil then
            -- Send error to client & stop project
            --print(err)
            proj_env = nil
            setmetatable(_G, nil)
        else
            local success, err = pcall(fn)
            if not success then
                print(err)
            end
        end
    end
    
    -- Call the project's setup() function
    if proj_env then
        local fn = rawget(proj_env, "setup")
        if fn then fn() end
    end
end

-- Reads a file as a binary string
local function read_file(asset_key)
    local file = io.open(asset_key.path, "rb")
    if not file then
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

-- Finds the most suitable icon for a specified
-- project.
local function get_icon(project_asset)
    local plist = readText(project_asset .. "/Info.plist")
    local icon_name = plist:match("<key>Icon</key>.-<string>(.-)</string>")
    
    local icon = nil
    
    if icon_name then
        local name, ext = icon_name:match("(.*)%.(.-)$")
        if name:find("@[0-9]x") == nil then
            -- Read higher dpi versions first
            icon = read_file(project_asset .. "/" .. name .. "@3x." .. ext)
            if icon then return icon end
            
            icon = read_file(project_asset .. "/" .. name .. "@2x." .. ext)
            if icon then return icon end
            
            icon = read_file(project_asset .. "/" .. icon_name)
            if icon then return icon end
        end
        
        -- Read the icon name exactly
        icon = read_file(project_asset .. "/" .. icon_name)
        if icon then return icon end
    end
    
    if icon == nil then
        -- Search for an icon file
        local icon = read_file(project_asset .. "/Icon@3x.png")
        if icon then return icon end
        
        local icon = read_file(project_asset .. "/Icon@2x.png")
        if icon then return icon end
        
        icon = read_file(project_asset .. "/Icon.png")
        if icon then return icon end
        
        return read_file(asset.documents.IconDefaultApp)
    end
end

function setup()
    server = WebServer(asset.site)
    
    -- Add icon handler
    server:add_resource("/project/(.*)/icon%.png",
    function(request, project)
        -- Assume a GET request
        local subfolder, project = project:match("(.-):(.*)")
        if subfolder == "Documents" then
            return 200, get_icon(asset.documents[project .. ".codea"])
        else
            return 200, get_icon(asset.documents[subfolder][project .. ".codea"])
        end
    end)
    
    server:add_websocket("/updates", function(new_client)
        -- Message handler saves tabs
        function new_client:on_message(msg)
            local msg = json.decode(msg)
            local handlers = {
                ["debug"] = function()
                    print("Dbg:", msg.content)
                end,
                ["get_tab"] = function()
                    new_client:send(json.encode({
                        ["type"] = "content",
                        ["content"] = readText(asset.documents .. msg.project .. ".codea/" .. msg.tab .. ".lua")
                    }))
                end,
                ["save"] = function()
                    saveText(asset.documents .. msg.project .. ".codea/" .. msg.tab .. ".lua", msg.content)
                    load_project(msg.project)
                end
            }
            if handlers[msg.type] then handlers[msg.type]() end
        end
    end)
end

function draw()
    if proj_env then
        local fn = rawget(proj_env, "draw")
        if fn then fn() end
    else
        background(113, 206, 155)
        
        -- Print connection info
        fill(0)
        textAlign(CENTER)
        text("Web Server running at:\nhttp://" .. server.ip .. ":" .. server.port .. "\nand\nhttp://localhost:" .. server.port, WIDTH/2, HEIGHT/2)
    end
end
