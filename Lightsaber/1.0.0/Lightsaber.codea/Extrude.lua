
function transformedPoints(points, xform)
    return map(points, function(p) 
        return xform * p
    end)
end

function quadsByExtrudingPoints(pointsA, pointsB, t0, t1)
    local v = {}
    local tc = {}
    local c = (#pointsA - 1)
    
    for i = 1,c do
        local tcA1 = vec2(t0, (i-1)/c)
        local tcA2 = vec2(t0, i/c)
        
        local tcB1 = vec2(t1, tcA1.y)
        local tcB2 = vec2(t1, tcA2.y)
        
        local pA1 = pointsA[i]
        local pA2 = pointsA[i+1]
        
        local pB1 = pointsB[i]
        local pB2 = pointsB[i+1]
        
        append(v, {pA1, pA2, pB2, pB2, pB1, pA1})
        append(tc, {tcA1, tcA2, tcB2, tcB2, tcB1, tcA1})
    end
    
    return v, tc
end

function meshByExtrudingPointsThroughTransforms(points, xforms)
    -- Result
    local m = mesh()
    local v = {}
    local tc = {}
    local c = (#xforms - 1)
    
    for i = 1,c do
        local x1 = xforms[i]
        local x2 = xforms[i+1]
        
        local pStart = transformedPoints(points, x1)
        local pEnd = transformedPoints(points, x2)
        
        local section, stc = quadsByExtrudingPoints(pStart, pEnd, (i-1)/c, (i+1)/c)
        
        append(v, section)
        append(tc, stc)
    end
    
    m.vertices = v
    m.texCoords = tc
    
    return m
end


