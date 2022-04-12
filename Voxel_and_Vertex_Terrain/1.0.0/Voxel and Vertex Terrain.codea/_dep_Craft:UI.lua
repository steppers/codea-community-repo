-- Contents:
--    Main.lua
--    Panel.lua
--    Label.lua
--    Image.lua
--    Button.lua

------------------------------
-- Main.lua
------------------------------
do
-- User Interface

-- Use this function to perform your initial setup
function setup()
    print("Hello World!")

    local bg = readImage(asset.builtin.UI.Blue_Button11)
    button1 = imageButton(WIDTH/2-200,HEIGHT/2-100,400,200,bg, true)
end

function imageButton(x,y,w,h,i,f)
    local button = ui.button
    {
        x=x,
        y=y,
        w=w,
        h=h,
        opaque=false,
        text = "UI",
        fontSize = 100,
        normalBg = i,
        highlightedBg = asset.builtin.UI.Blue_Button10,
        normalFill = color(255, 255, 255, 255),
        align = {h = ui.CENTER, v = ui.CENTER},
        inset = 10
    }

    return button
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color
    background(40, 40, 50)

    -- This sets the line thickness
    strokeWidth(5)

    -- Do your drawing here
    button1:update()
    button1:draw()

    --button2:update()
    --button2:draw()
end

end
------------------------------
-- Panel.lua
------------------------------
do
-- ** Panel **

ui = {}

ui.LEFT = 1
ui.CENTER = 2
ui.RIGHT = 3
ui.TOP = 4
ui.BOTTOM = 5
ui.STRETCH = 6

ui.panel = class()

function ui.panel:init(params)
    assert(params)

    local x = params.x or 0
    local y = params.y or 0
    local w = params.w or 200
    local h = params.h or 100
    
    self.frame = {x = 0, y = 0, w = 0, h = 0}
    self.tframe = {x = 0, y = 0, w = 0, h = 0}
   
    self.pivot = params.pivot or vec2(0.5, 0.5)  
    self.anchor = vec2(0,0)
    self.size = vec2(1,1)
    
    if params.parent then
        params.parent:addChild(self)
    end
    
    self:setFrame(x,y,w,h)    
    self.anchor = params.anchor or self.anchor
    self.size = params.size or self.size
    
    self.fill = params.fill or color(76, 76, 76, 255)
    self.interactive = false
    self.visible = true
    self.opaque = params.opaque and true
    self.needsLayout = false
    self.children = {}
    self.align = params.align or {h = ui.LEFT, v = ui.BOTTOM}
    self.border = params.border or 0
    self.inset = params.inset or 10
    
    if params.bg then
        x,y,w,h = self:getFrame()
        self.bg = ui.image
        {
            parent = self,
            size = vec2(1-(2*self.border/w),1-(2*self.border/h)),
            anchor = vec2(0.5, 0.5),
            image=params.bg, 
            fillMode = IMAGE_STRETCH, 
            inset = params.inset, 
            align = {h = ui.STRETCH, v = ui.STRETCH}
        }
    end
   
    self:update()
end

function ui.panel:draw() 
    if not self.visible then return end    

    if self.bg then
        self.bg.fill = self.fill
    end
    
    pushStyle() pushMatrix()
    translate(self.frame.x, self.frame.y)

    for k,v in pairs(self.children) do
        v:draw()
    end

    popStyle() popMatrix()
end

-- Layout and positioning
function ui.panel:update()
    
    -- Check is parent size has changed
    local pw, ph = WIDTH, HEIGHT
    if self.parent then
        pw = self.parent.frame.w
        ph = self.parent.frame.h        
    end
   
    -- Adjust width and height depending on stretching
    if pw ~= self.pw then
        local w = self.size.x * self.pw
        local x = self.anchor.x * self.pw - self.pivot.x * w

        if self.align.h == ui.LEFT then
            x = x + self.pivot.x * w
            self.anchor.x = x / pw
        elseif self.align.h == ui.CENTER then
            x = x - self.pw/2 + pw/2 + self.pivot.x * w
            self.anchor.x = x / pw
        elseif self.align.h == ui.RIGHT then
            x = x - self.pw + pw + self.pivot.x * w
            self.anchor.x = x / pw            
        elseif self.align.h == ui.STRETCH then
            local left = x
            local right = x - self.pw + pw + w
            w = right - left
            self.anchor.x = (left + self.pivot.x * w) / pw
        end
        
        self.size.x = w / pw           
              
        self.pw = pw
    end 

    if ph ~= self.ph then      
        local h = self.size.y * self.ph
        local y = self.anchor.y * self.ph - self.pivot.y * h   
        
        if self.align.v == ui.BOTTOM then
            y = y + self.pivot.y * h
            self.anchor.y = y / ph
        elseif self.align.v == ui.CENTER then
            y = y - self.ph/2 + ph/2 + self.pivot.y * h
            self.anchor.y = y / ph
        elseif self.align.v == ui.TOP then
            y = y - self.ph + ph + self.pivot.y * h
            self.anchor.y = y / ph            
        elseif self.align.v == ui.STRETCH then
            local left = y
            local right = y - self.ph + ph + h
            h = right - left
            self.anchor.y = (left + self.pivot.y * h) / ph
        end
        
        self.size.y = h / ph           
        
        self.ph = ph
    end
    
    
    if self.parent then
        self.frame.w = self.parent.frame.w * self.size.x 
        self.frame.h = self.parent.frame.h * self.size.y
        self.frame.x = self.anchor.x * self.parent.frame.w - self.frame.w * self.pivot.x
        self.frame.y = self.anchor.y * self.parent.frame.h - self.frame.h * self.pivot.y
        
        self.tframe.x = self.parent.tframe.x + self.frame.x
        self.tframe.y = self.parent.tframe.y + self.frame.y           
    else
        self.frame.w = WIDTH * self.size.x
        self.frame.h = HEIGHT * self.size.y
        self.frame.x = self.anchor.x * WIDTH - self.frame.w * self.pivot.x
        self.frame.y = self.anchor.y * HEIGHT - self.frame.h * self.pivot.y
        
        self.tframe.x = self.frame.x
        self.tframe.y = self.frame.y
    end 
    
    self.tframe.w = self.frame.w
    self.tframe.h = self.frame.h 
    
    if self.needsLayout and self.layout then 
        self:layout() 
        self.needsLayout = false
    end

    for k,v in pairs(self.children) do
        v:update()
    end
end

function ui.panel:setFrame(x,y,w,h)
    local pw, ph = WIDTH, HEIGHT
    if self.parent then
        pw = self.parent.frame.w
        ph = self.parent.frame.h        
    end
    
    self.anchor = vec2((x + self.pivot.x * w) / pw, (y + self.pivot.y * h) / ph)
    self.size = vec2(w / pw, h / ph)    
    self.pw = pw 
    self.ph = ph  
    
    self.frame.x = x
    self.frame.y = y   
    self.frame.w = w   
    self.frame.h = h         
end

function ui.panel:getFrame()
    if self.parent then
        local px,py,pw,ph = self.parent:getFrame()
        
        local w = self.size.x * pw
        local h = self.size.y * ph
        local x = self.anchor.x * pw - self.pivot.x * w
        local y = self.anchor.y * ph - self.pivot.y * h
        return x,y,w,h
    else
        local w = self.size.x * WIDTH
        local h = self.size.y * HEIGHT
        local x = self.anchor.x * WIDTH - self.pivot.x * w
        local y = self.anchor.y * HEIGHT - self.pivot.y * h
        return x,y,w,h
    end
end

function ui.panel:top(inside)
    local value = 0
    if inside then
        for k,v in pairs(self.children) do
            value = math.max(value, self.tframe.y + v.frame.y + v.frame.h)
        end
    else
        value = self.tframe.y + self.tframe.h 
    end
    return value
end

function ui.panel:bottom(inside)
    local value = self.tframe.y + self.tframe.h
    if inside then
        for k,v in pairs(self.children) do
            value = math.min(value, self.tframe.y + v.frame.y)
        end
    else
        value = self.tframe.y
    end
    return value
end

function ui.panel:right(inside)
    local value = 0
    if inside then
        for k,v in pairs(self.children) do
            value = math.max(value, self.tframe.x + v.frame.x + v.frame.w)
        end
    else
        value = self.tframe.x + self.tframe.w
    end
    return value
end

function ui.panel:layoutHorizontal(spacing, stretch)
    if stretch then
        local width = (self.frame.w - spacing * (#self.children+1)) / #self.children
        local x = spacing
        for k,v in pairs(self.children) do
            v.frame.x = x
            v.frame.w = width
            x = x + width + spacing
            v.needsLayout = true
        end
    else
        local x = spacing
        for k,v in pairs(self.children) do
            v.frame.x = x
            x = x + v.frame.w + spacing
            v.needsLayout = true
        end
    end
    self:update()
end

function ui.panel:layoutVertical(spacing, stretch)
    if stretch then
        local height = (self.frame.h - spacing * (#self.children+1)) / #self.children
        local y = self.frame.h - spacing
        for k,v in pairs(self.children) do
            v.frame.y = y - v.frame.h
            v.frame.h = height
            y = y - height - spacing
            v.needsLayout = true
        end
    else
        local y = self.frame.h - spacing
        for k,v in pairs(self.children) do
            v.frame.y = y - v.frame.h
            y = y - v.frame.h - spacing
            v.needsLayout = true
        end
    end
    self:update()
end


-- Hierarchy
function ui.panel:addChild(child)
    local x,y,w,h = child:getFrame()
    child.parent = self
    child:setFrame(x,y,w,h)
    
    table.insert(self.children, child)
end

-- Interaction
function ui.panel:hitTest(x,y)
    return x >= self.tframe.x and x <= self.tframe.x + self.tframe.w and
           y >= self.tframe.y and y <= self.tframe.y + self.tframe.h
end

function ui.panel:touched(touch)
    return self.interactive and self.visible and self:hitTest(touch.x, touch.y)
end



ui.swatch = class(ui.button)

function ui.swatch:init(x,y,w,h,c)
    ui.button.init(self,x,y,w,h)
    self.color = c
end

function ui.swatch:draw()
    if not self.visible then return end   

    pushStyle()
    pushMatrix()
    translate(self.frame.x, self.frame.y)
    ellipseMode(CORNER)
    fill(self.color)

    if self.selected then
        ellipse(0,0,self.frame.w,self.frame.h)
    else
        ellipse(5,5,self.frame.w-10, self.frame.h-10)
    end

    popMatrix()
    popStyle()
end

function rRect(w,h,r,c)
    strokeWidth(0)
    fill(c.r, c.g, c.b, c.a)
    ellipse(r/2,h-r/2,r) ellipse(w-r/2,h-r/2,r)
    ellipse(r/2,r/2,r) ellipse(w-r/2,r/2,r)
    rect(0,r/2,w,h-r) rect(r/2,0,w-r,h)
end
end
------------------------------
-- Label.lua
------------------------------
do
-- ** Label **

ui.label = class(ui.panel)

function ui.label:init(params)
    ui.panel.init(self, params)
    self.text = params.text
    self.alignment = params.alignment or CENTER
    self.fill = params.fill or color(255, 255, 255, 255)
    self.font = params.font or "SourceSansPro-Bold"
    self.fontSize = params.fontSize or 16
end

function ui.label:draw()
    if self.visible and self.text then
        pushStyle()
        
        font(self.font)
        
        textAlign(LEFT)
        textMode(CORNER)
        fontSize(self.fontSize)
        
        local w,h = textSize(self.text)
        
        fill(self.fill)
        
        local cx = self.frame.x + self.frame.w * 0.5 - w * 0.5
        if self.alignment == LEFT then
            cx = self.frame.x
        end
        
        local cy = self.frame.y + self.frame.h * 0.5 - h * 0.5
        text(self.text, cx, cy)
        
        popStyle()
    end
end
end
------------------------------
-- Image.lua
------------------------------
do
-- ** Image **

ui.image = class(ui.panel)

IMAGE_FILL = 1
IMAGE_FIT = 2
IMAGE_STRETCH = 3

function ui.image:init(params)
    ui.panel.init(self, params)
    -- you can accept and set parameters here

    self.flipX = params.flipX or false
    self.flipY = params.flipY or false
    self.fillMode = params.fillMode or IMAGE_FIT
    self.fill = params.fill or color(255, 255, 255, 255)
    self.opaque = params.opaque or false
    self.rotation = params.rotation or 0
    
    if params.inset and type(params.inset) == "table" then
        self.inset = params.inset
    else
        local i = params.inset
        self.inset = i and {t = i, r = i, b = i, l = i} or 
            {t = 0, r = 0, b = 0, l = 0}
    end
    
    self:setImage(params.image)
    self.model = mesh()
end

function ui.image:setImage(img)
    self.img = img
end

function ui.image:draw()
    if not self.visible then return end
    
    ui.panel.draw(self)
    
    pushStyle() pushMatrix()
    
    --noFill()
    --rect(self.frame.x, self.frame.x, self.frame.x + self.frame.w, self.frame.y + self.frame.h)
    
    if self.img then
        spriteMode(CENTER)
        local w,h = spriteSize(self.img)
        
        if self.fillMode == IMAGE_STRETCH then
            w = self.frame.w
            h = self.frame.h
        elseif self.fillMode == IMAGE_FIT then
            if self.frame.w >= self.frame.h then
                
            else
                
            end
        elseif self.fillMode == IMAGE_FILL then
            if self.frame.w >= self.frame.h then
                
            else
                
            end
        end

        -- 9 Patch Mode
        local t,r,b,l = self.inset.t, self.inset.r, self.inset.b, self.inset.l      
        if t > 0 or r > 0 or b > 0 or l > 0 then
            translate(self.frame.x, self.frame.y)
            
            self.model:clear()
            self.model.texture = self.img
            
            local sx, sy = spriteSize(self.img)

            -- Top
            local i = self.model:addRect(self.frame.w/2, self.frame.h - t/2, w - l - r, t)    
            self.model:setRectTex(i, l/sx,(sy-t)/sy,(sx-l-r)/sx,t/sy)
            
            -- Top Right
            i = self.model:addRect(self.frame.w - r/2, self.frame.h - t/2, r, t)    
            self.model:setRectTex(i, (sx-r)/sx,(sy-t)/sy,r/sx,t/sy)            
            
            -- Right
            i = self.model:addRect(self.frame.w - r/2, self.frame.h/2, r, h - t - b)    
            self.model:setRectTex(i, (sx-r)/sx,t/sy,r/sx,(sy - t - b)/sy)         
            
            -- Bottom Right
            i = self.model:addRect(self.frame.w - r/2, b/2, r, b)    
            self.model:setRectTex(i, (sx-r)/sx,0,r/sx,b/sy)
            
            -- Bottom
            local i = self.model:addRect(self.frame.w/2, b/2, w - l - r, b)    
            self.model:setRectTex(i, l/sx,0,(sx-l-r)/sx,t/sy)         
            
            -- Bottom Left
            i = self.model:addRect(l/2, b/2, l, b)    
            self.model:setRectTex(i, 0,0,l/sx,b/sy)
            
            -- Left
            i = self.model:addRect(l/2, self.frame.h/2, l, h - t - b)    
            self.model:setRectTex(i, 0,t/sy,l/sx,(sy - t - b)/sy)         
            
            -- Top Left
            i = self.model:addRect(l/2, self.frame.h - t/2, l, t)    
            self.model:setRectTex(i, 0,(sy-t)/sy,l/sx,t/sy) 
            
            -- Middle
            i = self.model:addRect(self.frame.w/2, self.frame.h/2, w-l-r, h-t-b)    
            self.model:setRectTex(i, l/sx,b/sy,(sx-l-r)/sx,(sy-b-t)/sy)          
            
            self.model:setColors(self.fill)
            
            self.model:draw()
        else
            translate(self.frame.x + self.frame.w/2, 
                      self.frame.y + self.frame.h/2)
            rotate(self.rotation or 0)
            
            if self.flipX then w = -w end
            if self.flipY then h = -h end
            tint(self.fill)
            sprite(self.img, 0, 0, w, h)
        end
        
    end
    
    popStyle() popMatrix()
end

end
------------------------------
-- Button.lua
------------------------------
do
-- ** Button **

ui.button = class(ui.panel)

function ui.button:init(params)
    params.bg = params.normalBg
    ui.panel.init(self, params)

    self.textFill = color(255, 255, 255, 255)
    self.selectedFill = color(29, 29, 29, 255)
    self.normalFill = params.normalFill or color(255, 255, 255, 255)
    self.highlightedFill = color(181, 181, 181, 255)

    self.normalBg = params.normalBg
    self.highlightedBg = params.highlightedBg or self.normalBg
    self.selectedBg = params.selectedBg or self.highlightedBg or self.selectedBg
    
    self.icon = ui.image 
    {
        anchor = vec2(0.5,0.5),
        size = vec2(1,1),
        align = {h = ui.STRETCH, v = ui.STRETCH},
        parent = self
    }
    
    self.label = ui.label
    {
        text = params.text,
        fontSize = params.fontSize
    }
    self:addChild(self.label)
    self.label.anchor = vec2(0.5, 0.5)
    self.label.size = vec2(1, 1)
    self.label.align = {h = ui.STRETCH, v = ui.STRETCH}
    
    self.highlighted = false
    self.selected = false
    self.onPressed = params.onPressed
    self.onReleased = params.onReleased
    self.interactive = true
    
    if touches then touches.addHandler(self,-2) end
end

function ui.button:draw()
    if not self.visible then return end

    self.fill = self.highlighted and self.highlightedFill or 
        (self.selected and self.selectedFill or self.normalFill)
    
    if self.bg then
        self.bg.img = self.highlighted and self.highlightedBg or 
            (self.selected and self.selectedBg or self.normalBg)
    end
    
    self.label.fill = self.textFill
    
    ui.panel.draw(self)
    
end

function ui.button:layout()
    self.label.frame.w = self.frame.w - 10
    self.label.frame.h = self.frame.h - 10
end

function ui.button:touched(touch)   
    if touch.state == BEGAN and ui.panel.touched(self, touch) then
        self.highlighted = true
        if self.onPressed then self.onPressed(self, touch) end
        return true
    elseif touch.state == MOVING then
        if self:hitTest(touch.x, touch.y) then
            self.highlighted = true
        elseif touches then
            if self.share then
                touches.share(self, touch, -2)
            end 
            self.highlighted = false
        end
        return true
    elseif touch.state == ENDED or touch.state == CANCELLED then
        self.highlighted = false
        if self:hitTest(touch.x, touch.y) then
            if self.onReleased then self.onReleased(self, touch) end
        end

        return true
    end

    return false
end
end
