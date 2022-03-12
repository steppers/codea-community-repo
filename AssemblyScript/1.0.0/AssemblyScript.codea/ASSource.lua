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
    self.source = source
    self.imports = imports or {}
    
    -- TODO: Verify dependencies are the correct type
    self.dependencies = dependency_sources or {}
    
    self._class_type = "ASSource"
end
