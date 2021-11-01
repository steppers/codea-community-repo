local meta = {
    name = nil,                 -- string
    category = nil,             -- string
    short_description = nil,    -- string
    description = nil,          -- string
    authors = nil,              -- table
    version = "1.0.0",          -- string
    update_notes = "",          -- string
    hidden = false,             -- bool
    icon = nil,                 -- string
    banner = nil,               -- string
    forum_link = "https://codea.io/talk/", -- string
    size = nil,                 -- integer
    key = nil,                  -- string
}

local submit_in_progress = false

local function saveMeta()
    local key = meta.key
    meta.key = nil -- remove key
    saveText(asset.documents.webrepocache_vfs .. "submit_meta.json", json.encode(meta))
    meta.key = key -- restore key
end

local function restoreMeta()
    local j = readText(asset.documents.webrepocache_vfs .. "submit_meta.json")
    if j then
        meta = json.decode(j)
    
        -- Convert authors array back into csv
        if type(meta.authors) == "table" then
            local num = #meta.authors
            local new_authors = ""
            for i,author in ipairs(meta.authors) do
                new_authors = new_authors .. author
                if i < num then new_authors = new_authors .. "," end
            end
            meta.authors = new_authors
        end
    end
end

local function verifyAndSubmit(submit_bttn, error_label, complete_callback)
    if submit_in_progress then return false, "Submit in progress" end -- abort
    
    if meta.name == nil then
        return false, "Project Missing"
    end
    
    if meta.name == "WebRepo" and not meta.key then
        return false, "Admin key required"
    end
    
    -- This is just a pre-check before we submit
    -- If you fancy trying your luck removing it, the server
    -- guards against reserved names and the submission will fail
    -- anyway.
    if meta.name == ".github" or meta.name == "screenshots" then
        return false, "Project name is reserved"
    end
    
    -- Check for an icon
    do
        local plist = readText(asset.documents .. meta.name .. ".codea/Info.plist")
        local icon = plist:match("<key>Icon</key>.-<string>(.-)</string>")
        if not icon then
            -- Scan the project dir for an icon file
            local file = io.open((asset.documents .. meta.name .. ".codea/Icon@2x.png").path, "rb")
            if file then
                icon = "Icon@2x.png"
                file:close()
            else
                file = io.open((asset.documents .. meta.name .. ".codea/Icon.png").path, "rb")
                if file then
                    icon = "Icon.png"
                    file:close()
                else
                    return false, "Project has no icon!"
                end
            end
        end
        
        local f = io.open((asset.documents .. meta.name .. ".codea/" .. icon).path)
        if not f then
            return false, "Project's set icon does not exist!"
        end
        meta.icon = meta.name .. ".codea/" .. icon
    end
    
    if not meta.category then
        return false, "Category missing"
    end
    
    -- Validate authors
    if not meta.authors or meta.authors == "" then
        return false, "Authors missing"
    end
    -- Split the authors into a table
    if type(meta.authors) == "string" then
        local new_authors = {}
        for author in string.gmatch(meta.authors, "([^,]*)") do
            table.insert(new_authors, author)
        end
        meta.authors = new_authors
    end
    -- TODO: Check authors in an existing submission and only allow
    -- if old authors are included.
    
    if not meta.short_description or meta.short_description == "" then
        return false, "Short description missing"
    end
    
    if not meta.description or meta.description == "" then
        return false, "Description missing"
    end
    
    -- Validate version
    if not meta.version or meta.version == "" then
        return false, "Version missing"
    end
    -- TODO: Check identical existing version & its review flag
    --   (already done server side but user feedback is better)
    
    -- Do our submission
    submit_in_progress = true
    Submission.submitProject(meta.name, meta, function(progress_msg)
        submit_bttn:add_style("text", progress_msg)
    end, function(error_msg)
        submit_in_progress = false
        error_label:add_style("text", error_msg)
    end, function()
        submit_in_progress = false
        complete_callback()
    end)
    return true
end

local function TextDropdown(x, y, w, h, default, options, cb)
    local dd = Oil.Dropdown(x, y, w, h, default)
    :add_style(UI.THEME.dropdown)
    
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
                :set_style_sheet(UI.THEME.divider)
            )
        end
        dd:add_child(
            -- Label
            Oil.Label(0, 0, 1.0, 20, item)
            :add_handler(handler)
            :set_style_sheet(UI.THEME.dropdown)
        )
    end
    
    return dd
end
    
function SubmitWindow()
    restoreMeta()
    
    local root = Oil.Rect(0, 0, 1.0, 1.0)
    :set_priority(20)
    :set_style_sheet(UI.THEME.background)
    :add_handler(function(node, event)
        return true
    end)
    
    local error_label = Oil.LabelResize(10, 0, -10, 50, "", CENTER)
    :set_style_sheet(UI.THEME.news_internal)
    :add_style("fontSize", 20)
    :add_style("font", "HelveticaNeue-Bold")
    :add_style("textFill", color(255, 14, 0))
    
    local projects = {}
    for _,item in ipairs(asset.documents.all) do
        local name = item.name:match("(.*)%.codea$")
        if name then
            table.insert(projects, name)
        end
    end
    
    local category_dd = TextDropdown(10, 0, -10, 30, meta.category or "Select Category", {
        "Game", "App", "Library" -- , "Asset Pack"
    }, function(category)
        meta.category = category
        saveMeta()
    end)
    
    local authors_text_entry = Oil.TextEntry(10, 0, -10, 35, meta.authors, function(str)
        meta.authors = str
        saveMeta()
    end)
    :set_style_sheet(UI.THEME.text_entry)
    
    local short_description_text_entry = Oil.TextEntry(10, 0, -10, 35, meta.short_description, function(str)
        meta.short_description = str
        saveMeta()
    end)
    :set_style_sheet(UI.THEME.text_entry)
    
    local description_text_entry = Oil.TextEntry(10, 0, -10, 200, meta.description, function(str)
        meta.description = str
        saveMeta()
    end)
    :set_style_sheet(UI.THEME.text_entry)
    
    local version_text_entry = Oil.TextEntry(10, 0, -10, 35, meta.version or "1.0.0", function(str)
        meta.version = str
        saveMeta()
    end)
    :set_style_sheet(UI.THEME.text_entry)
    
    local update_notes_text_entry = Oil.TextEntry(10, 0, -10, 100, meta.update_notes, function(str)
        meta.update_notes = str
        saveMeta()
    end)
    :set_style_sheet(UI.THEME.text_entry)
    
    local forum_link_text_entry = Oil.TextEntry(10, 0, -10, 35, meta.forum_link or "https://codea.io/talk/", function(str)
        meta.forum_link = str
        saveMeta()
    end)
    :set_style_sheet(UI.THEME.text_entry)
    
    local function load_values_from_app(app)
        if app == nil then return end
        
        -- Set the meta file
        meta = app.info
        saveMeta()
        
        category_dd:add_style("text", app.info.category)
        
        short_description_text_entry:add_style("text", app.info.short_description)
        short_description_text_entry.state.char_info_requires_update = true
        
        description_text_entry:add_style("text", app.info.description)
        description_text_entry.state.char_info_requires_update = true
        
        version_text_entry:add_style("text", app.info.version)
        version_text_entry.state.char_info_requires_update = true
        
        update_notes_text_entry:add_style("text", app.info.update_notes)
        update_notes_text_entry.state.char_info_requires_update = true
        
        forum_link_text_entry:add_style("text", app.info.forum_link)
        forum_link_text_entry.state.char_info_requires_update = true
        
        local authors_str = ""
        for i,a in ipairs(app.info.authors) do
            if i == 1 then
                authors_str = authors_str .. a
            else
                authors_str = authors_str .. ", " .. a
            end
        end
        authors_text_entry:add_style("text", authors_str)
        authors_text_entry.state.char_info_requires_update = true
    end
    
    local scroll = Oil.Scroll(0, 0, 1.0, -50)
    :add_style("bufferBottom", 450) -- So we can get the text entry above the software keyboard
    :add_style("clipAxis", AXIS_Y)
    :add_children(
        Oil.List(0.5, 1.0, 1.0)
        :add_children(
            Oil.Label(10, 0, -10, 25, "Project:", LEFT)
            :set_style_sheet(UI.THEME.news_internal),
            TextDropdown(10, 0, -10, 30, meta.name or "Select Project", projects, function(name)
                meta.name = name
                saveMeta()
                load_values_from_app(DB.getLatestApp(meta.name))
            end),
    
            Oil.Label(10, 0, -10, 25, "Category:", LEFT)
            :set_style_sheet(UI.THEME.news_internal),
            category_dd,
    
            Oil.Label(10, 0, -10, 25, "Author(s) (comma separated):", LEFT)
            :set_style_sheet(UI.THEME.news_internal),
            authors_text_entry,
    
            Oil.Label(10, 0, -10, 25, "Short Description (max. 4 words):", LEFT)
            :set_style_sheet(UI.THEME.news_internal),
            short_description_text_entry,
    
            Oil.Label(10, 0, -10, 25, "Full Description:", LEFT)
            :set_style_sheet(UI.THEME.news_internal),
            description_text_entry,
    
            Oil.Label(10, 0, -10, 25, "Version ID (max. 10 chars):", LEFT)
            :set_style_sheet(UI.THEME.news_internal),
            version_text_entry,
    
            Oil.Label(10, 0, -10, 25, "Update Notes:", LEFT)
            :set_style_sheet(UI.THEME.news_internal),
            update_notes_text_entry,
    
            Oil.Label(10, 0, -10, 25, "Forum Link (optional)", LEFT)
            :set_style_sheet(UI.THEME.news_internal),
            forum_link_text_entry,
    
            Oil.Label(10, 0, -10, 25, "Admin Key (protected projects only)", LEFT)
            :set_style_sheet(UI.THEME.news_internal),
            Oil.TextEntry(10, 0, -10, 35, "", function(str)
                meta.key = str
            end)
            :set_style_sheet(UI.THEME.text_entry),
    
            Oil.LabelResize(10, 0, -10, 25, "Following submission an admin will review your project to ensure it meets guidelines before being made available.\n\nNote: Please allow a few minutes for your submission to appear in the review menu.")
            :set_style_sheet(UI.THEME.news_internal)
            :add_style("textWrapWidth", 0.7),
            Oil.TextButton(0.5, 0, 250, 40, "Upload & Submit", function(bttn)
                local success, err = verifyAndSubmit(bttn, error_label, function()
                    tween(2.0, {}, {}, nil, function()
                        bttn:add_style("text", "Upload & Submit")
                    end)
                end)
                if not success then
                    error_label:add_style("text", err)
                else
                    error_label:add_style("text", "")
                end
            end)
            :set_style_sheet(UI.THEME.button),
    
            error_label
        )
    )
    
    root:add_children(
        scroll,
    
        Oil.Label(0.5, -0.0001, 1.0, 50, "Submit New Project")
        :set_style_sheet(UI.THEME.button)
        :add_style("fontSize", 20)
        :add_style("font", "HelveticaNeue-Bold"),
    
        -- Close button
        Oil.EmojiButton(10, -10, 30, 30, "❌", function()
            saveMeta()
            root:kill()
        end)
        :set_style_sheet(UI.THEME.button)
        :add_style("fontSize", 14)
        :add_style("textFill", color(255)),
    
        -- 1 pixel line
        Oil.Rect(5, -50, -5, 1.0001)
        :set_style_sheet(UI.THEME.divider)
    )
    
    return root
end