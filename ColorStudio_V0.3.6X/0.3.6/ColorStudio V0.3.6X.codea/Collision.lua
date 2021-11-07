Collision = {}

Collision.point = class()

function Collision.point:circle(pt, origin, diameter)
    if (pt-origin):len()/(diameter/2) <= 1 then
        return true
    else
        return false
    end
end

function Collision.point:ellipse(pt, origin, size)
    if (pt.x-origin.x)^2/(size.x/2)^2+(pt.y-origin.y)^2/(size.y/2)^2 <= 1 then
        return true
    else
        return false
    end
end