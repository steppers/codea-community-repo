--# Timer
Timer = class()

function Timer:init(duration, type, obj)
    self.type = type
    self.obj = obj
    self.done = false
    
    self.start = os.clock()
    self.max = self.start + duration
end

function Timer:update()
    self.start = self.start + DeltaTime
    
    if self.start > self.max then
        self.done = true
    end
end