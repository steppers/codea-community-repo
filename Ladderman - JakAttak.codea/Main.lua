-- Ladderman
-- Copyright 2014 Théo Arrouye
-- Art by Kenney.nl

displayMode(FULLSCREEN)
supportedOrientations(PORTRAIT)
function setup()
    LOADINGIMGS, PLAYING, LOST = 1, 2, 3
    
    imgLoader = Loader()
    
    MODE = LOADINGIMGS
end

function afterImgSetup()
    MODE = PLAYING
    
    stuffs()
    initialise()
end

function draw()
    background(255)
    
    if MODE == LOADINGIMGS then
        imgLoader:draw()
        
        if imgLoader.doneLoading then
            afterImgSetup()
        end
    end
    
    if MODE == PLAYING or MODE == LOST then
        drawGame()
    end
    
    if MODE == LOST then
        drawLost()
    end
end

function touched(t)
    if t.state == ENDED then
        if MODE == PLAYING then
            touchPlaying(t)
        elseif MODE == LOST then
            touchLost(t)
        end
    end
end

