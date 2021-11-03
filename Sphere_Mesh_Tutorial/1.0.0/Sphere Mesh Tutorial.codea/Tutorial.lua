Tutorial = class()

function Tutorial:init()
    -- these var are to keep track of various animations
    self.step = 0
    self.stepMax = 11
    self.ready = false
    
    -- buttons 'next and 'prev'
    fill(0, 0, 0, 255)
    fontSize(28)
    font("AmericanTypewriter-Bold")
    
    self.nextButton = image(90,50)    
    setContext(self.nextButton)
        background(COLOR)
        text("next",45,25)
    setContext()
    
    fontSize(27)
    font("AmericanTypewriter-Bold")
    self.prevButton = image(90,50)
    setContext(self.prevButton)
        background(COLOR)
        text("prev",45,25)
    setContext()
    
    self.lines = 0
    self.line = {}
end

function Tutorial:print(str)
    self.lines = self.lines + 1
    self.line[ self.lines ] = str
end

function Tutorial:clearPrint()
    self.lines = 0
end

function Tutorial:step0()
    if self.ready == false then
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 0  ###########")
        self:print("")
        self:print("This is a 'hands-on' tutorial about drawing spheres")
        self:print("On top left you can see the refreshing frequency (<60 frames per second)")
        self:print("to go to next example press 'next', to go back press 'prev'")
        self.ready = true
    else end
end

function Tutorial:step1()
    if self.ready == false then
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 1  ###########")
        self:print("")
        self:print("First you can start by drawing a flat mesh of triangles")

        local color1 = color(255, 0, 0, 128)
        local color2 = color(255, 255, 0, 128)
        planet1 = Sphere({  nx = 40, ny = 20   ,  -- mesh definition
                    c1 = color1 , c2 = color2 ,   -- mesh colors
                    cx=0, cy=-20, cz=0           -- sphere center    
                  })
        self.ready = true
        --     change camera position
        cam.camX, cam.camY, cam.camZ = 0, 0, 300
    else planet1:draw() end
end

function Tutorial:step2()
    if self.ready == false then
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 2  ###########")
        self:print("")
        self:print("Then you can warp the vertices of this mesh to a sphere shape")
self:print("The triangles are partly transparent because the colors of the vectors were set that way")
        self:print("you can rotate (1 finger) and zoom (2 fingers) the object")
        local color1 = color(255, 0, 0, 128)
        local color2 = color(255, 255, 0, 128)
        planet1 = Sphere({  
                    nx = 40, ny = 20 ,            -- mesh definition
                    c1 = color1 , c2 = color2 ,   -- mesh colors
                    cx=0, cy=-50, cz=0,          -- sphere center    
                    r = 100               -- radius of the sphere                   
                  })
        --     change camera position
        cam.camX, cam.camY, cam.camZ = 0, 200, 300
        self.ready = true
    else planet1:draw() end
end

function Tutorial:step3()
    if self.ready == false then
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 3  ###########")
        self:print("")
        self:print("you can make the sphere opaque by setting the color opaque")
        self:print("and you can make it rotate around its axis")
        self:print("the frame rate is still excellent: close to 60 fps")
        self:print("the next screen will take several seconds to appear... be patient!")
        local color1 = color(255, 0, 0, 255)
        local color2 = color(255, 255, 0, 255)
        planet1 = Sphere({  
                    nx = 40, ny = 20 ,    -- mesh definition
                    c1 = color1 , c2 = color2 ,   -- mesh colors
                    cx=0, cy=-50, cz=0,          -- sphere center    
                    r = 100    ,           -- radius of the sphere
                    rotTime1 = 10    -- rotation time in s
                  })
        self.ready = true
    else planet1:draw() end
end

function Tutorial:step4()
    if self.ready == false then
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 4  ###########")
        self:print("")
        self:print("we can multiply the number of vertices from 4800 (40x20x6) up to 43200 (120x60x6)")
        self:print("the setup time is long, but the fps still excellent")
        self:print("You can notice that the triangle sizes are not optimized for a sphere: ")
        self:print("the top ones are really too small compared to middle ones")
        local color1 = color(255, 0, 0, 255)
        local color2 = color(255, 255, 0, 255)
        planet1 = Sphere({  
                    nx = 120, ny = 60 ,    -- mesh definition
                    c1 = color1 , c2 = color2 ,   -- mesh colors
                    cx=0, cy=-50, cz=0,          -- sphere center    
                    r = 100    ,           -- radius of the sphere
                    rotTime1 = 10 ,   -- rotation time in s
                  })
        self.ready = true
    else planet1:draw() end
end

function Tutorial:step5()
    if self.ready == false then
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 5  ###########")
        self:print("")
        self:print("Here the triangles have been optimized to be approximately equal size")
        self:print("The difficulty is to find which vectors to assemble in triangles, but it is solved now...")
        local color1 = color(255, 0, 0, 255)
        local color2 = color(255, 255, 0, 255)
        planet1 = Sphere({  
                    nx = 40, ny = 20 ,            -- mesh definition
                    meshOptimize = true,           -- optimize mesh for sphere
                    c1 = color1 , c2 = color2 ,    -- mesh colors
                    cx=0, cy=-50, cz=0  ,         -- sphere center    
                    r = 100      ,         -- radius of the sphere
                    rotTime1 = 10 ,   -- rotation time in s
                  })
        self.ready = true
        --     change camera position
        -- cam.camX, cam.camY, cam.camZ = 0, 0, 300
    else planet1:draw() end
end

function Tutorial:step6()
    if self.ready == false then
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 6  ###########")
        self:print("")
        self:print("But it means that when back on a flat surface, the triangles are not equal.")
        local color1 = color(255, 0, 0, 255)
        local color2 = color(255, 255, 0, 255)
        planet1 = Sphere({  
                    nx = 40, ny = 20 ,            -- mesh definition
                    meshOptimize = true,           -- optimize mesh for sphere
                    c1 = color1 , c2 = color2 ,    -- mesh colors
                    cx=0, cy=-25, cz=0  ,         -- sphere center    
                  })
        self.ready = true
        --     change camera position
        cam.camX, cam.camY, cam.camZ = 0, 0, 300
    else planet1:draw() end
end

function Tutorial:step7()
    if self.ready == false then
        url1 = 'http://www.evl.uic.edu/pape/data/Earth/2048/PathfinderMap.jpg'
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 7  ###########")
        self:print("")
        self:print("we may want to draw an image on the sphere instead of just colors")
        self:print("all we need is to load an image, and 1/ define it as the 'texture' to use with the mesh ")
        self:print("and 2/ define where each vector lays on this image (in [0-1] relative coordinates)")
        self:print("The image used here is from "..url1)
        self:print("(it will take several seconds to load)The image should not be too big for ipad limits (2048x2048 max)")
        self:print("the image is right-left inverted, this is to be correct on the sphere, I dont know the reason")
        local color1 = color(255, 255, 255, 255)
        local color2 = color(127, 127, 127, 255)
        planet1 = Sphere({  
                    nx = 40, ny = 20 ,            -- mesh definition
                    meshOptimize = true,           -- optimize mesh for sphere
                    c1 = color1 , c2 = color2 ,    -- mesh colors
                    cx=0, cy=-25, cz=0  ,         -- sphere center    
                    url = url1,        -- texture image url
                    hflip = true,    -- to flip image horozontally
                  })
        self.ready = true
        --     change camera position
        cam.camX, cam.camY, cam.camZ = 0, 0, 300
    else planet1:draw() end
end

function Tutorial:step8()
    if self.ready == false then
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 8  ###########")
        self:print("")
        self:print("To turn this map into a planet, we must:")
        self:print("1/ set the mesh vertice colors to: color(255, 255, 255, 255)")
        self:print("2/ warp the vertices to a sphere")
        self:print("you can zoom to see the detail (this is done very simply via the 'camera' settings of CODEA)")
        self:print("This is a nice earth, but there is not the shadow of the sun...")

        local color1 = color(255, 255, 255, 255)
        planet1 = Sphere({  
                    nx = 40, ny = 20 ,            -- mesh definition
                    meshOptimize = true,           -- optimize mesh for sphere
                    c1 = color1 , c2 = color1 ,    -- mesh colors
                    cx=0, cy=-50, cz=0  ,         -- sphere center    
                    r = 100      ,         -- radius of the sphere
                    rotTime1 = 30 ,   -- rotation time in s
                    url = url1,        -- texture image url
                    hflip = true,    -- to flip image horozontally
                  })
        self.ready = true
        --     change camera position
        cam.camX, cam.camY, cam.camZ = 0, 200, 300
    else planet1:draw() end
end

function Tutorial:step9()
        url1 = 'http://www.evl.uic.edu/pape/data/Earth/2048/PathfinderMap.jpg'
    if self.ready == false then
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 9  ###########")
        self:print("")
        self:print("To add the sun, we simply add shadows on the planet. But the shadows should not turn.")
        self:print("So we will built a 2nd sphere, black and transparent as it is oriented to the light source")
        self:print("This sphere has a larger radius than the planet, to be adjusted to avoid rendering problems")
        self:print("To have a smoother shadow, i have increased the number of tirangles by 4 => I lose a little bit in fps")
        local color1 = color(255, 255, 255, 255)
        planet1 = Sphere({  
            nx = 80, ny = 40 ,            -- mesh definition
            meshOptimize = true,           -- optimize mesh for sphere
            c1 = color1 , c2 = color1 ,    -- mesh colors
            cx=0, cy=-50, cz=0  ,         -- sphere center    
            r = 100      ,         -- radius of the sphere
            rotTime1 = 30 ,   -- rotation time in s
            url = url1,        -- texture image url
            hflip = true,    -- to flip image horozontally
            lightDir = vec3(1,0,0),   -- a vec3 pointing to the sun
            shadowRatio = 1.05,    -- the ratio of radius of shadow sphere to sphere
        })
        self.ready = true
        --     change camera position
        cam.camX, cam.camY, cam.camZ = 200, 100, 300
    else planet1:draw() end
end

function Tutorial:step10()
    url1 = 'http://www.evl.uic.edu/pape/data/Earth/2048/PathfinderMap.jpg'
    url2 = "http://web.cortland.edu/flteach/civ/davidweb/images/moonb.jpg"
    if self.ready == false then
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 10  ###########")
        self:print("")
        self:print("Finally here is a moon to turn around our earth (too fast and too close...)")

        local color1 = color(255, 255, 255, 255)
        planet1 = Sphere({  
            nx = 80, ny = 40 ,            -- mesh definition
            meshOptimize = true,           -- optimize mesh for sphere
            c1 = color1 , c2 = color1 ,    -- mesh colors
            cx=0, cy=-50, cz=0  ,         -- sphere center    
            r = 100      ,         -- radius of the sphere
            rotTime1 = 30 ,   -- rotation time in s
            url = url1,        -- texture image url
            hflip = true,    -- to flip image horozontally
            lightDir = vec3(1,0,0),   -- a vec3 pointing to the sun
            shadowRatio = 1.02,    -- the ratio of radius of shadow sphere to sphere
        })
        local color2 = color(223, 211, 138, 255)
        moon1 = Sphere({  
            nx = 60, ny = 30 ,            -- mesh definition
            meshOptimize = true,           -- optimize mesh for sphere
            c1 = color2 , c2 = color2 ,    -- mesh colors
            cx=150, cy=0, cz=0  ,         -- sphere center    
            r = 20      ,         -- radius of the sphere
            rotTime1 = 30 ,   -- rotation time in s
            url = url2,
            lightDir = vec3(1,0,0),   -- a vec3 pointing to the sun
            shadowRatio = 1.02,    -- the ratio of radius of shadow sphere to sphere
            rotTime2 = 30,
            cx2=0, cy2=0, cz2=0,    -- center of rotation 2
            ax2=0, ay2=1, az2=0,    -- rotation axis
        })
        self.ready = true
        --     change camera position
        cam.camX, cam.camY, cam.camZ = 200, 100, 300
    else planet1:draw() moon1:draw() end
end

function Tutorial:step11()
    if self.ready == false then
        self:clearPrint()
        self:print("")
        self:print("###########  STEP 11  ###########")
        self:print("")
        self:print("This tutorial is over. Now it is you turn to play with the code...")
        self:print("Feel free to improve my functions, i have the feeling there are a couple bugs left.")
        self:print("And thank you to Simeon and the great team of Two Lives Left for the magic of CODEA!")
        self:print("")
        self:print("This tutorial was brought to you by JMV38")
        end
end

function Tutorial:update()
    if self.step == 0 then self:step0() end
    if self.step == 1 then self:step1() end
    if self.step == 2 then self:step2() end
    if self.step == 3 then self:step3() end
    if self.step == 4 then self:step4() end
    if self.step == 5 then self:step5() end
    if self.step == 6 then self:step6() end
    if self.step == 7 then self:step7() end
    if self.step == 8 then self:step8() end
    if self.step == 9 then self:step9() end
    if self.step == 10 then self:step10() end
    if self.step == 11 then self:step11() end
end

function Tutorial:draw()
    -- buttons 'next and 'prev'
    fontSize(28)
    font("AmericanTypewriter-Bold")
    rectMode(CENTER)
    fill(COLOR)
    rect(WIDTH-50,HEIGHT-25,90,50)
    rect(WIDTH-150,HEIGHT-25,90,50)
    fill(0, 0, 0, 255)
    text("next",WIDTH-50,HEIGHT-25)
    text("prev",WIDTH-150,HEIGHT-25)
    -- text of tutorial
    fill(COLOR)
    fontSize(20)
    font("Arial-BoldMT")
    if self.lines>0 then
        for i=1,self.lines do 
            text(self.line[i],WIDTH/2,HEIGHT-50-i*20)
        end
    end
end

function Tutorial:touched(touch)
    local dx,dy,step
    local ds = 0
    if touch.state == BEGAN then
        dx = math.abs(touch.x-(WIDTH-50))
        dy = math.abs(touch.y-(HEIGHT-25))
        if dx<50 and dy<50 then ds = 1 end
        dx = math.abs(touch.x-(WIDTH-150))
        dy = math.abs(touch.y-(HEIGHT-25))
        if dx<50 and dy<50 then ds = -1 end
        if ds~=0 then 
            step = self.step + ds  
            if  step < 0 then step = 0
            elseif step > self.stepMax then step = self.stepMax
            else     self.ready = false     self.step = step  end
        end
    end
end
