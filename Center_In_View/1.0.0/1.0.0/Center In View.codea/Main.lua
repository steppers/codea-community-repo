viewer.mode=FULLSCREEN

function setup()
    bx,bz=0,0   -- initial block position
    vel=.2      -- velocity
    dir=0
    
    scene = craft.scene()
    
    ground=scene:entity()
    ground.model = craft.model.cube(vec3(1000,1,1000))
    ground.position=vec3(0,-10,0)
    ground.material = craft.material(asset.builtin.Materials.Standard)
    ground.material.map = readImage(asset.builtin.Surfaces.Desert_Cliff_Normal)
    ground.material.offsetRepeat=vec4(0,0,50,50)
    
    ship = scene:entity()
    ship.model = craft.model(asset.builtin.SpaceKit.spaceCraft2_obj)
    
    cam = scene:entity()
    cam.position=vec3(0,8,14)    
    cam.parent=ship   -- attach camera to ship
    c=cam:add(craft.camera, 120, .1, 1000, false) -- set camera values
end

function update(dt)
    scene:update(dt)
    ship.eulerAngles = vec3(0,dir,0)
    bx=bx-vel*math.sin(math.rad(dir))   -- calculate x value
    bz=bz-vel*math.cos(math.rad(dir))   -- calculate z value
    ship.position=vec3(bx,0,bz)        -- update ship x,z position   
    c.entity.eulerAngles=vec3(0,180,-Gravity.x*100)  -- set camera pointing direction
end

function draw()
    update(DeltaTime)
    scene:draw()    
    dir=dir-Gravity.x*3
end