-- Lightsaber

function setup()
    touches = {}
    
    lightsaber = Saber(300, 15)
    
    lightsaber:setTransform(matrix():translate(WIDTH/2, HEIGHT/2, 0), false)
end

function draw()
    background(2, 2, 2, 255)

    font("GillSans")
    fontSize(24)
    fill(129, 158, 180, 255)
    textAlign(CENTER)
    text("Use two fingers to swing the lightsaber",WIDTH/2,100)
    
    lightsaber:draw()
    lightsaber:deleteTransform()
end

function touched(touch)
    if touch.state == BEGAN then
        table.insert(touches, touch)
        
        table.sort(touches, function(t1,t2)
            return t1.y < t2.y
        end)
    elseif touch.state == MOVING then
        replace(touches, touch, function(t)
            return touch.id == t.id
        end)
    elseif touch.state == ENDED or
           touch.state == CANCELLED then
        touches = filter(touches, function(t)
            return touch.id ~= t.id
        end)
    end
    
    local xform = transformFromTouches(touches)
    
    if xform ~= nil then
        lightsaber:setTransform(xform, true)
    end
end

function transformFromTouches(t)
    local gesture = map(first(t,2), function(touch)
        return vec2(touch.x, touch.y)
    end)
    
    if #gesture < 2 then
        return nil
    end
    
    local up = vec2(0, 1)
    local dir = (gesture[2] - gesture[1]):normalize()
    local center = gesture[2]
    
    local angle = math.deg(up:angleBetween(dir))
    
    return matrix()
            :translate(center.x, center.y, 0)
            :rotate(angle, 0, 0, 1)
end


