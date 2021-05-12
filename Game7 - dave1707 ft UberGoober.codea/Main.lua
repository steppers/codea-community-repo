viewer.mode=OVERLAY

function setup() 
    assert(craft, "Please include Craft as a dependency")   
    createStartConditions()
    createScene() 
    createLightConditions()
    createMaterialsForGlows()
    createStartingSpheres()   
    createParameters()
    createPresets()
    createShip()
    createFloor()
end

function createStartConditions()
    maxSpeed=.5
    count=100
    ships=4
    youWon,hitRed,youLost=false,false,false
    redBalls,greenBalls,yellowBalls=0,0,0
    hgx=Gravity.x
    speed,ey,ang=0,45,0
    cameraX,cameraZ=-205,-205
end

function createScene()
    scene = craft.scene()
    scene.camera.position = vec3(cameraX,0,cameraZ)
    scene.camera.eulerAngles=vec3(ex,ey,ez)
end

function createLightConditions()
    scene.sun.rotation = quat.eulerAngles(45,0,45)   
    scene.ambientColor = color(90,90,90)   
    skyMaterial = scene.sky.material
    skyMaterial.horizon = color(0, 203, 255, 255)    
    cameraComponent = scene.camera:get(craft.camera)
    cameraComponent.hdr = true
    cameraComponent.colorTextureEnabled = true
    sunLight = scene.sun:get(craft.light)
    bloom = craft.bloomEffect()
    cameraComponent:addPostEffect(bloom)
    bloom.threshold = 4
    bloom.intensity = 1.2
    bloom.softThreshold = 0.4
    bloom.iterations = 8
end

function createMaterialsForGlows()
    greenNormalMaterial = craft.material(asset.builtin.Materials.Specular) 
    greenNormalMaterial.diffuse = color(0, 255, 0)
    greenGlowyMaterial = craft.material(asset.builtin.Materials.Basic) 
    greenGlowyMaterial.diffuse = vec3(80/255, 200/255, 120/255) * 0.5
    yellowNormalMaterial = craft.material(asset.builtin.Materials.Specular) 
    yellowNormalMaterial.diffuse = color(255, 255, 0)
    yellowGlowyMaterial = craft.material(asset.builtin.Materials.Basic) 
    yellowGlowyMaterial.diffuse = vec3(255/255, 225/255, 120/255) * 9.75  
end

function createStartingSpheres()
    tab={}
    for z=1,count do    -- 1=red
        createSphere(math.random(-200,200),math.random(-200,200),2,1,255,0,0,0,0)
        redBalls=redBalls+1
    end
    for z=1,count do    -- 2=green  
        createSphere(math.random(-200,200),math.random(-200,200),.5,2,0,255,0,0,0)
        greenBalls=greenBalls+1
    end
end

function createParameters()
    parameter.integer("presets",1,2,1, function(value)
        if value == 1 then
            dave1707presets()
        elseif value == 2 then
            uberGooberPresets()
        end
    end)
    parameter.watch("currentPresets")
    currentPresets = "dave1707"
    parameter.boolean("greenBallDiffusionToggle", false, function(value)
        for k, v in pairs(tab) do
            if v.type == 2 then
                if value then
                    v.ent.material = greenGlowyMaterial
                else
                    v.ent.material = greenNormalMaterial
                end
            end
        end
    end)
    parameter.color("greenBallDiffusion", color(0, 255, 0), function(value)     
        greenGlowyMaterial.diffuse = colorToDiffusion(value)
    end)   
    parameter.boolean("yellowBallDiffusionToggle", false, function(value)
        print("diffusionating")
        for k, v in pairs(tab) do
            if v.type == 3 then
                if value then
                    v.ent.material = yellowGlowyMaterial
                else
                    v.ent.material = yellowNormalMaterial
                end
            end
        end
    end)
    parameter.color("yellowBallDiffusion", color(255, 247, 0), function(value)      
        yellowGlowyMaterial.diffuse = colorToDiffusion(value)
    end)  
    parameter.color("skyColor", scene.sky.material.sky)
    parameter.color("horizonColor", color(71, 104, 195))    
    parameter.number("sunIntensity",0, 10, sunLight.intensity) 
    parameter.integer("sunPosX",-180,180,45)
    parameter.integer("sunPosY",-180,180,0)
    parameter.integer("sunPosZ",-180,180,45)
end

function colorToDiffusion(colorGiven)
    local colorAsVec3 = vec3(colorGiven.r, colorGiven.g, colorGiven.b)
    return colorAsVec3 / 15
end

function setMaterialForSphereType(sphereType, material)
    for k, v in pairs(tab) do
        if v.type == sphereType then
            v.ent.material = material
        end
    end
end

function createPresets()
    dave1707presets = function()
        currentPresets = "dave1707"
        greenBallDiffusionToggle = false
        greenBallDiffusion = color(0, 255, 0)
        setMaterialForSphereType(2, greenNormalMaterial)
        yellowBallDiffusionToggle = false
        yellowBallDiffusion = color(255, 247, 0)
        setMaterialForSphereType(3, yellowNormalMaterial)
        skyColor = vec3(0.35,0.37,0.42)
        horizonColor = color(71, 104, 195)
        sunIntensity = 1
        sunPosX = 45
        sunPosY = 0
        sunPosZ = 45
    end
    uberGooberPresets = function()
        currentPresets = "UberGoober"
        
        greenBallDiffusionToggle = true
        greenBallDiffusion = vec3(55/255, 250/255, 90/255) * 3.75
        setMaterialForSphereType(2, greenGlowyMaterial)
        greenGlowyMaterial.diffuse = greenBallDiffusion
        
        yellowBallDiffusionToggle = true
        yellowBallDiffusion = vec3(255/255, 225/255, 120/255) * 9.75
        setMaterialForSphereType(3, yellowGlowyMaterial)
        yellowGlowyMaterial.diffuse = yellowBallDiffusion
        
        skyColor = color(25)
        horizonColor = color(30, 39, 66)    
        sunIntensity = 3
        sunPosX = -8
        sunPosY = -95
        sunPosZ = -83
    end
end

function createShip()
    ship = scene:entity()
    ship.model = craft.model(asset.builtin.SpaceKit.spaceCraft6_obj)
    ship.scale = ship.scale * 0.018
    ship.parent = scene.camera
    ship.position = ship.position + vec3(0,-HEIGHT*0.0003,HEIGHT*0.0015)    
end

function update(dt)
    scene:update(dt)
    scene.camera.position = vec3(cameraX,1,cameraZ)
    scene.camera.eulerAngles=vec3(0,ey,0)
    scene.sun.rotation = quat.eulerAngles(sunPosX, sunPosY, sunPosZ)
    scene.sky.material.sky = skyColor
    scene.sky.material.horizon = horizonColor
    sunLight.intensity = sunIntensity
end

function draw()
    background(0)
    if youLost then
        youLostFunc()
    elseif hitRed then
        hitRedFunc()
    elseif youWon then
        youWonFunc()
    else  
        update(DeltaTime)
        scene:draw()  
        if paused then  
            text("PAUSED",WIDTH/2,HEIGHT*.7)
            text("Triple tap to restart.",WIDTH/2,HEIGHT*.7-20)
        else
            text("Triple tap to pause.",WIDTH/2,HEIGHT-10)
            updateCameraPos()        
            checkCollisions()
            checkTilt()  
            drawShip()
            drawShipLevels()
        end
    end
end

function touched(t)
    if t.state==BEGAN then
        if t.tapCount==3 then
            ang=0
            paused=not paused
        end
        if t.tapCount==2 then
            if youWon then
                setup()
            elseif youLost then
                setup()
            elseif hitRed then
                hitRed=false
                hgx=Gravity.x
                cameraX,cameraZ=-205,-205
                ships=ships-1
                speed,ey,ang=0,45,0
            end
        else
            ang=0
            if speed==0 then
                speed=maxSpeed
            end
        end
    end
end

function youLostFunc()
    fill(255,0,0)
    text("YOU LOST!",WIDTH/2,HEIGHT/2+100)
    text("Hold the ipad level then",WIDTH/2,HEIGHT/2+50)
    text("Double tap the screen to play again.",WIDTH/2,HEIGHT/2)
end

function hitRedFunc()
    sprite(asset.builtin.Tyrian_Remastered.Explosion_Huge,WIDTH/2,HEIGHT/2,500,500)
    fill(255,0,0)
    text("Hold the ipad level then",WIDTH/2,HEIGHT/2+50)
    text("Double tap the screen to continue.",WIDTH/2,HEIGHT/2)
end

function youWonFunc()
    fill(255,0,0)
    text("YOU WON!",WIDTH/2,HEIGHT/2+100)
    text("Hold the ipad level then",WIDTH/2,HEIGHT/2+50)
    text("Double tap the screen to play again.",WIDTH/2,HEIGHT/2)
end

function drawShipLevels()
    for z=1,ships do
        sprite(asset.builtin.Tyrian_Remastered.Boss_A,z*50,HEIGHT-30,40)
    end
end

function updateCameraPos()
    ey=ey-ang
    x=speed*math.sin(math.rad(ey))
    z=speed*math.cos(math.rad(ey)) 
    cameraX=cameraX+x
    cameraZ=cameraZ+z
end

function checkCollisions()
    for a,b in pairs(tab) do
        if b.type==1 then
            if cameraX>=b.ent.position.x-b.size and 
            cameraX<=b.ent.position.x+b.size and 
            cameraZ>=b.ent.position.z-b.size and
            cameraZ<=b.ent.position.z+b.size then
                if ships==0 then
                    youLost=true
                else
                    hitRed=true
                end                
                sound(SOUND_EXPLODE, 27037)
            end
        end
        if b.type==2 then
            if cameraX>b.ent.position.x-b.size and 
            cameraX<b.ent.position.x+b.size and
            cameraZ>b.ent.position.z-b.size and 
            cameraZ<b.ent.position.z+b.size then
                b.ent:destroy()
                table.remove(tab,a)
                count=count-1
                sound(SOUND_HIT, 19423)
                createSphere(math.random(-200,200),
                math.random(-200,200),.5,3,255,255,0,.2,.2)
                yellowBalls=yellowBalls+1
                greenBalls=greenBalls-1
                if yellowBallDiffusionToggle then
                    setMaterialForSphereType(3, yellowGlowyMaterial)
                else
                    setMaterialForSphereType(3, yellowNormalMaterial)
                end
            end
        end
        if b.type==3 then
            if cameraX>=b.ent.position.x-b.size and 
            cameraX<=b.ent.position.x+b.size and 
            cameraZ>=b.ent.position.z-b.size and
            cameraZ<=b.ent.position.z+b.size then
                b.ent:destroy()
                table.remove(tab,a)
                yellowBalls=yellowBalls-1
                sound(SOUND_POWERUP, 19422)
                yellowHit=true
            else
                xx=b.ent.position.x
                zz=b.ent.position.z
                xx=xx+b.xv
                zz=zz+b.zv
                if xx<-200 or xx>200 then
                    b.xv=-b.xv
                end
                if zz<-200 or zz>200 then
                    b.zv=-b.zv
                end
                b.ent.position=vec3(xx,1,zz)
            end
        end
    end
    if yellowHit then   -- remove a red ball
        yellowHit=false
        for z=#tab,1,-1 do
            if tab[z].type==1 then
                tab[z].ent:destroy()
                table.remove(tab,z)
                redBalls=redBalls-1
                break
            end
        end
    end
    if redBalls+greenBalls+yellowBalls==0 then
        youWon=true
    end
    if speed==0 then
        text("Tap screen to start.",WIDTH/2,HEIGHT*.75)
    end
end

function checkTilt()
    gx=Gravity.x
    ang=ang+(gx-hgx)*4
    hgx=gx
    if gx>-.001 and gx<.001 then
        ang=0
    end
end

function drawShip()
    pushMatrix()
    translate(WIDTH/2,HEIGHT*0.255)
    rotate(ang*-30)
    --sprite(asset.builtin.Tyrian_Remastered.Boss_A,0,0,300)
    fill(255,0,0)
    text(redBalls,-40,0)
    fill(0,255,0)
    text(greenBalls,0,0)
    fill(255,255,0)
    text(yellowBalls,40,0)    
    translate()
    popMatrix()
    ship.eulerAngles = vec3(0,-135, -ang*20)
    ship.eulerAngles = vec3(0,180, -ang*30)
end

function createFloor(x,z)
    c1=scene:entity()
    c1.model = craft.model.cube(vec3(400,1,400))
    c1.position=vec3(x,-.5,z)
    c1.material = craft.material(asset.builtin.Materials.Standard)
    c1.material.map = readImage(asset.builtin.Surfaces.Desert_Cliff_Color)
    c1.material.offsetRepeat=vec4(0,0,50,50)
end

function createSphere(x,z,size,type,r,g,b,xv,zv)
    sphere1=scene:entity()
    sphere1.model = craft.model.icosphere(size,1)
    sphere1.position=vec3(x,1,z)
    sphere1.material = craft.material(asset.builtin.Materials.Specular)
    sphere1.material.diffuse=color(r,g,b)
    
    if type == 2 then       
        
        sphere1.material = greenNormalMaterial
    elseif type == 3 then
        sphere1.material = yellowNormalMaterial
        
    end
    table.insert(tab,{ent=sphere1,xv=xv,zv=zv,size=size,type=type})
end 