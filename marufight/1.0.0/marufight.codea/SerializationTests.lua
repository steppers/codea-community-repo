function testSerialization()
    CodeaUnit.detailed = true
    CodeaUnit.skip = false
    -- local shouldWipeDebugDraw = false
    
    _:describe("Testing Serialization", function()
        _:before(function()
        end)     
        _:after(function()
        end)
        parameter.watch()
        
        _:test("can serialize id", function()
            local critter = NewCreature()
            local serialized = critter:serialize()
            local revived = NewCreature()
            revived:restore(serialization)

            _:expect("ids not nil", (critter.id ~= nil) and (revived.id ~= nil)).is(true)
            
            _:expect("ids not 0", (critter.id ~= 0) and (revived.id ~= 0)).is(true)
            
                        _:expect("revived.id == critter.id", (revived.id == critter.id)).is(true)
            
        end)
        
    end)
end
