    
function OIL.Button(label, callback, x, y, w, h)
    
    local e = OIL.Element{
        x = x or 0.5, y = y or 0.5, w = w or 0.5, h = h or 60,
        label = label,
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

function OIL.UnicodeIcon(icon_string, x, y, w, h, priority)
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
        id="frame",
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
    
    function e:draw_children(hidden)
        -- Set clip so the children do not escape the container
        clip(self.frame.l, self.frame.b, self.frame.w, self.frame.h)
        
        -- Draw
        OIL.Element.draw_children(self, hidden)
        
        -- Reset the clip
        clip()
    end
    
    return e
end

function OIL.Text(txt, x, y, w, h, alignment, color, fontSize, fit_parent, priority)
    local e = OIL.Element{
        x = x or 0.5, y = y or 0.5, w = w or 0.5, h = h or 0.5, priority = priority or 0,
        style = {
            text = txt,
            textAlign = alignment,
            fillText = color,
            fontSize = fontSize
        }
    }
    
    function e:update()
        if fit_parent == nil or fit_parent then
            self.style.textWrapWidth = self.parent.frame.w - 10
        end
    end
    
    e:add_render_component(OIL.RenderComponent(function(self, w, h)
        textMode(CENTER)
        self:apply_style("fontSize")
        self:apply_style("fillText")
        self:apply_style("textWrapWidth")
        self:apply_style("textAlign")
        
        local tw, th = textSize(self:get_style("text"))
        
        -- Resize the owner
        self.owner.w = tw
        self.owner.h = th
        
        text(self:get_style("text"), w/2, h/2)
    end))
    
    return e
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

function OIL.Slider(x, y, w, min, max, callback, priority)
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
        if event.type == OIL.ETPan and (over(self, event.pos) or self.dragging) then
            local offset = math.min(math.max((event.pos.x - self.frame.l) / self.frame.w, 0.0), 1.0)
            if offset == 0.0 then
                handle.x = 0.001
            elseif offset == 1.0 then
                handle.x = 0.999
            else
                handle.x = offset
            end
            
            if event.state == ENDED then
                self.dragging = false
                handle.style.fill = handle:get_style("fillNotDragging")
            else
                self.dragging = true
                handle.style.fill = handle:get_style("fillDragging")
            end
            
            self.value = min + (max-min)*offset
            if callback then callback(self, self.value) end
            
            return self
        end
    end
    
    function e:get_handle()
        return handle
    end
    
    return e
end
