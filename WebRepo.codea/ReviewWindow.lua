
local entries = {}

-- Please don't hardcode a key here to avoid accidentally
-- publishing a key.
local review_key = ""

local function TextDropdown(x, y, w, h, default, callback)
    local dd = Oil.Dropdown(x, y, w, h, default)
    :add_style(UI.THEME.dropdown)
    
    dd.state.handler = function(node, event)
        if event.type == "tap" and node:covers(event.pos) then
            local val = node:get_style("text")
            dd:add_style("text", val)
            dd:transition(false)
            callback(val)
            return true
        end
        return false
    end
    
    return dd
end

function ReviewWindow()
    local root = Oil.Rect(0, 0, 1.0, 1.0)
    :set_priority(20)
    :set_style_sheet(UI.THEME.background)
    :add_handler(function(node, event)
        return true
    end)
    
    local forum_link_url
    local metadata_label = Oil.LabelResize(10, 0, -10, 800, "", LEFT)
    :add_style("textWrapWidth", 700)
    
    local forum_link_bttn = Oil.TextButton(0.5, 0, 250, 40, "Test Forum Link", function(bttn)
        if forum_link_url then
            openURL(forum_link_url, true)
        end
    end)
    :set_style_sheet(UI.THEME.button)
    :add_style("autoResize", false)
    
    local function update_metadata(id)
        DB.getReviewCandidateMetadata(entries[id], function(metadata)
            local json_md = json.decode(metadata)
            forum_link_url = json_md.forum_link
            
            metadata = metadata:gsub("\\n", "\n")
            metadata_label:add_style("text", metadata)
        end)
    end
    
    local project_dd = TextDropdown(10, 0, -10, 30, "", function(str)
        update_metadata(str)
    end)
    
    local list = Oil.Scroll(0.5, 0, 1.0, -51)
    :add_style("clipAxis", AXIS_Y)
    :add_style("bufferBottom", layout.safeArea.bottom)
    :add_child(Oil.List(0.5, -50, 1.0)
    :add_children(
        Oil.Label(10, 0, -10, 25, "Project:", LEFT)
        :set_style_sheet(UI.THEME.news_internal),
        project_dd,
    
        Oil.Label(10, 0, -10, 25, "Admin Key (for approval & rejection):", LEFT)
        :set_style_sheet(UI.THEME.news_internal),
        Oil.TextEntry(10, 0, -10, 35, review_key, function(str)
            review_key = str
        end)
        :set_style_sheet(UI.THEME.text_entry),
    
        Oil.Label(10, 0, -10, 25, "Metadata JSON:", LEFT)
        :set_style_sheet(UI.THEME.news_internal),
        metadata_label,
    
        forum_link_bttn,
    
        Oil.TextButton(0.5, 0, 250, 40, "INSTALL", function(bttn)
            if project_dd:get_style("text") ~= "" then
                DB.installReviewCandidate(entries[project_dd:get_style("text")], bttn)
            end
        end)
        :set_style_sheet(UI.THEME.button)
        :add_style("autoResize", false),
    
        Oil.TextButton(0.5, 0, 250, 40, "APPROVE", function(bttn)
            if project_dd:get_style("text") ~= "" then
                DB.approveReviewCandidate(entries[project_dd:get_style("text")], review_key, function(msg)
                    bttn:add_style("text", msg)
                    tween(3, {}, {}, tween.easing.linear, function()
                        bttn:add_style("text", "APPROVE")
                    end)
                end)
            end
        end)
        :set_style_sheet(UI.THEME.button)
        :add_style("autoResize", false),
    
        Oil.TextButton(0.5, 0, 250, 40, "REJECT", function(bttn)
            if project_dd:get_style("text") ~= "" then
                DB.rejectReviewCandidate(entries[project_dd:get_style("text")], review_key, function(msg)
                    bttn:add_style("text", msg)
                    tween(3, {}, {}, tween.easing.linear, function()
                        bttn:add_style("text", "REJECT")
                    end)
                end)
            end
        end)
        :set_style_sheet(UI.THEME.button)
        :add_style("autoResize", false),
    
        Oil.LabelResize(10, 0, -10, 25, "Note: Please allow a few minutes for the project to become available following approval.")
        :set_style_sheet(UI.THEME.news_internal)
        :add_style("textWrapWidth", 0.7)
    ))
    
    root:add_children(
        -- Close button
        Oil.EmojiButton(10, -10, 30, 30, "❌", function()
            root:kill()
        end)
        :set_style_sheet(UI.THEME.button)
        :add_style("fontSize", 14)
        :add_style("textFill", color(255)),
    
        Oil.Label(0.5, -0.0001, 1.0, 50, "Review Submissions")
        :set_style_sheet(UI.THEME.button)
        :add_style("fontSize", 20)
        :add_style("font", "HelveticaNeue-Bold"),
    
        -- 1 pixel line
        Oil.Rect(5, -50, -5, 1.0001)
        :set_style_sheet(UI.THEME.divider),
    
        -- The content
        list
    )
    
    -- Refresh the queue
    DB.getReviewQueue(function(queue)
        queue = queue or {}
        for i,e in ipairs(queue) do
            
            -- Add to entries map
            entries[e.name .. "-" .. e.version] = e
            
            -- Add to dropdown
            if i > 1 then
                project_dd:add_child(
                -- 1 pixel line
                Oil.Rect(0.5, 0, 100, 1.0001)
                :set_style_sheet(UI.THEME.divider)
                )
            else
                project_dd:add_style("text", e.name .. "-" .. e.version)
                update_metadata(e.name .. "-" .. e.version)
            end
            project_dd:add_child(
                -- Label
                Oil.Label(0, 0, 1.0, 20, e.name .. "-" .. e.version)
                :add_handler(project_dd.state.handler)
                :set_style_sheet(UI.THEME.dropdown)
            )
        end
    end)
end
