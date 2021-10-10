-- Rounded Rect renderer with mesh cache for reuse

local rrect_shader_src = {
    vert = [[
        uniform mat4 modelViewProjection;

        attribute vec3 vert;
        
        varying highp float vEdge;
        
        void main()
        {
            vEdge = vert.z;
            gl_Position = modelViewProjection * vec4(vert.xy, 0.0, 1.0);
        }
    ]],
    frag = [[
        precision highp float;

        uniform vec4 fill;
        uniform vec4 stroke;
        uniform float strokeWidth;
        uniform float radius;
        
        varying highp float vEdge;
        
        void main()
        {
            float threshold = 1.0 - (strokeWidth / radius);
            gl_FragColor = (float(vEdge >= threshold) * stroke) + (float(vEdge < threshold) * fill);
        }
    ]],
    vert_tex = [[
        uniform mat4 modelViewProjection;

        attribute vec3 vert;
        attribute vec2 uv;
        
        varying highp float vEdge;
        varying highp vec2 vUV;
        
        void main()
        {
            vEdge = vert.z;
            vUV = uv;
            gl_Position = modelViewProjection * vec4(vert.xy, 0.0, 1.0);
        }
    ]],
    frag_tex = [[
        precision highp float;
    
        uniform lowp sampler2D texture;

        uniform vec4 fill;
        uniform vec4 stroke;
        uniform float strokeWidth;
        uniform float radius;
        
        varying highp float vEdge;
        varying highp vec2 vUV;
        
        void main()
        {
            vec4 pixel = texture2D(texture, vUV) * fill;
            float threshold = 1.0 - (strokeWidth / radius);
            gl_FragColor = (float(vEdge > threshold) * stroke) + (float(vEdge <= threshold) * pixel);
        }
    ]],
}

local rrect_shader = shader(rrect_shader_src.vert, rrect_shader_src.frag)
local rrect_shader_tex = shader(rrect_shader_src.vert_tex, rrect_shader_src.frag_tex)

OIL.RenderComponent.RoundedRect = class(OIL.RenderComponent)
OIL.RenderComponent.RoundedRect.cache = {}

function OIL.RenderComponent.RoundedRect:init(style)
    
    -- Render func
    OIL.RenderComponent.init(self, function(self, w, h)
        -- Do blur effect
        if self:get_style("blur") then
            self.blur_tex = self.blur_tex or OIL.BlurTexture(self:get_style("blur_amount"), self:get_style("blur_kernel_size"), self:get_style("blur_downscale"))
            self.blur_tex:update(OIL.fb, self.owner.frame)
            self.style.tex = self.blur_tex:get()
        elseif self.blur_tex then
            -- Ensure the blur textures can be freed
            self.style.tex = nil
            self.blur_tex = nil
        end
        
        local m = self:get_mesh(w, h)
        if self.mesh_tex then
            m.shader.texture = self:get_style("tex", true)
        else
            m.shader.texture = nil
        end
        m.shader.fill = self:get_style("fill")
        m.shader.stroke = self:get_style("stroke")
        m.shader.strokeWidth = self:get_style("strokeWidth")
        m.shader.radius = self:get_style("radius")
        m:draw() -- Draw the cached mesh
    end, style)
        
    -- Add destructor to deref the mesh in the cache
    local mt = getmetatable(self)
    mt.__gc = function(self)
        self:deref_mesh()
    end
    setmetatable(self, mt)
end

function OIL.RenderComponent.RoundedRect:get_mesh(w, h)
    
    local has_tex = (self:get_style("tex", true) ~= nil)
    
    -- If nothing has changed, use the cached mesh
    if (self.mesh == nil) or
        (self.mesh_w ~= w) or
        (self.mesh_h ~= h) or
        (self.mesh_tex ~= has_tex) or
        (self.mesh_r ~= self:get_style("radius")) then
    
        -- Deref old mesh
        self:deref_mesh()
        
        -- Check cache
        self.mesh = self:ref_mesh(w, h, self:get_style("radius"), has_tex)
        
        -- Update cache values
        self.mesh_w = w
        self.mesh_h = h
        self.mesh_r = self:get_style("radius")
        self.mesh_tex = has_tex
        
        -- Cache miss so generate a new mesh
        if not self.mesh then
            local r = self.mesh_r
            
            self.mesh = mesh()
            if has_tex then
                self.mesh.shader = rrect_shader_tex
            else
                self.mesh.shader = rrect_shader 
            end
            
            -- Calculate number of corner segments & total vertices
            local segs = math.min(math.max(8, r // 4), 18)
            local vert_count = (6*5) + (segs * 3 * 4)
            
            -- Resize vertex buffer
            local vert = self.mesh:buffer("vert")
            vert:resize(vert_count)
            
            -- Add vert helper function
            local vert_i = 1
            local add_vert = function(v)
                vert[vert_i] = v
                vert_i = vert_i + 1
            end
            
            if has_tex then
                -- Resize UV buffer
                local uv = self.mesh:buffer("uv")
                uv:resize(vert_count)
                
                -- Override func
                add_vert = function(v)
                    vert[vert_i] = v
                    uv[vert_i] = vec2(v.x / w, v.y / h)
                    vert_i = vert_i + 1
                end
            end
            
            -- Add internal square
            add_vert(vec3(r, r, 0))
            add_vert(vec3(w-r, r, 0))
            add_vert(vec3(w-r, h-r, 0))
            add_vert(vec3(r, r, 0))
            add_vert(vec3(w-r, h-r, 0))
            add_vert(vec3(r, h-r, 0))
            
            -- Left edge
            add_vert(vec3(0, r, 1))
            add_vert(vec3(r, r, 0))
            add_vert(vec3(r, h-r, 0))
            add_vert(vec3(0, r, 1))
            add_vert(vec3(r, h-r, 0))
            add_vert(vec3(0, h-r, 1))
            
            -- Right edge
            add_vert(vec3(w-r, r, 0))
            add_vert(vec3(w, r, 1))
            add_vert(vec3(w, h-r, 1))
            add_vert(vec3(w-r, r, 0))
            add_vert(vec3(w, h-r, 1))
            add_vert(vec3(w-r, h-r, 0))
            
            -- Top edge
            add_vert(vec3(r, h-r, 0))
            add_vert(vec3(w-r, h-r, 0))
            add_vert(vec3(w-r, h, 1))
            add_vert(vec3(r, h-r, 0))
            add_vert(vec3(w-r, h, 1))
            add_vert(vec3(r, h, 1))
            
            -- Bottom edge
            add_vert(vec3(r, 0, 1))
            add_vert(vec3(w-r, 0, 1))
            add_vert(vec3(w-r, r, 0))
            add_vert(vec3(r, 0, 1))
            add_vert(vec3(w-r, r, 0))
            add_vert(vec3(r, r, 0))
            
            -- Corners
            -- TODO: Figure out why high radius values are causing Codea to crash...
            local function corner(id, root, last)
                for i = 1, segs do
                    local rad = math.rad((id + (i / segs)) * 90)
                    add_vert(root)
                    local current = root + vec3(math.sin(rad) * r, math.cos(rad) * r, 1)
                    add_vert(current)
                    add_vert(last)
                    last = current
                end
            end
            
            -- Top Right corner
            corner(0, vec3(w-r, h-r, 0), vec3(w-r, h, 1))
            
            -- Bottom Right corner
            corner(1, vec3(w-r, r, 0), vec3(w, r, 1))
            
            -- Bottom Left corner
            corner(2, vec3(r, r, 0), vec3(r, 0, 1))
            
            -- Top Left corner
            corner(3, vec3(r, h-r, 0), vec3(0, h-r, 1))
            
            -- Cache our new mesh
            self:cache_mesh()
        end
    end
        
    -- Return new mesh
    return self.mesh
end

-- Returns a mesh object if a mesh with the requested
-- attributes exists in the cache or nil if not.
function OIL.RenderComponent.RoundedRect:ref_mesh(w, h, radius, has_tex)    
    local key = table.concat({
        w,
        h,
        radius,
        tostring(has_tex)
    },",")
    
    local cache_entry = OIL.RenderComponent.RoundedRect.cache[key]
    
    -- Check for cache hit
    if cache_entry then
        cache_entry.ref_count = cache_entry.ref_count + 1 -- add to ref count
        return cache_entry.mesh
    end
    
    -- Cache miss
    return nil
end

-- Dereferences the current mesh if one is set so the garbage collector
-- can clean up the resource
function OIL.RenderComponent.RoundedRect:deref_mesh()   
    if not self.mesh then return end -- early out
     
    local key = table.concat({
        self.mesh_w,
        self.mesh_h,
        self.mesh_r,
        tostring(self.mesh_tex)
    },",")
    
    -- Assuming if we have a mesh, it's also cached
    local cache_entry = OIL.RenderComponent.RoundedRect.cache[key]
    cache_entry.ref_count = cache_entry.ref_count - 1 -- dec ref count
        
    -- If the ref count hits zero, remove it from the cache
    if cache_entry.ref_count == 0 then
        OIL.RenderComponent.RoundedRect.cache[key] = nil
    end
    
    -- Remove our ref
    self.mesh = nil
end

-- Adds a mesh object to the cache
function OIL.RenderComponent.RoundedRect:cache_mesh()    
    local key = table.concat({
        self.mesh_w,
        self.mesh_h,
        self.mesh_r,
        tostring(self.mesh_tex)
    },",")
    
    -- Add the new cache entry with a ref count of 1
    OIL.RenderComponent.RoundedRect.cache[key] = {
        ref_count = 1,
        mesh = self.mesh
    }
end
