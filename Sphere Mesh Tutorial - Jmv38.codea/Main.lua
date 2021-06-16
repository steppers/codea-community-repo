-- project "sphere" JMV38

function setup()
    --displayMode(STANDARD)
    displayMode(FULLSCREEN)
    
    COLOR = color(207, 207, 207, 255)
    fps = FPS()
    cam = CameraControl()
    tuto = Tutorial()
end

function draw()
    background(14, 14, 14, 255)
    rectMode(CORNER)
    rect(5,5,270,32)
    perspective(50, WIDTH/HEIGHT)    -- First arg is FOV, second is aspect    
        cam:setCam()    
        tuto:update()
    ortho()                          -- Restore orthographic projection 
    viewMatrix(matrix())             -- Restore the view matrix to the identity    
    tuto:draw()
    fps:draw()
end

function touched(touch)
    cam:touched(touch)
    tuto:touched(touch)
end



