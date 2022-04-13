ASSource = class()

function ASSource:init(name, source, imports, dependency_sources)
    assert(type(name) == 'string')
    
    -- Read source from disk
    if type(source) == 'userdata' then
        assert(source.path ~= nil, "Unexpected source type! Only source strings or Codea assets are accepted")
        
        -- Read the asset provided into the source variable
        local f = io.open(source.path, "r")
        source = f:read('*a')
        f:close()
    end
    
    self.name = name
    self.imports = imports or {}
    
    -- Trim whitespace from imports
    for k,v in pairs(self.imports) do
        if type(v) == "string" then
            imports[k] = v:gsub("^%s*", ""):gsub("%s*$", "")
        end
    end
    
    -- Preprocess the source
    for impl in source:gmatch("@js_import(.-)@js_end") do
        local key, val = impl:match("(.-)=(.-)$")
        key = key:gsub("^%s*", ""):gsub("%s*$", "")
        val = val:gsub("^%s*", ""):gsub("%s*$", "")
        self.imports[key] = val
    end
    self.source = source:gsub("@js_import.-@js_end", "")
    
    -- TODO: Verify dependencies are the correct type
    self.dependencies = dependency_sources or {}
    
    self._class_type = "ASSource"
end
