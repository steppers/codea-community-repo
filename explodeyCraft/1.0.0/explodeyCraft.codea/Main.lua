--explodeyCraft: dave1707's explosion code made into a self-contained function and enhanced with un-exploding by UberGoober

viewer.mode = STANDARD

function setup() 
    parameter.number("timeIncrement", 0, 1.5, 1)
    fill(255)
    tab={}
    assert(OrbitViewer, "Please include Cameras as a dependency")        
    scene = craft.scene()
    scene.sun.rotation=quat.eulerAngles(30,180,0)
    v=scene.camera:add(OrbitViewer,vec3(0,0,0), 20, 0, 2000)

    sphere=scene:entity()
    sphere.position = vec3(7, 0, 0)
    sphere.scale = vec3(1,1,1) * 1.55
    sphere.model = craft.model(asset.builtin.Primitives.Sphere)
    sphere.material = craft.material(asset.builtin.Materials.Standard)
    sphere.material.diffuse = color(96, 172, 59)
    sphere = explodeyCraft(sphere, color(96, 172, 59))
    
    monkey=scene:entity()
    monkey.position = vec3(2, 0, 0)
    monkey.scale = vec3(1,1,1) * 1.5
    monkey.eulerAngles = vec3(20, 165, -0)
    monkey.model = craft.model(asset.builtin.Primitives.Monkey)
    monkey.material = craft.material(asset.builtin.Materials.Standard)
    monkey.material.diffuse = color(168, 126, 126)
    monkey = explodeyCraft(monkey, color(168, 126, 126))
    
    ship=scene:entity()
    ship.position = vec3(-4, -1.5, 0)
    ship.eulerAngles = vec3(20, 165, -0)
    ship.model = craft.model(asset.builtin.Watercraft.watercraftPack_003_obj)
    ship = explodeyCraft(ship, color(217, 170, 114))
    
    entities = { sphere, monkey, ship }
    
    time = 0
    exploderIndex = 1
    shouldExplode = false
end

function draw()
    update(DeltaTime)
    scene:draw()
end

function update(dt)
    scene:update(dt)
    if shouldExplode then
        time = time + timeIncrement
    else
        time = math.max(0, time - timeIncrement)
    end
    if shouldExplode then
        entities[exploderIndex].explodeOneFrame(timeIncrement)
    else
        entities[exploderIndex].unexplodeOneFrame(timeIncrement)
    end
end

function touched(t)
    if t.state==BEGAN then
        shouldExplode = not shouldExplode
        if shouldExplode and time == 0 then
            exploderIndex = exploderIndex + 1
            if exploderIndex > #entities then exploderIndex = 1 end 
        end
    end
end