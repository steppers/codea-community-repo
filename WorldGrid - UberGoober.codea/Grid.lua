
-- world grid added to voxel editor's grid

Grid = class()
function Grid.worldGrid()
    
    gridSize = vec3(1, 1, 1) * 100
    xGridColor = color(0, 159, 255, 90)
    yGridColor = color(0, 255, 111, 90)
    zGridColor = color(255, 63, 0, 90)
    
    grids = 
    {
        x1 = Grid(vec3(0,1,0), vec3(0, 0, 0), 1, gridSize, xGridColor, true),
        x2 = Grid(vec3(0,1,0), vec3(0, 0, 0), 1, gridSize, xGridColor, true),
        x3 = Grid(vec3(0,1,0), vec3(0, 0, 0), 1, gridSize, xGridColor, true),
        x4 = Grid(vec3(0,1,0), vec3(0, 0, 0), 1, gridSize, xGridColor, true),
        
        y1 = Grid(vec3(0,0,1), vec3(0, 0, 0), 1, gridSize, yGridColor, true),
        y2 = Grid(vec3(0,0,1), vec3(0, 0, 0), 1, gridSize, yGridColor, true),
        y3 = Grid(vec3(0,0,1), vec3(0, 0, 0), 1, gridSize, yGridColor, true),
        y4 = Grid(vec3(0,0,1), vec3(0, 0, 0), 1, gridSize, yGridColor, true),
        
        z1 = Grid(vec3(1,0,0), vec3(0, 0, 0), 1, gridSize, zGridColor, true),
        z2 = Grid(vec3(1,0,0), vec3(0, 0, 0), 1, gridSize, zGridColor, true),
        z3 = Grid(vec3(1,0,0), vec3(0, 0, 0), 1, gridSize, zGridColor, true),
        z4 = Grid(vec3(1,0,0), vec3(0, 0, 0), 1, gridSize, zGridColor, true)
    }
    
    grids.x1.entity.eulerAngles = vec3(0, 0, 0)
    grids.x2.entity.eulerAngles = vec3(0, 90, 0)
    grids.x3.entity.eulerAngles = vec3(0, 180, 0)
    grids.x4.entity.eulerAngles = vec3(0, 270, 0)
    
    grids.y1.entity.eulerAngles = vec3(0, 0, 0)
    grids.y2.entity.eulerAngles = vec3(0, 0, 90)
    grids.y3.entity.eulerAngles = vec3(0, 0, 180)
    grids.y4.entity.eulerAngles = vec3(0, 0, 270)
    
    grids.z1.entity.eulerAngles = vec3(0, 0, 0)
    grids.z2.entity.eulerAngles = vec3(90, 0, 0)
    grids.z3.entity.eulerAngles = vec3(180, 0, 0)
    grids.z4.entity.eulerAngles = vec3(270, 0, 0)
    
end

function Grid:init(normal, origin, spacing, size, lineColor, enabled)
    self.normal = normal
    self.origin = origin
    self.spacing = spacing
    self.size = size
    self.axes = {vec3(), vec3()}
    self.lineColor = lineColor
    self.enabled = enabled
    
    if self.normal.x ~= 0 then
        self.axes[1].y = 1
        self.axes[2].z = 1
        self.axes2 = {3, 2, 1}
    elseif self.normal.y ~= 0 then
        self.axes[1].x = 1
        self.axes[2].z = 1
        self.axes2 = {1, 3, 2}
    elseif self.normal.z ~= 0 then
        self.axes[1].x = 1
        self.axes[2].y = 1
        self.axes2 = {1, 2, 3}
    end
    
    self.entity = scene:entity()
    self.r = self.entity:add(craft.renderer, craft.model.cube(vec3(1,1,1), vec3(0.5, 0.5, 0.5)))
    self.r.material = craft.material(asset.builtin.Materials.Specular)
    self.r.material.blendMode = NORMAL
    self:modified()
end

-- Checks if the grid is visible based on where the camera is pointed
function Grid:isVisible()
    local camVec = scene.camera.worldPosition - self.origin
    return self.enabled and self.normal:dot(camVec) > 0.0
end

function Grid:modified()
    local gx = self.size[self.axes2[1]]
    local gy = self.size[self.axes2[2]]
    local inset = 8
    local majorAxisWidth = 3.255
    local minorAxisWidth = 0.5
    
    self.img = image(gx * 20, gy * 20)
    
    self.r.material.map = self.img
    
    -- Pre-render the grid to an image to make it look nicer (anti-aliasing)
    setContext(self.img)
    noSmooth()
    background(0,0,0,0)
    pushStyle()
    stroke(self.lineColor)
    strokeWidth(majorAxisWidth)
    noFill()
    rectMode(CORNER)
    rect(-2,-2,self.img.width+4, self.img.height+4)
    
    strokeWidth(2)
    --stroke(255, 113)
    
    for x = 1,gx-1 do
        if x % 10 == 0 then strokeWidth(majorAxisWidth) else strokeWidth(minorAxisWidth) end
        line(x * (self.img.width/gx), inset, x * (self.img.width/gx), self.img.height-inset)
    end
    
    for y = 1,gy-1 do
        if y % 10 == 0 then strokeWidth(majorAxisWidth) else strokeWidth(minorAxisWidth) end
        line(inset, y * (self.img.height/gy), self.img.width-inset, y * (self.img.height/gy))
    end
    
    popStyle()
    setContext()
    
    local s = vec3()
    s[self.axes2[1]] = self.size[self.axes2[1]]
    s[self.axes2[2]] = self.size[self.axes2[2]]
    self.entity.scale = s
    local p = vec3()
    p[self.axes2[3]] = self.origin[self.axes2[3]]
    self.entity.position = p
end

function Grid:update()
    self.entity.active = self:isVisible()
end
