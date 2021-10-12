-- OIL Demo

viewer.mode = FULLSCREEN
viewer.preferredFPS = 60

local function demo()
    local bttn_bar = OIL.Frame(0, 0, 1.0, 90, 10, color(110), nil, true)
    function bttn_bar:on_event(event) -- block input
        if self:pos_is_inside(event.pos) then return self end
    end
    
    local bttn_size, bttn_spacing = 40, 20
    local bttn_news = OIL.UnicodeIcon(0.3, -10, bttn_size, bttn_size, "📅")
    local bttn_games = OIL.UnicodeIcon(0.4, -10, bttn_size, bttn_size, "🎮")
    local bttn_apps = OIL.UnicodeIcon(0.5, -10, bttn_size, bttn_size, "🛠")
    local bttn_libs = OIL.UnicodeIcon(0.6, -10, bttn_size, bttn_size, "📚")
    local bttn_search = OIL.UnicodeIcon(0.7, -10, bttn_size, bttn_size, "🔍")
    
    function bttn_bar:update()
        local step = bttn_size + bttn_spacing
        bttn_news.x = (self.frame.w - (5*bttn_size + 4*bttn_spacing))// 2
        bttn_games.x = bttn_news.x + step
        bttn_apps.x = bttn_games.x + step
        bttn_libs.x = bttn_apps.x + step
        bttn_search.x = bttn_libs.x + step
    end
    
    bttn_bar:add_child(bttn_news)
    bttn_bar:add_child(bttn_games)
    bttn_bar:add_child(bttn_apps)
    bttn_bar:add_child(bttn_libs)
    bttn_bar:add_child(bttn_search)
    
    local news_screen = OIL.ScrollingContainer(0, 0, 1.0, 1.0, 1)
    
    -- New App News!
    local e = OIL.RoundedFrame(0,0,1.0,1.0, nil, color(255), asset.builtin.Environments.Night_Front)
    e:add_child(OIL.Frame(0, 40, 1.0, 40, nil, color(220)))
    e:add_child(OIL.RoundedFrame(0, 0, 1.0, 80, nil, color(220))
        :add_child(OIL.Icon(asset.builtin.Small_World.Icon, 30, 0.5, 70, 70))
        :add_child(OIL.TextLabel(110, 0.70, 1.0, 1.0, "Small World", color(48), 32))
        :add_child(OIL.TextLabel(110, 0.32, 1.0, 1.0, "Daniel Cook", color(96), 24))
        :add_child(OIL.TextButton(-130, 0.5, -12, 50, "Install", function()
            OIL.Dialog("Dialog!", "This is a test dialog, you can open these to interrupt your normal UI.\n\nUnfortunately you can't actually install this so you'll have to wait for WebRepo 2.0 :)", function(result)
                -- result is either true or false
            end)
        end)
    ))
    e:add_child(OIL.TextLabel(30, -10, 1.0, 1.0, "New App - Small World", color(255), 32))
    e.id = "news"
    news_screen:add_child(e)
    
    -- Random list of icons? Why not?
    e = OIL.RoundedFrame(0,0,0,0, nil, color(69, 130, 218))
    l = OIL.List(0, 0, 1.0, 1.0, 30)
    l:add_child(OIL.UnicodeIcon(0.5, 0.5, 64, 64, "🎮"))
    l:add_child(OIL.UnicodeIcon(0.5, 0.5, 64, 64, "🌍"))
    l:add_child(OIL.UnicodeIcon(0.5, 0.5, 64, 64, "🌦"))
    l:add_child(OIL.UnicodeIcon(0.5, 0.5, 64, 64, "☄️"))
    l:add_child(OIL.UnicodeIcon(0.5, 0.5, 64, 64, "🍿"))
    l:add_child(OIL.UnicodeIcon(0.5, 0.5, 64, 64, "🎬"))
    l:add_child(OIL.UnicodeIcon(0.5, 0.5, 64, 64, "🎳"))
    l:add_child(OIL.UnicodeIcon(0.5, 0.5, 64, 64, "🧩"))
    l:add_child(OIL.UnicodeIcon(0.5, 0.5, 64, 64, "🏎"))
    e:add_child(l)
    news_screen:add_child(e)
    
    -- Toggle test
    e = OIL.RoundedFrame(0,0,0,0, nil, color(69, 218, 155))
    e:add_child(OIL.Toggle(20, 0.8)):add_child(OIL.TextLabel(104, 0.8, 0, 0, "I'm a toggle!", color(255), 24, LEFT))
    e:add_child(OIL.Toggle(20, 0.6)):add_child(OIL.TextLabel(104, 0.6, 0, 0, "I'm another!", color(255), 24, LEFT))
    e:add_child(OIL.Toggle(20, 0.4)):add_child(OIL.TextLabel(104, 0.4, 0, 0, "and another...", color(255), 24, LEFT))
    e:add_child(OIL.Toggle(20, 0.2)):add_child(OIL.TextLabel(104, 0.2, 0, 0, "and another...", color(255), 24, LEFT))
    news_screen:add_child(e)
    
    -- Slider test
    e = OIL.RoundedFrame(0,0,0,0, nil, color(218, 69, 192))
    -- Slider 1
    e:add_child(OIL.TextLabel(0.5, 0.9, 1.0, 1.0, "Sliders", color(255), 32))
    local slider = OIL.Slider(0.5, 0.7, 0.8, 0, 100, 87, true, function(s, v)
        s:get_handle().style.text = string.format("Int: %d", v)
    end)
    -- Add value label to handle
    slider:get_handle():add_child(OIL.TextLabel(0.5, 1.5, 0, 0, nil, color(255), 20))
    e:add_child(slider)
    -- Slider 2
    local slider = OIL.Slider(0.5, 0.5, 0.8, 0, 5, 1.3, false, function(s, v)
        s:get_handle().style.text = string.format("Float: %.2f", v)
    end)
    -- Add value label to handle
    slider:get_handle():add_child(OIL.TextLabel(0.5, 1.5, 0, 0, nil, color(255), 20))
    e:add_child(slider)
    -- Slider 3
    local slider = OIL.Slider(0.5, 0.3, 0.8, 0, 5, 4, true, function(s, v)
        s:get_handle().style.text = string.format("Int: %d", v)
    end)
    -- Add value label to handle
    slider:get_handle():add_child(OIL.TextLabel(0.5, 1.5, 0, 0, nil, color(255), 20))
    e:add_child(slider)
    news_screen:add_child(e)
    
    -- Text Input demo
    e = OIL.RoundedFrame(0,0,0,0, nil, color(0, 232, 255))
    e:add_child(OIL.TextInputField(0.5, 0.6, 0.8, 0.7, "I'm a text input field!\n\n- Tap on me to focus\n- Drag or scroll to scroll text\n- Tap to move the cursor\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\nWow!"))
    e:add_child(OIL.TextInputField(0.5, 0.125, 0.8, 0.15, "I'm just another input field"))
    news_screen:add_child(e)
    
    -- Dropdown demo
    e = OIL.RoundedFrame(0,0,0,0, nil, color(226, 72, 60))
    local dd = OIL.Dropdown(0.5, 0.9, 0.9, 0.9, "App:", function(self, item)
        self.style.text = "App: " .. item.style.text
    end)
    dd:add_item(OIL.TextLabel(0.5, 0.5, 1.0, 30, "Oil", nil, 24))
    dd:add_item(OIL.TextLabel(0.5, 0.5, 1.0, 30, "SODA", nil, 24))
    dd:add_item(OIL.TextLabel(0.5, 0.5, 1.0, 30, "WebRepo", nil, 24))
    dd:add_item(OIL.TextLabel(0.5, 0.5, 1.0, 30, "Foggy", nil, 24))
    dd:add_item(OIL.TextLabel(0.5, 0.5, 1.0, 30, "Fish", nil, 24))
    dd:add_item(OIL.TextLabel(0.5, 0.5, 1.0, 30, "Captain Codea", nil, 24))
    dd:add_item(OIL.TextLabel(0.5, 0.5, 1.0, 30, "Galaxian", nil, 24))
    dd:add_item(OIL.TextLabel(0.5, 0.5, 1.0, 30, "Butterflies", nil, 24))
    e:add_child(dd)
    news_screen:add_child(e)
    
    -- Old boring 'news' frames
    news_screen:add_child(OIL.RoundedFrame(0,0,0,0, nil, color(241, 255, 0)))
    news_screen:add_child(OIL.RoundedFrame(0,0,0,0, nil, color(18, 255, 0)))
    
    news_screen.scroll_buffer_top = 70
    news_screen.scroll_buffer_bottom = 120
    
    function news_screen:update()
        local item_spacing = 30
        local item_height = 400
        
        local iw = (self.frame.w - (item_spacing*3)) / 3
        
        -- Update child positioning and sizes
        if iw <= 250 then
            iw = self.frame.w - (item_spacing*2)
            for i,child in ipairs(self.children) do
                child.w = iw
                child.y = -(item_spacing + (item_spacing + item_height)*(i-1))
                child.x = item_spacing
                child.h = 400
            end
        else
            for i,child in ipairs(self.children) do
                local i = i-1
                local isLeft = ((i%2) == 0)
                local isLarge = ((i%4)%3 == 0)
                child.w = isLarge and (iw*2) or iw
                child.y = -(item_spacing  + (item_spacing + item_height)*(i//2))
                child.x = isLeft and item_spacing or -item_spacing
                child.h = 400
            end
        end
    end
end

function setup()
    OIL.setup()
    
    parameter.watch("FPS()")
    parameter.watch("LuaMem()")
    
    -- Do our pre-OIL rendering here
    OIL.root:add_render_component(OIL.RenderComponent(function(self, w, h)
        -- Clear the screen
        background(32)
    end))
    
    demo()
end
    

function draw()
    OIL.draw()
end

function sizeChanged(w, h)
    OIL.sizeChanged(w, h)
end

function touched(touch)
    OIL.touched(touch)
end

function hover(gesture)
    OIL.hover(gesture)
end

function scroll(gesture)
    OIL.scroll(gesture)
end

function pinch(gesture)
    OIL.pinch(gesture)
end

function keyboard(key)
    OIL.keyboard(key)
end

function LuaMem()
    return math.floor(collectgarbage('count'))
end

function FPS()
    return math.floor(1.0 / DeltaTime)
end
