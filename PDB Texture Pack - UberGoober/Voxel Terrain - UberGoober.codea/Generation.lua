-----------------------------------------
-- Deposit
-- Written by John Millard
-----------------------------------------
-- Description:
-- A function that generates terrain for a single voxel chunk (region of the world).
-- Most generation is handled by a tree of noise modules which progessively 
-- build up complexity.
-- Several helper functions are defined to make it easier to create noise trees.
-- More complex structures, such as caves, mineral deposits and trees are created
-- by using blocks that delay generation until later (by checking if there is room)
-- for them to be generated and waiting for adjacent regions to be loaded by finishing.
-----------------------------------------

-- The sea level for the terrain
SEA_LEVEL = 70
    
function generateTerrain(chunk)
    -- Cache the size of the chunk for use in other functions
    cx, cy, cz = chunk:size()

    seed = params.seed
        
    -- Basic block types as noise sources
    air = craft.noise.const(0)
    dirt = craft.noise.const(chunk:blockID("Dirt"))    
    stone = craft.noise.const(chunk:blockID("Stone"))    
    grass = craft.noise.const(chunk:blockID("Grass"))       
    water = craft.noise.const(chunk:blockID("Water"))       
    sand = craft.noise.const(chunk:blockID("Sand"))           
    bedrock = craft.noise.const(chunk:blockID("Bedrock"))
    rmap = riverMap(chunk)
    
    local n = nil
    
    if params.rivers then
        n = split(air, riverEdge(grass, sand), SEA_LEVEL)
    else
        -- Make the top layer grass and the rest air
        n = split(air, grass, SEA_LEVEL)
    end
    
    -- Make dirt the next layer down
    n = split(n, dirt, SEA_LEVEL-1) 

    -- Make the rest stone  
    n = split(n, stone, SEA_LEVEL-4)   
    
    -- Create final terrain height by blending two different terrains
    local b1 = blend2D(rollingPlains(), plains(), 0.1, 0.5, 4)   

    if params.rivers then
        -- Blend river height to terrain and warp original noise
        n = warp(n, cache2D(chunk, riverBed(b1)))    
        -- Add river bed and water
        n = river(n)
    else
        -- Warp noise using terrain
        n = warp(n, cache2D(chunk, b1))
    end
    
    -- Set the bottom layer to bedrock
    n = split(n, bedrock, 1)   
    
    -- Use the noise tree to generate the terrain
    chunk:setWithNoise(n)
    
    -- Place some trees randomlu
    surfaceScatter(chunk, 1, 2, 5, chunk:blockID("Tree Generator"))
    
    -- Place a cave randomly
    if math.random() < params.caveChance then
        surfaceScatter(chunk, 1, 1, 5, chunk:blockID("Cave"))        
    end

    volumeScatter(chunk, params.minDeposits, params.maxDeposits, chunk:blockID("Stone"), chunk:blockID("Deposit"))
end

-- Basic terrain presets
function plains()
    return hills(2, 0, 0.25, 3)
end

function cliffs()
    return hills(5, 0, 0.75, 5)
end

function rollingPlains()
    return hills(40, 0, 0.25, 3)
end

-- Gets the height of the terrain at a given point
function surfaceHeight(chunk, px, pz)    
    for py = cy-1,0,-1 do
        if chunk:get(px, py, pz, BLOCK_ID) ~= 0 then
            return py
        end
    end    
end

-- Scatters blocks on the surface of a chunk
function surfaceScatter(chunk, min, max, radius, id)
    local count = math.random(min, max)
    local points = {}
    
    for i = 1,count do
        local px = math.random(0,cx-1)
        local pz = math.random(0,cz-1)
        local py = surfaceHeight(chunk, px, pz)
        if py then
            chunk:set(px, py+1, pz, id)
        end
    end
end

-- Scatters blocks below the surface of a chunk
function volumeScatter(chunk, min, max, target, id)
    local count = math.random(min, max)
    local points = {}
    
    for i = 1,count do
        local px = math.random(0,cx-1)
        local py = math.random(0,cy-1)
        local pz = math.random(0,cz-1)

        if chunk:get(px, py, pz, BLOCK_ID) == target then
            chunk:set(px, py+1, pz, id)            
        end
    end
end

-- Determines which areas are part of a river
function riverMap(chunk)
    local r = craft.noise.rigidMulti()
    r.frequency = 0.1
    r.octaves = 1
    r.seed = seed
    
    local t = craft.noise.turbulence()
    t:setSource(0, r)
    t.frequency = params.riverTurbulence
    t.seed = seed
        
    return cache2D(chunk, flatten(t))
end

-- Blends between river and non-river areas
function riverEdge(input, riverbed)
    local s = craft.noise.select()
    s:setSource(0, input)
    s:setSource(1, riverbed)
    s:setSource(2, rmap)
    s:setBounds(-0.2, 10)
    
    local s2 = craft.noise.select()
    s2:setSource(0, s)
    s2:setSource(1, stone)
    s2:setSource(2, rmap)
    s2:setBounds(-0.5, 0)
    
    return s
end

-- Blends between river and non-river heights
function riverBed(input)
    -- blend height at river edges

    local s3 = craft.noise.select()
    s3:setSource(0, input)
    s3:setSource(1, craft.noise.const(0))
    s3:setSource(2, rmap)
    s3:setBounds(-0.5, 10)  
    s3.falloff = 0.15
    
    local s2 = craft.noise.select()
    s2:setSource(0, s3)
    s2:setSource(1, craft.noise.const(0.1))
    s2:setSource(2, rmap)
    s2:setBounds(0.0,10)
    s2.falloff = 0.25
    
    return s2
end

-- Carve rivers out and fill with water
function river(input)
    
    local s = craft.noise.select()
    s:setSource(0, air)
    s:setSource(1, split(air, water, SEA_LEVEL-7))
    s:setSource(2, rmap)
    s:setBounds(-0.1, 10)
    
    s = split(s, air, SEA_LEVEL-20)
    
    local m = craft.noise.merge()
    m:setSource(0, input)
    m:setSource(1, s)

    return m
end

-- Takes two noise functions and split based on elevation
function split(a, b, depth)
    depth = depth or 64
    
    local s = craft.noise.select()
    s:setSource(0, a)
    s:setSource(1, b)   
    s:setSource(2, craft.noise.gradient()) 
    s:setBounds(1.0 - depth / (cy + 0.0), 1.0)
    
    return s
end

-- Warp one noise function using others
function warp(input, d1, d2, d3)

    -- Full 3D warp
	if d1 and d2 and d3 then
		local zero = craft.noise.const()
	    
	    local displace = craft.noise.displace()
	    displace:setSource(0, input)
	    displace:setSource(1, d1) -- x
	    displace:setSource(2, d2) -- y
	    displace:setSource(3, d3) -- z

        return displace
    -- Vertical warp only (y-axis)
	else
		local zero = craft.noise.const()
	    
	    local displace = craft.noise.displace()
	    displace:setSource(0, input)
	    displace:setSource(1, zero) -- x
	    displace:setSource(2, d1) -- y
	    displace:setSource(3, zero) -- z

	   return displace
	end
end

-- Generic perlin noise hills (2D height map)
function hills(height, offset, frequency, octaves)

    height = height or 10
    offset = offset or 0
    octaves = octaves or 5
    frequency = frequency or 0.25
    
    local heightNorm = height / (cy + 0.0)
    
    local shape = craft.noise.perlin()
    shape.octaves = octaves
    shape.frequency = frequency
    shape.seed = seed
        
    local shape2D = flatten(shape)    
    
    local shapeFinal = craft.noise.scaleOffset()
    shapeFinal:setSource(0, shape2D)
    shapeFinal.scale = -heightNorm * 0.5
    shapeFinal.offset = -heightNorm - offset/cy 
        
    return shapeFinal
end

-- Take a noise module and flatten it (so values at any y position are the same)
function flatten(input)
    local n2D = craft.noise.scale(1,0,1)
    n2D:setSource(0, input)
    return n2D
end

-- Cache noise values in 2D space to reduce expensive computations
function cache2D(chunk, input)
    local cache = craft.noise.chunkCache2D(chunk)
    cache:setSource(0, input)
    return cache
end

-- Smoothly blend between two height maps based on a perlin control function
function blend2D(a, b, frequency, roughness, falloff)
    local n = craft.noise.perlin()
    n.octaves = 1
    n.frequency = frequency
    n.seed = seed
    
    local s = craft.noise.select()
    s:setSource(0, a)
    s:setSource(1, b)
    s:setSource(2, flatten(n))
    s:setBounds(0,10)
    if falloff then
        s.falloff = falloff
    end
    
    if roughness > 0 then
        local t = craft.noise.turbulence()
        t:setSource(0, s)
        t.frequency = 0.5
        t.power = roughness
        t.seed = seed
        
        s = t
    end
    return s
end