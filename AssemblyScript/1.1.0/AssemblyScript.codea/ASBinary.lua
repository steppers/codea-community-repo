ASBinary = class()
ASInstance = class()

local ids = {}
local function getUniqueID()
    local id = string.format("%016x", math.random(math.mininteger, math.maxinteger))
    -- Ensure it's unique
    while ids[id] == true do
        id = string.format("%016x", math.random(math.mininteger, math.maxinteger))
    end
    ids[id] = true -- reserve the id
    return id
end

function ASBinary:init(bin, binText, bindings)
    
    assert(bin, "Compiled Assembly Script must be provided")
    
    -- TODO: fixup asserts
    if type(bin) == 'table' then -- Byte array
        self.bin = bin
    elseif type(bin) == 'string' then -- Binary string
        self.bin = table.pack(bin:byte(1, -1))
        self.bin.n = nil
    else -- Asset (read from disk)
        
        local f = io.open(bin.path .. ".wasm", "rb")
        self.bin = table.pack(f:read("*a"):byte(1, -1))
        self.bin.n = nil
        f:close()
        
        -- Read .js bindings file too!
        f = io.open(bin.path .. ".js", "r")
        bindings = f:read("*a")
        f:close()
    end
    
    self.text = binText
    self.bindings = bindings
end

function ASBinary:save(assetFile, writeText)
    local f = io.open(assetFile.path .. ".wasm", 'wb')
    f:write(string.char(table.unpack(self.bin)))
    f:close()
    
    if self.text and writeText then
        f = io.open(assetFile.path .. ".txt", 'w')
        f:write(self.text)
        f:close()
    end
    
    f = io.open(assetFile.path .. ".js", 'wb')
    f:write(self.bindings)
    f:close()
end

function ASBinary:load(webview)
  
    local id = getUniqueID()
    
    -- Load the JS bindings file (also includes our imports)
    webview:loadJS(self.bindings, true)
    
    -- Only add the loader function once
    if not webview.__loadAssemblyScriptModule_Added then
        webview:loadJS([==[
            async function __loadAssemblyScriptModule(wasm, id) {
                let mem = new WebAssembly.Memory({initial:10});
        
                // Blank imports object
                var imports = {
                    builtin: {},
                    env: {
                        memory: mem
                    }
                };
        
                window[id] = await __AssemblyScriptInstantiate(new Uint8Array(wasm), imports);
            }
        
            function __callAssemblyScriptFunction(id, fnName, ...args) { 
                const fn = window[id][fnName];
                if (fn === undefined) {
                    throw new Error(`[AS] Function '${fnName}' does not exist! Has it been exported?`);
                }
                return fn(...args);
            }
        ]==], true)
        webview.__loadAssemblyScriptModule_Added = true
    end
    
    -- Load the module
    webview:call("__loadAssemblyScriptModule", self.bin, id)
    
    -- Return an instance of the AS module to track the id used
    return ASInstance(webview, id)
end

function ASInstance:init(webview, id)
    self.webview = webview
    self.id = id
end

function ASInstance:call(funcName, ...)
    return self.webview:call("__callAssemblyScriptFunction", self.id, funcName, ...)
end
