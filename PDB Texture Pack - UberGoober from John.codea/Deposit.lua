-----------------------------------------
-- Deposit
-- Written by John Millard
-----------------------------------------
-- Description:
-- Creates a block type that generates a randomised mineral deposit.
-- Deposit blocks can be placed during generation or during play and will still work.
-----------------------------------------

function depositGenerator()

    local deposit = scene.voxels.blocks:new("Deposit")
    -- No complex state required so we can get away with a scripted block (non-dynamic)
    deposit.scripted = true
    deposit.geometry = EMPTY
    deposit.static.hasIcon = false

    function deposit:generate()
        local x,y,z = self:xyz()

        -- Base ore type on y depth of the block
        -- This could easily be customised to use any block types you want.
        local depositType = "Coal Ore"

        if y < 64 then
            depositType = "Gold Ore"
        end

        if y < 32 then
            depositType = "Diamond Ore"
        end

        local r = 3
        local r2 = r*r

        -- Replace self with stone and then deposit minerals
        self.voxels:set(x,y,z,"Stone")

        self.voxels:iterateBounds(x-r, y-r, z-r, x+r, y+r, z+r, function(i,j,k,id)
            -- Scale density based on distance from deposit center
            local dx, dy, dz = x-i, y-j, z-k
            local d = dx*dx + dy*dy + dz*dz
            local p = 1.0 - (d / (r2+0.0))

            -- Only deposit ore on stone blocks, ignore everything else
            if math.random() < p and self.voxels:get(i, j, k, BLOCK_NAME) == "Stone" then
                self.voxels:set(i, j, k, depositType)
            end
        end)

    end

    function deposit:blockUpdate(t)
        local x,y,z = self:xyz()

        -- Wait until there is enough area loaded to generate the deposit
        if self.voxels:isRegionLoaded(x-3, y-3, z-3, x+3, y+3, z+3) then
            self:generate()
        else
            self:schedule(60)
        end
    end

    function deposit:created()
        self:schedule(1)
    end
end
