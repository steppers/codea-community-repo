--Trench Run

local touches, tArray, lastPinchDist = {}, {}
displayMode(OVERLAY)
displayMode(FULLSCREEN)

function setup() 
    supportedOrientations(LANDSCAPE_ANY)
    parameter.watch("#meshes")
    font("GillSans")
    strokeWidth(1)
    hiscore = readLocalData("hiscore", 0)
    friendly = 1 --mask flags for collisions
    hostile = 2
    model = {} --holds unique meshes
    trenchSize = 12.6
    trenchRadius = trenchSize/2

    parameter.watch("FPS")
    FPS=0
    Splash.init()
end

function setView()

end

function draw()
    background(15, 15, 20, 255)
    FPS=FPS*0.9+0.1/DeltaTime
    scene.draw()
end

function touched(t)
    scene.touched(t)
end
