BackgroundObject = class()

function BackgroundObject:init(x,y,lev,kind)
    self.x = x
    self.y=y
    self.lev=4-lev --0 foreground, 1 close, 2 mid, 3 far
    self.kind=kind
end

function BackgroundObject:draw()
    spriteMode(CORNER)
    sprite(spriteTable[11],self.x,self.y,50*self.lev,87*self.lev) --dandelion
    spriteMode(CENTER)
    if not stop then
    self.x = self.x - self.lev
        end
end
