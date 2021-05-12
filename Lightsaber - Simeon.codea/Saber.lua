Saber = class()

function Saber:init(length, trail)
    self.baseTex = blurredSquare(128,128)
    self.bladeGlowTex = blurredSquare(18,length)
    self.bladeTex = roundedTex(18,length,1)
    
    self.transformCount = trail or 20
    self.transformHistory = { matrix() }
    
    self.points = { vec3(0,0,0), vec3(0,20,0), vec3(0,length-20,0), vec3(0,length,0) }
    self.length = length
   
    self.bladeMeshBase = mesh()
    self.bladeMesh = mesh()
end

function Saber:computeMeshes()
    self.bladeMesh = meshByExtrudingPointsThroughTransforms(self.points, self.transformHistory)
    self.bladeMeshBase.vertices = self.bladeMesh.vertices
    self.bladeMesh.texture = self.baseTex
end

function Saber:setTransform(xform, record)
    if record == true then
        table.insert(self.transformHistory, 1, xform)
        
        if #self.transformHistory == (self.transformCount + 1) then
            table.remove(self.transformHistory, self.transformCount + 1)
        end
    else
        self.transformHistory = { xform }
    end
    
    self:computeMeshes()
end

function Saber:deleteTransform()
    if #self.transformHistory > 1 then
        table.remove(self.transformHistory)
    end
    
    self:computeMeshes()
end

function Saber:draw()
    pushStyle()
    
    pushMatrix()
    modelMatrix(self.transformHistory[1])
    
    blendMode(NORMAL)
    fill(71, 91, 122, 255)
    rectMode(CORNER)
    rect(-5, -120, 10, 124)
    fill(110, 124, 149, 255)
    rect(-10, -110, 20, 100)  
    
    popMatrix()
    
    fill(248, 39, 21, 255)
    blendMode(ADDITIVE)
    self.bladeMeshBase:draw()
    fill(223, 153, 155, 255)
    self.bladeMesh:draw()
    
    pushMatrix()
    modelMatrix(self.transformHistory[1])
  
    tint(248, 39, 21, 255)  
    spriteMode(CORNER)
    sprite(self.bladeTex, -9, 0)
    
    tint(255, 255, 255, 255)
    spriteMode(CORNER)
    sprite(self.bladeGlowTex, -9, -30, 18, self.length + 60)
    
    popMatrix()
    popStyle()
end

function Saber:touched(touch)
    -- Codea does not automatically call this method
end


