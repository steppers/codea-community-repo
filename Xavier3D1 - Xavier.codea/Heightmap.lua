-- Heightmap building class --
------------------------------------------------------
    
Model = class()
    
function Model:init(quality, n, wrapping, str)
    mapSize = 512
    step = math.pow(2,quality+2)
    self.vertices = {}
    self.faces = {}
    self.detailTexCoords = {}
    self.colorTexCoords = {}
    self.tris = {}
    self.tex = {}
    self.cols = {}
    local size = (mapSize/step)*(mapSize/step)*6
    for i=1, size do
        self.tris[i] = vec2(0,0)
        if (textured == 1 or wireframe == 1) then
            self.tex[i] = vec2(0,0)
        end
        if colored == 1 then
            self.cols[i] = color(255, 255, 255, 255)
        end
    end
    -- create vertices, the height value of the heightmap is a simple noise
    local i, j
    i=1
    for z=0, mapSize, step do
        for x=0, mapSize, step do
            j = (x + (z) * (mapSize+step)/step)/step+1
            self.vertices[j] = Vertex(x*wrapping,(currentZ)-noise(x/n, z/n)*str, z*wrapping)
            self.detailTexCoords[j] = vec2( x/step, z/step)
            self.colorTexCoords[j] = vec2( x/mapSize, z/mapSize)
            
            -- filling the face array with the indices of the vertices
            -- 4 points, two triangles
            if (z~=mapSize and x~=mapSize) then
                a = (x + (z) * (mapSize+step)/step)/step + 1
                b = (x + (z + step) * (mapSize+step)/step)/step + 1
                c = (x + step + (z + step) * (mapSize+step)/step)/step + 1
                d = (x + step + (z) * (mapSize+step)/step)/step + 1
                
                self.faces[i] = Face(a, b, c)
                self.faces[i+1] = Face(c, d, a)
                i = i + 2
            end
        end
    end
    return self
end
    