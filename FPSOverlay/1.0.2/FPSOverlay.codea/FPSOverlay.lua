FPSOverlay = {
    target = 60,
    low = 60 -- lowest framerate
}

local num_entries = 300 -- 5 seconds @ 60 FPS
local running_averages = {}
local frames = {}
local function onFrame()
    table.insert(frames, 1, DeltaTime)
    
    -- Calculate running average over the past 1 second
    local time_acc = 0
    local frame_count = FPSOverlay.target
    for i,time in ipairs(frames) do
        time_acc = time_acc + time
        if time_acc >= 1.0 then
            frame_count = i-1
            break
        end
    end
    table.insert(running_averages, 1, frame_count)
    
    -- Track lowest framerate
    FPSOverlay.low = math.min(FPSOverlay.low, frame_count)
    
    -- Limit number of entries
    if #frames > num_entries then
        table.remove(frames)
        table.remove(running_averages)
    end
end

function FPSOverlay.setup(fps_target)
    FPSOverlay.target = fps_target
    FPSOverlay.low = fps_target
    viewer.preferredFPS = fps_target
end

function FPSOverlay.draw()
    onFrame() -- Log this frame
    
    -- Reset the view & projection matrices
    local proj = projectionMatrix()
    local view = viewMatrix()
    ortho()
    viewMatrix(matrix())
    
    textMode(CENTER)
    smooth()
    strokeWidth(1)
    fill(255)
    fontSize(17)
    
    -- Draw low line first
    local low_line_y = FPSOverlay.low * 5
    stroke(255, 0, 43)
    line(0, low_line_y, WIDTH, low_line_y)
    text("Low: " .. tostring(FPSOverlay.low), WIDTH-40, low_line_y + 10)
    
    -- Draw live
    stroke(255)
    local interval = WIDTH / #running_averages
    local last = running_averages[1] * 5
    for i,framerate in ipairs(running_averages) do
        local this = framerate * 5
        line(WIDTH - (interval * (i-1)), last, WIDTH - (interval * i), this)
        last = this
    end
    
    -- Draw target line
    local target_line_y = FPSOverlay.target * 5
    text("Current: " .. tostring(running_averages[1]), WIDTH/2, target_line_y + 10) -- And current FPS
    stroke(0, 255, 16)
    line(0, target_line_y, WIDTH, target_line_y)
    text("Target: " .. tostring(FPSOverlay.target), 40, target_line_y + 10)
    
    -- Restore the view & projection matrices
    projectionMatrix(proj)
    viewMatrix(view)
end