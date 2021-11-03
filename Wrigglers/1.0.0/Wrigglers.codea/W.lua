Wriggle = class()

function Wriggle:init(x)
    self.points = {}
    self.drawPoints = {}
    self.widths = {}
    self.locked = false
    self.r=math.random(255)
    self.g=math.random(255)
    self.b=math.random(255)
    
end

function Wriggle:draw()
    
    
    if self.locked then
        local change = (self.points[2].p - self.points[1].p)
        local newPoint = self.points[#self.points].p + change
        
        table.insert(self.points, { p = newPoint })
        table.remove(self.points, 1)
        local x,y = newPoint.x % (2 * WIDTH), newPoint.y % (2 * HEIGHT)
        
        if x > WIDTH then
            x = WIDTH * 2 - x
        elseif x < 0 then
            x = -x
        end
        
        if y > HEIGHT then
            y = HEIGHT * 2 - y
        elseif y < 0 then
            y = -y
        end
        
        table.insert(self.drawPoints, { p = vec2(x,y) })
        table.remove(self.drawPoints, 1)
    end
    
    for i = 1, #self.drawPoints - 1 do
        pushStyle()
        stroke(self.r,self.g,self.b,(i/#self.drawPoints)*255)
        strokeWidth(self.widths[i].w * 0.8)
        local p1 = self.drawPoints[i].p
        local p2 = self.drawPoints[i + 1].p
        line(p1.x, p1.y, p2.x, p2.y)
        popStyle()
    end
end

function Wriggle:touched(t)
    print(t.radius)
    local tPoint = vec2(t.x, t.y)
    table.insert(self.points, { p = tPoint })
    table.insert(self.drawPoints, { p = tPoint })
    local falseTaper = 0
    if #self.widths <= 10 then
        falseTaper = 30 - (3 * #self.widths)
    end
    table.insert(self.widths, {w = t.radius - t.radiusTolerance - falseTaper})
    if t.state == ENDED then
        self.locked = true
    end
end
