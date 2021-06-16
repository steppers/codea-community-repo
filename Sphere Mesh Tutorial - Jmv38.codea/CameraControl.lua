CameraControl = class()

function CameraControl:init()
    -- this is for touch control
    self.touches = {}
    self.x0 = 0
    self.y0 = 0
    self.d0 = 100
    -- this is the camera position
    self.camX, self.camY, self.camZ = 0, 200, 500
    -- this is the point the camera is looking to
    self.tx ,self.ty ,self.tz  = 0,0,0
    -- vertical axis of the camera
    self.vx, self.vy, self.vz = 0,1,0
    -- distance limit from 0,0,0
    self.maxDist = 1000
    -- apply these settings
    self:setCam()
end

function CameraControl:touched(touch)
    if touch.state == ENDED then
        self.touches[touch.id] = nil
    else
        self.touches[touch.id] = touch
    end
    local n = 0
    for i,v in pairs(self.touches) do n = n + 1 end
    -- if exactly one touch then move
    if n==1 then self:move(touch) end
    -- if exactly 2 touches then zoom
    if n==2 then self:zoom() end
end

function CameraControl:zoom()
    local t = {}
    local n = 1
    for i,touch in pairs(self.touches) do
        t[n] = touch
        n = n + 1
    end
    local x1,y1,x2,y2,delta,d1
    if t[1].state == BEGAN or t[2].state == BEGAN then
        -- memorize the starting point of the touch
        x1,y1,x2,y2 = t[1].x, t[1].y, t[2].x, t[2].y
        delta = vec2(x2-x1,y2-y1):len() +100
        self.d0 = delta
    elseif t[1].state == MOVING or t[2].state == MOVING then
        x1,y1,x2,y2 = t[1].x, t[1].y, t[2].x, t[2].y
        delta = vec2(x2-x1,y2-y1):len() +100
        -- to prvent the camera to go too far
        if self.d0/delta > 1 then 
            if vec3(self.camX,self.camY,self.camZ):len()>self.maxDist then delta = self.d0 end
        end
        self.camX = self.d0/delta * self.camX
        self.camY = self.d0/delta * self.camY
        self.camZ = self.d0/delta * self.camZ        
        self.d0 = delta
        --print(self.camZ)
    end
end

function CameraControl:move(touch)
    local dx,dy,x,y,z,l0,l1
    local theta,phi,m,xphi,yphi,zphi,phiAxis,cosAngle
    local state = touch.state
    if state == BEGAN then
        -- memorize the starting point of the touch
        self.x0 = touch.x
        self.y0 = touch.y
    elseif state == MOVING then
        -- now the finger has move of how much?
        dx = touch.x - self.x0
        dy = touch.y - self.y0
        -- convert this into angles
        -- get camera position to the center...
        x,y,z = self.camX,self.camY,self.camZ
        local pos = vec3(x,y,z)
        l0 = pos:len()    -- ... to compute the distance to center
        pos = pos / l0
        -- convert this into angles (approx: angle ~tg(angle))
        local s = 180/math.pi -- coef to covert radians into degrees
        theta = dx/l0*s -- the angle around the y axis
        phi =  -dy/l0*s -- the angle around the horizontal axis
        -- the transparency seems to work based on z-axis only: so theta should be limited
        cosAngle = vec3(0,0,1):dot(pos)
        -- there is a pb when close y axis, so lock the phi to avoid this case
        cosAngle = vec3(0,1,0):dot(pos)
        if cosAngle > 0.95 and phi > 0 then phi=0 end
        if cosAngle < -0.95 and phi < 0 then phi=0 end
        -- the phis axis depends on the orientation but is easy to compute with cross product
        phiAxis = vec3(0,1,0):cross(pos)
        -- now, finally, let's compute the new camera position
        m = matrix( x,0,0,0, y,0,0,0, z,0,0,0, 0,0,0,0)
        m = m:rotate(theta,0,1,0)
        m = m:rotate(phi,phiAxis[1],phiAxis[2],phiAxis[3])
        x , y , z = m[1], m[5], m[9]
        -- save this new position of the camera
        self.camX,self.camY,self.camZ = x,y,z
        -- use this point as the start point for next move
        self.x0 = touch.x
        self.y0 = touch.y
    elseif state == ENDED then
    end
end

function CameraControl:setCam()
    camera( self.camX,self.camY,self.camZ, 
            self.tx ,self.ty ,self.tz,
            self.vx, self.vy, self.vz )
end


