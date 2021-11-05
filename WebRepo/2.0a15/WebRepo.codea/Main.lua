-- WebRepoSub

-- TODO:
-- Metadata review
-- One line text entry
-- Dynamic texture loading to reduce memory usage
-- Asset bundles
-- Multi project bundles
-- (DONE) Search tab
-- (DONE) Auto-update
-- (DONE) Remove old projects from repo
-- (DONE) Check flow of private keys/passwords
-- (DONE) iPhone & iPad specific projects
-- (DONE) Tab animations
-- (DONE) Handle submissions with dependencies
-- (DONE) Oil scroll nested clipping
-- (DONE) Fix buttons on news & app lists
-- (DONE) Settings screenr
-- (DONE) Approval timestamps (github end)
-- (DONE) Admin submissions
-- (DONE) Project sizes
-- (DONE) Forum-links
-- (DONE) Remove .version during submission
-- (DONE) What's New strings

function setup()
    viewer.mode = FULLSCREEN_NO_BUTTONS
    viewer.preferredFPS = 60
    
    Oil.setup()
    DB.setup()
    
    Oil.root:add_renderer(Oil.RectRenderer)
        :set_style(UI.THEME.background)
    
    -- Top right buttons
    do
        local node = Oil.HorizontalStack(-10, -(0.0001 + layout.safeArea.top), 1.0, 50)
        :set_priority(10)
        :add_style("align", RIGHT)
        
        -- Add review button
        UI.REVIEW_BUTTON = Oil.TextButton(0, 0.5, 80, 30, "Review", function()
            ReviewWindow()
        end)
        :set_style_sheet(UI.THEME.button)
        
        -- Allow it to be disabled
        UI.REVIEW_BUTTON.enabled = UI.ENABLE_REVIEW

        node:add_child(UI.REVIEW_BUTTON)
        
        -- Add other buttons
        node:add_children(
            Oil.TextButton(0, 0.5, 80, 30, "Submit", function()
                SubmitWindow()
            end)
            :set_style_sheet(UI.THEME.button),
        
            Oil.TextButton(0, 0.5, 80, 30, "Settings", function()
                SettingsWindow()
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
    local search = AppList(true) -- enable search
    CreateTabRow(news, games, apps, libs, --[[assets,]] search)
    
    -- Initialise tabs
    initNewsNode(news)
    news.hidden = true
    
    local onLoadStore = function(store)
        if store then
            
            -- Check if WebRepo is up to date and offer to update
            local webrepo_versions = store["WebRepo"]
            local webrepo_app = webrepo_versions[#webrepo_versions]
            if not DB.isAppInstalled("WebRepo", webrepo_app.version) then
                Oil.Alert("A WebRepo update is available.\nWould you like to update?\n(Recommended)",
                    function(result)
                        if result then
                            local status = Oil.StatusModal("Updating", UI.THEME.alert)
                            DB.downloadApp(webrepo_app, function(success, err)
                                if success then
                                    DB.installApp(webrepo_app.name, webrepo_app.version)
                                    viewer.close()
                                else
                                    status:kill()
                                end
                            end)
                        end
                    end,
                    UI.THEME.alert, UI.THEME.button_fixed)
            end
            
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
                
                search:add_app(app)
            end
            
            --apps:sort()
            --games:sort()
            --libs:sort()
        else
            print("Failed to load store")
        end
        news.hidden = false
    end
    
    -- Initialise the backend
    DB.loadStore(onLoadStore)
end

function draw()
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
