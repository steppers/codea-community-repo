-- Texture Generation --
------------------------------------------------------
    
-- Main texture 
function genTexture(w)
    
    local r = 512/w
    local t = image(w, w)
    local sx, sy, L, h, R, G, B
    
    -- define texture colors 
    local t1x, t1y, t1z, t1w
    local t2x, t2y, t2z, t2w
    local t3x, t3y, t3z, t3w
    local tW
    
    t1x = 0
    t1y = 0
    t1z = 1
    t1w = 1
    
    t2x = 0
    t2y = 1
    t2z = 0
    t2w = 1
    
    t3x = 1
    t3y = 1
    t3z = 1
    t3w = 1
    
    local nx, ny, nz
    local col = 0
    
    local min = math.min
    local max = math.max
    local abs = math.abs
    local sqrt = math.sqrt
    
    local rs = r/nPower
    local xrs, zrs
    
    for z=1, w do
        for x=1, w do
            xrs = x*rs
            zrs = z*rs
            h = (128+127*noise(x*rs, z*rs))/255
            -- Get the weight of each texture color type at current height
            
            t1w = min(1, max(0, 1 - abs(h - 0.2)*4))
            t2w = min(1, max(0, 1 - abs(h - 0.5)*4))
            t3w = min(1, max(0, 1 - abs(h - 0.8)*4))
            tW = t1w + t2w + t3w
            
            t1w = t1w/tW
            t2w = t2w/tW
            t3w = t3w/tW
            
            -- Blend the texture colors together
            R = t1x*t1w + t2x*t2w + t3x*t3w
            G = t1y*t1w + t2y*t2w + t3y*t3w
            B = t1z*t1w + t2z*t2w + t3z*t3w
            
            -- Calculate the normal for current pixel
            sx = noise(xrs+rs, zrs) - noise(xrs-rs, zrs)
            sy = noise(xrs, zrs+rs) - noise(xrs, zrs-rs)
            nx = -sx*w
            nz = sy*w
            L = 1/sqrt(nx*nx + 4 + nz*nz)
            nx = nx*L
            ny = 2*L
            nz = nz*L
            
            -- Calculate lightning
            col = 255*min(1,max(0.1, nx*lx + ny + nz*lz)*2)
            
            -- Blend lightning with texture color
            colR = math.floor(col*R)         
            colG = math.floor(col*G)       
            colB = math.floor(col*B)      
            t:set(x, z,colR, colG, colB, 255)
        end
    end
    return t
end
    
-- Wireframe texture
function genWireframe(w)
    local t = image(w, w)
    for y=1, w do
        for x=1, 3 do
            t:set(x, y, 255, 255, 255, 255)
        end
    end
    for x=1, w do
        for y=1, 3 do 
            t:set(x, y, 255, 255, 255, 255)
        end
    end
    for x=2, w-1 do
        t:set(x+1, x, 255, 255, 255, 255)
        t:set(x, x, 255, 255, 255, 255)
        t:set(x-1, x, 255, 255, 255, 255)
    end
    t:set(w, w, 255, 255, 255, 255)
    t:set(w-1, w, 255, 255, 255, 255)
    return t
end
    