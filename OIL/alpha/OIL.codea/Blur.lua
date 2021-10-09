-- Blur

OIL.BlurTexture = class()

local blur_shader_src = {
    vert = [[
        uniform mat4 modelViewProjection;

        attribute vec2 pos;
        attribute vec2 uv;
    
        varying highp vec2 vUV;
        
        void main()
        {
            vUV = uv;
            gl_Position = modelViewProjection * vec4(pos, 0.0, 1.0);
        }
    ]],
    frag = [[
        precision highp float;

        uniform lowp sampler2D texture;
        uniform vec2 scale;
    
        uniform vec3 kernel[%d];
        uniform vec2 uv_offset;
    
        varying highp vec2 vUV;

        vec4 blur(sampler2D image, vec2 uv) {
            vec4 color = vec4(0.0);
            for (int i = 0; i < %d; ++i) {
                color += texture2D(image, uv + (kernel[i].xy * scale)) * kernel[i].z;
            }
            return color;
        }
        
        void main()
        {
            gl_FragColor = blur(texture, vUV + uv_offset);
        }
    ]],
}

local shaders = {}
local function get_shader(kernel_size)
    if shaders[kernel_size] then -- Get from cache
        return shaders[kernel_size]
    end
    
    -- TODO: Support removal from the cache
    local frag_src = string.format(blur_shader_src.frag, kernel_size, kernel_size)
    shaders[kernel_size] = shader(blur_shader_src.vert, frag_src)
    return shaders[kernel_size]
end

local function gauss(x, sd)
    local a = 1 / (math.sqrt(math.pi * 2) * sd)
    local b = math.exp(-((x*x)/(2*(sd*sd))))
    return a * b
end

local function gauss_dist(size)
    -- Standard deviation
    local sd = size / 3.0
    
    -- Generate our distribution
    local dist = {}
    local acc = 0
    for x = -size, size do
        local g = gauss(x, sd)
        acc = acc + g
        table.insert(dist, g)
    end
    
    -- Normalise
    for i = 1, (1+size*2) do
        dist[i] = dist[i] / acc
    end
    
    return dist
end

local function gauss_kernel(dir, step, size)
    local dist_size = (size // 2)
    local dist = gauss_dist(dist_size)
    
    local kernel = {}
    local step = dir * step
    local c = -step*dist_size
    for i = 1, size do
        local v = vec3(c.x, c.y, dist[i])
        table.insert(kernel, v)
        c = c + step
    end
    
    return kernel
end

function OIL.BlurTexture:init(blur_factor, kernel_size, downscale)
    self.blur_kernel_horz = gauss_kernel(vec2(1.0, 0.0), 0.001 * (blur_factor or 1.0), kernel_size or 16)
    self.blur_kernel_vert = gauss_kernel(vec2(0.0, 1.0), 0.001 * (blur_factor or 1.0), kernel_size or 16)
    self.shader = get_shader(kernel_size or 16)
    self.downscale = downscale or 0.5
    self.textures = {}
    self.mesh = {}
    
    self.tex_w = 0
    self.tex_h = 0
end

function OIL.BlurTexture:update(src_tex, src_frame)
    local src_w, src_h = src_tex.width, src_tex.height
    
    -- Generate new blur textures
    if self.tex_w ~= src_frame.w or self.tex_h ~= src_frame.h or self.src_tex ~= src_tex then
        self.textures[1] = image(src_frame.w * self.downscale, src_frame.h * self.downscale)
        self.textures[2] = image(src_frame.w * self.downscale, src_frame.h * self.downscale)
        
        local l = (-src_frame.w/2) / src_w
        local r = (src_frame.w/2) / src_w
        local b = (-src_frame.h/2) / src_h
        local t = (src_frame.h/2) / src_h
        
        -- Horizontal pass
        self.mesh[1] = mesh()
        self.mesh[1].shader = self.shader
        self.mesh[1]:buffer("pos"):set({
            vec2(0, 0),
            vec2(src_frame.w * self.downscale, 0),
            vec2(src_frame.w * self.downscale, src_frame.h * self.downscale),
            vec2(0, 0),
            vec2(src_frame.w * self.downscale, src_frame.h * self.downscale),
            vec2(0, src_frame.h * self.downscale)
        })
        self.mesh[1]:buffer("uv"):set({
            vec2(l, b),
            vec2(r, b),
            vec2(r, t),
            vec2(l, b),
            vec2(r, t),
            vec2(l, t)
        })
        
        -- Vertical pass
        self.mesh[2] = mesh()
        self.mesh[2].shader = self.shader
        self.mesh[2]:buffer("pos"):set({
            vec2(0, 0),
            vec2(src_frame.w * self.downscale, 0),
            vec2(src_frame.w * self.downscale, src_frame.h * self.downscale),
            vec2(0, 0),
            vec2(src_frame.w * self.downscale, src_frame.h * self.downscale),
            vec2(0, src_frame.h * self.downscale)
        })
        self.mesh[2]:buffer("uv"):set({
            vec2(0, 0),
            vec2(1, 0),
            vec2(1, 1),
            vec2(0, 0),
            vec2(1, 1),
            vec2(0, 1)
        })
            
        -- Save size for quick reference
        self.tex_w = src_frame.w
        self.tex_h = src_frame.h
        
        -- Save texture source
        self.src_tex = src_tex
    end
    
    pushStyle()
    pushMatrix()
    resetMatrix()
    
    -- Textures need to be interpolated
    smooth()
    
    -- Horz pass
    setContext(self.textures[1])
    self.shader.scale = vec2(src_h/src_w, 1.0)
    self.shader.uv_offset = vec2(src_frame.x/src_w, src_frame.y/src_h)
    self.shader.texture = src_tex
    self.shader.kernel = self.blur_kernel_horz
    self.mesh[1]:draw()
    
    -- Vert pass
    setContext(self.textures[2])
    self.shader.scale = vec2(1.0, src_h/src_frame.h)
    self.shader.fill = vec4(fill()) / 255.0
    self.shader.uv_offset = vec2(0, 0)
    self.shader.texture = self.textures[1]
    self.shader.kernel = self.blur_kernel_vert
    self.mesh[2]:draw()
    
    -- Restore framebuffer
    setContext(OIL.fb)
    popMatrix()
    popStyle()
end
    
function OIL.BlurTexture:get()
    return self.textures[2] or nil
end
