-- Copyright 2019 Théo Arrouye

supportedOrientations(PORTRAIT)

function setup()
    touchTimes = {}
    displayMode(FULLSCREEN_NO_BUTTONS)
    parameter.color("penColor", color(255, 0, 0))
    parameter.number("penSize", 1, 40, 2.5)
    parameter.action("Clear screen", clearScreen)

    parameter.action("Save image", function()
    
    saveImage("Project:Icon",canvas)
end
    )
    
    if WIDTH > HEIGHT then
        xOffset = WIDTH / 2
        yOffset = 20
    else 
        xOffset = 0
        yOffset = 20
    end 
    dWidth = math.min(HEIGHT, WIDTH)
    dHeight = dWidth
    
    sizeSlider = Slider("penSize", 1, 20, WIDTH/2 - (WIDTH - dWidth * 0.7)/3, HEIGHT/2 + yOffset, nil, dWidth * 0.7)
    sizeSlider:setLabel("Pen Size")
    sizeSlider:setUnitsLabel("px")
    
    colorPicker = SwipeColorPicker(WIDTH / 2, HEIGHT / 2 + dWidth / 1.25 + yOffset, dWidth / 4)
    
    buttons = {
        textButton("Fill Screen", 10, HEIGHT / 2 + dWidth / 2.5 + yOffset, function() clearScreen(penColor) end, dWidth / 8, nil, nil, true),
        textButton("Clear Screen", 10, HEIGHT / 2 + dWidth / 4 + yOffset, clearScreen, dWidth / 8, nil, nil, true),
        textButton("Undo", 10, HEIGHT / 2 + dWidth / 1.75 + yOffset, undoMove, dWidth /8, nil, nil, true)
    }
    
    prevCanvases = {}
    clearScreen()
end

function clearScreen(col)
    saveForUndo()
    canvas = image(dWidth, dHeight)
    setContext(canvas)
    background(col or 255)
    setContext()
    lastPoint = nil
end

function saveForUndo()
    if canvas then
        local toSave = image(dWidth, dHeight)
        setContext(toSave)
        spriteMode(CORNER)
        sprite(canvas, 0,0)
        setContext()
        table.insert(prevCanvases, toSave)
    end
end
    

function undoMove()
    if #prevCanvases >= 1 then
        canvas = prevCanvases[#prevCanvases]
        print(canvas)
        table.remove(prevCanvases, #prevCanvases)
    end
end

function drawAtPoint(p)
    p2 = vec2(dWidth - p.x, p.y)
    p3 = vec2(dWidth - p.x, dHeight - p.y)
    p4 = vec2(p.x, dHeight - p.y)
    setContext(canvas)
    noStroke()
    fill(penColor)
    ellipse(p.x, p.y, penSize)
    ellipse(p2.x, p2.y, penSize)
    ellipse(p3.x, p3.y, penSize)
    ellipse(p4.x, p4.y, penSize)
    
    strokeWidth(penSize)
    stroke(penColor)
    if lastPoint ~= nil then
        lp2 = vec2(dWidth - lastPoint.x, lastPoint.y)
        lp3 = vec2(dWidth - lastPoint.x, dHeight - lastPoint.y)
        lp4 = vec2(lastPoint.x, dHeight - lastPoint.y)
        
        line(p.x, p.y, lastPoint.x, lastPoint.y)
        line(p2.x, p2.y, lp2.x, lp2.y)
        line(p3.x, p3.y, lp3.x, lp3.y)
        line(p4.x, p4.y, lp4.x, lp4.y)
    end
    setContext()
    
    lastPoint = p
end

function draw() 
    opColor = color(255 - penColor.r, 255 - penColor.g, 255 - penColor.b)
    background(255 - math.floor((penColor.r + penColor.g + penColor.b) /3))
    --background(opColor)
    spriteMode(CORNER)
    sprite(canvas, xOffset, yOffset)
    
    --slider
    sizeSlider.textFill = penColor
    sizeSlider.filledFill = penColor
    sizeSlider.baseFill = opColor
    sizeSlider:draw()
    
    stroke(penColor)
    strokeWidth(penSize)
    line(WIDTH - sizeSlider.x + sizeSlider.length / 2.5, sizeSlider.y, WIDTH - sizeSlider.x + sizeSlider.length / 2, sizeSlider.y)
    
    
    colorPicker:draw()
    penColor = colorPicker.color
    --penSize = colorPicker.strokeSize
    
    --buttons
    for i, but in pairs(buttons) do
        but.fill = penColor
        but:draw()
    end
    
    stroke(penColor)
    strokeWidth(10)
    line(xOffset, yOffset + dHeight + 5, xOffset + dWidth, yOffset + dHeight + 5)
end

function touched(touch)
    if ((touchTimes[os.time()] or 0) > 58) then
        print(touchTimes[os.time()])
     end
    if (touchTimes[os.time()] == nil) then
        touchTimes[os.time()] = 0
    end
    touchTimes[os.time()] = touchTimes[os.time()] + 1 
    if lastPoint == nil and not colorPicker.active then
            for i, but in pairs(buttons) do
                but:touched(touch)
            end
        end
    
    colorPicker:touched(touch)
    sizeSlider:touched(touch)
    
    if touch.state == BEGAN and touch.x >= xOffset and touch.x <=xOffset + dWidth and touch.y >= yOffset and touch.y <= yOffset + dHeight then
        startedTouch = true
        saveForUndo()
    end
    
    if startedTouch then
    
        t = vec2(touch.x - xOffset, touch.y - yOffset)
        
        if t.x >= 0 and t.x <= dWidth and t.y >= 0 and t.y <= dHeight then
            if t.x > dWidth / 2 then
                t.x = (dWidth - t.x) % (dWidth / 2)
            end
            if t.y > dHeight / 2 then 
                t.y = (dHeight - t.y) % (dHeight / 2)
            end
            drawAtPoint(t)
        end
    end
    
    if touch.state == ENDED or touch.state == CANCELLED then
        lastPoint = nil
        startedTouch = false
    end
end
