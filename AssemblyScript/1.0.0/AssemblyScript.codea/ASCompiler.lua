local __CODEA_AS_VERSION__ = readText(asset .. ".webrepo_version") or "1.0.0"

srcCodea = ASSource("codea", string.format([[

    // Internal
    declare function _error(msg: string): void;

    // Logging functions
    @global declare function print(msg: string): void;
    @global declare function warning(msg: string): void;
    @global function error(msg: string): void {
        _error('[ERR] ' + msg);
    }

    @global
    const __CODEA_AS_VERSION__ = '%s';

]], __CODEA_AS_VERSION__), {
    ["print(msg: string): void"] = "console.log",
    ["warning(msg: string): void"] = "console.warning",
    ["_error(msg: string): void"] = "console.error"
})

ASCompiler = class()

function ASCompiler:init()
    self.webview = WebView()

    -- Import terser (JS minifier)
    self.webview:loadJS("https://cdn.jsdelivr.net/npm/source-map@0.7.3/dist/source-map.js", true)
    self.webview:loadJS("https://cdn.jsdelivr.net/npm/terser/dist/bundle.min.js", true)
    
    -- Import require.js
    self.webview:loadJS("https://requirejs.org/docs/release/2.3.6/minified/require.js", true)
    
    -- Add AssemblyScript compiler
    self.webview:loadJS(string.format([==[
        const ascPromise = new Promise((resolve, reject) => {
            require(["https://cdn.jsdelivr.net/npm/assemblyscript@latest/dist/sdk.js"], ({ asc }) => {
                asc.ready.then(() => {
                    resolve(asc);
                });
            });
        });
                    
        async function compile(src, optimisationLevel)
        {
            // Wait for the compiler to load first
            let asc = await ascPromise;
                    	
            var options = {}
            options.optimizeLevel = optimisationLevel;
            options.exportRuntime = true;
            options.exportTable = true;
            options.importMemory = true;
            options.memoryBase = (20 + 'undefined'.length << 1);
            options.lib = "./"; // Allows for importing without './'
            // options.enable = [ 'threads' ];
                    
            const { text, binary, stderr } = asc.compileString(src, options);
    
            // Print errors
            if (binary === undefined) {
                return [ stderr.toString() ];
            }
    
            return [text, Array.from(binary)];
        }

        async function minifyImports(imports) {
            for (let mod in imports) {
                for (let imp in imports[mod]) {
                    let code = imports[mod][imp];
                    
                    // Use Terser to minimise the import code
                    const min = await Terser.minify(code.toString(), {
                        parse: {
                            bare_returns: true
                        }
                    });

                    // Overwrite with minimised code
                    imports[mod][imp] = min.code;
                }
            }

            return imports;
        }
    ]==], __CODEA_AS_VERSION__), true)
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

    -- Wrap import code in a return statement.
    local originalImports = imports
    local imports = {}
    for mod, modImports in pairs(originalImports) do
        imports[mod] = {}
        for i, code in pairs(modImports) do
            imports[mod][i] = "return (" .. code .. ")"
        end
    end    

    -- Minify imports
    imports = self.webview:call("minifyImports", imports)

    -- Compile!
    local wasmText, wasmBin = table.unpack(self.webview:call("compile", source, optimisationLevel or 0))
    
    if wasmBin == nil then
        ST.runMain(objc.warning, wasmText)
        ST.abort()
    end
        
    return ASBinary(wasmBin, wasmText, imports)
end
