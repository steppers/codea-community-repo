-- ColorStudio by Louis Marcellino (IG: @invinixity)
table.maxn = table.maxn or function(t) return #t end

function setup()
    
    smooth()
    displayMode(FULLSCREEN_NO_BUTTONS)
    
    --clearLocalData()
    
    glcv = GLSLCanvas()
    
    colCard = ColorCard(vec2(0, 0))
    
    font("ArialRoundedMTBold")
    
    dev = false
    grid = false
    
end

function draw()
    
    background(125)
    
    glcv.color.replacer = colCard.colChooser.color.current
    
    fill(255)
    glcv:draw(vec2(WIDTH, HEIGHT))
    
    colCard.pos = vec2(WIDTH-333+1.8, 27)
    
    fill(55)
    colCard:draw()
    
    if dev then
        pushMatrix()
        pushStyle()
        stroke(125, 255, 225, 225)
        strokeWidth(1)
        translate(WIDTH/2, HEIGHT/2)
        lineCapMode(SQUARE)
        local ln = math.max(WIDTH, HEIGHT)/9
        local ratio = math.min(WIDTH, HEIGHT)/math.max(WIDTH, HEIGHT)
        local w, h = WIDTH, HEIGHT
        if w > h then
            h = HEIGHT/ratio
        else
            w = WIDTH/ratio
        end
        if grid then
            for i = -ln/2, ln/2 do
                line(w/ln*i, -h/2, w/ln*i, h/2) line(-w/2, h/ln*i, w/2, h/ln*i)
            end
        end
        popStyle()
        popMatrix()
        
        fill(255, 125)
        rect(WIDTH-36, HEIGHT-36, 36)
    end
    
end

function touched(touch)
    
    glcv:touched(touch)
    colCard:touched(touch)
    
    if dev then
        if touch.state == BEGAN
        and touch.x > WIDTH-36 and touch.x < WIDTH
        and touch.y > HEIGHT-36 and touch.y < HEIGHT
        then
            if grid then
                grid = false
            else
                grid = true
            end
        end
    end
    
end