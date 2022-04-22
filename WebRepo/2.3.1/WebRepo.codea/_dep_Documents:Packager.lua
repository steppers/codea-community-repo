-- Contents:
--    Packager.lua

------------------------------
-- Packager.lua
------------------------------
do
-- Project Packager Lib
Packager = {}

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
function Packager.GetDependencySources(project_name, sources)
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
                Packager.GetSources(dep, sources, true)
            end
        end
    end
    
    return sources
end
    
-- Recursively adds all sources (including dependencies) of the
-- specified project to the 'sources' table, not including those
-- already present.
function Packager.GetSources(project_name, sources, is_dep)
    sources = sources or {}
    
    -- Get the project asset from the project subfolder:name combo
    local project_asset,_ = get_project_asset(project_name)
    
    -- Already added? do nothing.
    if sources[project_name] ~= nil then
        return sources
    end
    
    -- We are 'loaded' now!
    local source_table = {
        name = project_name:gsub(":", "_"),
        src = "",
        tabs = {}
    }
    sources[project_name] = source_table
    
    -- Ignore if the project cannot be found
    if project_asset == nil then
        error("Failed to get sources for project: " .. project_name .. "\n\nProject does not exist!\n\n")
    else
        -- Get dependencies
        Packager.GetDependencySources(project_name, sources)
        
        -- Get project plist
        local plist = readText(project_asset .. "Info.plist")
        
        -- Get every tab used in the project
        local tabs = plist:match("<key>Buffer Order</key>.-<array>(.-)</array>")
        
        -- Merge every tab into an uber source string
        local src = ""
        for tab in tabs:gmatch("<string>(.-)</string>") do
            
            -- Exclude the 'Main' tab if this is a dependency
            if not (is_dep and tab == "Main") then
            
                -- Get the tab source
                local tab_src = readText(project_asset .. tab .. ".lua")
                
                local dep_name = tab:match("_dep_(.*)")
                if dep_name then
                    if sources[dep_name] then
                        -- Ignore the sub-dependency if it's already included
                        -- elsewhere.
                        print(string.format(
                        [[Warning:
                        Dependency %s is already packed in project %s. This pre-packed dependency will be ignored.
                        Ensure the sub-dependency has no special modifications.]], dep_name, project_name))
                    else
                        -- Treat the sub dependency like a dependency to prevent it
                        -- being included again.
                        sources[dep_name] = {
                            name = dep_name,
                            src = tab_src,
                            tabs = {}
                        }
                        
                        -- Insert indexed source table so dependencies come first
                        table.insert(sources, sources[dep_name])
                    end
                    
                    -- Register this as an included tab so it's not copied anyway
                    source_table.tabs[tab .. ".lua"] = true
                else
                    
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
            end
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

-- Compiles all source code in the given project and produces
-- a new project (with prefix) to load the binary code in the
-- correct order (including dependencies). All non-code files
-- present in the original project are also copied to the new
-- one (such as art assets).
--
-- Optionally stripping debug data from the build can also
-- drastically reduce the size of the executed code. This is
-- more useful if the project is more code heavy than data
-- heavy.
function Packager.CompileProject(project_name, strip)
    
    -- Get all sources relevant to the project
    local sources = Packager.GetSources(project_name)
    
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

-- Given a project, retrieve the source code of all dependencies
-- and sub-dependencies then insert the dependency sources
-- into the project to be loaded before anything else. Once the
-- dependency code is included, the dependencies are removed
-- from the project's Info.plist file.
--
-- This is used by WebRepo 2.0 during project submission to ensure
-- any dependencies are included.
function Packager.IncludeDependencies(project_name)
    -- Gen uber source
    local sources = Packager.GetDependencySources(project_name)

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
