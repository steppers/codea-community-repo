-- Just holds most of the functions for the playing state

-- Resets the game
function initialise()
    ladders = {}
    player = { x = rightX, y = sizes.ladder.y * 2.5, cid = math.random(1, 5), iid = 1, angle = 0 }
    sign = { x = 0, y = sizes.ladder.y + sizes.sign.y / 2, alpha = 0 }
    
    for r = 1, math.ceil(HEIGHT / sizes.ladder.y) + 1 do
        addRow(true)
    end
    
    groundO = sizes.ladder.y
    score = 0
    highscore = readLocalData("highscore") or 0
    time = .5
    if timeT ~= nil then tween.stop(timeT) end
    canMove = true
    fell = false
end


-- Draws everything for the playing state
function drawGame()
    -- Draw the 'bulding' background
    for bi = #ladders, 1, -2 do
        sprite(imgs.brick, WIDTH / 2, ladders[bi].y, WIDTH, sizes.ladder.y)
    end
        
    -- Draw the ladders
    for li = #ladders, 1, -1 do
        local ladder = ladders[li]
        if not ladder.hole then
            sprite(imgs.ladder, ladder.x, ladder.y, sizes.ladder.x, sizes.ladder.y)
        else
            sprite(imgs.hole, ladder.x, ladder.y, sizes.ladder.x, sizes.ladder.y)
        end
    end

    -- Draw the player
    pushMatrix() translate(player.x, player.y) rotate(player.angle)
    sprite(imgs.player[player.cid][player.iid], 0, 0, sizes.player.x, sizes.player.y)
    popMatrix()
        
    -- Draw the ground if it is still onscreen
    if groundO < sizes.ladder.y then
        sprite(imgs.ground, WIDTH / 2, sizes.ladder.y / 2 - groundO, WIDTH, sizes.ladder.y)
    end
        
    -- Draw the timer bar
    local o = WIDTH / 200
    local a = (rightX - sizes.ladder.x / 2) - (leftX + sizes.ladder.x / 2)
    sprite(imgs.bar[1], WIDTH / 2, HEIGHT - WIDTH / 40 * (1024/768), a, HEIGHT / 10)
    sprite(imgs.bar[2], WIDTH / 2, HEIGHT - WIDTH / 40 * (1024/768), (a - o*1.8) * time, HEIGHT / 10 - o*1.8)
        
    -- Draws the score and then the highscore right below it
    sprite(imgs.panel, WIDTH / 2, HEIGHT / 2, sizes.replay.x)
    font(GAMEFONT)
    fill(0) if score >= highscore then fill(255,0,0) end 
    fontSize(sizes.scoreFont.x)
    if score > 100 then
        --fontSize(sizes.scoreFont.x * 0.75)
    end
    text(score, WIDTH / 2, HEIGHT / 2)
    fill(255,0,0) fontSize(sizes.scoreFont.y)
    text(math.floor(math.max(highscore, score)), WIDTH / 2, HEIGHT / 2 - fontSize() * 1.5)
    fill(0)
    text("SCORE", WIDTH / 2, HEIGHT / 2 + fontSize() * 1.5)
    stroke(0, 155, 255, 153) strokeWidth(oneS * 2)
    --line(WIDTH / 2 - sizes.replay.x / 2.17, HEIGHT / 2 - fontSize(), WIDTH / 2 + sizes.replay.x / 2.17, HEIGHT / 2 - fontSize())
    --line(WIDTH / 2 - sizes.replay.x / 2.17, HEIGHT / 2 + fontSize(), WIDTH / 2 + sizes.replay.x / 2.17, HEIGHT / 2 + fontSize())
    
    -- Lost / died sign
    tint(255, sign.alpha)
    sprite(imgs.sign, sign.x, sign.y, sizes.sign.x, sizes.sign.y)
    noTint()
end

-- Losing sequence
function fall()
    if fell then return end 
    canMove = false
    fell = true
    sounds.fall()
    
    if timeT ~= nil then tween.stop(timeT) end
    
    tween(.75, _G, { groundO = 0 })
    animateEndScore()
    falling = tween(.75, player, { y = 0, angle = 230 }, tween.easing.linear, function()
    sounds.die()
        sign.x = player.x + sizes.ladder.x / 2 + sizes.sign.x / 1.75
        if player.x == leftX then sign.x = player.x - sizes.ladder.x / 2 - sizes.sign.x / 1.75 end
        falling = tween(.5, sign, { alpha = 255 }, tween.easing.linear, function() 
            animateEndMenu()
            MODE = LOST
        end)
    end)
end

-- Adds another row to the top of the ladder
function addRow(rnok)
    local y
    if #ladders == 0 then y = sizes.ladder.y / 2
    else y = ladders[#ladders].y + sizes.ladder.y end
    
    local rand = math.random(1, 5)
    local rhole, lhole = false, false
    if not rnok then
        if rand == 2 and lastRand ~= 3 then rhole = true
        elseif rand == 3 and lastRand ~= 2 then lhole = true end
    end
    lastRand = rand
    
    table.insert(ladders, { x = rightX, y = y, hole = rhole })
    table.insert(ladders, { x = leftX, y = y, hole = lhole })
end

-- Checks if the player is in a hole
function checkLoss()
    if fell then return true end
    
    for li = #ladders, 1, -1 do
        local ladder = ladders[li]
        if ladder.hole and ladder.x == player.x and math.abs(ladder.y - player.y) < sizes.ladder.y / 2 then
            if score > highscore then
                saveLocalData("highscore", score)
            end
            
            fall()
            return true
        end
    end
    
    return false
end

-- Moves ladders and player, and calls to check if player is in a hole
function moveObjects(right)
    canMove = false
    player.iid = 2
    sounds.climb()
    
    if right then
        player.x = rightX
    else
        player.x = leftX
    end
    
    checkLoss()
    
    for li = #ladders, 1, -1 do
        local ladder = ladders[li]
        tween(0.04, ladder, { y = ladder.y - sizes.ladder.y })
        
        if ladder.y < 0 then
            table.remove(ladders, li)
        end
    end
    
    tween.delay(0.04, function()
        addRow()
    
        if not checkLoss() then
            player.iid = 1
    
            score = score + 1
            canMove = true
        end
    end)
end

-- Adds a bit of time to the timer
function addToTimer()
    if timeT ~= nil then
        tween.stop(timeT)
        timeT = nil
    end
    
    time = math.min(time + .04, 1)
    timeT = tween(time * 8, _G, { time = 0 }, tween.easing.linear, fall) 
end

-- All the touch code for the playing state
function touchPlaying(t)
    if canMove then
        moveObjects(t.x > WIDTH / 2)
        addToTimer()
    end
end

