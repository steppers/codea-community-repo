Picker = class()

function Picker:init(sizeA, sizeB)
    
    self.size = {
        current={
            A=sizeA,
            B=sizeB
        },
        previous=sizeA
    }
    
    self.animation = Timer(0.25)
    self.pop = 0
    self.held = false
    
end

function Picker:draw(pos, col)
    
    pushMatrix()
    pushStyle()
    
    if not self.animation:complete() then
        self.pop = self.animation.count/self.animation.interval
    else
        self.prevPos = pos
    end
    
    local size = Math:mix(
        self.size.previous,
        Math:mix(
            self.size.current.A,
            self.size.current.B,
            Math:b2n(self.held)
        ),
        Math:smootherstep(0.0, 1.0, self.pop) * 0.75
    )
    self.size.previous = size
    
    noStroke()
    fill(25, 125)
    ellipse(pos.x, pos.y-3, size)
    
    stroke(255)
    strokeWidth(2)
    fill(col)
    ellipse(pos.x, pos.y, size)
    
    popStyle()
    popMatrix()
    
end

function Picker:touched(touch, area)
    
    if area and touch.state == BEGAN and not self.held then
        self.held = true
        self.animation:start()
    elseif touch.state == ENDED and self.held then
        self.held = false
        self.animation:start()
    end
    
end