--# Animation
Animation = class()

function Animation:init(effect, pos, loop, speed, size, alpha)
    self.pos = vec2(pos.x, pos.y)
    self.img = "Project:" .. effect
    self.timer = 0
    self.loop = loop
    self.speed = speed or .1
    self.scale = size or 1
    self.alpha = alpha or 1
    
    self.rot = math.random()*math.pi*2
    
    self.w, self.h = spriteSize(self.img)
    self.size = 1/math.floor(self.w/64)
    self.mdl = mesh()
    self.id = self.mdl:addRect(0, 0, 64, 64, self.rot)
    self.mdl.texture = self.img
    self.mdl:setRectTex(self.id, 0, 0, self.size, 1)
    self.mdl:setRectColor(self.id, color(255, 255, 255, self.alpha*255))
    self.offset = 0
    
    self.done = false
end

function Animation:update()
    self.timer = self.timer + DeltaTime
    if self.timer > self.speed  then
        self.timer = 0
        self.offset = self.offset + self.size
        if self.offset > 1 then
            self.done = true
        else
            self.mdl:setRectTex(self.id, self.offset, 0, self.size, 1)            
        end
    end
end

function Animation:draw(vec)
    local pos = self.pos - vec
    pushMatrix()
    translate(pos.x, pos.y)
    --   rotate(ElapsedTime*360)
    --   tint(255, 255, 255, self.timer*255*self.alpha)
    scale(self.scale)
    self.mdl:draw()
    --    sprite(self.img, 0, 0, self.size)
    
    popMatrix()
end