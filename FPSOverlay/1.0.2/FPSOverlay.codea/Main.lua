
function setup()
    viewer.mode = FULLSCREEN
    FPSOverlay.setup(60)
end

function draw()
    background(32)
    FPSOverlay.draw()
end