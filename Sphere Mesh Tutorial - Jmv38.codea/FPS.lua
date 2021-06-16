FPS = class()

function FPS:init()
    self.val = 60
end

function FPS:draw()
    -- update FPS value with some smoothing
    self.val = self.val*0.9+ 1/(DeltaTime)*0.1
    -- write the FPS on the screen
    fill(COLOR)
    fontSize(30)
    font("AmericanTypewriter-Bold")
    rectMode(CENTER)
    text(math.floor(self.val).." fps",50,HEIGHT-25)
end


