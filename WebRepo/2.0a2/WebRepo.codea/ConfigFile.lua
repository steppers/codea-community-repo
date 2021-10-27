ConfigFile = class()

function ConfigFile:init(name, defaults)
    self.name = name
    local data = readText(asset.documents.webrepocache_vfs .. "cfg_" .. name .. ".json")
    if data then
        self.vals = json.decode(data)
    else
        self.vals = defaults or {}
    end
    self:flush()
end

function ConfigFile:flush()
    saveText(asset.documents.webrepocache_vfs .. "cfg_" .. self.name .. ".json", json.encode(self.vals, {
        indent = true
    }))
end

function ConfigFile:set(key, val)
    self.vals[key] = val
    self:flush()
end

function ConfigFile:get(key)
    return self.vals[key]
end
