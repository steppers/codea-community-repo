Timer = class(timeInterval)

function Timer:init(timeInterval)
    self.timerStart = -timeInterval
    self.interval = timeInterval
end

function Timer:start()
    self.timerStart = ElapsedTime
end

function Timer:complete()
    self.count = ElapsedTime-self.timerStart
    if self.count > self.interval then
        return true
    else
        return false
    end
end