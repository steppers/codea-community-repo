-- VoxelCopter

function setup()  
    scene = craft.scene()
    v=scene.camera:add(OrbitViewer, vec3(12,20,0), 90, 0, 1000)
    v.rx, v.ry = 30, 3  
    skyMaterial = scene.sky.material
    skyMaterial.horizon = color(255)
    scene.ambientColor = color(255, 0)
    scene.sky.material.envMap = craft.cubeTexture(asset.CanyonScaledByHalf)
    scene.camera.position = -scene.camera.forward * 5
    CameraSettings = scene.camera:get(craft.camera)
    CameraX,CameraY,CameraZ = 0,0,0 
    copter = VoxelCopter(scene)
    
end

function update(dt)
    scene:update(dt)
end

function draw()
    update(DeltaTime)    
    copter:draw()
    scene:draw()	
end