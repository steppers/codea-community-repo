-- Rect renderer utilising Signed Distance Fields
-- in order to avoid the need for multiple meshes

local blank_image = image(1,1)
blank_image:set(1,1,color(255))

local shader_src = {
    vert = [[
        uniform mat4 modelViewProjection;

        attribute vec2 position;
        attribute vec2 texCoord;
        
        varying highp vec2 vUV;
        
        void main()
        {
            vUV = texCoord;
            gl_Position = modelViewProjection * vec4(position.xy, 0.0, 1.0);
        }
    ]],
    frag = [[
        precision highp float;
    
        uniform lowp sampler2D texture;
        uniform vec2 rectSize;
        uniform vec4 fill;
        uniform vec4 stroke;
        uniform float radius;
        uniform float strokeWidth;
        
        varying highp vec2 vUV;
    
        float RectSDF(vec2 p, vec2 b, float r)
        {
            vec2 d = abs(p) - b + vec2(r);
            return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - r;
        }
        
        void main() 
        {
            vec2 pos = rectSize * vUV;
            
            float fDist = RectSDF(pos-rectSize/2.0, rectSize/2.0, radius);
            float fBlendAmount = (strokeWidth > 0.0) ? smoothstep(0.0, 1.0, abs(fDist) - strokeWidth / 2.0) : 1.0;
        
            gl_FragColor = (fDist > 0.0) ? vec4(0.0) : mix(stroke, texture2D(texture, vUV) * fill, fBlendAmount);
        }
    ]],
}

local coords = {
    vec2(0, 0),
    vec2(1, 0),
    vec2(1, 1),
    vec2(0, 0),
    vec2(1, 1),
    vec2(0, 1),
}
local rmesh = mesh()
rmesh.vertices = coords
rmesh.texCoords = coords
rmesh.shader = shader(shader_src.vert, shader_src.frag)

function Oil.RectRenderer(node, w, h)
    -- Do blur effect
    if node:get_style("blur") then
        node.state.blur_tex = node.state.blur_tex or Oil.BlurTexture(node:get_style("blur_amount"), node:get_style("blur_kernel_size"), node:get_style("blur_downscale"))
        node.state.blur_tex:update(Oil.fb, node.frame)
        node.style.tex = node.state.blur_tex:get()
    elseif node.state.blur_tex then
        -- Ensure the blur textures can be freed
        node.style.tex = nil
        node.state.blur_tex = nil
    end
        
    -- Setup uniforms
    rmesh.shader.rectSize = vec2(w, h)
    rmesh.shader.texture = node:get_style("tex") or blank_image
    rmesh.shader.fill = node:get_style("fill")
    rmesh.shader.stroke = node:get_style("stroke")
    rmesh.shader.strokeWidth = node:get_style("strokeWidth")
    rmesh.shader.radius = node:get_style("radius")
        
    -- Draw
    pushMatrix()
    scale(w, h)
    rmesh:draw()
    popMatrix()
end
