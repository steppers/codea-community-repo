
function roundRect(x,y,w,h,r)
    ellipseMode(RADIUS)
    rectMode(CENTER)
    ellipse(x - w/2 + r, y - h/2 + r, r)
    ellipse(x + w/2 - r, y - h/2 + r, r)
    ellipse(x + w/2 - r, y + h/2 - r, r)
    ellipse(x - w/2 + r, y + h/2 - r, r) 
    rect(x,y,w,h - r*2)
    rect(x,y,w - r*2,h)
end

function roundedTex(w, h, f)
    local tex = image(w,h)
    setContext(tex)
    fill(255)
    local rw,rh = w*f,h*f
    roundRect(w/2,h/2,rw,rh,math.min(rh*0.0625,rw/2))
    setContext()
    
    return tex
end

function blurredSquare(w, h)
    local tex = roundedTex(w,h,0.75)
    
    local m = mesh()
    m:addRect(w/2,h/2,w,h)
    m.texture = tex
    m.shader = shader("Filters:Radial Blur")
    m.shader.sampleDist = 1.0
    m.shader.sampleStrength = 2.2
    
    tex = image(w,h)
    setContext(tex)
    m:draw()
    setContext()
    
    m.texture = tex
    
    tex = image(w,h)
    setContext(tex)
    m:draw()
    setContext()
    
    return tex
end
