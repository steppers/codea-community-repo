function stuffs()
    GAMEFONT = "Futura-CondensedMedium"
    
    oneS = WIDTH / 768
    twoS = (1024/768)
    
    sounds = {
        climb = function() sound("A Hero's Quest:Swing 3") end,
        fall = function() sound("A Hero's Quest:Hurt 4") end,
        die = function() sound("A Hero's Quest:Hurt 5") end
    }
    
    local bimg, gimg = makeImgs()
    imgs = {
        ladder = readImage("Documents:LMLadder"),
        hole = readImage("Documents:LMHole"),
        player = { 
            { readImage("Documents:LMPlayerB1"), readImage("Documents:LMPlayerB2") },
            { readImage("Documents:LMPlayerL1"), readImage("Documents:LMPlayerL2") },
            { readImage("Documents:LMPlayerP1"), readImage("Documents:LMPlayerP2") },
            { readImage("Documents:LMPlayerG1"), readImage("Documents:LMPlayerG2") },
            { readImage("Documents:LMPlayerY1"), readImage("Documents:LMPlayerY2") },
        },
        ground = gimg,
        sign = readImage("Documents:LMRipsign"),
        brick = bimg,
        bar = { readImage("Documents:LMBargray"), readImage("Documents:LMBarred") },
        panel = readImage("Documents:LMGlasspanel")
    }
    
    sizes = {
        ladder = vec2(WIDTH / 9, WIDTH / 9 *(twoS)),
        player = vec2(WIDTH / 10, WIDTH / 9.5 * twoS),
        sign = vec2(WIDTH / 8, WIDTH / 9 * twoS),
        replay = vec2(WIDTH / 3.5, WIDTH / 9),
        smallFont = vec2(WIDTH / 7.5, WIDTH / 20),
    
        bigFont = vec2(WIDTH / 5, WIDTH / 10), 
        scoreFont = vec2()
    }
    sizes.scoreFont = vec2(sizes.smallFont.x, sizes.smallFont.y)
    
    replay = { x = WIDTH / 2, y = -sizes.replay.y / 2 }
    
    leftX = WIDTH / 3.5
    rightX = WIDTH * 2.5/3.5
end

function makeImgs()
    local brickImg = image(WIDTH, HEIGHT / 9) setContext(brickImg)
    for i = 1, 9 do
        sprite("Documents:LMStone", -WIDTH / 18 + (WIDTH / 9) * i, HEIGHT / 18, WIDTH / 9, HEIGHT / 9)
    end
    setContext()
    
    local groundImg = image(WIDTH, HEIGHT / 9) setContext(groundImg)
    for i = 1, 9 do
        sprite("Documents:LMGrass", -WIDTH / 18 + (WIDTH / 9) * i, HEIGHT / 18, WIDTH / 9, HEIGHT / 9)
    end
    setContext()
    
    
    return brickImg, groundImg
end

