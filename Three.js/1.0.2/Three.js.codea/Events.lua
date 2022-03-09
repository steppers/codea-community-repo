-- Event dispatch thread
local events = {}
ST.Thread(function()
    
    -- Wait until the webview is initialised
    while webview == nil do
        ST.yield()
    end
    
    ST.loop(function()
        for _,event in ipairs(events) do
            webview:callAsync(event[1], event[2])
        end
        events = {}
    end)
end)

function sendEvent(fn, arg)
    table.insert(events, {fn, arg})
end

function touched(t)
    sendEvent("__touched", {
        id = t.id,
        pos = { x = t.pos.x, y = t.pos.y },
        prevPos = { x = t.prevPos.x, y = t.prevPos.y },
        precisePos = { x = t.precisePos.x, y = t.precisePos.y },
        precisePrevPos = { x = t.precisePrevPos.x, y = t.precisePrevPos.y },
        delta = { x = t.delta.x, y = t.delta.y },
        force = t.force,
        maxForce = t.maxForce,
        altitude = t.altitude,
        azimuth = t.azimuth,
        azimuthVec = { x = t.azimuthVec.x, y = t.azimuthVec.y },
        type = t.type,
        state = t.state,
        tapCount = t.tapCount,
        timestamp = t.timestamp
    })
end

function hover(g)
    sendEvent("__hover", {
        state = g.state,
        location = { x = g.location.x, y = g.location.y },
        translation = { x = g.translation.x, y = g.translation.y },
        delta = { x = g.delta.x, y = g.delta.y },
        pinchScale = g.pinchScale,
        pinchVelocity = g.pinchVelocity,
        alt = g.alt,
        control = g.control,
        command = g.command,
        shift = g.shift,
        capsLock = g.capsLock
    })
end

function scroll(g)
    sendEvent("__scroll", {
        state = g.state,
        location = { x = g.location.x, y = g.location.y },
        translation = { x = g.translation.x, y = g.translation.y },
        delta = { x = g.delta.x, y = g.delta.y },
        pinchScale = g.pinchScale,
        pinchVelocity = g.pinchVelocity,
        alt = g.alt,
        control = g.control,
        command = g.command,
        shift = g.shift,
        capsLock = g.capsLock
    })
end

function pinch(g)
    sendEvent("__pinch", {
        state = g.state,
        location = { x = g.location.x, y = g.location.y },
        translation = { x = g.translation.x, y = g.translation.y },
        delta = { x = g.delta.x, y = g.delta.y },
        pinchScale = g.pinchScale,
        pinchVelocity = g.pinchVelocity,
        alt = g.alt,
        control = g.control,
        command = g.command,
        shift = g.shift,
        capsLock = g.capsLock
    })
end

function willClose()
    sendEvent("__willClose")
end

function sizeChanged(nw, nh)
    sendEvent("__resize", { nw, nh })
end
