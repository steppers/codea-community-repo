-- MouseLib

function draw()
    background(0, 255, 50)
    
    -- Polling
    -- 'A' key == 4
    --print("A key down? ", iskeydown(4))
    
    -- Left mouse button
    --print("Left mouse down? ", ismousedown(MOUSELEFT))
end

-- Callbacks

function mousemove(dx, dy)
    print("mousemove", dx, dy)
end

function mousedown(bttn)
    print("mousedown", bttn)
end

function mouseup(bttn)
    print("mouseup", bttn)
end

function keydown(key)
    print("keydown", key)
end

function keyup(key)
    print("keyup", key)
end
