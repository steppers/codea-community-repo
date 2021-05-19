// Created with Shade for iPad
Shader "Shade/Explosion"
{
    Properties
    {
        [NoScaleOffset] _colorMap  ("Color Map", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        ZWrite On
        LOD 200

        CGPROGRAM

        #pragma target 4.0

        // Unlit model
        #pragma surface surf NoLighting vertex:vert noforwardadd addshadow

        fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            fixed4 c;
            c.rgb = s.Albedo + s.Emission.rgb;
            c.a = s.Alpha;
            return c;
        }

        struct Input {
            float2 texcoord : TEXCOORD0;
            float3 worldNormal; 
            float4 color : COLOR;
        };

        sampler2D _colorMap;
        
        float remap(float value, float minA, float maxA, float minB, float maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float2 remap(float2 value, float2 minA, float2 maxA, float2 minB, float2 maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float3 remap(float3 value, float3 minA, float3 maxA, float3 minB, float3 maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float4 remap(float4 value, float4 minA, float4 maxA, float4 minB, float4 maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float2 remap(float2 value, float minA, float maxA, float minB, float maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float3 remap(float3 value, float minA, float maxA, float minB, float maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float4 remap(float4 value, float minA, float maxA, float minB, float maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        
        const float2x2 myt = float2x2(.12121212, .13131313, -.13131313, .12121212);
        const float2 mys = float2(1e4, 1e6);
        
        float2 rhash(float2 uv) {
            uv *= myt;
            uv *= mys;
            return frac(frac(uv / mys) * uv);
        }
        
        float3 hash(float3 p) {
            return frac(sin(float3(dot(p, float3(1.0, 57.0, 113.0)),
            dot(p, float3(57.0, 113.0, 1.0)),
            dot(p, float3(113.0, 1.0, 57.0)))) *
            43758.5453);
        }
        
        
        float3 voronoi3D(const in float3 x)
        {
            float3 p = floor(x);
            float3 f = frac(x);
        
            float id = 0.0;
            float2 res = float2(100.0);
            for (int k = -1; k <= 1; k++) {
                for (int j = -1; j <= 1; j++) {
                    for (int i = -1; i <= 1; i++) {
                        float3 b = float3(float(i), float(j), float(k));
                        float3 r = float3(b) - f + hash(p + b);
                        float d = dot(r, r);
        
                        float cond = max(sign(res.x - d), 0.0);
                        float nCond = 1.0 - cond;
        
                        float cond2 = nCond * max(sign(res.y - d), 0.0);
                        float nCond2 = 1.0 - cond2;
        
                        id = (dot(p + b, float3(1.0, 57.0, 113.0)) * cond) + (id * nCond);
                        res = float2(d, res.x) * cond + res * nCond;
        
                        res.y = cond2 * d + nCond2 * res.y;
                    }
                }
            }
        
            return float3(sqrt(res), abs(id));
        }
        
        
        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.texcoord = v.texcoord;
            float mod_3 = fmod((_Time.y * 0.75), 2.0);
            float min_6 = min(mod_3, 2.5);
            float sqrt_16 = sqrt(min_6);
            float localVar_ExplosionTime = sqrt_16;
            float remap_23 = remap(localVar_ExplosionTime, float2(0.0, 1.0).x, float2(0.0, 1.0).y, float2(0.5, 1.3).x, float2(0.5, 1.3).y);
            float3 multiply_26 = (v.normal * remap_23);
            float multiply_21 = (localVar_ExplosionTime * 4.0);
            float3 voronoi3d_27 = voronoi3D((multiply_26+float3(0.0, multiply_21, 0.0)));
            float3 split_28 = voronoi3d_27;
            float oneminus_29 = (1.0 - split_28.r);
            float sqrt_31 = sqrt(oneminus_29);
            float3 normalize_13 = normalize(normalize( mul( float4( v.normal, 0.0 ), unity_ObjectToWorld ).xyz ));
            float3 multiply_35 = (sqrt_31 * normalize_13);
            float remap_24 = remap(localVar_ExplosionTime, float2(0.0, 1.0).x, float2(0.0, 1.0).y, float2(-2.0, 6.0).x, float2(-2.0, 6.0).y);
            float3 multiply_36 = (multiply_35 * remap_24);
            float3 multiply_20 = (normalize_13 * localVar_ExplosionTime);
            float3 multiply_22 = (multiply_20 * (v.texcoord.y*3.0));
            v.vertex.xyz += (multiply_36+multiply_22);
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            float mod_3 = fmod((_Time.y * 0.75), 2.0);
            float min_6 = min(mod_3, 2.5);
            float sqrt_16 = sqrt(min_6);
            float localVar_ExplosionTime = sqrt_16;
            float oneminus_25 = (1.0 - localVar_ExplosionTime);
            float remap_23 = remap(localVar_ExplosionTime, float2(0.0, 1.0).x, float2(0.0, 1.0).y, float2(0.5, 1.3).x, float2(0.5, 1.3).y);
            float3 multiply_26 = (normalize( mul( float4(normalize(IN.worldNormal) , 0.0 ), unity_WorldToObject ).xyz ) * remap_23);
            float multiply_21 = (localVar_ExplosionTime * 4.0);
            float3 voronoi3d_27 = voronoi3D((multiply_26+float3(0.0, multiply_21, 0.0)));
            float3 split_28 = voronoi3d_27;
            float multiply_30 = (oneminus_25 * split_28.r);
            float4 temp_ColorMap = /* TEXTURE2D NOT IMPLEMENTED */;
            float3 subtract_34 = (temp_ColorMap.rgb - 0.5);
            float3 clamp01_37 = clamp(subtract_34, 0.0, 1.0);
            o.Emission = clamp01_37;
            o.Albedo = temp_ColorMap.rgb;
            float oneminus_29 = (1.0 - split_28.r);
            float multiply_32 = (oneminus_29 * 1.0);
            o.Alpha = multiply_32;
        }
        ENDCG
    }
}
