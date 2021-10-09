-- Rect renderer with mesh cache for reuse

local rect_shader_src = {
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
        
        varying highp float vEdge;
        
        void main()
        {
            gl_FragColor = (float(vEdge > 0.0) * stroke) + (float(vEdge == 0.0) * fill);
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
        
        varying highp float vEdge;
        varying highp vec2 vUV;
        
        void main()
        {
            vec4 pixel = texture2D(texture, vUV) * fill;
            gl_FragColor = (float(vEdge > 0.0) * stroke) + (float(vEdge == 0.0) * pixel);
        }
    ]],
}

local rect_shader = shader(rect_shader_src.vert, rect_shader_src.frag)
local rect_shader_tex = shader(rect_shader_src.vert_tex, rect_shader_src.frag_tex)

OIL.RenderComponent.Rect = class(OIL.RenderComponent)
OIL.RenderComponent.Rect.cache = {}

function OIL.RenderComponent.Rect:init(style)
    
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
            
        -- Gen mesh
        local m = self:get_mesh(w, h)
            
        if self.mesh_tex then
            m.shader.texture = self:get_style("tex", true)
        end
        m.shader.fill = self:get_style("fill")
        m.shader.stroke = self:get_style("stroke")
        m:draw() -- Draw the cached mesh
    end, style)
        
    -- Add destructor to deref the mesh in the cache
    local mt = getmetatable(self)
    mt.__gc = function(self)
        self:deref_mesh()
    end
    setmetatable(self, mt)
end

function OIL.RenderComponent.Rect:get_mesh(w, h)
    
    local has_tex = (self:get_style("tex", true) ~= nil)
    
    -- If nothing has changed, use the cached mesh
    if (self.mesh == nil) or
        (self.mesh_w ~= w) or
        (self.mesh_h ~= h) or
        (self.mesh_tex ~= has_tex) or
        (self.mesh_sw ~= self:get_style("strokeWidth")) then
    
        -- Deref old mesh
        self:deref_mesh()
        
        -- Check cache
        self.mesh = self:ref_mesh(w, h, has_tex, self:get_style("strokeWidth"))
        
        -- Update cache values
        self.mesh_w = w
        self.mesh_h = h
        self.mesh_tex = has_tex
        self.mesh_sw = self:get_style("strokeWidth")
        
        -- Cache miss so generate a new mesh
        if not self.mesh then
            self.mesh = mesh()
            if has_tex then
                self.mesh.shader = rect_shader_tex
            else
                self.mesh.shader = rect_shader 
            end
            
            local vert = {}
            local uv = {}
            local function add_vert(v)
                table.insert(vert, v)
                table.insert(uv, vec2(v.x / w, v.y / h))
            end
            
            local function add_rect(l, b, w, h, edge)
                add_vert(vec3(l, b, edge))
                add_vert(vec3(l+w, b, edge))
                add_vert(vec3(l+w, b+h, edge))
                add_vert(vec3(l, b, edge))
                add_vert(vec3(l+w, b+h, edge))
                add_vert(vec3(l, b+h, edge))
            end
            
            local r = self.mesh_sw or 0
            
            -- Add internal square
            add_rect(r, r, w-(2*r), h-(2*r), 0)
            
            -- Border
            add_rect(0, 0, r, h, 1)
            add_rect(0, 0, w, r, 1)
            add_rect(w-r, 0, r, h, 1)
            add_rect(0, h-r, w, r, 1)
            
            self.mesh:buffer("vert"):set(vert)
            
            if has_tex then
                self.mesh:buffer("uv"):set(uv)
            end
            
            -- Cache our new mesh
            self:cache_mesh()
        end
    end
        
    -- Return new mesh
    return self.mesh
end

-- Returns a mesh object if a mesh with the requested
-- attributes exists in the cache or nil if not.
function OIL.RenderComponent.Rect:ref_mesh(w, h, has_tex, strokeWidth)    
    local key = table.concat({
        w,
        h,
        tostring(has_tex),
        strokeWidth
    },",")
    
    local cache_entry = OIL.RenderComponent.Rect.cache[key]
    
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
function OIL.RenderComponent.Rect:deref_mesh()   
    if not self.mesh then return end -- early out
     
    local key = table.concat({
        self.mesh_w,
        self.mesh_h,
        tostring(self.mesh_tex),
        self.mesh_sw
    },",")
    
    -- Assuming if we have a mesh, it's also cached
    local cache_entry = OIL.RenderComponent.Rect.cache[key]
    cache_entry.ref_count = cache_entry.ref_count - 1 -- dec ref count
        
    -- If the ref count hits zero, remove it from the cache
    if cache_entry.ref_count == 0 then
        OIL.RenderComponent.Rect.cache[key] = nil
    end
    
    -- Remove our ref
    self.mesh = nil
end

-- Adds a mesh object to the cache
function OIL.RenderComponent.Rect:cache_mesh()    
    local key = table.concat({
        self.mesh_w,
        self.mesh_h,
        tostring(self.mesh_tex),
        self.mesh_sw
    },",")
    
    -- Add the new cache entry with a ref count of 1
    OIL.RenderComponent.Rect.cache[key] = {
        ref_count = 1,
        mesh = self.mesh
    }
end
