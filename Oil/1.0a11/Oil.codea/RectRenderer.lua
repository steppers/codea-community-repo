-- Rect renderer utilising Signed Distance Fields
-- in order to avoid the need for multiple meshes

local blank_image = image(1,1)
blank_image:set(1,1,color(255))

local shader_src = {
    vert = [[
        uniform mat4 modelViewProjection;
        uniform vec2 rectSize;
        uniform vec4 uvScaleOffset;

        attribute vec2 position;
        attribute vec2 texCoord;
        
        varying highp vec2 vUV;
        varying highp vec2 vPos;
        
        void main()
        {
            vPos = rectSize * texCoord;
            vUV = (texCoord * uvScaleOffset.xy) + uvScaleOffset.zw;
            gl_Position = modelViewProjection * vec4(position.xy, 0.0, 1.0);
        }
    ]],
    frag = [[
        precision highp float;
    
        uniform lowp sampler2D texture;
        uniform vec4 fill;
        uniform vec4 stroke;
        uniform float radius;
        uniform vec2 rectSize;
        uniform float strokeWidth;
        uniform bool shadow;
        uniform float shadowWidth;
        uniform float shadowIntensity;
        
        varying highp vec2 vUV;
        varying highp vec2 vPos;
    
        float RectSDF(vec2 p, vec2 b, float r)
        {
            vec2 d = abs(p) - b + vec2(r);
            return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - r;
        }
        
        void main() 
        {
            if (shadow)
            {
                float fDist = RectSDF(vPos-rectSize/2.0, rectSize/2.0, radius + shadowWidth);
                gl_FragColor = vec4(vec3(0.0), smoothstep(0.0, 1.0, (-fDist/(shadowWidth*2.0))) * shadowIntensity);
            }
            else
            {
                float fDist = RectSDF(vPos-rectSize/2.0, rectSize/2.0, radius);
                
                // Not great from an optimisation standpoint I know, but
                // it looks great.
                if (fDist > -0.5)
                {
                    vec4 from = (strokeWidth > 0.0) ? stroke : texture2D(texture, vUV) * fill;
                    gl_FragColor = mix(from, vec4(from.rgb, 0.0), smoothstep(0.0, 1.0, abs(fDist+0.5)));
                }
                else
                {
                    float fBlendAmount = (strokeWidth > 0.0) ? smoothstep(0.0, 1.0, abs(fDist) - strokeWidth/2.0) : 1.0;
                    gl_FragColor = mix(stroke, texture2D(texture, vUV) * fill, fBlendAmount);
                }
            }
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
        if node:get_style("blur_once") and node.state.blur_tex then
            -- Don't update the blur. It's only done once
        else
            node.state.blur_tex = node.state.blur_tex or Oil.BlurTexture(node:get_style("blur_amount"), node:get_style("blur_kernel_size"), node:get_style("blur_downscale"))
            node.state.blur_tex:update(Oil.fb, node.frame)
            node.style.tex = node.state.blur_tex:get()
        end
    elseif node.state.blur_tex then
        -- Ensure the blur textures can be freed
        node.style.tex = nil
        node.state.blur_tex = nil
    end
    
    -- Setup uniforms
    local tex = node:get_style("tex")
    rmesh.shader.texture = tex or blank_image
    rmesh.shader.fill = node:get_style("fill")
    rmesh.shader.stroke = node:get_style("stroke")
    rmesh.shader.strokeWidth = node:get_style("strokeWidth")
    rmesh.shader.radius = node:get_style("radius")
    
    if node:get_style("texAspectFill") and tex then
        local tw,th = spriteSize(tex)
        local tar = tw/th
        local rar = w/h
        if tar > rar then
            tar = rar / tar
            rmesh.shader.uvScaleOffset = vec4(tar, 1, (1.0-tar)/2.0, 0)
        elseif tar < rar then
            tar = tar / rar
            rmesh.shader.uvScaleOffset = vec4(1, tar, 0, (1.0-tar)/2.0)
        else
            rmesh.shader.uvScaleOffset = vec4(1, 1, 0, 0)
        end
    else
        rmesh.shader.uvScaleOffset = vec4(1, 1, 0, 0)
    end
    
    -- Draw shadow
    if node:get_style("shadow") then
        local shadowWidth = node:get_style("shadowWidth")
        rmesh.shader.rectSize = vec2(w + shadowWidth*2, h + shadowWidth*2)
        rmesh.shader.shadow = true
        rmesh.shader.shadowWidth = shadowWidth
        rmesh.shader.shadowIntensity = node:get_style("shadowIntensity")
        pushMatrix()
        translate(-shadowWidth, -shadowWidth)
        scale(w+shadowWidth*2, h+shadowWidth*2)
        rmesh:draw()
        popMatrix()
    end
    
    -- Draw Rect
    rmesh.shader.rectSize = vec2(w, h)
    rmesh.shader.shadow = false
    pushMatrix()
    scale(w, h)
    rmesh:draw()
    popMatrix()
end
