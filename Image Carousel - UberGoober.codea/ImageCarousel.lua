ImageCarousel = class()

function ImageCarousel:init(images, navDotsAreThumbnails, optionalX, optionalY, optionalWidth, optionalHeight)
    self.width = optionalWidth or WIDTH
    self.height = optionalHeight or HEIGHT
    self.x = optionalX or 0
    self.y = optionalY or 0
    self.navDotsAreThumbnails = navDotsAreThumbnails
    self.images = images
    self.scroll = 0
    self.limit = 0
    self.page = 1
    self.vel = 0
    self.dotMeshes = {}
    local overallDotAreaWidth =self.width*0.84 --limits the horizontal space the dot area takes up if you want to force it to be smaller than the screen
    if not self.navDotsAreThumbnails then
        overallDotAreaWidth = self.width * 0.76
    end
    self.dotHeight = (self.height * 0.13) + self.y
    self.dotSpaceFactor=0.45 -- space between dots as a percentage of the dot size
    local maxDotSize=self.width/30 --sets the absolute maximum size of a circle no matter what
    local minDotSize = 6 --minimum size should be absolute, not relative to self
    if self.navDotsAreThumbnails == false then
        --non-thumbnail dots should be a consistent size
        maxDotSize=6
    end
    self.dotRadius=math.min(maxDotSize, (overallDotAreaWidth/(#self.images*(1+self.dotSpaceFactor)))/2)  --calculate the maximum allowable radius size
    self.dotRadius=math.max(minDotSize, self.dotRadius)
    for i=1,#images do
        self.dotMeshes[i] = ImageCarousel.circleMesh(self.dotRadius*0.8, 360, self.images[i]) --make the circle image 80% of the dot size
        self.dotMeshes[i]:setColors( 255,255,255 )
    end
end

function ImageCarousel:draw()

    --only show area defined by bounds
    clip(self.x, self.y, self.width, self.height)
    
    --correct self.page if it's less than one, or more than the total image count
    if self.page > #self.images then self.page = 1 end
    if self.page < 1 then self.page = #self.images end
    self.limit = (self.page-1)*self.width
    
    --calculate amount to scroll images
    if self.swipe == true then
        if self.scroll ~= self.limit then
            self.scroll = self.scroll - (self.scroll-self.limit)/5
        end
        self.vel = 0
        self.scroll = self.scroll + self.vel
    end   
    pushMatrix()
    translate(-self.scroll,0)
        --image drawing sequence (only draws the current, previous, and next image)
    for i,v in ipairs(self.images) do
        if self.images[i] ~= nil and math.abs(i-self.page)<2 then
            sprite(self.images[i],(i*self.width-self.width/2) + self.x,(self.height/2) + self.y, self.width, self.height)
        end
        --special cases for beginning and end of image table
        if i == 1 then
            sprite(self.images[#self.images], (-self.width/2)+self.x, (self.height/2)+self.y, self.width, self.height)
        elseif i == #self.images then
            sprite(self.images[1],  ((#self.images + 1) * self.width)-self.width/2 + self.x, (self.height/2)+self.y, self.width, self.height)
        end
    end
    popMatrix()
    pushStyle()
    
    --if the navDot flag is nil, don't draw dots at all
    if self.navDotsAreThumbnails == nil then return end
    
    --draw the page-location dots
    for i = 1,#self.images do
        noStroke()
        local spacingConstant = self.dotRadius * (1+self.dotSpaceFactor)*2 --calculate the size of each dot element - this is basically the original dot size plus the space around it (if it is also currently selected and the ellipse is bigger)
        local s = #self.images*spacingConstant/2 + (spacingConstant/2)
        noStroke()
        
        if i == self.page then
            pushMatrix()
            translate(self.width/2-s+i*spacingConstant+self.x,self.dotHeight)
            scale((1+(1.4*self.dotSpaceFactor)),(1+(1.4*self.dotSpaceFactor))) --calculates scale of selected dot as a fraction of the space between dots so that it doesn't overlap neighbors
            noStroke()
            fill(255, 180)
            
            ellipse(0,0,self.dotRadius*1.85) --ellipse takes a diameter rather than radius
            if self.navDotsAreThumbnails then
                self.dotMeshes[i]:draw()
            end
            popMatrix()
            else
            pushMatrix()
            translate(self.width/2-s+i*spacingConstant+self.x,self.dotHeight)
            fill(99, 221)
            
            ellipse(0,0,self.dotRadius*1.85) --ellipse takes a diameter rather than radius
            if self.navDotsAreThumbnails then
                self.dotMeshes[i]:draw()
            end
            popMatrix()
        end
    end
    popStyle()
    clip()
end

function ImageCarousel:touched(touch)
    if touch.state == BEGAN then
        --reject touches that don't start inside bounds
        if touch.pos.x < self.x or
        touch.pos.x > self.x + self.width or
        touch.pos.y < self.y or
        touch.pos.y > self.y + self.height then
            return
        else
            self.trackedTouch = touch.id
        end
        self.vel = nil
        self.temp1 = nil
        self.temp2 = nil
    end
    
    if touch.id ~= self.trackedTouch then return end
    
    if touch.state ~= ENDED then
        self.swipe = false
        self.scroll = self.scroll - touch.deltaX
        if self.scroll < self.limit - self.width then self.scroll = self.limit - self.width end
        if self.scroll > self.limit + self.width then self.scroll = self.limit + self.width end
        else
        self.swipe = false
    end
    
    if touch.state == ENDED then
        self.swipe = true
        if self.vel > 5 or self.scroll > self.limit + 200 then self.page = self.page + 1 end
        if self.vel < -5 or self.scroll < self.limit - 200 then self.page = self.page - 1 end
        if self.page > #self.images then
            self.page = 1
            self.scroll = self.scroll - #self.images*self.width
        end
        if self.page < 1 then
            self.page = #self.images
            self.scroll = self.scroll + #self.images*self.width
        end
        self.limit = (self.page-1)*self.width
    end
    self.vel = self.temp1 or -touch.deltaX
    self.temp1 = self.temp2 or -touch.deltaX
    self.temp2 = -touch.deltaX
    
    if touch.state == ENDED then
        self.trackedTouch = nil
    end
    
    --if the navDot flag is nil, don't detect taps on dots at all
    if self.navDotsAreThumbnails == nil then return end
    
    if touch.state == ENDED and touch.tapCount > 0 then
        for i = 1,#self.images do
            local spacingConstant = self.dotRadius * (1+self.dotSpaceFactor)*2
            local s = #self.images*spacingConstant/2 + (spacingConstant/2)
            local x,y = self.width/2-s+i*spacingConstant+self.x,self.dotHeight
            local v = vec2(touch.x,touch.y)-vec2(x,y)
            if v:len() < self.dotRadius then self.page = i end
        end
    end
    
end

function ImageCarousel.circleMesh(rad, sides, texture)
    local newMesh = mesh()
    
    local verts = {}
    local tex = {}
    
    for i=1,sides do
        local r1 = (i-1)/sides * math.pi * 2
        local r2 = i/sides * math.pi * 2
        
        local p1 = vec2( math.cos(r1), math.sin(r1) )
        local p2 = vec2( math.cos(r2), math.sin(r2) )
        
        -- Verts
        table.insert(verts, p1 * rad)
        table.insert(verts, p2 * rad)
        table.insert(verts, vec2(0,0)) -- center
        
        -- Tex Coords
        table.insert(tex, (p1 + vec2(1,1)) * 0.5)
        table.insert(tex, (p2 + vec2(1,1)) * 0.5)
        table.insert(tex, vec2(0.5,0.5))
    end
    
    newMesh.vertices = verts
    newMesh.texCoords = tex
    newMesh.texture = texture
    newMesh:setColors( 255,80,129 ) --pinkish
    
    return newMesh
end
