--# Model
Model = class()

function Model:init(owner)
    self.owner = owner
    self.frames = {
        idle = {
            {1/3, 1/3}
        },
        moving = {
            {1/3, 1/3},
            {2/3, 1/3},
            {1/3, 1/3},
            {0, 1/3}
        }}
    self.currentFrame = 1
    self.timer = 0 
    self.mdl = mesh()
    self.id = self.mdl:addRect(0, 0, 160/3, 105,-math.pi/2)
    if self.owner.side == 1 then
        self.mdl.texture = "Project:Toon"
    else
        self.mdl.texture = "Project:Toon2"
    end
    local frame = self.frames[self.owner.status][self.currentFrame]
    self.mdl:setRectTex(self.id, frame[1], 0, frame[2], 1)
end

function Model:update()
    self.timer = self.timer + DeltaTime
    
    if self.timer > .1 then
        self.timer = 0
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > #self.frames[self.owner.status] then
            self.currentFrame = 1
        end   
        local frame = self.frames[self.owner.status][self.currentFrame]
        self.mdl:setRectTex(self.id, frame[1], 0, frame[2], 1)
    end
    
end

function Model:draw()
    if self.owner.showFlash then
        self.mdl:setRectColor(self.id, 1000, 1000, 1000, 255)
    elseif self.owner.showHit then
        self.mdl:setRectColor(self.id, 10000, 0, 0, 255)
    else
        self.mdl:setRectColor(self.id, 255, 255, 255, 255)
    end
    
    self.mdl:draw()
end