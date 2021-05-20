--3D Animation viewer
displayMode(OVERLAY)

--saveImage("Project:Icon", readImage(asset.icon))

local walkSpeed, joyMax = -1.9, 120

function setup() 
    aerial=color(28, 33, 36, 255)
    fill(0, 255, 58, 255)
    stroke(0, 255, 58, 128)
    strokeWidth(10)
    floor.init()
    linearShader=shader(FrameBlendNoTex.linearVert, FrameBlendNoTex.frag)
    splineShader=shader(FrameBlendNoTex.splineVert, FrameBlendNoTex.frag)

    parameter.watch("FPS")
    parameter.action("DeleteStoredData",DeleteData)

    FPS=0
    cam={} --move camera around
    cam.p=vec4(70,250,150,1)
    tween(13,cam.p,{x=-50}, {easing=tween.easing.sineInOut, loop=tween.loop.pingpong})
    tween(19,cam.p,{y=80}, {easing=tween.easing.sineInOut, loop=tween.loop.pingpong})
    tween(27,cam.p,{z=10}, {easing=tween.easing.sineInOut, loop=tween.loop.pingpong})

    walkAngle, angleTarget=0,0
    LoadModel()
end

function LoadModel() 
    model=Rig(Models[1].name,Models[1].mtl,Models[1].actions)
    oldDraw=draw
    draw=loadDraw
end

function DeleteData()
    if model then model:DeleteData() end
end

function loadDraw()
    local _,c,total = coroutine.resume(model.loader)
    background(aerial)
    local unit = WIDTH/(total+3)
    rect(100,400,c*unit,50)
    if model.ready then
        draw=oldDraw
        displayMode(FULLSCREEN)
        print("ready")
    end
end

function draw()
    background(aerial) 
    FPS=FPS*0.9+0.1/DeltaTime

    perspective(65)
    camera(cam.p.x,cam.p.y,cam.p.z, 0,0,80, 0,0,1)
    pushMatrix()
 
    floor.draw(cam.p)
    
    rotate(walkAngle,0,0,1)
    walkVec=vecMat(vec2(0,walkSpeed), modelMatrix()) --get the movement vector from angle of transform
    
    model:anim()
    model:draw(cam.p)
    
    popMatrix()
    ortho()
    -- Restore the view matrix to the identity   
    viewMatrix(matrix())
    if walking then 
        local diff = (((angleTarget - walkAngle)+180)%360)-180
        walkAngle = walkAngle + diff * 0.1 --turn toward target angle
        floor.move(walkVec) --move floor in opposite direction to walking
        fill(127, 127, 127, 130) --draw joypad ellipses
        stroke(127, 127, 127, 70)
        strokeWidth(10)
        ellipse(touch.x,touch.y, 100)
        noFill()
        ellipse(anchor.x,anchor.y,joyMax*2+100)
    end  
end

function touched(t)
    if t.state==ENDED then 
        if walking then
            model:endAnim() --animate to stand-still
            walking=false
        end
    elseif t.state==BEGAN then 
        if t.x<WIDTH*0.5 then
            model:cueAnim("walk", {0,1,2,3,4}) --anim name matches key identifier in assets tab
            walking=true
            anchor=vec2(t.x,t.y)
        else
            walking=false
            model:cueAnim("kick", {0,1,2,3,2,1,0,0}, 0.1)
        end
    elseif t.state==MOVING and walking then
        touch=vec2(t.x, t.y)
        local diff = touch-anchor
        if diff:len()>joyMax then --constrain joystick
            touch = anchor + diff:normalize() * joyMax
        end
        angleTarget=math.deg(math.atan(diff.y,diff.x))+90 --not 100% sure why we need to add 90deg
    end
end

function vecMat(vec, mat) --rotate vector by current transform. 
    return vec2(mat[1]*vec.x + mat[5]*vec.y, mat[2]*vec.x + mat[6]*vec.y)
end

