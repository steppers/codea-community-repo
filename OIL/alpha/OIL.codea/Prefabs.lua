    
function OIL.Button(x, y, w, h, callback)
    
    local e = OIL.Element{
        x = x or 0.5, y = y or 0.5, w = w or 0.5, h = h or 60,
        on_event = function(self, event)
            if self:pos_is_inside(event.pos) then
                if event.type == OIL.ETTouchDown then
                    return self
                elseif event.type == OIL.ETTap then
                    if callback then callback(self) end
                    return self
                elseif event.type == OIL.ETHover then
                    return self
                end
            end
                    
            if event.type == OIL.ETTouchUp or event.type == OIL.ETHover or event.type == ETScroll then
                return nil
            end
        end,
        style = {
            scale = 1.0
        }
    }
    
    return e
end

function OIL.TextButton(x, y, w, h, label, callback)
    
    local e = OIL.Element{
        x = x or 0.5, y = y or 0.5, w = w or 0.5, h = h or 60,
        on_event = function(self, event)
            if self:pos_is_inside(event.pos) then
                if event.type == OIL.ETTouchDown then
                    self.style.fill = self.render_components[1]:get_style("fillSelected")
                    --tween(0.05, self.style, { scale = 0.95 })
                    return self
                elseif event.type == OIL.ETTap then
                    if callback then callback(self) end
                    return self
                elseif event.type == OIL.ETHover then
                    self.style.fill = self.render_components[1]:get_style("fillHover")
                    return self
                end
            end
                    
            if event.type == OIL.ETTouchUp or event.type == OIL.ETHover or event.type == ETScroll then
                self.style.fill = self.render_components[1]:get_style("fillUnselected")
                --tween(0.05, self.style, { scale = 1.0 })
                return nil
            end
        end,
        style = {
            text = label,
            fill = OIL.Style.default.fillUnselected,
            scale = 1.0
        }
    }
    :add_render_component(OIL.RenderComponent.RoundedRect(), OIL.Style.button.bg)
    :add_render_component(OIL.RenderComponent.Text(), OIL.Style.button.text)
    
    return e
end

function OIL.Icon(asset, x, y, w, h, radius, priority)
    local e = OIL.Element{
        x = x or 0.5, y = y or 0.5, w = w or 64, h = h or 64, priority = priority or 0,
        style = {
            fill = color(255),
            tex = asset,
            radius = radius,
        }
    }
    
    if radius ~= nil then
        e:add_render_component(OIL.RenderComponent.RoundedRect())
    else
        e:add_render_component(OIL.RenderComponent.Rect())
    end
        
    return e
end

function OIL.UnicodeIcon(x, y, w, h, icon_string, priority)
    return OIL.Element{
        x = x or 0.5, y = y or 0.5, w = w or 64, h = h or 64, priority = priority or 0,
        style = {
            text = icon_string,
            fontSize = h
        }
    }
    :add_render_component(OIL.RenderComponent.Text())
end

function OIL.Frame(x, y, w, h, priority, color, tex, blurred)
    return OIL.Element{
        x = x or 0.5, y = y or 0.5, w = w or 0.5, h = h or 0.5, priority = priority or 0,
        style = {
            fill = color,
            tex = tex,
            blur = blurred
        }
    }
    :add_render_component(OIL.RenderComponent.Rect())
end

function OIL.RoundedFrame(x, y, w, h, priority, color, tex, blurred)
    return OIL.Element{
        x = x or 0.5, y = y or 0.5, w = w or 0.5, h = h or 0.5, priority = priority or 0,
        style = {
            fill = color,
            tex = tex,
            blur = blurred
        }
    }
    :add_render_component(OIL.RenderComponent.RoundedRect())
end

function OIL.Container(x, y, w, h, priority)
    return OIL.Element{
        x = x or 0.5, y = y or 0.5, w = w or 0.5, h = h or 0.5, priority = priority or 0
    }
end

function OIL.ScrollingContainer(x, y, w, h, priority)
    local e = OIL.Element({
        x = x or 0.5, y = y or 0.5, w = w or 0.5, h = h or 0.5, priority = priority or 0,
        scroll_y = 0, scroll_vy = 0, free_scroll = true
    })
    
    function e:_update()
        self.scroll_y = self.scroll_y + self.scroll_vy
        self.scroll_vy = self.scroll_vy * 0.94
        
        local top = self.frame.t_unscrolled
        local bottom = self.frame.b_unscrolled
        for _,child in ipairs(self.children) do
            top = math.max(top, child.frame.t_unscrolled)
            bottom = math.min(bottom, child.frame.b_unscrolled)
        end
        self.scrollHeight = (top - bottom) + (self.scroll_buffer_bottom or 0) + (self.scroll_buffer_top or 0)
        if self.h > self.scrollHeight then
            self.scrollHeight = 0
        end
        
        local scrollH = math.max(0, self.scrollHeight - self.frame.h)
        if self.scroll_y<0 then 
            self.scroll_y = self.scroll_y * 0.6
        elseif self.scroll_y>scrollH then
            self.scroll_y = self.scroll_y - ((self.scroll_y - scrollH) * 0.6)
        end
    end
    
    function e:on_event(event)
        if event.type == OIL.ETScroll or event.type == OIL.ETPan then
            if event.state == BEGAN and self:pos_is_inside(event.pos) then
                self.scroll_vy = event.delta.y
                self.scrolling = true
                return self
            elseif self.scrolling and event.state == CHANGED then
                self.scroll_vy = event.delta.y
                return self
            elseif self.scrolling and event.state == ENDED then
                self.scrolling = false
                return self
            end
        end
        return nil
    end
    
    function e:draw_children(hidden, do_draw)
        -- Set clip so the children do not escape the container
        clip(self.frame.l, self.frame.b, self.frame.w, self.frame.h)
        
        -- Draw
        OIL.Element.draw_children(self, hidden, do_draw)
        
        -- Reset the clip
        clip()
    end
    
    return e
end

function OIL.Text(x, y, w, h, txt, style, fit_parent, priority)
    local e = OIL.Element{
        x = x or 0.5, y = y or 0.5, w = w or 0.5, h = h or 0.5, priority = priority or 0,
        style = {
            text = txt
        },
        fit_parent = fit_parent
    }
    
    function e:update()
        if e.fit_parent == nil or e.fit_parent then
            self.style.textWrapWidth = self.parent.frame.w - 10
        end
    end
    
    e:add_render_component(OIL.RenderComponent(function(self, w, h, do_draw)
        textMode(CENTER)
        self:apply_style("fontSize")
        self:apply_style("fillText")
        self:apply_style("textWrapWidth")
        self:apply_style("textAlign")
        
        local tw, th = textSize(self:get_style("text"))
        
        -- Resize the owner
        self.owner.w = tw
        self.owner.h = th
        
        if do_draw == nil or do_draw then
            text(self:get_style("text"), tw/2, th/2)
        end
    end), style)
    
    return e
end

function OIL.TextLabel(x, y, w, h, label, col, font_size, align, fit_parent, priority)
    return OIL.Text(x, y, w, h, label, {
        fontSize = font_size or 16,
        fillText = col or color(0),
        textWrapWidth = 0,
        textAlign = align or CENTER
    }, fit_parent or false, priority)
end

function OIL.List(x, y, w, h, spacing, priority)
    local e = OIL.ScrollingContainer(x, y, w, h, priority or 0)
    local spacing = spacing or 0
    
    function e:update()
        local y = -0.001
        for _,child in ipairs(self.children) do
            child.x = 0.5
            child.y = y
            y = y - child.h - spacing
        end
        self.list_height = -y
    end
    
    return e
end

function OIL.Toggle(x, y, callback, priority)
    local e = OIL.Element{
        x = x or 0.5, y = y or 0.5, w = 64, h = 36, priority = priority or 0,
        style = OIL.Style.clone(OIL.Style.toggle.bg),
        value = false
    }
    :add_render_component(OIL.RenderComponent.RoundedRect())
    
    local knob = OIL.Element{
        x = 0.25, y = 0.5, w = 0.5625, h = 1.0,
        style = OIL.Style.clone(OIL.Style.toggle.handle)
    }
    :add_render_component(OIL.RenderComponent.RoundedRect())
    e:add_child(knob)
    
    function e:on_event(event)
        if event.type == OIL.ETTap and self:pos_is_inside(event.pos) then
            self.value = not self.value
            if self.value then
                self.style.fill = self:get_style("fillToggleOn")
                tween(0.2, knob, {x = 0.75})
            else
                self.style.fill = self:get_style("fillToggleOff")
                tween(0.2, knob, {x = 0.25})
            end
            
            self.tween = tween.path(0.2, self.style, {
                {scale = 1.0},
                {scale = 0.8},
                {scale = 1.0}
            })
            
            if callback then callback(self.value) end
        end
    end
    
    return e
end

function OIL.Slider(x, y, w, min, max, default, integer, callback, priority)
    local e = OIL.Element{
        x = x or 0.5, y = y or 0.5, w = w, h = 2, priority = priority or 0,
        style = OIL.Style.clone(OIL.Style.slider.bar),
        value = 0.0
    }
    :add_render_component(OIL.RenderComponent.Rect())
    
    local handle = OIL.Element{
        x = 0.001, y = 0.5, w = 32, h = 32,
        style = OIL.Style.clone(OIL.Style.slider.handle)
    }
    :add_render_component(OIL.RenderComponent.RoundedRect())
    e:add_child(handle)
        
    local function over(self, pos)
        return  self.frame.l <= pos.x and
                self.frame.r >= pos.x and
                self.frame.b-15 <= pos.y and
                self.frame.t+15 >= pos.y
    end
    
    function e:on_event(event)            
        if event.type == OIL.ETPan then
            if event.state == BEGAN and over(self, event.pos) then
                handle.style.fill = handle:get_style("fillDragging")
                self.dragging = true
            elseif event.state == ENDED then
                handle.style.fill = handle:get_style("fillNotDragging")
                self.dragging = false
            end
        end
        
        if self.dragging then
            local offset = math.min(math.max((event.pos.x - self.frame.l) / self.frame.w, 0.0), 1.0)
            
            -- Integer rounding
            if integer then
                offset = math.floor(offset * (max-min) + 0.5) * (1.0/(max-min))
            end
            
            if offset == 0.0 then
                handle.x = 0.001
            elseif offset == 1.0 then
                handle.x = 0.999
            else
                handle.x = offset
            end
            
            if integer then
                self.value = min + math.floor((max-min)*offset + 0.5)
            else
                self.value = min + (max-min)*offset
            end
            if callback then callback(self, self.value) end
            
            return self
            
        elseif event.type == OIL.ETTap and over(self, event.pos) then
            local offset = math.min(math.max((event.pos.x - self.frame.l) / self.frame.w, 0.0), 1.0)
            
            -- Integer rounding
            if integer then
                offset = math.floor(offset * (max-min) + 0.5) * (1.0/(max-min))
            end
            
            if offset == 0.0 then
                tween(0.1, handle, {x=0.001})
            elseif offset == 1.0 then
                tween(0.1, handle, {x=0.999})
            else
                tween(0.1, handle, {x=offset})
            end
            
            if integer then
                self.value = min + math.floor((max-min)*offset + 0.5)
            else
                self.value = min + (max-min)*offset
            end
            if callback then callback(self, self.value) end
            
            return self
        end
    end
    
    function e:get_handle()
        return handle
    end
    
    -- Initialise the slider with a default value
    if default then
        -- Map default to 0-1
        local offset = (default-min) / (max-min)
                
        if offset == 0.0 then
            handle.x = 0.001
        elseif offset == 1.0 then
            handle.x = 0.999
        else
            handle.x = offset
        end
        
        if callback then callback(e, default) end
    end
    
    return e
end

function OIL.Dialog(title, message, callback)
    local bg = OIL.Frame(0, 0, 1.0, 1.0, 100, color(160), nil, true)
    
    bg:add_child(OIL.RoundedFrame(0.5, 0.5, 0.5, 0.5, 100, color(230), nil, false)
    :add_child(OIL.TextLabel(0.5, -20, 0, 0, title, color(0, 153, 255), 24, nil, true))
    :add_child(OIL.TextLabel(0.5, 0.5, 0, 0, message, color(64), 20, nil, true))
    :add_child(OIL.TextButton(0.25, 10, 0.45, 50, "Cancel", function(self)
        bg:kill()
        if callback then callback(false) end
    end))
    :add_child(OIL.TextButton(0.75, 10, 0.45, 50, "OK", function(self)
        bg:kill()
        if callback then callback(true) end
    end)))
    
    function bg:on_event(event)
        return self
    end
end

function OIL.Separator(x, y, w, h, style)
    
    -- Support color
    if type(style) ~= "table" then
        style = {
            strokeSeparator = style
        }
    end
    
    local e = OIL.Element{
        x = x, y = y, w = w, h = h,
    }
    :add_render_component(OIL.RenderComponent(function(self, rw, rh, do_draw)
        self:apply_style("strokeSeparator")
        strokeWidth(rh)
        lineCapMode(ROUND)
        
        if do_draw == nil or do_draw then
            line(0, rh/2, rw, rh/2)
        end
    end), style)
    
    return e
end

function OIL.Dropdown(x, y, w, h, name, callback, priority)
    
    local target_height = 0
    
    local root = OIL.Element{
        x = x, y = y, w = w, h = 40,
        style = {
            text = name
        },
        open = false
    }
    
    -- Resizable frame
    local frame = OIL.Element{
        x = 0, y = -0.001, w = 1.0, h = 40
    }
    :add_render_component(OIL.RenderComponent.RoundedRect(OIL.Style.dropdown))
    
    -- Header
    local icon = OIL.UnicodeIcon(15, -10, 20, 20, "🔽")
    frame:add_child(icon)
    frame:add_child(OIL.TextLabel(45, -8, 0, 0, nil, nil, 22))
    
    -- Scrolling list
    local list = OIL.List(0, -40, 1.0, 1.001, 4)
    frame:add_child(list)
    
    local function toggle()
        root.open = not root.open
        if root.open then
            list.hidden = false
            tween(0.3, frame, {h=target_height})
            tween(0.3, list, {h=target_height - 44})
        else
            tween(0.3, frame, {h=40})
            tween(0.3, list, {h=1.001}, nil, function()
                list.hidden = true
            end)
        end
        icon.style.text = (root.open and "🔼") or "🔽"
    end
    
    -- Toggle button
    frame:add_child(OIL.Button(0, -0.001, 1.0, 40, function()
        toggle()
    end))
    
    root:add_child(frame)
    
    -- Adds elements to the scrolling list
    function root:add_item(item)
        
        if #list.children > 0 then
            list:add_child(OIL.Separator(0.5, 0, 0.3, 1.001, OIL.Style.dropdown))
        end
        
        -- Make the item a button
        item:add_child(OIL.Button(0, 0, 1.0, 1.0, function()
            toggle()
            if callback then callback(self, item) end
        end))
        list:add_child(item)
        
        -- Do the list's draw routine skipping the actual render
        -- so we can update the list size
        list:draw(nil, false)
        
        -- Update size
        target_height = math.min(list.list_height + 44, 400)
    end
    
    return root
end

function OIL.TextInputField(x, y, w, h, default)
    
    local cursor_index = 1
    local cursor_x, cursor_y = 0, 0
    local f_keep_in_frame = false
    
    local root = OIL.Element{
        x = x, y = y, w = w, h = h,
        style = OIL.Style.text_input
    }
    :add_render_component(OIL.RenderComponent.RoundedRect())
    
    -- Vertical Scrolling
    local scroll = OIL.ScrollingContainer(20, 4, -20, -4)
    root:add_child(scroll)
    
    -- Text
    local textbox = OIL.Element{
        x = 0, y = 0, w = 1.0, h = 1.0, priority = priority or 0,
        focus = false,
        style = {
            text = default
        }
    }
    scroll:add_child(textbox)
    
    -- Keep the cursor in frame
    local function keep_cursor_in_frame()
        local font_size = scroll:get_style("fontSize")
        if cursor_y + scroll.scroll_y < 0 then
            scroll.scroll_y = -cursor_y
        elseif (cursor_y + font_size) + scroll.scroll_y >= scroll.frame.h then
            -- TODO: This needs a little work
            scroll.scroll_y = scroll.frame.h - (cursor_y + font_size)
        end
    end
    
    textbox:add_render_component(OIL.RenderComponent(function(self, w, h, do_draw)
        fill_text = self:get_style("fillText")
        fill(fill_text)
        stroke(fill_text)
        local font_size = self:get_style("fontSize")
        fontSize(font_size)
        textMode(CORNER)
        textAlign(LEFT)
        local wrap_width = self.owner.parent.frame.w
        strokeWidth(2)
        
        local str = self:get_style("text")
        local strlen = string.len(str)
        
        local show_cursor = (math.floor(ElapsedTime*1.5) % 2) == 0
        
        -- Render the string 1 character at a time
        -- so we can later determine where to draw
        -- the cursor.
        local x = 1
        local y = scroll.frame.h - font_size - 4
        for i = 1,strlen do
            local c = string.sub(str, i,i) -- get char
            local cw, _ = textSize(c)
            
            if x + cw > wrap_width then
                x = 1
                y = y - font_size
            end
            
            if do_draw == nil or do_draw then
                if i == cursor_index and show_cursor and textbox.focus then
                    line(x, y, x, y+font_size)
                    cursor_x, cursor_y = x, y
                end
                text(c, x, y)
            end
            
            if c == "\n" then
                x = 1
                y = y - font_size
            else
                x = x + cw
            end
        end
        
        if (do_draw == nil or do_draw) and strlen+1 == cursor_index and show_cursor and textbox.focus then
            line(x, y, x, y+font_size)
            cursor_x, cursor_y = x, y
        end
        
        -- Resize the textbox element
        textbox.h = math.max(scroll.frame.h - y, scroll.frame.h)
        
        if f_keep_in_frame then
            f_keep_in_frame = false
            keep_cursor_in_frame()
        end
    end))
    
    -- Calculates the cursor index from a position within the frame
    local function set_cursor_pos(x, y)
        local font_size = textbox:get_style("fontSize")
        local str = textbox:get_style("text")
        local strlen = string.len(str)
        local wrap_width = scroll.frame.w
        fontSize(font_size)
        
        x = x - textbox.frame.l
        
        local line_no = ((scroll.frame.t - 4 + scroll.scroll_y) - y) // font_size
        local line_x = 1
        cursor_y = -(line_no+1)*font_size
        
        local li = 0
        for i = 1, strlen do
            local c = str:sub(i,i)
            local cw, _ = textSize(c)
            if line_no == li then
                if (x >= line_x - cw/2 and x < line_x + cw/2) or c == "\n" then
                    cursor_index = i
                    return
                end
            elseif c == "\n" or (line_x + cw > wrap_width) then
                li = li + 1
                line_x = 1
            end
            line_x = line_x + cw
        end
        
        cursor_index = strlen + 1
    end
    
    local function set_focus(focus)
        if textbox.focus ~= focus then
            textbox.focus = focus
            
            if focus then
                showKeyboard()
            else
                hideKeyboard()
            end
        end
    end
    
    local function insert(char)
        local str = textbox.style.text
        textbox.style.text = string.sub(str, 1, cursor_index-1)  .. char .. string.sub(str, cursor_index, -1)
        
        local font_size = textbox:get_style("fontSize")
        fontSize(font_size)
        
        local cw, _ = textSize(char)
        cursor_x = cursor_x + cw
        if char == "\n" or cursor_x > scroll.frame.w then
            cursor_x = 1
            cursor_y = cursor_y - font_size
        end
        
        cursor_index = cursor_index + 1
        
        keep_cursor_in_frame()
    end
    
    -- TODO: Figure out why this is triggering twice after focus...
    local function backspace()
        if cursor_index == 1 then
            -- do nothing
            return
        elseif cursor_index == 2 then
            -- remove first char
            textbox.style.text = string.sub(textbox.style.text, 2, -1)
        else
            -- Remove any other chars
            local str = textbox.style.text
            textbox.style.text = string.sub(str, 1, cursor_index-2) .. string.sub(str, cursor_index, -1)
        end
        
        cursor_index = cursor_index - 1
        f_keep_in_frame = true -- trigger an update following the cursor pos calc in draw()
    end
    
    function textbox:on_event(event)
        if root:inframe(event.pos) then
            local st = {
                [OIL.ETTap] = function()
                    set_focus(true)
                    set_cursor_pos(event.pos.x, event.pos.y)
                    
                    -- double tap?
                    
                    return self
                end,
                [OIL.ETScroll] = function()
                    return nil -- pass to scroll element
                end,
                [OIL.ETPan] = function()
                    -- press & drag?
                    
                    return nil -- pass to scroll element
                end,
            }
            return st[event.type] and st[event.type]()
        elseif self.focus then
            local st = {
                [OIL.ETTap] = function()
                    -- Just defocus and pass the event on
                    set_focus(false)
                    return nil
                end,
                [OIL.ETScroll] = function()
                    set_focus(false)
                    return nil -- pass to scroll element
                end,
                [OIL.ETPan] = function()
                    if event.state == BEGAN then
                        set_focus(false)
                        return nil -- pass to scroll element
                    end
                end,
                [OIL.ETKey] = function()
                    if event.key == BACKSPACE then
                        backspace()
                    else
                        insert(event.key)
                    end
                end
            }
            return st[event.type] and st[event.type]()
        end
        
        return (self.focus and self) or nil
    end
    
    return root
end
