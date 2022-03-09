-- Contents:
--    TweenInterval.lua
--    STLib.lua
--    Threads.lua
--    Util.lua

------------------------------
-- TweenInterval.lua
------------------------------
do
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
    self.running = self.overshoot
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
        callback(loop)
        
        -- Did the callback call stop?
        if loop.forceStop then
            return
        end
        
        -- Execute as accurately as we can
        -- so account for any overshoot of timing
        -- in the current invocation
        loop.time = math.max(0, period - loop.overshoot)
            
        -- Restart our tween
        tween.reset(loop)
        tween.play(loop)
    end
    
    function loop:stop()
        tween.stop(self)
        self.forceStop = true
    end
    
    return loop
end
end
------------------------------
-- STLib.lua
------------------------------
do
ST = {
    VERSION = "1.0.0"
}
end
------------------------------
-- Threads.lua
------------------------------
do
-- Locals
local cyield = coroutine.yield
local threads = {}
local currentThread = nil

-- Executes a function once every frame with no user setup
local function backgroundTask(func)
    local t = tween.interval(0.00001, func)
    t.time = 0
    return t
end

-- Background task to resume each thread
local sbFlushImage = image(1,1)
backgroundTask(function()
    local deadThreads = {}
    
    for i,thread in ipairs(threads) do
        -- Is the coroutine dead?
        if coroutine.status(thread.co) == "dead" then
            table.insert(deadThreads, i)
        
        -- Ignore this thread if it's sleeping
        elseif thread.sleep and os.clock() < thread.sleep then
        else
            
            -- Track the current thread
            currentThread = thread
            
            while true do
                local res = table.pack(coroutine.resume(thread.co))
                if not res[1] then
                    -- Propagate the error
                    error(res[2])
                elseif res[2] then
                    -- Call the value returned from the resume
                    -- and resume again.
                    -- This is how a thread forces something to
                    -- run on the main thread.
                    currentThread = nil
                    res[2](select(3, table.unpack(res)))
                    currentThread = thread
                else
                    -- Pause execution
                    break
                end
            end
            
            currentThread = nil
        end
    end
    
    for _,ti in ipairs(deadThreads) do
        table.remove(threads, ti)
    end
    
    -- Render an offscreen sprite to flush the
    -- spritebatcher.
    -- This ensures sprite rendering done on
    -- threads is actually visible on screen.
    -- A wild guess is that the batcher is only
    -- flushed after the draw() call, and not
    -- after tween handling.
    spriteMode(CORNER)
    sprite(sbFlushImage, -1, -1)
end)

-- Thread
ST.Thread = class()
local Thread = ST.Thread

function Thread:init(func)
    self.co = coroutine.create(func)
    table.insert(threads, self)
end

function Thread:resume()
    if coroutine.status(self.co) == "dead" then
        task:stop()
        return
    end
    local success, err = coroutine.resume(self.co)
    if not success then
        error(err) -- Propagate the error
    end
end

-- Semaphore
ST.Semaphore = class()
local Semaphore = ST.Semaphore

function Semaphore:init()
    self.value = 0
    self.waiting = 0
end

function Semaphore:wait()
    self.waiting = self.waiting + 1
    while self.value == 0 do
        cyield()
    end
    self.waiting = self.waiting - 1
    self.value = self.value - 1
end

function Semaphore:signal()
    self.value = self.value + 1
end

function Semaphore:signalAll()
    self.value = self.value + self.waiting
end

-- Promise
ST.Promise = class()
local Promise = ST.Promise

function Promise:init()
    self.sem = Semaphore()
    self.fulfilled = false
end

function Promise:resolve(...)
    assert(not self.fulfilled, "Promise already resolved!")
    self.fulfilled = true
    self.val = table.pack(...)
    self.sem:signalAll()
end

function Promise:get()
    if not self.fulfilled then
        self.sem:wait()
    end
    return table.unpack(self.val)
end

function Promise:consume()
    if not self.fulfilled then
        self.sem:wait()
    end
    local v = self.val
    self:reset()
    return table.unpack(v)
end

function Promise:reset()
    self.fulfilled = false
    self.val = nil
end


-- Global funcs ------------------------------------------
function ST.yield()
    cyield()
end
ST.swapBuffers = ST.yield

-- This returns execution to the main lua 'thread' before
-- calling the provided function. Very useful when a callback
-- API does not work correctly from within a coroutine.
function ST.runMain(func, ...)
    if func == nil then
        return -- do nothing
    end
    cyield(func, ...)
end

-- Suspends the thread for a period of time
function ST.sleep(duration)
    currentThread.sleep = os.clock() + duration
    ST.yield()
    currentThread.sleep = nil
end

function ST.loop(func)
    while func() == nil do
        ST.yield()
    end
end

function ST.hang()
    objc.warning("aborting.")
    threads = {}
    ST.yield()
end
ST.abort = ST.hang

function ST.IsSThread()
    return currentThread ~= nil
end



-- If you're using the 'SThreads' library then
-- we probably shouldn't allow manual yielding directly
-- to avoid confusing the background tasks that handle
-- thread updates.
coroutine.yield = nil

-- Initialise the main user thread that calls the 'main()'
-- function.
Thread(function()
    if type(main) ~= "function" then
        objc.warning("[SThreads] main() function is undefined!")
    else
        main()
    end
end)

end
------------------------------
-- Util.lua
------------------------------
do

local terminators = {}

function ST.registerTerminator(func)
    table.insert(terminators, func)
end

function willClose()
    for _,term in ipairs(terminators) do
        term()
    end
end

end
