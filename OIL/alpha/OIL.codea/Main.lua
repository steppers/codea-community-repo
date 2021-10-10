-- OIL Demo

viewer.mode = FULLSCREEN
viewer.preferredFPS = 60

local function demo()
    local bttn_bar = OIL.Frame(0, 0, 1.0, 90, 10, color(110), nil, true)
    function bttn_bar:on_event(event) -- block input
        if self:pos_is_inside(event.pos) then return self end
    end
    
    local bttn_size, bttn_spacing = 40, 20
    local bttn_news = OIL.UnicodeIcon("📅", 0.3, -10, bttn_size, bttn_size)
    local bttn_games = OIL.UnicodeIcon("🎮", 0.4, -10, bttn_size, bttn_size)
    local bttn_apps = OIL.UnicodeIcon("🛠", 0.5, -10, bttn_size, bttn_size)
    local bttn_libs = OIL.UnicodeIcon("📚", 0.6, -10, bttn_size, bttn_size)
    local bttn_search = OIL.UnicodeIcon("🔍", 0.7, -10, bttn_size, bttn_size)
    
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
    e:add_child(OIL.Frame(0, 50, 1.0, 50, nil, color(197)))
    e:add_child(OIL.RoundedFrame(0, 0, 1.0, 100, nil, color(197))
        :add_child(OIL.Icon(asset.builtin.Small_World.Icon, 30, 0.5, 70, 70))
        :add_child(OIL.Text("Small World", 110, 0.70, 1.0, 1.0, CENTER, color(48), 32))
        :add_child(OIL.Text("Daniel Cook", 110, 0.32, 1.0, 1.0, CENTER, color(96), 24))
        :add_child(OIL.Button("Install", nil, -130, 0.5, -12, 50)))
    e:add_child(OIL.Text("New App - Small World", 30, -10, 1.0, 1.0, CENTER, color(255), 32))
    e.id = "news"
    news_screen:add_child(e)
    
    -- Random list of icons? Why not?
    e = OIL.RoundedFrame(0,0,0,0, nil, color(69, 130, 218))
    l = OIL.List(0, 0, 1.0, 1.0, 30)
    l:add_child(OIL.UnicodeIcon("🎮", 0.5, 0.5, 64, 64))
    l:add_child(OIL.UnicodeIcon("🌍", 0.5, 0.5, 64, 64))
    l:add_child(OIL.UnicodeIcon("🌦", 0.5, 0.5, 64, 64))
    l:add_child(OIL.UnicodeIcon("☄️", 0.5, 0.5, 64, 64))
    l:add_child(OIL.UnicodeIcon("🍿", 0.5, 0.5, 64, 64))
    l:add_child(OIL.UnicodeIcon("🎬", 0.5, 0.5, 64, 64))
    l:add_child(OIL.UnicodeIcon("🎳", 0.5, 0.5, 64, 64))
    l:add_child(OIL.UnicodeIcon("🧩", 0.5, 0.5, 64, 64))
    l:add_child(OIL.UnicodeIcon("🏎", 0.5, 0.5, 64, 64))
    e:add_child(l)
    news_screen:add_child(e)
    
    -- Toggle test
    e = OIL.RoundedFrame(0,0,0,0, nil, color(69, 218, 155))
    e:add_child(OIL.Toggle(20, 0.8)):add_child(OIL.Text("I'm a toggle!", 104, 0.8, 0, 0, LEFT, color(255), 24))
    e:add_child(OIL.Toggle(20, 0.6)):add_child(OIL.Text("I'm another!", 104, 0.6, 0, 0, LEFT, color(255), 24))
    e:add_child(OIL.Toggle(20, 0.4)):add_child(OIL.Text("and another...", 104, 0.4, 0, 0, LEFT, color(255), 24))
    e:add_child(OIL.Toggle(20, 0.2)):add_child(OIL.Text("and another...", 104, 0.2, 0, 0, LEFT, color(255), 24))
    news_screen:add_child(e)
    
    -- Slider test
    e = OIL.RoundedFrame(0,0,0,0, nil, color(218, 69, 192))
    local slider = OIL.Slider(0.5, 0.5, 0.8, 0, 1, function(s, v)
        s:get_handle().style.text = string.format("%.2f", v)
    end)
    -- Add value label to handle
    slider:get_handle():add_child(OIL.Text(nil, 0.5, 1.5, 0, 0, CENTER, color(255), 20, false))
    slider:get_handle().style.text = "0.00"
    e:add_child(slider)
    news_screen:add_child(e)
    
    -- Old boring 'news' frames
    news_screen:add_child(OIL.RoundedFrame(0,0,0,0, nil, color(226, 72, 60)))
    news_screen:add_child(OIL.RoundedFrame(0,0,0,0, nil, color(0, 232, 255)))
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

function LuaMem()
    return math.floor(collectgarbage('count'))
end

function FPS()
    return math.floor(1.0 / DeltaTime)
end
