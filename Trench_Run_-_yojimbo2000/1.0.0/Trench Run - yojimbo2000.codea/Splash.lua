Splash = {} --state 

function Splash.init(x)
    ready = false
    progress = 1 --progress of loading (remote requests)
    progress2 = 0 --progress of building(coroutine)
    checkAssets()
    message = string.format("Hiscore: %.4d", hiscore)
    fill(0, 152, 255, 211)
    stroke(0, 153, 255, 160)
    scene = Splash
end

function Splash.draw()
    translate(WIDTH/2, HEIGHT/2)
    fontSize(60)
    fill(0, 152, 255, 211)
    text("A long time ago, in a galaxy far,\nfar away....")
    translate(0,-200)
    fontSize(20)
    fill(120)
    text(message)
    translate(0,-60)
    if loading then 
        local _, prog = coroutine.resume(loading)
        if coroutine.status(loading) == "dead" then
            ready = true
        else
            progress2 = prog
        end
    end
    if ready then      
        text("Hold your device in the desired position\nThen tap to begin")
    elseif loading then
        text("Building:")
     else
        text("Loading:")   
    end
    rect(-150,-80, (progress + progress2) * 30, 30)

end

function Splash.ready()
    ready = true
end

function Splash.update()
    progress = progress + 1
    sound(SOUND_PICKUP, 6270)
end

function Splash.touched(t)
    if ready then Game.init() end
end
