function map(t, f)
    local m = {}
    for i,v in pairs(t) do
        m[i] = f(v)
    end
    return m
end

function filter(t, f)
    local m = {}
    for i,v in pairs(t) do
        if f(v) then m[i] = v end
    end
    return m
end

function replace(t, r, f)
    for i,v in pairs(t) do
        if f(v) then t[i] = r end
    end    
end

function count(t)
    local c = 0
    for _,_ in pairs(t) do
        c = c + 1
    end
    return c
end

function append(t, d)
    for i,v in pairs(d) do
        table.insert(t, v)
    end
end

function first(t, n)
    local set = {}
    for k,v in pairs(t) do
        if #set > n then
            break
        end 
        table.insert(set, v)
    end
    return set
end



