Game = {}

function Game.init(wire)
    meshes = {}
    deviceOri = vec2(Gravity.x, Gravity.y) --current device position
    fontSize(30)
    model.trench:setColors(
    color(203, 220, 255, 255)) --tint the trench so that the craft stand out against it
   -- Mesh{pos = vec3(0,0,0), mesh = model.trench, instances = 20, scenery = true} --trench, drawn with instancing
    for i = 0,19 do
        --local a,b = math.floor((i%4)/2), math.floor(((i+1)%4)/2)
        local a = i % 2
        local m = matrix():translate(0,0,i*trenchSize):rotate(a*180, 0,1,0) --:scale(b*-1,0,0) --
      --  Mesh{pos = vec3(0,0,i*trenchSize), angle = vec3(0, a*180, 0), mesh = model.trench, instances = 1, scenery = true}
        MeshStatic{matrix = m, mesh = model.trench, scenery = true}
    end
    player = Player{pos = vec3(0,6.3,0)} --player
    wave = Wave() --waves
    score = 0
    
    cam = { --camera
    follow = player,
    offset = vec3(0,0.6,-4),
    up = vec3(0,1,0),
    fov = 35}
    
    tween(4, cam, {fov = 70, offset = vec3(0,0.5,-3)}, tween.easing.cubicInOut) --, offset = vec3(0,0.5,-0.75)
 
    globalOffset = 0 --used to loop trench by pulling all non-scenery objects back, stops z coords getting too huge
    if wire then --wireframe mode
        for i,v in pairs(model) do
            wireframe.set(v)
        end
        model.trench.shader = shader(wireframe.vertInst, wireframe.frag)
        model.trench.shader.strokeWidth = 1
        model.playerBolt.shader.strokeWidth = 10
        model.enemyBolt.shader.strokeWidth = 10
    end
    gameStart = ElapsedTime
    scene = Game
end

function Game.draw()
    --update all positions
    wave:update()
    for i = #meshes,1,-1 do
        local v = meshes[i]
        if v.kill then 
            table.remove(meshes, i)
        elseif not v.scenery then 
            v.pos.z = v.pos.z - globalOffset 
            v:update()
        end
    end
    --set camera according to player position
    perspective(cam.fov) 
    cam.ori = cam.follow.pos + cam.follow.forward --vec3(0,0.5,0)
    cam.pos = cam.follow.pos + cam.offset - 1.5 * cam.follow.forward 
    cam.up = (cam.follow.up + vec3(0,1,0)) * 0.5
    cam.forward = (cam.ori - cam.pos):normalize()
    camera(cam.pos.x, cam.pos.y,cam.pos.z, cam.ori.x, cam.ori.y,cam.ori.z, cam.up.x, cam.up.y, cam.up.z)
    --check collisions, then draw
    for i = #meshes,1,-1 do
        local v = meshes[i]
        if not v.scenery then v:collisions() end
        v:draw()
    end
    --loop the trench by bringing every moving object back one segment every few frames
    if player.pos.z>25.2 then globalOffset = 25.2 --25.2
    else globalOffset = 0 end
    -- back to 2D to draw the hud
    ortho()
    viewMatrix(matrix())

    fill(0, 152, 255, 160)
    rect(50, HEIGHT-60, (WIDTH - 200) * player.shield, 30)
    textMode(CORNER)
    text(string.format("%.6d", score), WIDTH - 135, HEIGHT - 60)
end

function Game.touched(touch)
    player:touched(touch)
end
