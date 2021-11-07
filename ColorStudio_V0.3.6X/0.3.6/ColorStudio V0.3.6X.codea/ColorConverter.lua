ColorConverter = class()

function ColorConverter:rgb2hsb(c)
    
    c = c/255.0
    
    local cmax = math.max(math.max(c.x, c.y), c.z)
    local cmin = math.min(math.min(c.x, c.y), c.z)
    local delta = cmax-cmin
    
    local hue = 0.0
    if delta == 0.0 then
        hue = 0.0
    elseif cmax == c.x then
        hue = math.fmod((c.y-c.z)/delta, 6.0)
    elseif cmax == c.y then
        hue = (c.z-c.x)/delta+2.0
    elseif cmax == c.z then
        hue = (c.x-c.y)/delta+4.0
    end
    hue = hue * 60
    
    if hue < 0 then
        hue = 300+(60+hue)
    end
    
    local saturation = 1.0
    if cmax == 0.0 then
        saturation = 0.0
    else
        saturation = delta/cmax
    end
    
    local value = cmax;
    
    return vec3(hue, saturation * 100.0, value * 100.0)
    
end

function ColorConverter:hsb2rgb(c)
    
    c = vec3(Math:clamp(math.fmod(c.x, 360.0), 0.0, 360.0), Math:clamp(c.y/100.0, 0.0, 1.0), Math:clamp(c.z/100.0, 0.0, 1.0))
    
    local H = c.x
    local S = c.y
    local V = c.z
    
    local C = V * S
    local X = C * (1.0-math.abs(math.fmod(H/60.0, 2.0)-1.0))
    local m = V-C
    
    local rgb = vec3(0.0, 0.0, 0.0)
    
    if 0.0 <= H and H < 60.0 then
        rgb = vec3(C, X, 0.0)
    elseif 60.0 <= H and H < 120.0 then
        rgb = vec3(X, C, 0.0)
    elseif 120.0 <= H and H < 180.0 then
        rgb = vec3(0.0, C, X)
    elseif 180.0 <= H and H < 240.0 then
        rgb = vec3(0.0, X, C)
    elseif 240.0 <= H and H < 300.0 then
        rgb = vec3(X, 0.0, C)
    elseif 300.0 <= H and H < 360.0 then
        rgb = vec3(C, 0.0, X)
    end
    
    return (rgb + vec3(m, m, m)) * 255.0;
    
end