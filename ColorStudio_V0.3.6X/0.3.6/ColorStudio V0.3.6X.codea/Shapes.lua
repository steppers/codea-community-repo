Shapes = class()

function Shapes:roundedRect(posX, posY, width, height, radius)
    
    if strokeWidth() == 0 then
        stroke(fill())
        noStroke()
    end
    
    radius = Math:clamp(radius, 0, math.min(width, height))
    local s = color(fill())
    local sW = strokeWidth()
    
    pushStyle()
    
    lineCapMode(ROUND)
    rectMode(CORNER)
    
    for j = 0, 1 do
        local half_rad = radius*0.5
        fill(stroke())
        strokeWidth(radius)
        for i = 0, 1 do
            line(posX+half_rad,
            posY+half_rad+(height-radius)*i,
            posX+width-half_rad,
            posY+half_rad+(height-radius)*i)
        end
        noStroke()
        rect(posX-0.5, posY+half_rad, width+1, height-radius)
        stroke(s)
        posX, posY, width, height = posX+sW, posY+sW, width-sW/0.5, height-sW/0.5
        radius = radius-Math:clamp(sW, 0, radius/2)/0.5
    end
    
    popStyle()
    
end
