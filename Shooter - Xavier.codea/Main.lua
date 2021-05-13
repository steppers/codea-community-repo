--# Main
-- Fight
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN)
function setup()
    showEditor = true--false
    
    screen = "editor"
    
    noSmooth()
    fill(255)
    font("Copperplate-Bold")
    scene = nil
    
    editor = Editor()
    world = World(12, 9)
    origin = {}
    time, fps, cnt, lastFps = 0, 0, 0, 0
    
    --    editor.editMode = false
    strokeWidth(2)
    stroke(0, 0, 0, 255)
    
    
    assetList("Project", TEXT)
    
    touches = {}
    nbTouches = 0
    
    if not showEditor then
        scene = Scene()
        music("A Hero's Quest:Battle", true, .3)
    end
    
end


function draw()
    background(240, 240, 240, 255)
    sprite("Project:bg", WIDTH/2,HEIGHT/2, WIDTH, HEIGHT)
    
    if showEditor and editor.editMode then
        editor:draw()
    else
        scene:update()
        
        scene:draw()
        
        		-- cleanup obselete objects
        if scene.bulletIndex then
            table.remove(scene.bullets, scene.bulletIndex)
        end
        if scene.animIndex then
            table.remove(scene.animations, scene.animIndex)
        end
        
        if showEditor then
            editor.playButton.img = "Project:edit"
            editor.playButton:draw()
        end
        
        scene.p1:drawGUI()
        scene.p2:drawGUI()
        
    end
    
    fontSize(17)
    fill(255)
    time = time + DeltaTime
    cnt = cnt + 1
    fps = fps + 1/DeltaTime
    if time > .5 then
        lastFps = math.floor(10*fps/cnt)/10
        time = 0
        cnt = 0
        fps = 0
        
    end
    text(lastFps, WIDTH-20, 10)
    --     collectgarbage()
end


function touched(touch)
    	-- allows multitouch
    if touch.state == ENDED then
        touches[touch.id] = nil
        nbTouches = nbTouches - 1
    else
        if touch.state == BEGAN then
            nbTouches = nbTouches + 1
        end
        touches[touch.id] = touch
    end
    
    
    if showEditor and editor.editMode then
        editor:touched(touch)
    else
        if showEditor and touch.state == ENDED then
            editor.playButton:touched(touch)
        end
        scene:touched(touch)
    end
end