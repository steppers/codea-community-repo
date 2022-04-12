-- from https://ronjeffries.com/articles/020-dung/-v022f/d-225/
-- 20220312: 尝试使用TDD方式开发，用测试用例来管理需求特性

function testMyProject()
    CodeaUnit.detailed = false
    
    _:describe("My ProcTreeLua Tests", function()
        
        _:before(function()
        end)
        
        _:after(function()
        end)
        
        _:test("Branch ", function()
            -- myTree = Tree({})
            
        end)
        
        --[[ 用法示例，实际使用时可注释关闭这些说明性代码
        _:test("Array of Array of Hexes", function()
            -- 执行要测试的函数，代码
            local hexes = createHexes(15,10)
            -- 把实测结果跟期望结果做对比
            _:expect(hexes:xCount()).is(15)
            _:expect(hexes:yCount()).is(10)
            _:expect(hexes:get(5,5):coords()).is(Coord(5,5))
            _:expect(hexes:get(7,9):coords()).is(Coord(7,9))
        end)
        
        _:test("Coordinate Creation", function()
            local coord = Coord(0,0,0)
            _:expect(coord:valid()).is(true)
            local f = function() Coord(1,1,1) end
            _:expect(f()).throws("Invalid Coord")
        end)
        
        _:test("Screen Positions", function()
            _:expect(Coord(0,0,0):screenPos()).is(vec2(0,0))
        end)
        
        _:test("X spacing", function()
            local expectedWidth = 0
            local hex = Hex(0,0)
            local hexX = hex:xWidth()
            _:assert(hexX).is(expectedWidth)
        end)
        --]]
        
        
    end)
end

function setCurr(ret,index,char)
    local res = ret:sub(1,index-1)..char
    if res:len() < ret:len() then
        res = res..ret:sub(index+1)
    end
    return res
end

--]]

-- ------ functions below here
function manhattan(v1,v2)
    local abs = math.abs
    local s = 0
    for i in ipairs(v1) do
        s = s + abs(v2[i]-v1[i])
    end
    return s
end

-- 用法示例
function checkRing(dungeon, x1,y1, x2,y2, msgTable)
    local ann
    local msgs
    local t
    for x = x1,x2 do
        t = dungeon:privateGetTileXY(x,y1)
        ann = findTriggerIn(t)
        t = dungeon:privateGetTileXY(x,y2)
        ann = findTriggerIn(t)
    end
    for y = y1,y2 do
        t = dungeon:privateGetTileXY(x1,y)
        ann = findTriggerIn(t)
        t = dungeon:privateGetTileXY(x2,y)
        ann = findTriggerIn(t)
    end
end

function findTriggerIn(tile)
    _:expect(tile:getContents()[1]:is_a(Trigger)).is(true)
end

function checkRange(dungeon, x1, y1, x2, y2, checkFunction)
    x1,x2 = math.min(x1,x2), math.max(x1,x2)
    y1,y2 = math.min(y1,y2), math.max(y1,y2)
    for x = x1,x2 do
        for y = y1,y2 do
            local t = dungeon:privateGetTileXY(x,y)
            local r = checkFunction(t)
            if not r then
                local msg = string.format("checkRange %d,%d fails", x,y)
                _:expect(r,msg).is(true)
                return r,x,y
            end
        end
    end
    _:expect(true).is(true)
    return true,0,0
end

--- CodeaUnit functions below here

function runCodeaUnitTests()
    local det = CodeaUnit.detailed
    CodeaUnit.detailed = false
    Console = _.execute()
    CodeaUnit.detailed = det
end

function showCodeaUnitTests()
    --[[
    if  Console:find("[1-9] Failed") then
        sound(asset.downloaded.Game_Sounds_One.Bell_2)
    end--]]
    pushMatrix()
    pushStyle()
    scale(1)
    background(40, 40, 50)
    zLevel(10)
    fontSize(16)
    textAlign(CENTER)
    if Console:find("[1-9] Failed") 
    or Console:find("[1-9][0-9] Failed") then
        stroke(255,0,0)
        fill(255,0,0)
    elseif Console:find("[1-9] Ignored") 
    or Console:find("[1-9][0-9] Ignored") then
        stroke(255,255,0)
        fill(255,255,0)
    else
        fill(0,255,0, 100)
    end
    text(Console, WIDTH/2, HEIGHT/2)
    popStyle()
    popMatrix()
end

function codeaTestsVisible(aBoolean)
    CodeaVisible = aBoolean
end

function printv(v)
    print("(",v.x,", ",v.y,")")
end