-- Array

function Array(size, default)
    local a = {}
    
    if default ~= nil then
        for i = 1, size do
            a[i] = default()
        end
    else
        for i = 1, size do
            a[i] = {}
        end
    end
    
    return a
end

function Array2d(w, h, default)
    local a = {}
    
    if default ~= nil then
        for x = 1, w do
            local ax = {}
            for y = 1, h do
                ax[y] = default()
            end
            a[x] = ax
        end
    else
        for x = 1, w do
            local ax = {}
            for y = 1, h do
                ax[y] = {}
            end
            a[x] = ax
        end
    end 
    
    return a
end
