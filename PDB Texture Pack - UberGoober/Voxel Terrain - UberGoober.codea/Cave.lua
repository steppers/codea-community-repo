-----------------------------------------
-- Deposit
-- Written by John Millard
-----------------------------------------
-- Description:
-- Creates a block type that generates a randomised cave.
-- Cave blocks can be placed during generation or during play and will still work.
-----------------------------------------

function caveGenerator()
        
    local cave = scene.voxels.blocks:new("Cave")
    -- Cave generators are dynamic so they can contain complex persistent state
    cave.dynamic = true
    -- Cave generators are invisible while generating
    cave.geometry = EMPTY
    cave.static.hasIcon = false

    -- This function carves out a section of the cave then moves to the next location
    function cave:carve()
        local x,y,z = self.cx, self.cy, self.cz
        local caveID = cave.id
        local waterID = self.voxels.blocks.water.id
        local bedrockID = self.voxels.blocks.bedrock.id        
        
        local r = math.floor( (self.gr:getValue(x/16.0, y/16.0, z/16.0)+1)*0.5 * 2.5 + 1.5 )
        local r2 = r*r
        
        -- Carve out a section based on the radius from the noise function
        self.voxels:iterateBounds(x-r, y-r, z-r, x+r, y+r, z+r, function(i,j,k,id)
            local dx, dy, dz = x-i, y-j, z-k
            local d = dx*dx + dy*dy + dz*dz       
        
            -- Only carve non-cave blocks (to avoid erasing self) and ignore water / bedrock for obvious reasons    
            if id ~= caveID and id ~= waterID and id ~= bedrockID and d < r2 then
                self.voxels:set(i,j,k,0)
            end
        end)
        
        -- The current direction to move in
        local dir = vec3(self.gx:getValue(x/16.0, y/16.0, z/16.0), 
                         self.gy:getValue(self.cx/16.0, self.cy/16.0, self.cz/16.0), 
                         self.gz:getValue(self.cx/16.0, self.cy/16.0, self.cz/16.0))
        dir.y = dir.y - 0.1
        dir.x = dir.x * 1.5
        dir.z = dir.z * 1.5        
        dir = dir:normalize()
            
        self.pos = self.pos + dir
            
        self.cx = math.tointeger(math.floor(self.pos.x))
        self.cy = math.tointeger(math.floor(self.pos.y))
        self.cz = math.tointeger(math.floor(self.pos.z))
        
        -- Return if the cave should keep going or not
        self.length = self.length - 1
        return self.length > 0
    end
    
    -- This gets called periodically to try carving more of the cave
    function cave:blockUpdate(t)
        local x,y,z = self:xyz()

        if self.gx == nil then
            return
        end

        -- This checks to see if the cave can be carved out, if the area isn't loaded yet it will wait for abit
        if self.voxels:isRegionLoaded(x-3, y-3, z-3, x+3, y+3, z+3) then
            -- Keep carving until carve() returns false
            if self:carve() then
                self:schedule(1)
            else
                -- When finished have a random chance to spawn some more caves (to create forks / loops)
                self.voxels:set(x,y,z,0)
                if math.random() < 0.25 then
                    self.voxels:set(x+3, y+1, z-2, cave.id)
                end
                if math.random() < 0.25 then
                    self.voxels:set(x-3, y+1, z+2, cave.id)
                end
            end
        else
            self:schedule(60)
        end
    end
    
    -- Create 4 different noise modules to control cave carving direction and radius
    function cave:setup()
        self.gx = craft.noise.perlin()
        self.gx.frequency = 0.5
        self.gx.seed = self.x
        self.gy = craft.noise.perlin()        
        self.gy.frequency = 0.5
        self.gy.seed = self.y
        self.gz = craft.noise.perlin()                
        self.gz.frequency = 0.5
        self.gz.seed = self.z
        
        self.gr = craft.noise.perlin()                
        self.gr.frequency = 0.5
        self.gr.seed = self.x * self.z
            
        -- The integral position to carve (integer)
        self.cx = self.x
        self.cy = self.y
        self.cz = self.z 
        
        -- The current position to carve (floating point)
        self.pos = vec3(self.x, self.y, self.z)

        -- The total length of the cave is randomised from the start
        self.length = math.random(50,150)
        
        -- Caves can only start on a grass block (otherwise self-destruct)
        local x,y,z = self:xyz()
        if self.voxels:get(x,y-1,z,BLOCK_NAME) ~= "Grass" then
            self.voxels:set(x,y,z,0)
            return
        end
        
        -- Try carving next update
        self:schedule(1)  
    end

    -- If a cave is loaded from a saved chunk just call setup
    function cave:load()
        self:setup()
    end
        
    function cave:created()
        self:setup()
    end
    
end
