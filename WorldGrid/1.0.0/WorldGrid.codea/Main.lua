-- World Grid

-- world grid added to voxel editor's grid

function setup()
    scene = craft.scene()
    scene.sky.material.sky = color(242, 238, 241)       
    scene.sky.material.horizon = color(221, 231, 228)       
    scene.camera:add(OrbitViewer,vec3(0,0,0),5,0,1000)
    
    Grid.worldGrid()
end

function update(dt)
    scene:update(dt)
end

function draw()
    update(DeltaTime)
    scene:draw()	
end