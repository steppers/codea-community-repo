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
