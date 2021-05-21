local shadow_vs_source = [[
    precision highp float;

    uniform mat4 fixMatrix;
    uniform mat4 model;
    uniform mat4 view;
    uniform mat4 projection;
    
    attribute vec4 position;

    varying float vFragDepth;
    
    void main()
    {
        gl_Position = fixMatrix * (projection * view * model) * position;
    }
]]

local shadow_fs_source = [[
    precision highp float;

    // https://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
    vec4 EncodeFloatRGBA( float v ) {
        vec4 enc = vec4(1.0, 255.0, 65025.0, 16581375.0) * v;
        enc = fract(enc);
        enc -= enc.yzww * vec4(1.0/255.0,1.0/255.0,1.0/255.0,0.0);
        return enc;
    }
    
    void main()
    {
        gl_FragColor = EncodeFloatRGBA(gl_FragCoord.z);
    }
]]

function ShadowMapShader()
    return shader(shadow_vs_source, shadow_fs_source)
end

local render_vs_source = [[
    precision highp float;

    uniform mat4 fixMatrix;
    uniform mat4 model;
    uniform mat4 view;
    uniform mat4 projection;

    uniform mat4 shadowView;
    uniform mat4 shadowProjection;
    
    attribute vec4 position;
    attribute vec4 color;

    varying vec3 vFragPosInShadow;
    varying vec4 vColor;

    const mat4 bias = mat4(
        0.5, 0.0, 0.0, 0.0,
        0.0, 0.5, 0.0, 0.0,
        0.0, 0.0, 0.5, 0.0,
        0.5, 0.5, 0.503, 1.0
    );
    
    void main()
    {
        vColor = color;
        vFragPosInShadow = (bias * fixMatrix * shadowProjection * shadowView * model * position).xyz;

        gl_Position = fixMatrix * projection * view * model * position;
    }
]]

local render_fs_source = [[
    precision highp float;

    uniform lowp sampler2D shadowMap;

    uniform int pass1_samples;// = 32;
    uniform int pass2_samples;// = 128;
    uniform float scale;// = 0.5;
    uniform float intensity;// = 0.9;

    varying vec3 vFragPosInShadow;
    varying vec4 vColor;

    // https://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
    float DecodeFloatRGBA( vec4 rgba ) {
        return dot( rgba, vec4(1.0, 1.0/255.0, 1.0/65025.0, 1.0/16581375.0) );
    }

    // https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
    float Noise(vec2 co)
    {
        return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
    }

    // https://www.gamedev.net/tutorials/programming/graphics/contact-hardening-soft-shadows-made-fast-r4906/
    vec2 VogelDiskSample(int sampleIndex, int samplesCount, float phi)
    {
        float GoldenAngle = 2.4;

        float r = sqrt(float(sampleIndex) + 0.5) / sqrt(float(samplesCount));
        float theta = float(sampleIndex) * GoldenAngle + phi;
        
        float sine = sin(theta);
        float cosine = cos(theta);
        
        return vec2(r * cosine, r * sine);
    }

    void main()
    {
        float noise = Noise(gl_FragCoord.xy);

        float average_occluder_depth = 0.0;
        float occluders = 0.0;
        for (int i = 0; i < pass1_samples; ++i)
        {
            vec2 offset = VogelDiskSample(i, pass1_samples, noise);
            float shadowDepth = DecodeFloatRGBA(texture2D(shadowMap, vFragPosInShadow.xy + offset*0.02));
            if (shadowDepth > vFragPosInShadow.z) {
                occluders += 1.0;
                average_occluder_depth += shadowDepth;
            }
        }
        average_occluder_depth /= occluders;

        float penumbra = (average_occluder_depth - vFragPosInShadow.z) / vFragPosInShadow.z;
        penumbra *= penumbra;
        penumbra = clamp(scale * penumbra, 0.0, 1.0);

        float shadow = 0.0;
        for (int i = 0; i < pass2_samples; ++i)
        {
            vec2 offset = VogelDiskSample(i, pass2_samples, noise);
            float shadowDepth = DecodeFloatRGBA(texture2D(shadowMap, vFragPosInShadow.xy + (offset*penumbra)));
        
            if (shadowDepth > vFragPosInShadow.z)
            {
                shadow += intensity;
            }
        }

        shadow = 1.0 - (shadow / float(pass2_samples));
        
        // Maintain the alpha channel
        gl_FragColor = vec4(vColor.rgb * shadow, vColor.a);
    }
]]

function RenderShader()
return shader(render_vs_source, render_fs_source)
end
