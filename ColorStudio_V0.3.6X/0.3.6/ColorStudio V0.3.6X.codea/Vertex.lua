function vertex()
    return
[[
uniform mat4 modelViewProjection;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

void main()
{
    vColor = color;
    vTexCoord = texCoord;
    
    gl_Position = modelViewProjection * position;
}
  
]]
end
