local splitSize = 25 * 1024 * 1024;
    
function splitProject(project)
    local splits = {}
    local count = 1
    
    local function split(f, s, size)
        while size > 0 do
            local readSize = math.min(splitSize, size)
            
            local d = f:read(readSize)
            local nf = io.open(project.path .. "/_wrsplit_" .. count .. ".splt", "wb")
            nf:write(d)
            nf:close()
            
            table.insert(s, count)
            count = count + 1
            size = size - readSize
        end
    end
    
    local function splitFolder(folder) 
        local files = folder.all
        for _,file in ipairs(files) do
            if file.type == "folder" then
                splitFolder(file)
            else
                local f = io.open(file.path, "rb")
                f:seek("end")
                local filesize = f:seek()
                -- Split the file into 25MB chunks
                if filesize > 25 * 1024 * 1024 then
                    f:seek("set", 0)
                    local s = {}
                    
                    local sub = project.path:gsub("%.", "%%.") .. "/"
                    sub = sub:gsub("%-", "%%-")
                    splits[file.path:gsub(sub, "")] = s
                    split(f, s, filesize)
                end
                f:close()
            end
        end
    end
    
    splitFolder(project)
    
    -- Write split manifest
    if count > 1 then
        local f = io.open(project.path .. "/_wrsplit_manifest.txt", "w")
        f:write(json.encode(splits))
        f:close()
    end
end

function unsplitProject(project)
    -- Read split manifest
    local man = readText(project .. "/_wrsplit_manifest.txt")
    if man then
        local splits = json.decode(man)
        
        -- Merge the split files back into their original files
        for path, s in pairs(splits) do
            local f = io.open(project.path .. "/" .. path, "wb")
            
            for _,v in ipairs(s) do
                -- Read the split file
                local fs = io.open(project.path .. "/_wrsplit_" .. v .. ".splt", "rb")
                local data = fs:read("*a")
                fs:close()
                
                -- Write split data to original file
                f:write(data)
                
                -- Delete split file
                os.remove(project.path .. "/_wrsplit_" .. v .. ".splt")
            end
            
            f:close()
        end
        
        -- Delete split manifest
        os.remove(project.path .. "/_wrsplit_manifest.txt")
    end
end
