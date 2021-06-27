VFS = class()

local MVAL_DIR          = 0 << 0
local MVAL_FILE         = 1 << 0
local MVAL_TYPE_MASK    = 0x01

-- Returns the VFS node corresponding to the
-- provided path.
--
-- path must be absolute
local function getNode(vfs, path)
    
    -- Make sure it's absolute
    path = vfs:toAbsolute(path)
    
    -- Start at root
    local node = vfs.nodes["/"]
    
    -- Return root
    if path.val == "/" then
        return node
    end
    
    local walker = path:walker()
    local next_node = walker()
    
    while next_node ~= nil do
        
        -- Walk the VFS nodes
        node = node.data[next_node]
        if node == nil then
            return nil
        end
        
        -- Get next node
        next_node = walker()
    end
    
    return node
end

local function getFile(vfs, path)
    local n = getNode(vfs, path)
    if n and ((n.meta & MVAL_TYPE_MASK) == MVAL_FILE) then
        return n
    end
end

local function getDir(vfs, path)
    local n = getNode(vfs, path)
    if n and ((n.meta & MVAL_TYPE_MASK) == MVAL_DIR) then
        return n
    end
end

-- Initialises a new VFS in a subfolder in the Codea
-- documents directory.
--
-- If the VFS already exists then it is loaded instead.
function VFS:init(name, autoflush)
    
    -- Start in root dir
    self.wd = Path("/")
    
    -- Flush after each operation by default
    self.autoflush = autoflush or true
    
    -- Always in documents directory
    self.vfs_root = (asset.documents .. name .. "_vfs").path .. "/"
    self.entry_file = asset.documents .. name .. "_vfs/" .. name .. ".json"
    
    -- Attempt to open the file system
    local json_data = readText(self.entry_file)
    if json_data == nil then
            
        -- Create a temporary project to generate the sub directory
        createProject(name .. "_vfs:deleteme")
        deleteProject(name .. "_vfs:deleteme")
            
        -- Init the content json
        local default_nodes = {
            ["/"] = {
                ["data"] = {}, -- content
                ["meta"] = MVAL_DIR
            },
            next_index = 1
        }
        
        -- Flush to disk
        self.nodes = default_nodes
        self:flush()
    else
        
        -- Decode the data
        self.nodes = json.decode(json_data)
    end
end

-- Erases all files and directories from the VFS
function VFS:format()
    
    local node = self:getDir("/")
    
    for k,_ in pairs(node.data) do
        self:rm("/" .. k)
    end
    
    self.nodes.next_index = 1
    
    if self.autoflush then
        self:flush()
    end
end

-- Flushes the nodes to disk
function VFS:flush()
    saveText(self.entry_file, json.encode(self.nodes, {
        indent = true, level = 2,
        keyorder = {
            "next_index",
            "meta",
            "file",
            "data"
        }
    }))
end

-- Returns the provided path as an absolute
-- path.
-- Note: the returned value is a Path object
function VFS:toAbsolute(path)
    local p = asPath(path)
    
    -- If not absolute then prepend the working dir
    if not p:isAbsolute() then
        p = self.wd:append(p)
    end
    
    return p
end

-- Changes the working directory without checking if the directory
-- actually exists.
function VFS:cd(path)
    local p = asPath(path)
    
    -- Either set or append
    if p:isAbsolute() then
        self.wd = p
    else
        self.wd = self.wd:append(path)
    end
end

-- Returns the current working directory
-- as a Path object
function VFS:cwd()
    return self.wd
end

-- Returns true if the path exists in the VFS.
-- The node can be either a file or a directory.
function VFS:exists(path)
    return (getNode(self, path) ~= nil)
end

-- Returns true if the path exists in the VFS
-- and the node is a file
function VFS:fileExists(path)
    local n = getNode(self, path)
    return n and ((n.meta & MVAL_TYPE_MASK) == MVAL_FILE)
end

-- Returns true if the path exists in the VFS
-- and the node is a directory
function VFS:dirExists(path)
    local n = getNode(self, path)
    return n and ((n.meta & MVAL_TYPE_MASK) == MVAL_DIR)
end

-- Returns the node present for the provided path
-- or nil if the node doesn't exist or it's not a file
function VFS:getFile(path)
    local n = getNode(self, path)
    if n and ((n.meta & MVAL_TYPE_MASK) == MVAL_FILE) then
        return n
    end
end

-- Returns the node present for the provided path
-- or nil if the node doesn't exist or it's not a directory
function VFS:getDir(path)
    local n = getNode(self, path)
    if n and ((n.meta & MVAL_TYPE_MASK) == MVAL_DIR) then
        return n
    end
end

-- Creates a new directory at the provided location.
function VFS:mkdir(path)
    local p = self:toAbsolute(path)
    
    local parent = getNode(self, p:parent())
    local dir = p:leaf()
    
    if not parent then
        error("Cannot mkdir: '" .. path .. "' as the parent does not exist!")
    elseif ((parent.meta & MVAL_TYPE_MASK) ~= MVAL_DIR) then
        error("Cannot mkdir: '" .. path .. "' as the parent is not a directory!")
    end
    
    if parent.data[dir.val] ~= nil then
        print("Cannot mkdir: '" .. path .. "' as an entry already exists!")
        return
    end
    
    parent.data[dir.val] = {
        ["data"] = {}, -- content
        ["meta"] = MVAL_DIR
    }
    
    if self.autoflush then
        self:flush()
    end
end

-- Returns the files and directories in the
-- folder specified.
--
-- Returns 2 arrays, files & dirs
function VFS:ls(path)
    local node = self:getDir(path)
    
    if node == nil then
        print("Folder does not exist: " .. path)
        return nil
    end
    
    local files = {}
    local dirs = {}
    
    for k, v in pairs(node.data) do
        if ((v.meta & MVAL_TYPE_MASK) == MVAL_DIR) then
            table.insert(dirs, k)
        else
            table.insert(files, k)
        end
    end
    
    return files, dirs
end

-- Opens a file at the specified 'path' using 'mode'.
--
-- This is equivalent to using io.open(file_path, mode)
-- and the returned value is the same.
--
-- Use io.close(file) when finished accessing the file.
function VFS:open(path, mode)
    local p = self:toAbsolute(path)
    
    local node = self:getFile(path)
    if not node then
        local filename = tostring(self.nodes.next_index) .. ".txt"
        
        local parent = getNode(self, p:parent())
        local file = p:leaf().val
        
        parent.data[file] = {
            ["file"] = filename,
            ["meta"] = MVAL_FILE
        }
        self.nodes.next_index = self.nodes.next_index + 1
        
        if self.autoflush then
            self:flush()
        end
        
        return io.open(self.vfs_root .. filename, mode)
    else
        return io.open(self.vfs_root .. node.file, mode)
    end
end

-- Removes the specified file or directory from
-- the VFS. Directories are removed recursively.
function VFS:rm(path)
    
    if path == "/" then
        print("Unable to delete root directory ('/')")
        return
    end
    
    local p = self:toAbsolute(path)
    
    local node = getFile(self, path)
    if node then
        
        -- Remove reference from parent node
        local file = p:leaf().val
        local parent = getNode(self, p:parent())
        parent.data[file] = nil
        
        -- Delete the file
        os.remove(self.vfs_root .. node.file)
       
        -- Flush to disk
        if self.autoflush then
            self:flush()
        end 
    else
        node = getDir(self, path)
        if node then
            
            -- Recursively delete contents
            for name,v in pairs(node.data) do
                if ((v.meta & MVAL_TYPE_MASK) == MVAL_DIR) then
                    self:rm(path .. "/" .. name) -- recurse
                else
                    os.remove(self.vfs_root .. v.file)
                    node.data[name] = nil
                end
            end
            
            -- Remove reference from parent node
            local dir = p:leaf().val
            local parent = getNode(self, p:parent())
            parent.data[dir] = nil
            
            -- Flush to disk
            if self.autoflush then
                self:flush()
            end 
        end
    end
end
