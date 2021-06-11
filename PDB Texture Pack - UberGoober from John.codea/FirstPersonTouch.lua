FirstPersonTouch = class()

FirstPersonTouch.NONE = 1
FirstPersonTouch.BEGAN = 2
FirstPersonTouch.DRAGGING = 3
FirstPersonTouch.LONG_PRESS = 4

function FirstPersonTouch:init(entity, longPressDuration, dragThreshold, callbacks)
    self.longPressDuration = longPressDuration or 1.0
    self.dragThreshold = dragThreshold or 5
    self.state = FirstPersonTouch.NONE
    self.callbacks = callbacks or {}
    touches.addHandler(self, -1, false)
end

function FirstPersonTouch:longPressProgress()
    if self.state == FirstPersonTouch.BEGAN then
        return (ElapsedTime - self.startTime) / self.longPressDuration
    elseif self.state == FirstPersonTouch.LONG_PRESS then
        return 1.0
    end
    return 0
end

function FirstPersonTouch:update()
    if self.state == FirstPersonTouch.BEGAN then
        if ElapsedTime - self.startTime >= self.longPressDuration then
            self.state = FirstPersonTouch.LONG_PRESS
            touches.share(self, self.lastTouch, 0)
            if self.callbacks.longPressed then self.callbacks.longPressed(self.lastTouch) end
        end
    end
    
    if self.state == FirstPersonTouch.LONG_PRESS then
        if self.callbacks.longPressing then self.callbacks.longPressing(self.lastTouch) end
    end
    
    if self.state == FirstPersonTouch.DRAGGING then
        if self.callbacks.dragging then self.callbacks.dragging(self.lastTouch) end
    end
end

function FirstPersonTouch:touched(touch)
    self.lastTouch = touch    
    
    if self.state == FirstPersonTouch.NONE then
        if touch.state == BEGAN then
            self.startPos = vec2(touch.x, touch.y)
            self.startTime = ElapsedTime
            self.state = FirstPersonTouch.BEGAN
            if self.callbacks.began then self.callbacks.began(touch) end
            return true
        end
    end
    
    if self.state == FirstPersonTouch.BEGAN then
        if touch.state == MOVING then
            self.endPos = vec2(touch.x, touch.y)
            if self.startPos:dist(self.endPos) >= self.dragThreshold then
                self.state = FirstPersonTouch.DRAGGING
                touches.share(self, touch, 0)
            end
        end
    end
    
    if self.state ~= FirstPersonTouch.NONE then
        if touch.state == ENDED or touch.state == CANCELLED then
            if self.state == FirstPersonTouch.BEGAN then
                if self.callbacks.tapped then self.callbacks.tapped(touch) end
            end
            if self.callbacks.ended then self.callbacks.ended(touch) end
            self.state = FirstPersonTouch.NONE
        end
    end
    
end
