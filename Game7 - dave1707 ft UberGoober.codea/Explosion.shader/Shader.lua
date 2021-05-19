{
    name = "Explosion",

    options =
    {
        USE_COLOR = { true },
        SELECTION_MODE = { true },
    },

    properties =
    {
        _time = { "float", "0.0" },
        _colorMap = { "texture2D", "Color Map", { mipmap = false, repeats = false } },
        _clipGradient = { "texture2D", "Clip Gradient", { mipmap = false, repeats = false } },
    },

    pass =
    {
        base = "Surface",

        blendMode = "disabled",
        depthWrite = true,
        depthFunc = "lessEqual",
        renderQueue = "solid",
        colorMask = {"rgba"},
        cullFace = "back",

        vertex =
        [[
            uniform float _time;
            out vec3 vNormal;

            

            float remap(float value, float minA, float maxA, float minB, float maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec2 remap(vec2 value, vec2 minA, vec2 maxA, vec2 minB, vec2 maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec3 remap(vec3 value, vec3 minA, vec3 maxA, vec3 minB, vec3 maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec4 remap(vec4 value, vec4 minA, vec4 maxA, vec4 minB, vec4 maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec2 remap(vec2 value, float minA, float maxA, float minB, float maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec3 remap(vec3 value, float minA, float maxA, float minB, float maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec4 remap(vec4 value, float minA, float maxA, float minB, float maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            

            const mat2 myt = mat2(.12121212, .13131313, -.13131313, .12121212);

            const vec2 mys = vec2(1e4, 1e6);

            

            vec2 rhash(vec2 uv) {

                uv *= myt;

                uv *= mys;

                return fract(fract(uv / mys) * uv);

            }

            

            vec3 hash(vec3 p) {

                return fract(sin(vec3(dot(p, vec3(1.0, 57.0, 113.0)),

                dot(p, vec3(57.0, 113.0, 1.0)),

                dot(p, vec3(113.0, 1.0, 57.0)))) *

                43758.5453);

            }

            

            

            vec3 voronoi3D(const in vec3 x)

            {

                vec3 p = floor(x);

                vec3 f = fract(x);

            

                float id = 0.0;

                vec2 res = vec2(100.0);

                for (int k = -1; k <= 1; k++) {

                    for (int j = -1; j <= 1; j++) {

                        for (int i = -1; i <= 1; i++) {

                            vec3 b = vec3(float(i), float(j), float(k));

                            vec3 r = vec3(b) - f + hash(p + b);

                            float d = dot(r, r);

            

                            float cond = max(sign(res.x - d), 0.0);

                            float nCond = 1.0 - cond;

            

                            float cond2 = nCond * max(sign(res.y - d), 0.0);

                            float nCond2 = 1.0 - cond2;

            

                            id = (dot(p + b, vec3(1.0, 57.0, 113.0)) * cond) + (id * nCond);

                            res = vec2(d, res.x) * cond + res * nCond;

            

                            res.y = cond2 * d + nCond2 * res.y;

                        }

                    }

                }

            

                return vec3(sqrt(res), abs(id));

            }

            

            
            void vertex(inout Vertex v, out Input o)
            {
                vec3 original = v.position;
                {
                        float mod_3 = mod((_time * 0.75), 2.0);
                        float min_6 = min(mod_3, 2.5);
                        float sqrt_16 = sqrt(min_6);
                        float localVar_ExplosionTime = sqrt_16;
                        float remap_23 = remap(localVar_ExplosionTime, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y, vec2(0.5, 1.3).x, vec2(0.5, 1.3).y);
                        vec3 multiply_26 = (v.normal * remap_23);
                        float multiply_21 = (localVar_ExplosionTime * 4.0);
                        vec3 voronoi3d_27 = voronoi3D((multiply_26+vec3(0.0, multiply_21, 0.0)));
                        vec3 split_28 = voronoi3d_27;
                        float oneminus_29 = (1.0 - split_28.r);
                        float sqrt_31 = sqrt(oneminus_29);
                        vec3 normalize_13 = normalize((modelMatrix * vec4(v.normal, 0.0)).xyz);
                        vec3 multiply_35 = (sqrt_31 * normalize_13);
                        float remap_24 = remap(localVar_ExplosionTime, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y, vec2(-2.0, 6.0).x, vec2(-2.0, 6.0).y);
                        vec3 multiply_36 = (multiply_35 * remap_24);
                        vec3 multiply_20 = (normalize_13 * localVar_ExplosionTime);
                        vec3 multiply_22 = (multiply_20 * (v.uv.y*3.0));
                        v.position += (multiply_36+multiply_22);
                        vNormal = normal;
                }
                vec3 newPosition = v.position;
                vec3 position = original + tangent.xyz * 0.01;
                v.position = position;
                {
                        float mod_3 = mod((_time * 0.75), 2.0);
                        float min_6 = min(mod_3, 2.5);
                        float sqrt_16 = sqrt(min_6);
                        float localVar_ExplosionTime = sqrt_16;
                        float remap_23 = remap(localVar_ExplosionTime, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y, vec2(0.5, 1.3).x, vec2(0.5, 1.3).y);
                        vec3 multiply_26 = (v.normal * remap_23);
                        float multiply_21 = (localVar_ExplosionTime * 4.0);
                        vec3 voronoi3d_27 = voronoi3D((multiply_26+vec3(0.0, multiply_21, 0.0)));
                        vec3 split_28 = voronoi3d_27;
                        float oneminus_29 = (1.0 - split_28.r);
                        float sqrt_31 = sqrt(oneminus_29);
                        vec3 normalize_13 = normalize((modelMatrix * vec4(v.normal, 0.0)).xyz);
                        vec3 multiply_35 = (sqrt_31 * normalize_13);
                        float remap_24 = remap(localVar_ExplosionTime, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y, vec2(-2.0, 6.0).x, vec2(-2.0, 6.0).y);
                        vec3 multiply_36 = (multiply_35 * remap_24);
                        vec3 multiply_20 = (normalize_13 * localVar_ExplosionTime);
                        vec3 multiply_22 = (multiply_20 * (v.uv.y*3.0));
                        v.position += (multiply_36+multiply_22);
                        vNormal = normal;
                }
                vec3 positionAndTangent = v.position;
                vec3 bitangent = cross(normal, tangent.xyz); //* tangent.w;
                position = original + bitangent * 0.01;
                v.position = position;
                {
                        float mod_3 = mod((_time * 0.75), 2.0);
                        float min_6 = min(mod_3, 2.5);
                        float sqrt_16 = sqrt(min_6);
                        float localVar_ExplosionTime = sqrt_16;
                        float remap_23 = remap(localVar_ExplosionTime, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y, vec2(0.5, 1.3).x, vec2(0.5, 1.3).y);
                        vec3 multiply_26 = (v.normal * remap_23);
                        float multiply_21 = (localVar_ExplosionTime * 4.0);
                        vec3 voronoi3d_27 = voronoi3D((multiply_26+vec3(0.0, multiply_21, 0.0)));
                        vec3 split_28 = voronoi3d_27;
                        float oneminus_29 = (1.0 - split_28.r);
                        float sqrt_31 = sqrt(oneminus_29);
                        vec3 normalize_13 = normalize((modelMatrix * vec4(v.normal, 0.0)).xyz);
                        vec3 multiply_35 = (sqrt_31 * normalize_13);
                        float remap_24 = remap(localVar_ExplosionTime, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y, vec2(-2.0, 6.0).x, vec2(-2.0, 6.0).y);
                        vec3 multiply_36 = (multiply_35 * remap_24);
                        vec3 multiply_20 = (normalize_13 * localVar_ExplosionTime);
                        vec3 multiply_22 = (multiply_20 * (v.uv.y*3.0));
                        v.position += (multiply_36+multiply_22);
                        vNormal = normal;
                }
                vec3 positionAndBitangent = v.position;
                v.position = newPosition;

                vec3 newTangent = ( positionAndTangent - newPosition ); // leaves just 'tangent'
                vec3 newBitangent = ( positionAndBitangent - newPosition ); // leaves just 'bitangent'
                v.position = newPosition;
                v.normal = normalize(cross(newTangent, newBitangent));
            }
        ]],

        surface =
        [[
            uniform float _time;
            in vec3 vNormal;
            uniform mediump sampler2D _colorMap;
            uniform mediump sampler2D _clipGradient;
            
            float remap(float value, float minA, float maxA, float minB, float maxB)
            {
                return minB + (value - minA) * (maxB - minB) / (maxA - minA);
            }
            
            vec2 remap(vec2 value, vec2 minA, vec2 maxA, vec2 minB, vec2 maxB)
            {
                return minB + (value - minA) * (maxB - minB) / (maxA - minA);
            }
            
            vec3 remap(vec3 value, vec3 minA, vec3 maxA, vec3 minB, vec3 maxB)
            {
                return minB + (value - minA) * (maxB - minB) / (maxA - minA);
            }
            
            vec4 remap(vec4 value, vec4 minA, vec4 maxA, vec4 minB, vec4 maxB)
            {
                return minB + (value - minA) * (maxB - minB) / (maxA - minA);
            }
            
            vec2 remap(vec2 value, float minA, float maxA, float minB, float maxB)
            {
                return minB + (value - minA) * (maxB - minB) / (maxA - minA);
            }
            
            vec3 remap(vec3 value, float minA, float maxA, float minB, float maxB)
            {
                return minB + (value - minA) * (maxB - minB) / (maxA - minA);
            }
            
            vec4 remap(vec4 value, float minA, float maxA, float minB, float maxB)
            {
                return minB + (value - minA) * (maxB - minB) / (maxA - minA);
            }
            
            
            const mat2 myt = mat2(.12121212, .13131313, -.13131313, .12121212);
            const vec2 mys = vec2(1e4, 1e6);
            
            vec2 rhash(vec2 uv) {
                uv *= myt;
                uv *= mys;
                return fract(fract(uv / mys) * uv);
            }
            
            vec3 hash(vec3 p) {
                return fract(sin(vec3(dot(p, vec3(1.0, 57.0, 113.0)),
                dot(p, vec3(57.0, 113.0, 1.0)),
                dot(p, vec3(113.0, 1.0, 57.0)))) *
                43758.5453);
            }
            
            
            vec3 voronoi3D(const in vec3 x)
            {
                vec3 p = floor(x);
                vec3 f = fract(x);
            
                float id = 0.0;
                vec2 res = vec2(100.0);
                for (int k = -1; k <= 1; k++) {
                    for (int j = -1; j <= 1; j++) {
                        for (int i = -1; i <= 1; i++) {
                            vec3 b = vec3(float(i), float(j), float(k));
                            vec3 r = vec3(b) - f + hash(p + b);
                            float d = dot(r, r);
            
                            float cond = max(sign(res.x - d), 0.0);
                            float nCond = 1.0 - cond;
            
                            float cond2 = nCond * max(sign(res.y - d), 0.0);
                            float nCond2 = 1.0 - cond2;
            
                            id = (dot(p + b, vec3(1.0, 57.0, 113.0)) * cond) + (id * nCond);
                            res = vec2(d, res.x) * cond + res * nCond;
            
                            res.y = cond2 * d + nCond2 * res.y;
                        }
                    }
                }
            
                return vec3(sqrt(res), abs(id));
            }
            
            
            void surface(in Input IN, inout SurfaceOutput o)
            {
                o.emissive = 1.0;
                float mod_3 = mod((_time * 0.75), 2.0);
                float min_6 = min(mod_3, 2.5);
                float sqrt_16 = sqrt(min_6);
                float localVar_ExplosionTime = sqrt_16;
                float oneminus_25 = (1.0 - localVar_ExplosionTime);
                float remap_23 = remap(localVar_ExplosionTime, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y, vec2(0.5, 1.3).x, vec2(0.5, 1.3).y);
                vec3 multiply_26 = (normalize(vNormal) * remap_23);
                float multiply_21 = (localVar_ExplosionTime * 4.0);
                vec3 voronoi3d_27 = voronoi3D((multiply_26+vec3(0.0, multiply_21, 0.0)));
                vec3 split_28 = voronoi3d_27;
                float multiply_30 = (oneminus_25 * split_28.r);
                vec4 temp_ColorMap = texture(_colorMap, vec2((localVar_ExplosionTime-multiply_30), 0.0));
                o.diffuse = temp_ColorMap.rgb;
                vec3 subtract_34 = (temp_ColorMap.rgb - 0.5);
                vec3 clamp01_37 = clamp(subtract_34, 0.0, 1.0);
                o.emission = clamp01_37;
                float oneminus_29 = (1.0 - split_28.r);
                float multiply_32 = (oneminus_29 * 1.0);
                o.opacity = multiply_32;
                if (o.opacity < texture(_clipGradient, vec2(localVar_ExplosionTime, 0.0)).rgb.r) discard;
            }
        ]]
    }
}
