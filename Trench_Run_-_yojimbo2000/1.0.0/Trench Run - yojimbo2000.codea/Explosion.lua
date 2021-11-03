Explosion = class()

function Explosion:init(t)
    self.pos = t.pos
    local range = 6
    sound("Game Sounds One:Explode 1")
    --plasma effect
  --  self.sloMo=t.sloMo or 1
 --   if self.sloMo > 1 then self.mesh = Explosion.mesh2 else self.mesh = Explosion.mesh end
    self.explOff=math.random(5000)
    self.time=0
    self.offset = 0.4 --/self.sloMo
    self.rad=range*0.05 --0.38
    self.radius = range --used to calculate light position
    self.tween = tween(3,self,{time=4.8}, tween.easing.cubicOut, function() self.kill=true end) --, 1.8, 4.8loop=tween.loop.pingpong cubicOut
    table.insert( meshes, 1, self)
end

function Explosion:update()
   -- if lights[self] then lights[self]:update() end
end

function Explosion:collisions()
    
end

function Explosion:draw()
  pushMatrix()
--blendMode(ONE, ONE_MINUS_SRC_ALPHA) --for use with premultiplied alpha
blendMode(ADDITIVE)
   translate(self.pos.x,self.pos.y,self.pos.z)
    scale(self.rad+(self.time*self.rad * 4))
    self.mesh.shader.push=self.time*0.19 --0.185
   self.mesh.shader.offset=self.offset*ElapsedTime+self.explOff    
    self.mesh:draw()
blendMode(NORMAL)
    popMatrix()
end

function explosionAssets()
     ExplosionShader = shader([[
    //
    // A basic vertex shader
    //
    
    //This is the current model * view * projection matrix
    // Codea sets it automatically
    uniform mat4 modelViewProjection;
    
    //This is the current mesh vertex position, color and tex coord
    // Set automatically
    attribute vec4 position;
    
    uniform float offset;
    
    /// GLSL textureless classic 3D noise "cnoise",
    // with an RSL-style periodic variant "pnoise".
    // Author:  Stefan Gustavson (stefan.gustavson@liu.se)
    // Version: 2011-10-11
    //
    // Many thanks to Ian McEwan of Ashima Arts for th ideas for permutation and gradient selection.
    //
    // Copyright (c) 2011 Stefan Gustavson. All rights reserved.
    // Distributed under the MIT license. See LICENSE file.
    // https://github.com/ashima/webgl-noise
    //
    
    vec3 mod289(vec3 x)
    {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    
    vec4 mod289(vec4 x)
    {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    
    vec4 permute(vec4 x)
    {
    return mod289(((x*34.0)+1.0)*x);
    }
    
    vec4 taylorInvSqrt(vec4 r)
    {
    return 1.79284291400159 - 0.85373472095314 * r;
    }
    
    vec3 fade(vec3 t) {
    return t*t*t*(t*(t*6.0-15.0)+10.0);
    }
    
    // Classic Perlin noise, periodic variant
    float pnoise(vec3 P, vec3 rep)
    {
    vec3 Pi0 = mod(floor(P), rep); // Integer part, modulo period
    vec3 Pi1 = mod(Pi0 + vec3(1.0), rep); // Integer part + 1, mod period
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    vec3 Pf0 = fract(P); // Fractional part for interpolation
    vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
    vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    vec4 iy = vec4(Pi0.yy, Pi1.yy);
    vec4 iz0 = Pi0.zzzz;
    vec4 iz1 = Pi1.zzzz;
    
    vec4 ixy = permute(permute(ix) + iy);
    vec4 ixy0 = permute(ixy + iz0);
    vec4 ixy1 = permute(ixy + iz1);
    
    vec4 gx0 = ixy0 * (1.0 / 7.0);
    vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
    gx0 = fract(gx0);
    vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
    vec4 sz0 = step(gz0, vec4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);
    
    vec4 gx1 = ixy1 * (1.0 / 7.0);
    vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
    gx1 = fract(gx1);
    vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
    vec4 sz1 = step(gz1, vec4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);
    
    vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
    vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
    vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
    vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
    vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
    vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
    vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
    vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);
    
    vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;
    
    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);
    
    vec3 fade_xyz = fade(Pf0);
    vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
    vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
    return 2.2 * n_xyz;
    }
    
    varying float noise;
    
    float turbulence( vec3 p ) {
        float w = 100.0;
        float t = -.5;
        for (float f = 1.0 ; f <= 10.0 ; f++ ){
            float power = pow( 2.0, f );
            t += abs( pnoise( vec3( power * p ), vec3( 10.0, 10.0, 10.0 ) ) / power );
        }
        return t;
    }
    
    void main() {
    
        // get a turbulent 3d noise using the normal, normal to high freq
        noise = -1.0 * turbulence( 0.5 * position.xyz + offset );
        // get a 3d noise using the position, low frequency
        float b = 5.0 * pnoise( 1.3 * (position.xyz) + vec3( 2.0 * offset ), vec3( 100.0 ) );
        // compose both noises
        float displacement = -10. * noise + b;
        
        vec3 newPosition = position.xyz + ((position.xyz * displacement) / 20.0);
        gl_Position = modelViewProjection * vec4( newPosition, 1.0 );
    
    }
    
    ]], [[
    //
    // A basic fragment shader
    //
    
    //Default precision qualifier
    precision highp float;
    
    //This represents the current texture on the mesh
    uniform lowp sampler2D texture;
    
    uniform float push;
    
    varying float noise;
    
    void main() {
    
        // lookup vertically in the texture, using noise
        // to get the right RGB colour
         vec2 tPos = vec2( 0, 0.5 + 1.0 * noise - push); //9 pixels wide
        vec4 color = texture2D( texture, tPos );
         if (color.r < 0.005) discard;
         else gl_FragColor = color; // vec4( color.rgb, color.r );
        //color.rgb = color.rgb * color.a; //premultiply alpha
        //gl_FragColor = texture2D( texture, tPos ); //vec4( color.rgb, 1.0);
    //}
    }
    
    ]] )
    
    local img=readImage(asset.explosion)
   -- local h=img.height
    --[[
    for y=1,30 do --bottm fifth of texture
        for x=1,img.width do
            local r,g,b,a=img:get(x,y)
          --  a=(y-1)*10
            a=math.floor((y-0.5)*8.5)
            local m = a//255
            img:set(x,y,r*m,g*m,b*m,a) --premultiply the alpha
        end
    end
      ]]
   -- img.premultiplied = true
    Explosion.mesh=mesh()
    Explosion.mesh.vertices=Isosphere(3)
 --   Explosion.mesh2=Isosphere(5)
    Explosion.mesh.shader=ExplosionShader
    Explosion.mesh.shader.texture=img
  --  Explosion.mesh2.shader=ExplosionShader
  --  Explosion.mesh2.shader.texture=img
end

function Isosphere(depth,s)
    local s = s or 1 --scale
    local t = (1 + math.sqrt(5)) / 2
    --all the vertices of an icosohedron
    local vertices = {
            vec3(-1 , t, 0):normalize() * s,
            vec3(1 , t, 0):normalize() * s,
            vec3(-1 , -t, 0):normalize() * s,
            vec3(1 , -t, 0):normalize() * s,
            
            vec3(0 , -1, t):normalize() * s,
            vec3(0 , 1, t):normalize() * s,
            vec3(0 , -1, -t):normalize() * s,
            vec3(0 , 1, -t):normalize() * s,
            
            vec3(t , 0, -1):normalize() * s,
            vec3(t , 0, 1):normalize() * s,
            vec3(-t , 0, -1):normalize() * s,
            vec3(-t , 0, 1):normalize() * s
        }
    --20 faces
    icovertices = {
            -- 5 faces around point 0
            vertices[1], vertices[12], vertices[6],
            vertices[1], vertices[6], vertices[2],
            vertices[1], vertices[2], vertices[8],
            vertices[1], vertices[8], vertices[11],
            vertices[1], vertices[11], vertices[12],
            
            -- 5 adjacent faces
            vertices[2], vertices[6], vertices[10],
            vertices[6], vertices[12], vertices[5],
            vertices[12], vertices[11], vertices[3],
            vertices[11], vertices[8], vertices[7],
            vertices[8], vertices[2], vertices[9],
            
            -- 5 faces around point 3
            vertices[4], vertices[10], vertices[5],
            vertices[4], vertices[5], vertices[3],
            vertices[4], vertices[3], vertices[7],
            vertices[4], vertices[7], vertices[9],
            vertices[4], vertices[9], vertices[10],
            
            --5 adjacent faces
            vertices[5], vertices[10], vertices[6],
            vertices[3], vertices[5], vertices[12],
            vertices[7], vertices[3], vertices[11],
            vertices[9], vertices[7], vertices[8],
            vertices[10], vertices[9], vertices[2]
        }
    
    local finalVertices = {}
    --divide each triangle into 4 sub triangles to make an isosphere     
    --this can be repeated (based on depth) for higher res spheres   
    for j=1,depth do
        for i=1,#icovertices/3 do
            midpoint1 = ((icovertices[i*3-2] + icovertices[i*3-1])/2):normalize() * s
            midpoint2 = ((icovertices[i*3-1] + icovertices[i*3])/2):normalize() * s
            midpoint3 = ((icovertices[i*3] + icovertices[i*3-2])/2):normalize() * s
            --triangle 1
            table.insert(finalVertices,icovertices[i*3-2] )
            table.insert(finalVertices,midpoint1)
            table.insert(finalVertices,midpoint3)
            --triangle 2
            table.insert(finalVertices,midpoint1)
            table.insert(finalVertices,icovertices[i*3-1] )
            table.insert(finalVertices,midpoint2)
            --triangle 3
            table.insert(finalVertices,midpoint2)
            table.insert(finalVertices,icovertices[i*3] )
            table.insert(finalVertices,midpoint3)
            --triangle 4
            table.insert(finalVertices,midpoint1)
            table.insert(finalVertices,midpoint2)
            table.insert(finalVertices,midpoint3) 
        end
        icovertices = finalVertices
        finalVertices = {}
    end
   
    print("icovertices="..#icovertices)
    return icovertices
end
