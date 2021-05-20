floor={}

local w,h = 256, 256 --512, 512    
local tw, th = 3000,3000

function floor.init()
    floor.m=mesh()
    floor.m.shader=shader(TilerShader.vs, TilerShader.fs)
    floor.m.shader.aerial=aerial

    local name="Documents:lichen brick2"
    local img=readImage(name)
    if not img then
        LoadImages("http://homeinteriorsdesigns.info/wp-content/uploads/2014/09/seamless-stone-texture.jpg", name, function() floor.m.texture=readImage(name) floor.ready=true end)
    else
        floor.m.texture=img
        floor.ready=true
    end   

    floor.m.shader.fogRadius = tw*0.3
    floor.m:addRect(0,0,tw,th)

    local a,b,c,d = vec2(-w/tw, h/th), vec2(-w/tw,-h/th), vec2(w/tw, -h/th), vec2(w/tw, h/th)
    floor.x, floor.y = 0,0
    floor.m:setRectTex(1,floor.x,floor.y,tw/w,th/h)

end

function floor.move(v)
    floor.x = (floor.x + v.x)%w
    floor.y = (floor.y + v.y)%h
    
end

function floor.draw(e)
    pushMatrix()
    translate(floor.x, floor.y,0)
    floor.m.shader.eye=e
    floor.m.shader.modelMatrix=modelMatrix()
    floor.m:draw()
    popMatrix()
end

TilerShader={vs=[[
    uniform mat4 modelViewProjection;
    uniform mat4 modelMatrix;    
        
    attribute vec4 position;
    attribute vec4 color;
    attribute vec2 texCoord;
    
    varying lowp vec4 vColor;
    varying highp vec2 vTexCoord;
    varying lowp vec4 vPosition;
        
    void main()
    {
        vColor = color;
        vTexCoord = texCoord;
        vPosition = modelMatrix * position;
        //vDist = clamp(1.0-(vPosition.y-eye.y)/fogRadius+0.1, 0.0, 1.1); // (vPosition.y-eye.y) distance(vPosition.xyz, eye.xyz)
        gl_Position = modelViewProjection * position;
    }
    ]],fs=[[
    precision highp float;
    
    uniform lowp sampler2D texture;
    uniform lowp vec4 aerial; //aerial perspective
    uniform vec4 eye;  //xyz1
    uniform float fogRadius;
            
    varying lowp vec4 vColor;
    varying highp vec2 vTexCoord;
    varying lowp vec4 vPosition;
        
    void main()
    {
        lowp vec4 pixel = texture2D( texture, vec2(fract(vTexCoord.x), fract(vTexCoord.y)) ) * vColor;
        float dist = clamp(1.0-distance(vPosition.xyz, eye.xyz)/fogRadius+0.1, 0.0, 1.1); //
        lowp vec4 col = mix(aerial, pixel, dist*dist);  
        //col.a = pixel.a;
        gl_FragColor = col;
    }
    ]]}
    
