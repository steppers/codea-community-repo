-- WebRepoSub

-- TODO:
-- Fix buttons on news & app lists
-- Search tab
-- Sorted app lists
-- Auto-update
-- Check flow of private keys/passwords
-- (DONE) Approval timestamps (github end)
-- (DONE) Admin submissions
-- (DONE) Project sizes
-- (DONE) Forum-links
-- (DONE) Remove .version during submission
-- (DONE) What's New strings

local function import_bin(name)
    local f = io.open((asset .. name .. ".lbin").path, "rb")
    load(f:read("*a"))()
    f:close()
end

import_bin("Oil")
import_bin("Zip")

function setup()
    Oil.setup()
    DB.setup()
    
    Oil.root:add_renderer(Oil.RectRenderer)
        :set_style(UI.THEME.background)
    
    -- Top right buttons
    do
        local node = Oil.HorizontalStack(-10, -(0.0001 + layout.safeArea.top), 1.0, 50)
        :set_priority(10)
        :add_style("align", RIGHT)
        
        -- Add review button if review is enabled
        if UI.ENABLE_REVIEW then
            node:add_child(Oil.TextButton(0, 0.5, 80, 30, "Review", function()
                ReviewWindow()
            end)
            :set_style_sheet(UI.THEME.button))
        end
        
        -- Add other buttons
        node:add_children(
            Oil.TextButton(0, 0.5, 80, 30, "Submit", function()
                SubmitWindow()
            end)
            :set_style_sheet(UI.THEME.button),
        
            Oil.TextButton(0, 0.5, 80, 30, "Settings", function()
                --SettingsWindow()
            end)
            :set_style_sheet(UI.THEME.button)
        )
    end
    
    -- Top left buttons
    Oil.HorizontalStack(10, -(0.0001 + layout.safeArea.top), 1.0, 50)
    :set_priority(10)
    :add_style("align", LEFT)
    :add_children(
        Oil.EmojiButton(0, 0.5, 30, 30, "❌", function()
            viewer.close()
        end)
        :set_style_sheet(UI.THEME.button)
        :add_style("fontSize", 14)
        :add_style("textFill", color(255))
    )
    
    -- Bottom bar
    local news = Oil.Node(0, 0, 1.0, 1.0)
    local games = AppList()
    local apps = AppList()
    local libs = AppList()
    --local assets = AppList()
    local search = AppList()
    CreateTabRow(news, games, apps, libs, --[[assets,]] search)
    
    -- Initialise tabs
    initNewsNode(news)
    
    local onLoadStore = function(store)
        if store then
            for name,versions in pairs(store) do
                -- Only use the latest version
                local app = store[name][#versions]
                
                newsAddItem({
                    type = (#versions == 1 and "new_project") or "new_update",
                    app = app
                })
                
                if app.info.category == "App" then
                    apps:add_app(app)
                elseif app.info.category == "Game" then
                    games:add_app(app)
                elseif app.info.category == "Library" then
                    libs:add_app(app)
                elseif app.info.category == "Assets" then
                    --assets:add_app(app)
                    libs:add_app(app)
                end
            end
            
            --apps:sort()
            --games:sort()
            --libs:sort()
        else
            print("Failed to load store")
        end
    end
    
    -- Initialise the backend
    DB.loadStore(onLoadStore)
end

function draw()
    viewer.mode = FULLSCREEN_NO_BUTTONS
    collectgarbage("collect")
    
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
