
function GCLogger(object, name)
    local mt = getmetatable(object)
    mt.__gc = function(self)
        print("Deleted: " .. name)
    end
    setmetatable(object, mt)
end
