-- This Tween 'mod' modifies the local finishTween
-- function from the tween source to stop the tween
-- before executing the callback.
--
-- This allows the restart of a tween from inside the callback
-- and avoids having to recreate one after every callback
-- which led to excess memory consumption.





-- tween.update uses finishTween as an upvalue so this is
-- our way in.
local nups = debug.getinfo(tween.update, "u").nups

-- Find the finishTween upvalue
local finishTweenOrig = nil
local upvalueIndexToOverride = nil
for i=1,nups do
    local name, val = debug.getupvalue(tween.update, i)
    if name == "finishTween" then
        upvalueIndexToOverride = i
        finishTweenOrig = val
        break
    end
end

-- Get all of the upvalues from the original function
local upvalues = {}
for i=1,debug.getinfo(finishTweenOrig, "u").nups do
    local name, val = debug.getupvalue(finishTweenOrig, i)
    upvalues[name] = val
end

-- Get all the upvalues we need to override the function
local easeWithTween = assert(upvalues["easeWithTween"])
local copyTable = assert(upvalues["copyTables"])
local tweens = assert(upvalues["tweens"])

-- Define our override
-- This will use the same upvalues as the original
local function finishTweenNew(self)
    self.overshoot = self.running - self.time
    self.running = self.time
    easeWithTween(self, self.subject, self.target, self.initial)
    
    -- Stop BEFORE we execute the callback
    tween.stop(self)
    
    if self.callback then self.callback(table.unpack(self.args)) end

    if self.next then
        self.next.initial = copyTables(self.next.initial, self.target, self.subject)
        tweens[self.next] = self.next
    end
end

debug.setupvalue(tween.update, upvalueIndexToOverride, finishTweenNew)

-- Executes a function every 'period' seconds
-- 
-- Period is not accurate & is bound to frame
-- rate. The callback will be called a maximum
-- of once per frame.
--
-- If for instance your period is equivalent
-- to 1.5x framerate, when the period elapses
-- mid-frame the callback will not be executed
-- until the following frame.
function tween.interval(period, callback)
    local loop = tween.delay(period)
    loop.callback = function()
        
        -- Call the interval callback
        callback()
        
        -- Execute as accurately as we can
        -- so account for any overshoot of timing
        -- in the current invocation
        loop.time = math.max(0.0000001, period - loop.overshoot)
            
        -- Restart our tween
        tween.reset(loop)
        tween.play(loop)
    end
end

-- Original Function
--[[
local function finishTween(self)
    self.running = self.time
    easeWithTween(self, self.subject, self.target, self.initial)
    if self.callback then self.callback(table.unpack(self.args)) end

    tween.stop(self)

    if self.next then
        self.next.initial = copyTables(self.next.initial, self.target, self.subject)
        tweens[self.next] = self.next
    end
end
]]