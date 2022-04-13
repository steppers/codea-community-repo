-- Contents:
--    ASSource.lua
--    ASCompiler.lua
--    ASBinary.lua

------------------------------
-- ASSource.lua
------------------------------
do
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

end
------------------------------
-- ASCompiler.lua
------------------------------
do
local __CODEA_AS_VERSION__ = readText(asset .. ".webrepo_version") or "1.0.0"

srcCodea = ASSource("codea", asset.documents.AssemblyScript.libs.codea)

ASCompiler = class()

function ASCompiler:init()
    self.webview = WebView(asset.documents.AssemblyScript.html.index)

    -- Import terser (JS minifier)
    self.webview:loadJS("https://cdn.jsdelivr.net/npm/source-map@0.7.3/dist/source-map.js", true)
    self.webview:loadJS("https://cdn.jsdelivr.net/npm/terser/dist/bundle.min.js", true)
    
    -- Import require.js
    self.webview:loadJS("https://requirejs.org/docs/release/2.3.6/minified/require.js", true)
    
    -- Add AssemblyScript compiler
    self.webview:loadJS(asset.documents.AssemblyScript.js.compiler, true)
end

function ASCompiler:compile(sources, optimisationLevel)
    
    -- Convert string to array
    if type(sources) == 'string' then
        sources = { ASSource('user', sources) }
    end
    
    -- Convert to array
    if type(sources) == 'table' and sources._class_type == 'ASSource' then
        sources = { sources }
    end

    -- Check we actually have sources
    assert(#sources > 0, "No sources provided! Is your first provided source nil?")


    -- Check none of the passed sources are nil
    -- and track all provided source names
    local source_names = {}
    for i = 1, #sources do
        local s = sources[i]
        if s == nil then
            ST.runMain(error, "\n\nYour source @ index " .. i .. " was nil! I doubt this was what you intended.\n\n")
        else
            if source_names[s.name] then
                print("Duplicate AS source: " .. s.name)
            end
            source_names[s.name] = true
        end
    end

    -- Add all dependencies
    do
        local i = 1
        while i <= #sources do
            local s = sources[i]
            
            for _,dep in ipairs(s.dependencies) do
                -- Is the dependency already added?
                if source_names[dep.name] == nil then
                
                    -- Add the new dependency
                    source_names[dep.name] = true
                    table.insert(sources, dep)
                end        
            end
        
            -- Check next source
            i = i + 1
        end
    end

    -- Add builtin sources
    table.insert(sources, srcCodea)
    
    local source = {}
    local imports = {}
    for i = 1, #sources do
        local s = sources[i]
        source[s.name .. ".ts"] = s.source
        imports[s.name] = s.imports
    end

    -- Compile!
    local wasmText, wasmBin, bindings = table.unpack(self.webview:call("compile", source, optimisationLevel or 0))
    
    if wasmBin == nil then
        ST.runMain(objc.warning, wasmText)
        ST.abort()
    end
    
    -- Fixup JS binding code for Codea integration
    bindings = bindings:gsub("export async function instantiate", "async function __AssemblyScriptInstantiate")
    bindings = bindings:gsub("const { exports } = await WebAssembly%.instantiate%(module, adaptedImports%);", "const { instance } = await WebAssembly.instantiate(module, adaptedImports); const exports = instance.exports;")
    
    -- Include all of our imports in the JS bindings
    for module, mod_imports in pairs(imports) do
        local mod = {}
        
        for name, body in pairs(mod_imports) do
            -- Start at module root
            local curr = mod
            local target = nil
            local leaf_name = nil
            
            -- Get to target level
            for p in name:gmatch("[^%.]*") do
                target = curr
                
                if curr[p] == nil then
                    curr[p] = {}
                end
                
                curr = curr[p]
                leaf_name = p
            end
            
            -- Strip trailing comments
            if type(body) == "string" then
                body = body:gsub("%s*//[^\n]-$", "")
            end
            
            -- Add the import body
            target[leaf_name] = body
        end
        
        -- Generate the module's JS object representation
        local t = { "{\n" }
        local function add_imports(imports, level)
            level = level or 1
            for name, body in pairs(imports) do
                if type(body) == "table" then
                    table.insert(t, string.rep("\t", level))
                    table.insert(t, string.format("%s: {\n", name))
                    
                    add_imports(body, level + 1)
                    
                    table.insert(t, string.rep("\t", level))
                    table.insert(t, "},\n")
                else
                    if type(body) == "string" then
                        -- Strip trailing comments
                        body = body:gsub("%s*//[^\n]-$", "")
                    end
                    
                    table.insert(t, string.rep("\t", level))
                    table.insert(t, string.format("%s: %s,\n", name, body))
                end
            end
        end
        add_imports(mod)
        table.insert(t, "  }")
        
        -- Add the module to the JS bindings
        bindings = bindings:gsub("imports." .. module .. ";", table.concat(t) .. ";")
    end
	
    -- Add '__liftFunction' to the JS bindings
    bindings = bindings:gsub("return exports;",
    [[const table = exports.table;
  __liftFunction = (pointer) => {
    if (!pointer) return null;
    const fnIndex = new Uint32Array(memory.buffer, pointer, 1)[0];
	return table.get(fnIndex);
  }
  return exports;]])
    
    -- Minify the JS bindings
    bindings = self.webview:call("minify", bindings)
    
    return ASBinary(wasmBin, wasmText, bindings)
end

end
------------------------------
-- ASBinary.lua
------------------------------
do
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

end
