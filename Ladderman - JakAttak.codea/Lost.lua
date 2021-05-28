-- Just holds most of the functions for the lost state
function animateEndScore() 
    tween(.5, sizes.scoreFont, { x = sizes.bigFont.x, y = sizes.bigFont.y })
    tween(.5, sizes.replay, { x = sizes.replay.x * 2, y = sizes.replay.y * 2 })
end

function animateEndMenu()
    tween(.5, replay, { y = HEIGHT / 2 - sizes.replay.x })
end

function animateHideEndMenu()
    tween(.5, sizes.scoreFont, { x = sizes.smallFont.x, y = sizes.smallFont.y })
    tween(.5, sizes.replay, { x = sizes.replay.x / 2, y = sizes.replay.y / 2 })
    
    tween(.5, replay, { y = -sizes.replay.y / 2 }, tween.easing.linear, function()
        initialise()
        MODE = PLAYING
    end)
end

function drawLost()
    sprite(imgs.panel, replay.x, replay.y, sizes.replay.x, sizes.replay.y)
    stroke(0, 155, 255, 153) strokeWidth(oneS * 2)
    local lof, sof, tof = sizes.replay.x / 2.17, sizes.replay.y / 4, sizes.replay.y / 9
    --line(replay.x - lof, replay.y - sof, replay.x + lof, replay.y - sof)
    --line(replay.x - lof, replay.y + sof, replay.x + lof, replay.y + sof)
    
    fill(0) fontSize(sizes.replay.y * .6)
    text("AGAIN?", replay.x, replay.y)
end

function touchLost(t)
    if t.x >= replay.x - sizes.replay.x / 2 and t.x <= replay.x + sizes.replay.x / 2
    and t.y >= replay.y - sizes.replay.y / 2 and t.y <= replay.y + sizes.replay.y / 2 then
        animateHideEndMenu()
    end
end

