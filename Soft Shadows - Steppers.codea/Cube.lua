Cube = class()

function Cube:init(w, h, d, in_color)
    self.mesh = mesh()
    self.mesh:resize(6 * 6) -- 6 sides, 6 verts each
    
    local w2 = w/2
    local h2 = h/2
    local d2 = d/2
    
    local ftl = vec3(-w2, h2, -d2)
    local ftr = vec3(w2, h2, -d2)
    local fbl = vec3(-w2, -h2, -d2)
    local fbr = vec3(w2, -h2, -d2)
    local btl = vec3(-w2, h2, d2)
    local btr = vec3(w2, h2, d2)
    local bbl = vec3(-w2, -h2, d2)
    local bbr = vec3(w2, -h2, d2)
    
    self.mesh.vertices = {
        -- Front
        ftl, fbr, fbl,
        ftl, ftr, fbr,
        
        -- Left
        btl, fbl, bbl,
        btl, ftl, fbl,
        
        -- Right
        ftr, bbr, fbr,
        ftr, btr, bbr,
        
        -- Back
        btr, bbl, bbr,
        btr, btl, bbl,
        
        -- Top
        btl, ftr, ftl,
        btl, btr, ftr,
        
        -- Bottom
        fbl, bbr, bbl,
        fbl, fbr, bbr,
    }
    
    self.mesh:setColors(in_color or color(255))
    
    self.trans = Transform()
end

function Cube:draw(shader_to_use)
    self.trans:setMatrix()
    shader_to_use.model = modelMatrix()
    self.mesh.shader = shader_to_use
    self.mesh:draw()
end
