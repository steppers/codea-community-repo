-- API Updater
--
-- Scans lua code identifying old API usage and upgrades it

local function updateStorageAPI(str)
    
    -- '"Project:"' -> 'asset'
    str = string.gsub(str, "\"Project:\"", "asset")
    
    -- '"Project:' -> 'asset .. "'
    str = string.gsub(str, "\"Project:", "asset .. \"")
    
    -- '"Dropbox:"' -> 'asset.documents.Dropbox'
    str = string.gsub(str, "\"Dropbox:\"", "asset.documents.Dropbox")
    
    -- '"Dropbox:' -> 'asset.documents.Dropbox .. "'
    str = string.gsub(str, "\"Dropbox:", "asset.documents.Dropbox .. \"")
    
    return str
end

function updateAPI(str)
    str = updateStorageAPI(str)
    
    return str
end
