-- Path

Path = class()

-- Returns the parameter as a Path object
function asPath(p)
    if getmetatable(p) == Path then
        return p
    else
        return Path(p)
    end
end
    
-- Returns the string value
function Path:__tostring()
    return self.val
end

function Path:init(str)
    
    -- Strip trailing slash
    str = str:gsub("([^/]+)/$", "%1")
    
    self.val = str
end

function Path:clone()
    return Path(self.val)
end

function Path:isAbsolute()
    return (self.val:match("^/") ~= nil)
end

function Path:append(path)
    if getmetatable(path) == Path then
        
        -- Another path object
        if path:isAbsolute() then
            error("Unable to append an absolute path! " .. path.val)
        end
        
        -- Remove trailing slash (when root)
        return Path(self.val:gsub("/$", "") .. "/" .. path.val)
    else
        
        -- A string so turn it into a path object
        return self:append(Path(path))
    end
end

function Path:parent()
    return Path(self.val:match("(.*/).-$"))
end

function Path:leaf()
    return Path(self.val:match("([^/]-)$"))
end

-- Returns a function that 'walks' down the
-- path each time it is called
function Path:walker()
    return self.val:gmatch("/([^/]*)")
end
