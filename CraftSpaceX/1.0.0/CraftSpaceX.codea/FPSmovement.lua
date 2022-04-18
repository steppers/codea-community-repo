-- FPSmovement

-- to use: set variable (e.g. cameraFPS) = cameraClass() and use cameraFPS to update actual scene.camera

-- in function draw(s)
--  background(0)
--  cx,cy,cz,ax,ay,az= cameraFPS:updateCameraPos()
--  scene.camera.position = vec3(cx,cy,cz)
--  scene.camera.eulerAngles= vec3(ax,ay,az)
--  scene:draw()
--  cameraFPS:draw()
--  end

-- in function touched(t)
--  cameraFPS:touched(t)
--  end

-- in function sizeChanged()
--  cameraFPS:moveButtonCloser(cameraFPS)
--  end



cameraClass=class()

function cameraClass:init()
    self.angleX,self.angleY,self.angleZ=0,0,0
    self.speed,self.xx,self.yy=0,0,0
    self.x1,self.y1,self.z1=0,0,0
    self.maxDist=.2    -- max speed per draw cycle, change for your needs
    self.cameraX,self.cameraY,self.cameraZ=0,0,0
    
    -- create button array using buttonClass
    self.btnTab={}    
    table.insert(self.btnTab,buttonClass(WIDTH/20,150,"Look Left",
    function() self:setZero() self.xx=-self.maxDist Astronaut.eulerAngles= vec3(0,30,0) end))
    
    table.insert(self.btnTab,buttonClass(WIDTH/20 + 110,150,"Look Right",
    function() self:setZero() self.xx=self.maxDist Astronaut.eulerAngles= vec3(0,-30,0) end)) 
    
    table.insert(self.btnTab,buttonClass(WIDTH/20 + 55,200,"Look Up",
    function() self:setZero() self.yy=-self.maxDist Astronaut.eulerAngles= vec3(-1,0,0) end))  
    
    table.insert(self.btnTab,buttonClass(WIDTH/20 + 55,100,"Look Down",
    function() self:setZero() self.yy=self.maxDist Astronaut.eulerAngles= vec3(10,0,0) end))
    
    table.insert(self.btnTab,buttonClass(WIDTH - (WIDTH/20 + 80),175,"Forward",
    function() 
        self:setZero() 
        abx=math.abs(self.angleX)%360
        if abx>=0 and abx<=90 or abx>=270 and abx<=360 then
            self.speed=.1
        else
            self.speed=-.1
        end 
    end))
    
    table.insert(self.btnTab,buttonClass(WIDTH - (WIDTH/20 + 80),125,"Backward",
    function() 
        self:setZero() 
        abx=math.abs(self.angleX)%360
        if abx>=0 and abx<=90 or abx>=270 and abx<=360 then
            self.speed=-.1
        else
            self.speed=.1
        end 
    end))
    
    table.insert(self.btnTab,buttonClass(WIDTH - (WIDTH/20 + 80),225,"Move Up",
    function() self:setZero() self.y1=self.maxDist end)) 
    
    table.insert(self.btnTab,buttonClass(WIDTH - (WIDTH/20 + 80),75,"Move Down",
    function() self:setZero() self.y1=-self.maxDist end))
    
    table.insert(self.btnTab,buttonClass(WIDTH - (WIDTH/20 + 170),150,"Move Left",
    function() self:setZero() self.x1=self.maxDist end))
    
    table.insert(self.btnTab,buttonClass(WIDTH - (WIDTH/20 + -10),150,"Move Right",
    function() self:setZero() self.x1=-self.maxDist end))
    
    -- optional additional rotation buttons below:
    
    --    table.insert(self.btnTab,buttonClass(WIDTH/2-100,50,"Rotate Left",
    --    function() self:setZero() self.z1=self.maxDist end)) 
    
    --    table.insert(self.btnTab,buttonClass(WIDTH/2+100,50,"Rotate Right",
    --    function() self:setZero() self.z1=-self.maxDist end)) 
end

function cameraClass:moveButtonCloser(btn)
    -- update buttons on screen when screen orientation changes (button 5/6/7/8 forwrd/bckwrd/moveup/movedwn, 9/10 moveL/R)
    btn.btnTab[5].x = (WIDTH - (WIDTH/20 + 80))
    btn.btnTab[6].x = (WIDTH - (WIDTH/20 + 80))
    btn.btnTab[7].x = (WIDTH - (WIDTH/20 + 80))
    btn.btnTab[8].x = (WIDTH - (WIDTH/20 + 80)) 
    btn.btnTab[9].x = (WIDTH - (WIDTH/20 + 170))
    btn.btnTab[10].x = (WIDTH - (WIDTH/20 + -10))
    draw()
end

function cameraClass:draw()
    pushStyle()
    for a,b in pairs(self.btnTab) do
        b:draw()
    end
end

function cameraClass:touched(t)
    for a,b in pairs(self.btnTab) do
        touchEnded=b:touched(t)
    end
    if touchEnded then
        self:setZero()
    end
end

function cameraClass:setZero()
    self.xx,self.yy,self.zz,self.speed=0,0,0,0
    self.x1,self.y1,self.z1=0,0,0
end

function cameraClass:updateCameraPos()
    -- angleX=angle up/down,        yy=+- look up/down
    self.angleX=self.angleX+self.yy
    
    -- angleY=angle left/right,     xx=+- look left/right
    self.angleY=self.angleY-self.xx
    
    -- angleZ=rotate left/right
    self.angleZ=self.angleZ+self.z1
    
    -- calc distance
    x=self.speed*math.sin(math.rad(self.angleY))
    y=-self.speed*math.tan(math.rad(self.angleX))
    z=self.speed*math.cos(math.rad(self.angleY))
    
    -- move the same distance per draw cycle irregardless of direction
    if x~=0 or y~=0 or z~=0 then
        local dist=1/math.sqrt(x^2+y^2+z^2)
        x=x*dist*self.maxDist
        y=y*dist*self.maxDist
        z=z*dist*self.maxDist
    end    
    
    -- before actually move check to see if there is an obstruction
    checkObstruction()
    if obstruction then return self.cameraX,self.cameraY,self.cameraZ,self.angleX,self.angleY,self.angleZ else
        -- camera move forward/backward, look left/right, look up/down
        self.cameraX=self.cameraX+x
        self.cameraY=self.cameraY+y
        self.cameraZ=self.cameraZ+z 
        
        -- camera move up/down
        self.cameraY=self.cameraY+self.y1
        
        -- camera move left/right
        self.cameraX=self.cameraX+math.cos(math.rad(self.angleY))*self.x1
        self.cameraZ=self.cameraZ-math.sin(math.rad(self.angleY))*self.x1   
        return self.cameraX,self.cameraY,self.cameraZ,self.angleX,self.angleY,self.angleZ
    end
end

-- create buttons
buttonClass=class()

function buttonClass:init(x,y,n,a)
    self.x=x
    self.y=y
    self.name=n  
    self.action=a  
end

function buttonClass:draw()
    pushStyle()
    rectMode(CENTER)
    fill(255)
    rect(self.x,self.y,90,40)
    fill(0)
    text(self.name,self.x,self.y)
    popStyle()
end

function buttonClass:touched(t)
    if t.state==BEGAN or t.state==CHANGED then
        if t.x>self.x-45 and t.x<self.x+45 and t.y>self.y-20 and t.y<self.y+20 then 
            self.action()            
        end 
    end 
    if t.state==ENDED then
        Astronaut.eulerAngles = vec3(0,0,0)
        return true
    end
end