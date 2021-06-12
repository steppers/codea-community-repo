function soundb()
    local soundb = scene.voxels.blocks:new("Sound")
    soundb.setTexture(ALL, packPrefix.."Sound")
    soundb.tinted = true
    soundb.scripted = true
    
    function soundb:created()
        -- Randomise colour based on location
        local x,y,z = self:xyz()
        math.randomseed(x * y * z)
        local c =color(math.random(200,255), math.random(200,255), math.random(200,255))
        self.voxels:set(x,y,z,"color", c)
    end
        
    -- Play a sound when interacted with
    function soundb:interact()
        local x,y,z = self:xyz()
        sound(SOUND_RANDOM, x * y * z)
    end 
    
    return soundb
end  