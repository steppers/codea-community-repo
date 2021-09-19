Soda.Frame = class() --the master class for all UI elements. 

function Soda.Frame:init(t)
    t.shapeArgs = t.shapeArgs or {}
    t.style = t.style or Soda.style.default
    if not t.label and t.title then
        t.label = {x=0.5, y=-10}
    end
    self:storeParameters(t)
 
    self.callback = t.callback or null --triggered on action completion
    self.update = t.update or null --triggered every draw cycle.
    
    --null = function() end. ie no need to test if callback then callback()
    
    --parenthood, baseStyle inheritance
    self.child = {} --hold any children
    if t.parent then
        local priority = t.priority or #t.parent.child+1
        table.insert(t.parent.child, priority, self) --if this has a parent, add it to the parent's list of children
        self.style = t.style or t.parent.style
  --      self.inactive = self.inactive or self.parent.inactive
    else
        local priority = t.priority or #Soda.items+1
        table.insert( Soda.items, priority, self) --no parent = top-level, added to Soda.items table
        self.style = t.style or Soda.style.default
    end
    self.styleList = {self.style}
    self.subStyle = t.subStyle or {}
    for i,v in ipairs(self.subStyle) do
        table.insert(self.styleList, self.style[v]) 
    end
    
    self:setPosition()

    self.mesh = {} --holds additional effects, such as shadow and blur
    if t.blurred then
        self.mesh[#self.mesh+1] = Soda.Blur{parent = self}
        self.shapeArgs.tex = self.mesh[#self.mesh].image
        self.shapeArgs.resetTex = self.mesh[#self.mesh].image
        table.insert(self.styleList, self.style["blurred"]) 
    end
    if t.shadow then
        self.mesh[#self.mesh+1] = Soda.Shadow{parent = self}
    end
    
    self.sensor = Soda.Gesture{parent=self, xywhMode = CENTER}
    self:setInactive(self.inactive or self.hidden)
    --elements that are defined as hidden (invisible) are also inactive (untouchable) at initialisation    

end

function Soda.Frame:setInactive(b)
    self.inactive = b
    self.sensor.enabled = not self.inactive
end

function Soda.Frame:childrenTouched(t,tpos)
    local off = tpos - vec2(self:left(), self:bottom())
    for i = #self.child, 1, -1 do --children take priority over frame for touch
        local v = self.child[i]
        if v:touched(t, off) then return true end
    end
end

function Soda.Frame:touched(t, tpos)
    if self.inactive then return end
    if self.sensor:touched(t, tpos) then return true end
    return self.alert
end

function Soda.Frame:storeParameters(t)
    self.parameters = {}
    for k,v in pairs(t) do
        
        if k =="label" or k=="shapeArgs" then
            self[k] = {}
            self.parameters[k] = {}
            for a,b in pairs(v) do
                self[k][a] = b
                self.parameters[k][a] = b
            end
        else
            self.parameters[k] = v
            self[k] = v
        end
        
    end
end

function Soda.Frame:setPosition() --all elements defined relative to their parents. This is recalculated when orientation changes
    local t = self.parameters
    local edge = vec2(WIDTH, HEIGHT)
    if self.parent then
        edge = vec2(self.parent.w, self.parent.h)
    end
    
    self.x, self.w = Soda.parseCoordSize(t.x or 0.5, t.w or 0.4, edge.x)
    self.y, self.h = Soda.parseCoordSize(t.y or 0.5, t.h or 0.3, edge.y)
    if t.label then
        self.label.w, self.label.h = self:getTextSize()
        
        self.label.x = Soda.parseCoord(t.label.x,self.label.w,self.w)
        self.label.y = Soda.parseCoord(t.label.y,self.label.h,self.h)

    end
    if self.shapeArgs then
        local s = self.shapeArgs
        s.w = t.shapeArgs.w or self.w
        s.h = t.shapeArgs.h or self.h

        s.x = Soda.parseCoord(t.shapeArgs.x or 0, s.w, self.w)
        s.y = Soda.parseCoord(t.shapeArgs.y or 0, s.h, self.h)
    end
end

function Soda.Frame:setStyle(list, pref1, pref2)
    for i,v in ipairs(list) do
        Soda.setStyle(v[pref1] or v[pref2])
    end
end

function Soda.Frame:getTextSize(sty, tex)
    pushStyle()

   -- Soda.setStyle(Soda.style.default.text)
    Soda.setStyle(sty or self.style.text) --sty or 

    local w,h = textSize(tex or self.title)
    popStyle()
    return w,h
end

function Soda.Frame:show(direction)
    self.hidden = false --so that we can see animation

    self:setInactive(false)

    if direction then --animation
        self:setPosition()
        local targetX = self.x
        if direction==LEFT then
            self.x = - self.w * 0.5
        elseif direction==RIGHT then
            self.x = WIDTH + self.w * 0.5
        end
        tween(0.4, self, {x=targetX}, tween.easing.cubicInOut) 
    end
    if self.shapeArgs and self.shapeArgs.tex then self.shapeArgs.resetTex = self.shapeArgs.tex end --force roundedrect to switch texture (because two rects of same dimensions are cached as one mesh)
end

function Soda.Frame:hide(direction)
    --self.inactive=true --cannot touch element during deactivation animation
    if direction then
        local targetX
        if direction==LEFT then
            targetX = - self.w * 0.5
        elseif direction==RIGHT then
            targetX = WIDTH + self.w * 0.5
        end
        tween(0.4, self, {x=targetX}, tween.easing.cubicInOut, function() self.hidden = true self:setInactive(true)  end) --user cannot touch buttons until animation completes
    else
        self.hidden = true
        self:setInactive(true)
    end
end

function Soda.Frame:toggle(direction)
    if self.inactive then self:show(direction)
    else self:hide(direction)
    end
end

function Soda.Frame:activate()
        self:setInactive(false)
end

function Soda.Frame:deactivate()
        self:setInactive(true)
end

function Soda.Frame:draw(breakPoint)
    if breakPoint and breakPoint == self then return true end
    if self.hidden then return end
    self:update()
    if self.alert then
        Soda.darken.draw() --darken underlying interface elements
    end
    
    for i = #self.mesh, 1, -1 do
        self.mesh[i]:draw() --draw shadow
    end
    
    local sty = {table.unpack(self.styleList)} --shallow copy of the lisr of styles self.style
    if self.inactive then
        sty[#sty+1] = Soda.style.inactive
    elseif self.highlighted and self.highlightable then
       -- sty[#sty+1] = self.style.highlight --self.style.highlight or Soda.style.default.highlight
        sty[#sty] = sty[#sty].highlight
    end

    pushMatrix()
    pushStyle()
    
    translate(self:left(), self:bottom())
    if self.shape then
        self:drawShape(sty)
    end
        popStyle()
    pushStyle()
    self:setStyle(sty, "body", "text")
    --Soda.setStyle(self.style.body) --(Soda.style.default.body)
 -- Soda.setStyle(sty.text)
    
    self:drawContent()
    local titleText = "text"
    if self.content then
        textWrapWidth(self.w * 0.9)
        text(self.content, self.w * 0.5, self.h * 0.6)
        textWrapWidth()
        titleText = "title"
    end
    if self.label then
        
      --  Soda.setStyle(sty.text) --(Soda.style.default.text)
       self:setStyle(sty, titleText, "text")
        
        text(self.title, self.label.x, self.label.y)
        
    end

    popStyle()
    
    for i, v in ipairs(self.child) do --nb children are drawn with parent's transformation

        if v.kill then
            table.remove(self.child, i)
        else
            if v:draw(breakPoint) then return true end
        end
    end
    popMatrix()

end

function Soda.Frame:drawContent() end --overridden by subclasses

function Soda.Frame:drawShape(sty)
    self:setStyle(sty, "shape")
    self.shape(self.shapeArgs)
end

function Soda.Frame:bottom()
    return self.y - self.h * 0.5
end

function Soda.Frame:top()
    return self.y + self.h * 0.5
end

function Soda.Frame:left()
    return self.x - self.w * 0.5
end

function Soda.Frame:right()
    return self.x + self.w * 0.5
end

function Soda.Frame:selectFromList(child) --method used by parents of selectors. 
    if child==self.selected then --pressed the one already selected
        if self.noSelectionPossible then
            child.highlighted = false
            self.selected = nil
        end
    else
        if self.selected then 

            self.selected.highlighted = false 

            if self.selected.panel then self.selected.panel:hide() end
        end
        self.selected = child
        child.highlighted = true
        if child.panel then child.panel:show() end
        tween.delay(0.1, function() self:callback(child, child.title) end) --slight delay for list animation to register before panel disappears
    end
end

function Soda.Frame:pointIn(x,y)
    return x>self:left() and x<self:right() and y>self:bottom() and y<self:top()
end

function Soda.Frame:orientationChanged()
    self:setPosition()
    
    for _,v in ipairs(self.mesh) do
        v:setMesh()
    end
    
    for _,v in ipairs(self.child) do
        v:orientationChanged()
    end
end





