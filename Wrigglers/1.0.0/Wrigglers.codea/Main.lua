-- Gesture "

-- Use this function to perform your initial setup
function setup()
    parameter.watch("1/DeltaTime")
    wriggles = {}
end

function draw()
    background(255, 255, 255, 255)
    
    strokeWidth(25)
    for i, wriggle in ipairs(wriggles) do
        wriggle:draw()
    end
end

function touched(t)
    if t.state == BEGAN then
        table.insert(wriggles, Wriggle())
    end
    
    for i, wriggle in ipairs(wriggles) do
        if not wriggle.locked then
            wriggle:touched(t)
        end
    end
end
