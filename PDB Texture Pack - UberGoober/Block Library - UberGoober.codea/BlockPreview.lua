-- Uses the camera to generate previews of blocks before the scene starts
function generateBlockPreview(block)
    
    -- Try to read a cached version of the icon first
    --[[
    local img = readImage("Project:"..block.name)
    
    if img then
        return img
    end
    ]]
    
    local camera = scene.camera:get(craft.camera)
    local sky = scene.sky
    
    local ortho = camera.ortho
    local orthoSize = camera.orthoSize
    
    camera.ortho = true
    camera.orthoSize = 0.9
    camera.entity.rotation = quat.eulerAngles(35, 45, 0)
    camera.entity.position = vec3(0.5, 0.5, 0.5) - camera.entity.forward * 5
    camera.clearColorEnabled = false
    sky.active = false
    
    local volumeObj = scene:entity()
    local volume = volumeObj:add(craft.volume, 1, 1, 1)   

    if block.tinted then
        volume:set(0,0,0,"name", block.name, "color", color(255,255,255,255))        
    else
        volume:set(0,0,0,block.name)
    end

    img = image(48, 48)
    setContext(img, true)
    camera:draw()
    setContext()
    
    volumeObj:destroy() 
    
    camera.ortho = ortho
    camera.orthoSize = orthoSize
    camera.clearColorEnabled = true
    sky.active = true
    
    saveImage("Project:"..block.name, img)
    return img 
end
