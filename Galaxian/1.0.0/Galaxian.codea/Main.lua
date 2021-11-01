-----------------
--  Galaxian   --
-----------------

-- Keith Davis --
--  (c) 2021   --
--  ZuniSoft   --

sfPlayer = {}
sfPMissile = {}
sfEMissile = {}
sfBadGuy1 = {}
sfBadGuy2 = {}
sfBadGuy3 = {}
sfBadGuy4 = {}
sfEx1 = {}
sfEx2 = {}
sfEx3 = {}
sfEx4 = {}
sfEx5 = {}
sfScore300 = {}
extraLife = image()
levelFlags = {}
stars = {}
-- these lists manage our sprites
sprites = {}
sprites2 = {}
grid = {}
-- this keeps track of how to move the bad guy grid
dxGrid = 0
-- a game counter for delays
gameCount = 0
gameResume = 0
-- set if anything is attacking
attacking = false
-- number of lives left
numPlayerLives = 0
displayNumPlayerLives = 0
-- which level
level = 0
-- enemy attack info
attackFrequency = 0.0
enemyFireFrequency = 0.0
maxEnemyDescentSpeed = 0
maxEnemyLateralSpeed = 0
maxEnemiesAttacking = 0
-- score stuff
highScore = 0
score = 0
nextFreeGuy = 0
-- Font stuff
fontHeight = 0
-- game state
gameState = 0

-- use this function to perform your initial setup
function setup()
    viewer.mode = FULLSCREEN_NO_BUTTONS
    -- global constants
    Global:init()
    -- set sprite mode
    spriteMode(CORNER)
    -- scale elements
    scaleScreenElements(Global.DEFAULT_SCALE)
    -- initial game state
    gameState = Global.GSTATE_GAMEOVER
    -- load up all the images and sounds we'll need
    loadMedia()
    -- create sprite lists
    for i=1,10 do
        grid[i] = {}
        for j=1,6 do
            grid[i][j] = nil
        end
    end
    -- set up a font
    font("SourceSansPro-Bold")
    fontSize(24 * Global.SCALE)
    fontMetrics = fontMetrics()
    fontHeight = fontMetrics.capHeight
    -- explosions
    createExImages()
    -- get hiscore
    highScore = math.floor(readLocalData(Global.HIGH_SCORE_PREF, 0))
    -- stars
    for i = 1, Global.NUM_STARS, 1 do
        table.insert(stars, vec2(math.random() * Global.SCREEN_WIDTH, math.random() * Global.SCREEN_HEIGHT))
    end
    -- controls
    rightBtn = Button(200, 110, asset.arrowright, 64, 64)
    leftBtn = Button(64, 110, asset.arrowleft, 64, 64)
    fireBtn = Button(Global.SCREEN_WIDTH - 132, 110, asset.firebutton, 64, 64)
end

-- this function gets called once every frame
function draw()
    -- background color 
    background(0, 0, 0)
    -- update background items
    updateBackground()
    -- process game and animate
    execute()
    -- update foreground items
    rightBtn:draw()
    leftBtn:draw()
    fireBtn:draw()
end

-- execute the game process
function execute()  
    if gameState == Global.GSTATE_PLAYING then
        processGame()
    elseif gameState == Global.GSTATE_PLAYERDIED then
        processPlayerDied()
    elseif gameState == Global.GSTATE_CHANGINGLEVEL1 or gameState == Global.GSTATE_CHANGINGLEVEL2 then
        processChangingLevel()
    elseif gameState == Global.GSTATE_GAMEOVER or gameState == Global.GSTATE_PAUSED then
        updateBackground()
    end    
    Global.playerFired = false
    gameCount = gameCount + 1
end

-- process the game
function processGame()
    -- animate a frame
    animate()
    -- save score
    if score > highScore then
        highScore = score
        saveLocalData(Global.HIGH_SCORE_PREF, highScore)
    end
    -- player may have died
    if not Global.playerAlive then
        numPlayerLives = numPlayerLives - 1
        gameResume = gameCount + 200
        gameState = Global.GSTATE_PLAYERDIED
    end
    -- new level
    if Global.numBadGuys == 0 and gameResume < 0 then
        gameState = Global.GSTATE_CHANGINGLEVEL1
        gameResume = gameCount + 50
        level = level + 1
        attackFrequency = attackFrequency + Global.LEVELINC_ATTACK_FREQUENCY
        enemyFireFrequency = enemyFireFrequency + Global.LEVELINC_ENEMY_FIRE_FREQUENCY
        -- make things a little more extreme every other level
        if (level-1)%2 == 0 then
            maxEnemyDescentSpeed = maxEnemyDescentSpeed + 1
            if maxEnemyDescentSpeed  > Global.MAX_ENEMY_DESCENT_SPEED then
                maxEnemyDescentSpeed = Global.MAX_ENEMY_DESCENT_SPEED
            end
            maxEnemyLateralSpeed = maxEnemyLateralSpeed + 1
            if maxEnemyLateralSpeed > Global.MAX_ENEMY_LATERAL_SPEED then
                maxEnemyLateralSpeed = Global.MAX_ENEMY_LATERAL_SPEED
            end
            maxEnemiesAttacking = maxEnemiesAttacking + 1
        end
    end
    -- May need to play a player fired sound
    if Global.playerFired then
        sound(asset.playerfired)
    end
end

-- when in player died state
function processPlayerDied()
    if gameCount > gameResume and not attacking then
        displayNumPlayerLives = displayNumPlayerLives - 1
        -- add a player sprite
        table.insert(sprites, PlayerSprite((Global.SCREEN_WIDTH - Global.PLAYER_WIDTH - Global.PLAYER_XOFFSET)/2, Global.PLAYER_Y,Global.PLAYER_WIDTH, Global.PLAYER_HEIGHT, sfPlayer))
        -- add a missile
        table.insert(sprites, PlayerMissileSprite((Global.SCREEN_WIDTH - Global.PMISSILE_WIDTH)/2, Global.PLAYER_Y + Global.PLAYER_HEIGHT - 7, Global.PMISSILE_WIDTH, Global.PMISSILE_HEIGHT, sfPMissile))
        -- missle tweek - bad hack to line up missile
        Global.direction = Global.MOVELEFT
        tween.delay(.05, function()
            Global.direction = Global.NOMOVE
        end)    
        Global.loadAnotherMissile = false
        gameResume = -1
        Global.playerAlive = true 
        if numPlayerLives < 0 then
            gameState = Global.GSTATE_GAMEOVER
            sound(asset.gameover)
        else
            gameState = Global.GSTATE_PLAYING
        end
    else
        animate()
    end
end

-- when in changing levels state
function processChangingLevel()
    if gameState == Global.GSTATE_CHANGINGLEVEL1 then
        if gameCount > gameResume then
            gameState = Global.GSTATE_CHANGINGLEVEL2
            gameResume = gameCount + 150
            sound(asset.getready)
        else
            animate()
        end
    elseif gameState == Global.GSTATE_CHANGINGLEVEL2 then
        if gameCount > gameResume then
            gameResume = gameResume - 1
            initBadGuyGrid()
            gameState = Global.GSTATE_PLAYING
            sound(asset.startgame)
        else
            updateBackground()
        end
    end
end

-- processes one frame of animation
function animate()
    -- update background
    updateBackground()
    -- draw the sprites
    for i, s in ipairs(sprites) do
        s:update()
        sprite(s:getCurrFace(), s.x, s.y)
    end
    -- collision check our Sprites
    local explosionPoints = {}
    local score300 = {}
    for i, s1 in ipairs(sprites) do
        -- only consider sprites that aren't type 0 or dead
        if s1.type ~= 0 and s1.alive then
            for j, s2 in ipairs(sprites) do
                -- make sure we're not dealing with the same sprite, a Sprite with
                -- type 0, a dead sprite, or sprites of the same type
                local differentSigns = (s1.type > 0 and s2.type < 0) or (s1.type < 0 and s2.type > 0)
                if s2.type ~= 0 and s1 ~= s2 and differentSigns and s2.alive then
                    -- check if their collision rectangles are intersecting
                    if (s1:getCollisionRect():intersects(s2:getCollisionRect())) then
                        addToScore = 0
                        -- update sprite states
                        local ctype = getCollisionType(s1.type, s2.type)
                        if ctype == Global.COL_PMISSILE_EMISSILE then
                        elseif ctype == Global.COL_EMISSILE_PLAYER then
                            s1.alive = false
                            s2.alive = false
                            table.insert(explosionPoints, vec2(s1.x, s1.y))
                            table.insert(explosionPoints, vec2(s2.x, s2.y))
                            sound(asset.playerexplode)
                        elseif ctype == Global.COL_PLAYER_BADGUY then
                            s1.alive = false
                            s2.alive = false
                            table.insert(explosionPoints, vec2(s2.x, s2.y))
                            table.insert(explosionPoints, vec2(s1.x, s1.y))
                            if s1.type == Global.HEADBADGUY_TYPE or s2.type == Global.HEADBADGUY_TYPE then
                                sound(asset.shotbigbadguy)
                            else
                                if (math.random(100) > 50) then
                                    sound(asset.shotbadguy1)
                                else
                                    sound(asset.shotbadguy2)
                                end
                            end
                            sound(asset.playerexplode)
                            addToScore = getScoreFromCollision(s1, s2)
                        elseif ctype == Global.COL_PMISSILE_BADGUY then
                            s1.alive = false
                            s2.alive = false
                                table.insert(explosionPoints, vec2(s1.x, s1.y))
                            if (s1.type == Global.HEADBADGUY_TYPE or s2.type == Global.HEADBADGUY_TYPE) then
                                sound(asset.shotbigbadguy)
                            else
                                if math.random(100) > 50 then
                                    sound(asset.shotbadguy1)
                                else 
                                    sound(asset.shotbadguy2)
                                end
                            end
                            addToScore = getScoreFromCollision(s1, s2)
                            -- update score
                            score = score + addToScore
                            if (addToScore == 300) then
                                table.insert(score300, vec2(s1.x, s1.y))
                            end
                            -- maybe we get a free guy
                            if score >= nextFreeGuy then
                                sound(asset.freeguy)
                                nextFreeGuy = nextFreeGuy + Global.FREE_GUY_INTERVAL
                                numPlayerLives = numPlayerLives + 1
                                displayNumPlayerLives = displayNumPlayerLives + 1
                            end
                        end
                    end
                end
            end
        end
    end
    -- now clear out the dead sprites and update our attacking flag
    for k in pairs (sprites2) do
        sprites2[k] = nil
    end
    attacking = false
    local numAttacking = 0
    for i, s in pairs(sprites) do
        if s.alive then
            table.insert(sprites2, s)
            if s.classType == 'BadGuySprite' then
                if s:isAttacking() then
                    attacking = true
                    numAttacking = numAttacking + 1
                end
            end         
        else
            s:died()
        end
    end
    -- switch back to main list
    -- populated from the second list
    for k in pairs (sprites) do
        sprites[k] = nil
    end
    for i, k in pairs (sprites2) do
        table.insert(sprites, k)
    end
    -- may need to make an explosion 
    for j, p in pairs (explosionPoints) do
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 50, 50, sfEx5))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 50, 50, sfEx5))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 40, 40, sfEx4))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 29, 29, sfEx5))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 27, 27, sfEx3))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 23, 23, sfEx3))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 22, 22, sfEx2))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 22, 22, sfEx2))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 50, 50, sfEx1))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 40, 40, sfEx1))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 1, 1, sfEx1))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 1, 1, sfEx1))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 1, 1, sfEx1))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 1, 1, sfEx1))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 1, 1, sfEx1))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 1, 1, sfEx1))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 1, 1, sfEx1))
        table.insert(sprites, ExplosionPieceSprite(p.x, p.y, 1, 1, sfEx1))
    end
    -- may need to add a score 300
    for i, s in pairs (score300) do
        table.insert(sprites, Score300Sprite(s.x, s.y, 0, 0, sfScore300))
    end
    -- we may need to create another missile
    if Global.loadAnotherMissile then
        table.insert(sprites, PlayerMissileSprite(Global.playerx, Global.PLAYER_Y + Global.PMISSILE_YOFFSET,
        Global.PMISSILE_WIDTH, Global.PMISSILE_HEIGHT, sfPMissile))
        -- update the bulletin board
        Global.loadAnotherMissile = false
    end
    -- update the grid and look for new attackers
    local doAttack
    local dir
    for col=1, 10, 1 do
        for row=1, 6, 1 do
            if grid[col][row] ~= nil then
                if not grid[col][row].alive then
                    grid[col][row] = nil
                elseif grid[col][row].classType == "BadGuySprite" then
                    s = grid[col][row]
                    --sprite(s.faces[s.currFace], s.x, s.y)
                    -- Perhaps the enemy should fire
                    if math.random(0) < enemyFireFrequency and s:isInChaseMode() then
                        table.insert(sprites, EnemyMissileSprite(grid[col][row].x + Global.EMISSILE_XOFFSET,
                        grid[col][row].y + Global.EMISSILE_YOFFSET,
                        Global.EMISSILE_WIDTH, Global.EMISSILE_HEIGHT, sfEMissile))
                        sound(asset.enemyfired)
                    end
                end
                doAttack = false
                dir = (col >= 5 and Global.BADGUY_ATTACK_RIGHT or Global.BADGUY_ATTACK_LEFT)
                
                if Global.numBadGuys < 4 and Global.playerAlive then
                    doAttack = true
                else
                    -- check if this one can attack
                    if canBadGuyAttack(dir, col, row) and math.random() < attackFrequency and numAttacking < maxEnemiesAttacking then
                        doAttack = true
                    end
                end
            end
            if (doAttack) then
                if not s:isAttacking() then
                    sound(asset.badguyattacking)
                    s:attack(dir)
                    -- if this sprite is a head bad guy, we need to find wing men
                    -- for him by choosing any 2 out of 3 possible
                    if s.type == Global.HEADBADGUY_TYPE then
                        local wingMan1, wingMan2, wingMan3
                        wingMan1 = grid[col+1][4]
                        wingMan2 = grid[col][4]
                        wingMan3 = grid[col-1][4]
                        local numGoing = 0
                        -- left side
                        if col == 3 then
                            if wingMan3 ~= nil then
                                numGoing = numGoing + 1
                                wingMan3:attackMaster(dir, s)
                            end
                            if wingMan2 ~= nil then
                                numGoing = numGoing + 1
                                wingMan2:attackMaster(dir, s)
                            end
                            if numGoing < 2 and wingMan1 ~= nil then
                                numGoing = numGoing + 1
                                wingMan1:attackMaster(dir, s)
                            end
                        end   
                        -- right side
                        if col == 6 then
                            if wingMan1 ~= nil then
                                numGoing = numGoing + 1
                                wingMan1:attackMaster(dir, s)
                            end
                            if wingMan2 ~= null then
                                numGoing = numGoing + 1
                                wingMan2:attackMaster(dir, s)
                            end
                            if numGoing < 2 and wingMan3 ~= nil then
                                numGoing = numGoing + 1
                                wingMan3:attackMaster(dir, s)
                            end
                        end
                    end
                end
            end
        end
    end
    -- update the left edge
    Global.gridLeftEdge = Global.gridLeftEdge + dxGrid
    if (Global.gridLeftEdge + Global.BADGUY_HORZ_SPACE*10 > Global.SCREEN_WIDTH or Global.gridLeftEdge < 0) then
        Global.gridLeftEdge = Global.gridLeftEdge - dxGrid
        dxGrid = dxGrid * -1
    end
end
  
-- to figure out scoring
function getCollisionType(t1, t2)
    if (t1 == Global.PMISSILE_TYPE and isBadGuy(t2) or isBadGuy(t1) and t2 == Global.PMISSILE_TYPE) then
        return Global.COL_PMISSILE_BADGUY
    elseif (t1 == Global.PLAYER_TYPE and isBadGuy(t2) or
        isBadGuy(t1) and t2 == Global.PLAYER_TYPE) then
        return Global.COL_PLAYER_BADGUY
    elseif (t1 == Global.PLAYER_TYPE and t2 == Global.EMISSILE_TYPE or t1 == Global.EMISSILE_TYPE and t2 == Global.PLAYER_TYPE) then
        return Global.COL_EMISSILE_PLAYER
    elseif (t1 == Global.PMISSILE_TYPE or t2 == Global.EMISSILE_TYPE or t1 == Global.EMISSILE_TYPE and t2 == Global.PMISSILE_TYPE) then
        return Global.COL_PMISSILE_EMISSILE
    end
    return 0
end

-- To determine score
function getScoreFromCollision(s1, s2)
    local s
    if isBadGuy(s1.type) then
        s = s1
    else
        s = s2
    end
    if s.type == Global.BADGUY1_TYPE then return 20
    elseif s.type == Global.BADGUY2_TYPE then return 30
    elseif s.type == Global.BADGUY3_TYPE then return 50
    elseif s.type == Global.HEADBADGUY_TYPE then
        if s.classType == "BadGuySprite" then
            if s:isAttackingOrChasing() then
                return 300
            end
            return 75
        end
    end
    return 0
end
   
-- to determine what kind of Sprite we're dealing with
function isBadGuy(stype)
    return (stype == Global.BADGUY1_TYPE or
    stype == Global.BADGUY2_TYPE or
    stype == Global.BADGUY3_TYPE or
    stype == Global.HEADBADGUY_TYPE)
end
    
-- an enemy can attack if he has no neighbor to his right (or left)
-- and no neighbor above him
function canBadGuyAttack(leftOrRight, col, row) 
    local horzNeighbor
    local vertNeighbor
    -- unless the head bad guys are gone, row 4 can't attack
    if (Global.numHeadBadGuys ~= 0 and row == 4) then
        return false
    end
    -- if the player is dead, we can't attack
    if not Global.playerAlive then
        return false
    end
    local tmpCol = col + (leftOrRight == Global.BADGUY_ATTACK_RIGHT and 1 or -1) + 1
    local tmpRow = row + 1
    if (tmpRow > 5) then
        vertNeighbor = false
    elseif (grid[col][tmpRow] ~= nil) then
        vertNeighbor = true
    else 
        vertNeighbor = false
    end
    if (tmpCol < 0) then
        horzNeighbor = false
    elseif (tmpCol > 9) then
        horzNeighbor = false
    elseif (grid[tmpCol][row] ~= nil) then
        horzNeighbor = true
    else 
        horzNeighbor = false
    end
    return not (vertNeighbor or horzNeighbor)
end
    
-- loads all the artwork and sounds
function loadMedia()
    -- load sprite graphics
    sfPlayer = loadImages(Global.PLAYER_IMAGES_TO_LOAD, Global.PLAYER_IMAGE_BASE)
    sfPMissile = loadImages(Global.PMISSILE_IMAGES_TO_LOAD, Global.PMISSILE_IMAGE_BASE)
    sfEMissile = loadImages(Global.EMISSILE_IMAGES_TO_LOAD, Global.EMISSILE_IMAGE_BASE)
    sfBadGuy1 = loadImages(Global.BADGUY1_IMAGES_TO_LOAD, Global.BADGUY1_IMAGE_BASE)
    sfBadGuy2 = loadImages(Global.BADGUY2_IMAGES_TO_LOAD, Global.BADGUY2_IMAGE_BASE)
    sfBadGuy3 = loadImages(Global.BADGUY3_IMAGES_TO_LOAD, Global.BADGUY3_IMAGE_BASE)
    sfBadGuy4 = loadImages(Global.HEADBADGUY_IMAGES_TO_LOAD, Global.HEADBADGUY_IMAGE_BASE)
    sfScore300 = loadImages(Global.SCORE300_IMAGES_TO_LOAD, Global.SCORE300_IMAGE_BASE)
    -- extra life
    extraLife = readImage(asset.extralife0)
    -- level flags
    levelFlags[Global.LEVELFLAG_NORMAL] = readImage(asset .. Global.LEVELFLAG_IMAGE_BASE .. "0")
    levelFlags[Global.LEVELFLAG_WORTH5] = readImage(asset .. Global.LEVELFLAG_IMAGE_BASE .. "1")
end

-- loads a sprite's faces
function loadImages(n, base)
    local sf = {}
    local img
    for i = 0, n, 1 do
        img = readImage(asset .. base .. i)
        table.insert(sf, img)
    end
    return sf
end

-- draw the background things like the level and the number of lives left
function updateBackground()
    local x, y
    -- update the stars
    for i, s in ipairs(stars) do
        local x = s.x
        local y = s.y
        if i%3 == 0 then
            y = y - 2
        else
            y = y - 1
        end
        if y < 0 then
            y = Global.SCREEN_HEIGHT
        end
        fill(math.random(255), math.random(255), math.random(255), 255)
        ellipse(x, y, 2.0 * Global.SCALE)
        
        s.x = x
        s.y = y
    end
    -- extra lives
    x = Global.EXTRALIFE_STARTX
    for  i = 1, displayNumPlayerLives, 1 do
        sprite(extraLife, x, Global.EXTRALIFE_HEIGHT)
        x = x + Global.EXTRALIFE_HORZ_SPACE
    end
    -- level
    local rem = level%5
    local div = level/5
    x = Global.LEVELFLAG_STARTX
    for i = 1, div, 1 do
        sprite(levelFlags[Global.LEVELFLAG_WORTH5], x, Global.LEVELFLAG_HEIGHT)
        x = x - Global.LEVELFLAG_HORZ_SPACE
    end
    for i = 1, rem, 1 do
        sprite(levelFlags[Global.LEVELFLAG_NORMAL], x, Global.LEVELFLAG_HEIGHT)
        x = x - Global.LEVELFLAG_HORZ_SPACE
    end
    -- score, high score
    pushStyle()
    highScoreLoc = (Global.SCREEN_WIDTH - textSize("High Score"))/ 2
    stroke(255, 255, 255)
    fill(255, 255, 255)
    text("Score", 55, Global.SCREEN_HEIGHT - fontHeight)
    text("High Score", highScoreLoc + 35, Global.SCREEN_HEIGHT - fontHeight)
    stroke(255, 0, 0)
    fill(255, 0, 0)
    text(tostring(score), 55, Global.SCREEN_HEIGHT - fontHeight*3) 
    text(tostring(highScore), highScoreLoc + 35, Global.SCREEN_HEIGHT - fontHeight*3)
    popStyle()
    if gameState == Global.GSTATE_GAMEOVER then
        messageBox("GAME OVER")
    elseif gameState == Global.GSTATE_CHANGINGLEVEL2 then
        messageBox("GET READY")
    elseif gameState == Global.GSTATE_PAUSED then
        messageBox("PAUSED...")
    end
end

-- initialize a new game
function initNewGame()
    -- play state
    gameState = Global.GSTATE_PLAYING
    -- clear out all the sprites
    for k in pairs (sprites) do
        sprites[k] = nil
    end
    -- add a player Sprite
    table.insert(sprites, PlayerSprite((Global.SCREEN_WIDTH - Global.PLAYER_WIDTH - Global.PLAYER_XOFFSET)/2, Global.PLAYER_Y, Global.PLAYER_WIDTH, Global.PLAYER_HEIGHT, sfPlayer))
    -- add a missile
    table.insert(sprites, PlayerMissileSprite((Global.SCREEN_WIDTH - Global.PMISSILE_WIDTH) / 2, Global.PLAYER_Y + Global.PMISSILE_YOFFSET, Global.PMISSILE_WIDTH, Global.PMISSILE_HEIGHT, sfPMissile))
    -- missle tweek - bad hack to line up missile
    Global.direction = Global.MOVELEFT
    tween.delay(.05, function()
        Global.direction = Global.NOMOVE
    end)
    -- update the bulletin board variables
    Global.loadAnotherMissile = false
    Global.numBadGuys = 0
    Global.numHeadBadGuys = 0
    -- reset enemy downward and lateral speeds
    maxEnemyDescentSpeed = Global.INITIAL_ENEMY_DESCENT_SPEED
    maxEnemyLateralSpeed = Global.INITIAL_ENEMY_LATERAL_SPEED
    -- reset the max num of attackers at once
    maxEnemiesAttacking = 3
    -- initialize the bad guys
    initBadGuyGrid()
    -- reset our game counter
    gameCount = 0
    gameResume = -1
    -- No one is attacking
    attacking = false
    -- number of lives back to 2
    numPlayerLives = 2 
    displayNumPlayerLives = 2
    -- reset level
    level = 1
    -- zero out score
    score = 0
    -- zero out free guy
    nextFreeGuy = Global.FREE_GUY_INTERVAL
    -- reset difficulty
    attackFrequency = Global.INITIAL_ATTACK_FREQUENCY
    enemyFireFrequency = Global.INITIAL_ENEMY_FIRE_FREQUENCY
    -- play sounds
    sound(asset.startgame)
end

-- Create all the explosion images
function createExImages()
    local img
    local component
    local i 
    component = 255
    for i = 1,  11, 1 do
        img = image(50.0*Global.SCALE, 50.0*Global.SCALE)
        setContext(img)
        fill(component, 0, 0)
        rect(0, 0, 50.0*Global.SCALE, 50.0*Global.SCALE)
        setContext()
        sfEx5[i] = img
        component = component - 25
        if component < 0 then
            component = 0
        end
    end
    component = 255
    for i = 1, 11, 1 do
        img = image(40.0*Global.SCALE, 40.0*Global.SCALE)
        setContext(img)
        fill(0, component, 0)
        rect(0, 0, 40.0*Global.SCALE, 40.0*Global.SCALE)
        setContext()
        sfEx4[i] = img
        component = component - 25
        if component < 0 then
            component = 0
        end
    end
    component = 255
    for i = 1, 11, 1 do
        img = image(29.0*Global.SCALE, 29.0*Global.SCALE)
        setContext(img)
        fill(0, 0, component)
        rect(0, 0, 29.0*Global.SCALE, 29.0*Global.SCALE)
        setContext()
        sfEx3[i] = img
        component = component - 25
        if component < 0 then
            component = 0
        end
    end
    component = 255
    for i = 1, 11, 1 do
        img = image(28.0*Global.SCALE, 28.0*Global.SCALE)
        setContext(img)
        fill(component, 0, component)
        rect(0, 0, 28.0*Global.SCALE, 28.0*Global.SCALE)
        setContext()
        sfEx2[i] = img
        component = component - 25
        if component < 0 then
            component = 0
        end
    end
    component = 255
    for i = 1, 11, 1 do
        img = image(3.0*Global.SCALE, 3.0*Global.SCALE)
        setContext(img)
        fill(component, component, component)
        rect(0, 0, 3.0*Global.SCALE, 3.0*Global.SCALE)
        setContext()
        sfEx1[i] = img
        component = component - 25
        if component < 0 then
            component = 0
        end
    end
end

-- init bad guy grid
function initBadGuyGrid()
    local y = Global.BADGUY_VERT_START
    local x
    for row = 1, 4, 1 do
        x = (Global.SCREEN_WIDTH - (Global.BADGUY_HORZ_SPACE * 10)) / 2;
        for col = 1, 10, 1 do
            s = BadGuySprite(row, col, x, y, Global.BADGUY1_WIDTH, Global.BADGUY1_HEIGHT, sfBadGuy1, Global.BADGUY1_TYPE, maxEnemyDescentSpeed, maxEnemyLateralSpeed)
            table.insert(sprites, s)
            grid[col][row] = s
            x = x + Global.BADGUY_HORZ_SPACE
            Global.numBadGuys = Global.numBadGuys + 1
        end
        y = y + Global.BADGUY_VERT_SPACE
    end
    grid[1][4] = nil
    grid[9][3] = nil
    x = (Global.SCREEN_WIDTH - (Global.BADGUY_HORZ_SPACE *  10))/ 2 + Global.BADGUY_HORZ_SPACE
    for col = 2, 9, 1 do
        s = BadGuySprite(3, col, x, y, Global.BADGUY2_WIDTH, Global.BADGUY2_HEIGHT, sfBadGuy2, Global.BADGUY2_TYPE,
        maxEnemyDescentSpeed, maxEnemyLateralSpeed)
        table.insert(sprites, s)
        grid[col][3] = s
        x = x + Global.BADGUY_HORZ_SPACE
        Global.numBadGuys = Global.numBadGuys + 1
    end
    y = y + Global.BADGUY_VERT_SPACE
    grid[1][4] = nil
    grid[2][4] = nil
    grid[8][4] = nil
    grid[9][4] = nil
    x = (Global.SCREEN_WIDTH - (Global.BADGUY_HORZ_SPACE * 10)) / 2 + (Global.BADGUY_HORZ_SPACE * 2)
    for col = 3, 8, 1 do
        s = BadGuySprite(4, col, x, y, Global.BADGUY3_WIDTH, Global.BADGUY3_HEIGHT, sfBadGuy3, Global.BADGUY3_TYPE,
        maxEnemyDescentSpeed, maxEnemyLateralSpeed)
        table.insert(sprites, s)
        grid[col][4] = s
        x = x + Global.BADGUY_HORZ_SPACE
        Global.numBadGuys = Global.numBadGuys + 1
    end
    y = y + Global.BADGUY_VERT_SPACE
    grid[1][5] = nil
    grid[2][5] = nil
    grid[3][5] = nil
    grid[7][5] = nil
    grid[8][5] = nil
    grid[9][5] = nil
    x = (Global.SCREEN_WIDTH - (Global.BADGUY_HORZ_SPACE * 10)) / 2 + (Global.BADGUY_HORZ_SPACE * 3);
    s = BadGuySprite(5, 4, x, y, Global.HEADBADGUY_WIDTH, Global.HEADBADGUY_HEIGHT, sfBadGuy4, Global.HEADBADGUY_TYPE,
    maxEnemyDescentSpeed, maxEnemyLateralSpeed)
    table.insert(sprites, s)
    grid[3][5] = s
    x = x + Global.BADGUY_HORZ_SPACE * 3
    Global.numBadGuys = Global.numBadGuys + 1
    Global.numHeadBadGuys = Global.numHeadBadGuys + 1
    x = (Global.SCREEN_WIDTH - (Global.BADGUY_HORZ_SPACE * 10)) / 2 + (Global.BADGUY_HORZ_SPACE * 6);
    s = BadGuySprite(5, 7, x, y, Global.HEADBADGUY_WIDTH, Global.HEADBADGUY_HEIGHT, sfBadGuy4, Global.HEADBADGUY_TYPE,
    maxEnemyDescentSpeed, maxEnemyLateralSpeed)
    table.insert(sprites, s)
    grid[6][5] = s
    Global.numBadGuys = Global.numBadGuys + 1
    Global.numHeadBadGuys = Global.numHeadBadGuys + 1
    Global.gridLeftEdge = (Global.SCREEN_WIDTH - (Global.BADGUY_HORZ_SPACE * 10)) / 2
    dxGrid = 1
end

-- message box for game state
function messageBox(s)
    local t, w, h
    -- figure out how wide and high
    w = -1
    h = fontHeight + Global.FONT_LINE_SPACING  
    if (textSize(s) > w) then
        w, h = textSize(s)
    end
    h = h + Global.FONT_LINE_SPACING
    t = (Global.SCREEN_HEIGHT - h) / 2
    pushStyle()
    fill(255, 0, 0)
    y = t + fontHeight + Global.FONT_LINE_SPACING
    text(s, ((Global.SCREEN_WIDTH - textSize(s)) / 2) + 50, y)
    y = y + fontHeight + Global.FONT_LINE_SPACING
    popStyle()
end
 
-- scale elements, needs work   
function scaleScreenElements(scale)
    Global.SCREEN_WIDTH = Global.SCREEN_WIDTH/Global.SCALE*scale
    Global.SCREEN_HEIGHT = Global.SCREEN_HEIGHT/Global.SCALE*scale
    Global.GRID_RIGHT_LIMIT = Global.GRID_RIGHT_LIMIT/Global.SCALE*scale
    Global.FONT_LINE_SPACING = Global.FONT_LINE_SPACING/Global.SCALE*scale
    Global.PLAYER_WIDTH = Global.PLAYER_WIDTH/Global.SCALE*scale
    Global.PLAYER_HEIGHT = Global.PLAYER_HEIGHT/Global.SCALE*scale
    Global.PLAYER_XOFFSET = Global.PLAYER_XOFFSET/Global.SCALE*scale
    Global.PLAYER_X_TWEEK = Global.PLAYER_X_TWEEK/Global.SCALE*scale
    Global.PLAYER_Y = Global.PLAYER_Y/Global.SCALE*scale
    Global.PMISSILE_WIDTH = Global.PMISSILE_WIDTH/Global.SCALE*scale
    Global.PMISSILE_HEIGHT = Global.PMISSILE_HEIGHT/Global.SCALE*scale
    Global.PMISSILE_YOFFSET = Global.PMISSILE_YOFFSET/Global.SCALE*scale
    Global.BADGUY1_WIDTH = Global.BADGUY1_WIDTH/Global.SCALE*scale
    Global.BADGUY1_HEIGHT = Global.BADGUY1_HEIGHT/Global.SCALE*scale
    Global.BADGUY2_WIDTH = Global.BADGUY2_WIDTH/Global.SCALE*scale
    Global.BADGUY2_HEIGHT = Global.BADGUY2_HEIGHT/Global.SCALE*scale
    Global.BADGUY3_WIDTH = Global.BADGUY3_WIDTH/Global.SCALE*scale
    Global.BADGUY3_HEIGHT = Global.BADGUY3_HEIGHT/Global.SCALE*scale
    Global.HEADBADGUY_WIDTH = Global.HEADBADGUY_WIDTH/Global.SCALE*scale
    Global.HEADBADGUY_HEIGHT = Global.HEADBADGUY_HEIGHT/Global.SCALE*scale
    Global.BADGUY_HORZ_SPACE = Global.BADGUY_HORZ_SPACE/Global.SCALE*scale
    Global.BADGUY_VERT_SPACE = Global.BADGUY_VERT_SPACE/Global.SCALE*scale
    Global.BADGUY_VERT_START = Global.BADGUY_VERT_START/Global.SCALE*scale
    Global.EMISSILE_WIDTH = Global.EMISSILE_WIDTH/Global.SCALE*scale
    Global.EMISSILE_HEIGHT = Global.EMISSILE_HEIGHT/Global.SCALE*scale
    Global.EMISSILE_XOFFSET = Global.EMISSILE_XOFFSET/Global.SCALE*scale
    Global.EMISSILE_YOFFSET = Global.EMISSILE_YOFFSET/Global.SCALE*scale
    Global.EXTRALIFE_HEIGHT = Global.EXTRALIFE_HEIGHT/Global.SCALE*scale
    Global.EXTRALIFE_STARTX = Global.EXTRALIFE_STARTX/Global.SCALE*scale
    Global.EXTRALIFE_HORZ_SPACE = Global.EXTRALIFE_HORZ_SPACE/Global.SCALE*scale
    Global.LEVELFLAG_HEIGHT = Global.LEVELFLAG_HEIGHT/Global.SCALE*scale
    Global.LEVELFLAG_STARTX = Global.LEVELFLAG_STARTX/Global.SCALE*scale
    Global.LEVELFLAG_HORZ_SPACE = Global.LEVELFLAG_HORZ_SPACE/Global.SCALE*scale
    Global.INITIAL_ENEMY_DESCENT_SPEED = Global.INITIAL_ENEMY_DESCENT_SPEED/Global.SCALE*scale
    Global.INITIAL_ENEMY_LATERAL_SPEED = Global.INITIAL_ENEMY_LATERAL_SPEED/Global.SCALE*scale
    Global.MAX_ENEMY_DESCENT_SPEED = Global.MAX_ENEMY_DESCENT_SPEED/Global.SCALE*scale
    Global.MAX_ENEMY_LATERAL_SPEED = Global.MAX_ENEMY_LATERAL_SPEED/Global.SCALE*scale
    Global.SCALE = scale
end

-- touch events
function touched(touch)
    if rightBtn:touched(touch) then
        if touch.state == BEGAN then
            Global.direction = Global.MOVERIGHT
        end 
        if touch.state == ENDED then
            if Global.direction == Global.MOVERIGHT then
                Global.direction = Global.NOMOVE
            end
        end
    elseif leftBtn:touched(touch) then
        if touch.state == BEGAN then
            Global.direction = Global.MOVELEFT
        end
        if touch.state == ENDED then
            if Global.direction == Global.MOVELEFT then
                Global.direction = Global.NOMOVE
            end
        end
    elseif fireBtn:touched(touch) then
        if touch.state == BEGAN then
            Global.fire = true
        end
        if touch.state == ENDED then
            Global.fire = false
        end
    else
        if touch.state == BEGAN then
            if touch.y > 300 then
                if gameState == Global.GSTATE_PAUSED then
                    music.stop()
                    gameState = Global.GSTATE_PLAYING
                elseif gameState == Global.GSTATE_PLAYING then
                    gameState = Global.GSTATE_PAUSED
                    music(asset.muzak, true)
                else
                    initNewGame()
                end
            end
        end
    end
end
