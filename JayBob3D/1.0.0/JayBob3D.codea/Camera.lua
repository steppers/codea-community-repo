--
--

--# Camera

Camera = class()

function Camera:init(eX,eY,eZ,lX,lY,lZ,uX,uY,uZ)
    self.eye = vec3(eX or 0, eY or 0, eZ or 400)
    self.lat = vec3(lX or 0, lY or 0, lZ or 0)
    self.upV = vec3(uX or 0, uY or 1, uZ or 0)
    self.dist = self.lat:dist(self.eye)
    self.angH = 90
    self.angV = -90
    self.fix = false
    self.crosshair = false
end

function Camera:draw()
    if self.fix then
        self.eye = -self:rotatePoint() + self.lat
    else
        self.lat =  self:rotatePoint() + self.eye
    end
    camera(
    self.eye.x, self.eye.y, self.eye.z,
    self.lat.x, self.lat.y, self.lat.z,
    self.upV.x, self.upV.y, self.upV.z)
    if self.crosshair then self:drawCrosshair(50) end
end

function Camera:movement(z,x)
    if z and z ~= 0 then
        local zVel = (self.lat-self.eye):normalize() * z
        self.eye = self.eye + zVel
        self.lat = self.lat + zVel
    end
    if x and x ~= 0 then
        local xVel = (self.lat-self.eye):cross(vec3(0,1,0)):normalize() * x
        self.eye = self.eye + xVel
        self.lat = self.lat + xVel
    end
end

function Camera:rotatePoint()
    -- calculate y and z from angV at set distance
    local y = math.cos(math.rad(self.angV))*self.dist
    local O = math.sin(math.rad(self.angV))*self.dist
    -- calculate x and z from angH using O as the set distance
    local x = math.cos(math.rad(self.angH))*O
    local z = math.sin(math.rad(self.angH))*O
    return vec3(x,y,z)
end

function Camera:updateAngles()
    self.angH = math.deg(math.atan2(self.lat.z-self.eye.z,self.lat.x-self.eye.x))+180
    self.angV = -math.deg(math.acos((self.lat.y-self.eye.y)/self.dist))
end

function Camera:lookAt(target)
    self.dist = self.eye:dist(target)
    self.lat = target
    self:updateAngles()
end

function Camera:drawCrosshair(w)
    pushMatrix()pushStyle()
    translate(self.lat.x,self.lat.y, self.lat.z)
    strokeWidth(2)
    line(-w/2,0,w/2,0)
    line(0,-w/2,0,w/2) rotate(90,1,0,0)
    line(0,-w/2,0,w/2)
    popMatrix()popStyle()
end