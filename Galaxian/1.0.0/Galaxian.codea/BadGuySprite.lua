-----------------
--  Galaxian   --
-----------------

-- Keith Davis --
--  (c) 2021   --
--  ZuniSoft   --

BadGuySprite = class()

function BadGuySprite:init(r, c, x, y, w, h, f, spriteType, maxDescent, maxLateral) 
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.origy = y
    self.locRect = Rectangle(x, y, w, h)
    self.faces = f
    self.currFace = 1
    self.alive = true
    self.type = spriteType
    self.classType = "BadGuySprite"
    self.ATTACK_NOT_ATTACKING = 0
    self.ATTACK_BEGIN = 1
    self.ATTACK_CHASE = 2
    self.ATTACK_DESCEND = 3
    self.ATTACK_HOME = 4
    self.ATTACK_AS_SLAVE = 5
    self.ATTACK_SPIN_SPEED = 10
    self.cnt = 0
    self.dy = 0
    self.dx = 0
    self.attackDirection = 0
    self.facePattern = {}
    self.facePattern[0] = 0
    self.facePattern[1] = 1
    self.facePattern[2] = 0
    self.facePattern[3] = 2
    self.facePatternIdx = c%4
    self.row = r
    self.col = c
    self.attackState = self.ATTACK_NOT_ATTACKING
    self.master = nil
    self.maxDescentSpeed = maxDescent
    self.maxLateralSpeed = maxLateral
    -- when in slave mode, we have a master
    self.master = nil
end

function BadGuySprite:update()
    if self.attackState == self.ATTACK_BEGIN then self:attackBegin()
    elseif self.attackState == self.ATTACK_CHASE then self:attackChase()
    elseif self.attackState == self.ATTACK_DESCEND then self:attackDescend()
    elseif self.attackState == self.ATTACK_HOME then self:attackHome()
    elseif self.attackState == self.ATTACK_AS_SLAVE then self:getMasterState()
    else self:updateNotAttacking() end
end

function BadGuySprite:getCurrFace()
    if self.currFace < 1 or self.currFace > #self.faces then
        return self.faces[1]
    end
    return self.faces[self.currFace]
end

function BadGuySprite:getCurrFaceIdx()
    return self.currFace
end

function BadGuySprite:getMasterState()
    -- if died, we're on our own
    if not self.master.alive or self.locRect.y > Global.SCREEN_HEIGHT then
        self.attackState = self.ATTACK_CHASE
        self.dy = self.maxDescentSpeed
        return
    end
    local masterx = self.master.x
    local mastery = self.master.y
    self.currFace = self.master:getCurrFaceIdx()
    self.locRect.x = masterx
    self.x = self.locRect.x
    if self:getCol() < self.master:getCol() then
        self.locRect.x = self.locRect.x - Global.BADGUY_HORZ_SPACE
        self.x = self.locRect.x
    elseif self:getCol() > self.master:getCol() then
        self.locRect.x = self.locRect.x + Global.BADGUY_HORZ_SPACE
        self.x = self.locRect.x
    end
    self.locRect.y = mastery + Global.BADGUY_HORZ_SPACE
    self.y = self.locRect.y
end

-- this is the "up and over" manuver
function BadGuySprite:attackBegin()
    local deltaFace = self.attackDirection == Global.BADGUY_ATTACK_LEFT and -1 or 1
    local targetFace = self.attackDirection == Global.BADGUY_ATTACK_LEFT and 3 or 18
    self.dx = math.floor(self.attackDirection == Global.BADGUY_ATTACK_LEFT and -2.0 * Global.SCALE or 2.0 * Global.SCALE)
    self.locRect.x = self.locRect.x + self.dx
    self.locRect.y = self.locRect.y - self.dy
    self.x = self.locRect.x
    self.y = self.locRect.y
    self.dy = self.dy + Global.SCALE
    if self.dy > self.maxDescentSpeed then
        self.dy = self.maxDescentSpeed
    end
    if self.cnt%self.ATTACK_SPIN_SPEED == 0 then
        self.currFace = self.currFace + deltaFace
    end
    if self.currFace == targetFace then
        self.attackState = self.ATTACK_CHASE
        self.currFace = 19
    end
    self.cnt = self.cnt + 1
end

-- adjust our lateral speed and angle to try and sweep the player
function BadGuySprite:attackChase()
    local d = self.locRect.x < Global.playerx and 1.0 * Global.SCALE or -1.0 * Global.SCALE
    self.dx = self.dx * d
    if self.cnt%7 == 0 then
        if self.dx > self.maxLateralSpeed then
            self.dx = self.maxLateralSpeed
        elseif self.dx < -self.maxLateralSpeed then
            self.dx = -self.maxLateralSpeed
        end
    end
    if self.dx == 0 then
        self.currFace = 19
    elseif (self.dx > 0) then
        -- 4.0 is the number of available faces
        local faceIdx = math.floor(4.0 * self.dx // self.maxLateralSpeed)
        -- face '18' is the least angled  moving right, '14' is most angled
        self.currFace = 18 - faceIdx
        if self.currFace < 15 then
            self.currFace = 15
        end
    else
        -- 4.0 is the number of available faces
        local faceIdx = math.floor(4.0 * self.dx // self.maxLateralSpeed)
        -- face '3' is the least angled  moving left face, '6' is most angled
        self.currFace = 3 + -faceIdx
        if self.currFace > 6 then
            self.currFace = 6
        end
    end
    self.locRect.x = self.locRect.x + self.dx
    self.locRect.y = self.locRect.y + self.dy
    self.x = self.locRect.x
    self.y = self.locRect.y
    if self.locRect.y > 400.0 * Global.SCALE then
        self.attackState = self.ATTACK_DESCEND
    end
    self.cnt = self.cnt + 1
end

-- made a swoop, now just continue downward
function BadGuySprite:attackDescend()
    self.locRect.x = self.locRect.x + self.dx
    self.locRect.y = self.locRect.y - self.dy
    self.x = self.locRect.x
    self.y = self.locRect.y
    if self.locRect.y < 0 then
        self.locRect.y = self.locRect.h
        self.locRect.x = Global.gridLeftEdge + (Global.BADGUY_HORZ_SPACE * self.col)
        self.x = self.locRect.x
        self.attackState = self.ATTACK_HOME
        self.locRect.y = Global.SCREEN_HEIGHT
        self.y = self.locRect.y
        self.currFace = 19
        self.dy = 2.0 * Global.SCALE
    end
    self.cnt = self.cnt + 1
end

-- return home
function BadGuySprite:attackHome()
    -- bad hack for lining up top level bad guys
    local adj = 0
    if self.type == Global.BADGUY3_TYPE then
        adj = 4
    elseif self.type == Global.HEADBADGUY_TYPE then
        adj = 9
    end
    self.origy = Global.BADGUY_VERT_START + Global.BADGUY_VERT_SPACE - adj + self.locRect.h * self.row
    self.locRect.y = self.locRect.y - self.dy
    self.y = self.locRect.y
    if self.origy - self.locRect.y > 11 then
        self.currFace = self.currFace - 1
        if self.currFace > 11 then
            self.locRect.y = self.origy
            self.facePatternIdx = self.col%4
            self.currFace = self.facePattern[self.facePatternIdx]
            self.attackState = self.ATTACK_NOT_ATTACKING
        end
    end
    self.locRect.x = Global.gridLeftEdge + (Global.BADGUY_HORZ_SPACE * self.col)
    self.cnt = self.cnt + 1   
end

-- not attacking
function BadGuySprite:updateNotAttacking()
    if self.cnt%15 == 0 then
        self.facePatternIdx = self.facePatternIdx + 1
        if self.facePatternIdx > 3 then
            self.facePatternIdx = 0
        end
        self.currFace = self.facePattern[self.facePatternIdx]
    end
    self.cnt = self.cnt + 1
    self.locRect.x = Global.gridLeftEdge + (Global.BADGUY_HORZ_SPACE * self.col) - Global.GRID_RIGHT_LIMIT
    self.x = self.locRect.x
end

-- regular attack mode
function BadGuySprite:attack(direction)
    self.attackState = self.ATTACK_BEGIN
    self.attackDirection = direction
    self.currFace = self.attackDirection == Global.BADGUY_ATTACK_LEFT and 10 or 11
    self.dy = -5.0 * Global.SCALE
end

-- slave attack mode
function BadGuySprite:attackMaster(direction, myMaster)
    self.attackState = self.ATTACK_AS_SLAVE
    self.master = myMaster
    self.attackDirection = direction
    self.currFace = attackDirection == Global.BADGUY_ATTACK_LEFT and 10 or 11
    self.dy = -5.0 * Global.SCALE
end

function BadGuySprite:isAttacking()
    return self.attackState ~= self.ATTACK_NOT_ATTACKING
end

function BadGuySprite:isInChaseMode()
    return self.attackState == self.ATTACK_CHASE
end

function BadGuySprite:isAttackingOrChasing()
    return self:isAttacking() or self:isInChaseMode()
end

function BadGuySprite:getRow()
    return self.row
end

function BadGuySprite:getCol()
    return self.col
end

function BadGuySprite:died()
    Global.numBadGuys = Global.numBadGuys - 1
    if self.type == Global.HEADBADGUY_TYPE then
        Global.numHeadBadGuys = Global.numHeadBadGuys - 1
    end
end

function BadGuySprite:getCollisionRect()
    return self.locRect
end
