-- CraftSpace

viewer.mode=FULLSCREEN

function setup()
    a = 1
    btn={}
    rectMode(CENTER)
    assert(craft, "Include Craft as a dependency")
    -- cameraFPS coordinate and angular variables
    cx,cy,cz, ax,ay,az = 0
    scene = craft.scene()
    
    -- create instance of fps camera and set position in scene
    cameraFPS = cameraClass()
    cameraFPS.cameraX, cameraFPS.cameraY, cameraFPS.cameraZ = 0,0,0
    
    -- define distance to detect fps camera running into environment
    obstructionDistance = 0.2
    obstructionRadius = 0.4
    
    -- setup sun and space background
    -- skybox is a free download available at: https://www.pngegg.com/en/png-mlweb/download
    scene.sun.rotation = quat.eulerAngles(0,-90,45) 
    scene.sky.material.envMap = craft.cubeTexture(asset.SkyboxNightSky)
    
    -- all 3D models below are free to download; download addresses are listed above each model
    -- https://www.renderhub.com/shredder/space-station-kds179
    SpaceStation = scene:entity()    
    SpaceStation.model = craft.model(asset.SpaceStation2_obj)
    --    SpaceStation.model.material = craft.model(asset.documents.SpaceStation_mtl)
    Astronaut = scene:entity()
    -- free download from NASA site: https://nasa3d.arc.nasa.gov/detail/nmss-z2
    Astronaut.model = craft.model(asset.Z2)
    --    Astronaut.model.material= craft.model(asset.documents.Z2_mtl)
    Earth = scene:entity()
    -- free download: https://www.turbosquid.com/3d-models/earth-max-free/1016431
    Earth.model = craft.model(asset.Earth)
    Earth.material = craft.material(asset.builtin.Materials.Standard)
    Earth.material.map = readImage(asset.Earth_Diffuse)
    SpaceStation.position = vec3(-10,0,40)
    SpaceStation.scale = vec3(0.1,0.1,0.1)
    -- position astronaut just below and in front of the camera
    Astronaut.position = vec3(0,-0.6,0.4)
    Astronaut.scale = vec3(0.3,0.3,0.3)
    Astronaut.eulerAngles = vec3(0,0,0)
    Astronaut.parent = scene.camera
    Earth.position = vec3(-10,-1,125)
    Earth.scale = vec3(1,1,1)
    -- create a Gyro and put it over the astronauts head to help user navigate in the 3D space
    createGyro()
    Gyro.position = vec3(0,0,0.3)
    Gyro.eulerAngles = vec3(Gx,Gy,Gz)
    Gyro.parent = scene.camera
    -- add static rigid body structure to the SpaceStation & Earth model entities so can detect when astronaut is about to hit either of these structuries
    SpaceStation:add(craft.rigidbody, STATIC)
    SpaceStation:add(craft.shape.model, SpaceStation.model)
    Earth:add(craft.rigidbody, STATIC)
    Earth:add(craft.shape.model, Earth.model)     
end

function createGyro()   
    Gyro = scene:entity()
    Gyro.model = craft.model.icosphere(2,8)
    Gyro.material = craft.material(asset.builtin.Materials.Standard)
    -- created a four color texture .png file to wrap around gyro sphere
    Gyro.material.map = readImage(asset.fourColorTexture)
    Gyro.scale = vec3(0.005,0.005,0.005)
end

function draw()
    background(0)
    cx,cy,cz,ax,ay,az= cameraFPS:updateCameraPos()
    scene.camera.position = vec3(cx,cy,cz)
    scene.camera.eulerAngles= vec3(ax,ay,az)
    Gyro.eulerAngles=vec3(ax,ay,az)
    scene:draw()
    cameraFPS:draw()
end

function touched(t)
    --if screen is touched then iterate over the btn table and call button:touched()
    cameraFPS:touched(t)
end

function sizeChanged()
    cameraFPS:moveButtonCloser(cameraFPS)
end

function checkObstruction()
    -- compute coordinate for next move then spherecast a sphere to it and see if it hits it (if so, obstruction = true)
    local cameraX2=cameraFPS.cameraX+x
    local cameraY2=cameraFPS.cameraY+y
    local cameraZ2=cameraFPS.cameraZ+z 
    -- camera move up/down
    local cameraY2=cameraY2+cameraFPS.y1
    -- camera move left/right
    local cameraX2=cameraX2+math.cos(math.rad(cameraFPS.angleY))*cameraFPS.x1
    local cameraZ2=cameraZ2-math.sin(math.rad(cameraFPS.angleY))*cameraFPS.x1  
    local direction = vec3(cameraX2,cameraY2,cameraZ2) - vec3(scene.camera.x,scene.camera.y,scene.camera.z)
    obstruction = scene.physics:spherecast(vec3(cameraX2,cameraY2,cameraZ2), direction, obstructionDistance, obstructionRadius) 
end
