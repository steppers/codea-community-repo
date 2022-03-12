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
    self.source = source
    self.imports = imports or {}
    
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

local validTypes = {
    ["string"]  = true,
    ["u8"]      = true,
    ["u16"]     = true,
    ["u32"]     = true,
    ["u64"]     = true,
    ["i8"]      = true,
    ["i16"]     = true,
    ["i32"]     = true,
    ["i64"]     = true,
    ["f32"]     = true,
    ["f64"]     = true,
    ["void"]    = true,
    ["bool"]    = true,
    ["isize"]    = true,
    ["usize"]    = true,
    ["function"] = true
}

local function parseFunctionSignature(signature)
    local name = signature:match("^ *([^%(: ]*)")
    local params = signature:match("%((.-)%)") or ""
    local returnType = signature:match("%) *: *([^ ]*)") or "void"
    
    assert(validTypes[returnType], "Attempting to use unsupported return type: " .. returnType)
    
    local paramTypes = {}
    for p in params:gmatch(",? *([^,]+)") do
        p = p:match("[^ :]*$")
        assert(validTypes[p], "Attempting to use unsupported type: " .. p)
        table.insert(paramTypes, p)
    end
    
    return name, paramTypes, returnType
end





function ASBinary:init(bin, binText, imports)
    
    assert(bin, "Compiled Assembly Script must be provided")
    
    -- TODO: fixup asserts
    if type(bin) == 'table' then -- Byte array
        self.bin = bin
    elseif type(bin) == 'string' then -- Binary string
        self.bin = table.pack(bin:byte(1, -1))
        self.bin.n = nil
    else -- Asset (read from disk)
        
        -- TODO: support import overrides
        assert(imports == nil, "Imports are also read from disk!")
        
        local f = io.open(bin.path, "rb")
        self.bin = table.pack(f:read("*a"):byte(1, -1))
        self.bin.n = nil
        f:close()
        
        -- Read .jsimports file too!
        f = io.open(bin.path .. "_jsimports", "r")
        imports = json.decode(f:read("*a"))
        f:close()
    end
    
    self.text = binText
    self.imports = imports
end

function ASBinary:save(assetFile, writeText)
    local f = io.open(assetFile.path, 'wb')
    f:write(string.char(table.unpack(self.bin)))
    f:close()
    
    f = io.open(assetFile.path .. "_jsimports", 'wb')
    f:write(json.encode(self.imports, { indent = true }))
    f:close()
    
    if self.text and writeText then
        f = io.open(assetFile.path .. ".txt", 'w')
        f:write(self.text)
        f:close()
    end
end

function ASBinary:load(webview)
  
    local id = getUniqueID()
    
    -- Parse our imports
    local imports = {}
    for module, modImports in pairs(self.imports) do
        local t = {}
        for k, fnBody in pairs(modImports) do
            local name, pTypes, rType = parseFunctionSignature(k)
            table.insert(t, {
                asName = name,
                asPTypes = pTypes,
                asRType = rType,
                fnBody = fnBody
            })
        end
        imports[module] = t
    end
        
    -- Only add the loader function once
    if not webview.__loadAssemblyScriptWASM_Added then
        webview:loadJS([==[
            async function __loadAssemblyScriptWASM(wasm, id, in_imports)
            {
                let mem = new WebAssembly.Memory({initial:10});
                let table = null;
        
                // Add static 'undefined' string in memory
                {
                    const str = 'undefined';
                    const len = str.length;
                    const ptr = 20;
        
                    const U32 = new Uint32Array(mem.buffer, ptr-8, 2);
                    U32[0] = 1;             // String class id
                    U32[1] = len << 1;      // String length
        
                    const U16 = new Uint16Array(mem.buffer, ptr, len);
                    for (var i = 0; i < len; ++i)
                    {
                        U16[i] = str.charCodeAt(i);
                    }
                }
        
                // Maps Assembly Script values to equivalent values in JS
                const paramMap = {
                    "string": (addr) => {
                        // Get length
                        var m = new Uint32Array(mem.buffer, addr-4, 1);
                        const len = m[0];
        		
                        // Get actual string memory
                        m = new Uint8Array(mem.buffer, addr, len);
        		
                        // Decode the memory to form the string!
                        var decoder = new TextDecoder("utf-16");
                        const str = decoder.decode(m.slice(0, len));
                        return str;
                    },
                    "function": (addr) => {
                        // Get function index
                        const fnIndex = new Uint32Array(mem.buffer, addr, 1)[0];
                        return table.get(fnIndex);
                    }
                }
        
                // Maps JS values back to values Assembly Script can understand
                const retMap = {
                    "string": (str) => {
                        /** Allocates a new string in the module's memory and returns its pointer. */
                        if (str == null) return 0;
                        const length = str.length;
                        const ptr = window[id].instance.exports.__new(length << 1, 1);
                        const U16 = new Uint16Array(mem.buffer);
                        for (var i = 0, p = ptr >>> 1; i < length; ++i) U16[p + i] = str.charCodeAt(i);
                        return ptr;
                    }
                }
            
                // Blank imports object
                var imports = {
                    builtin: {},
                    env: {
                        abort: (message) => {
                            console.log(`[AS] ABORT: ${message} ${mmem}`);
                        },
                        memory: mem
                    }
                };
        
                // Populate imports for each module
                for (const module in in_imports) {
        
                    // Empty imports table
                    imports[module] = {};
        
                    in_imports[module].forEach( entry => {
                        const name = entry.asName;
                        const pTypes = entry.asPTypes;
                        const fnBody = entry.fnBody;
            
                        const fn = Function(fnBody)();
                        
                        if (typeof fn === 'string') {
                            console.warning(`[AS] String imports are not supported! Import: '${name}'`);
                            imports[module][name] = 20;
                        } else if (typeof fn !== 'function') {
                            imports[module][name] = fn;
                        } else {
                            imports[module][name] = function(args) {
                                //console.log(`call ${name}() with ${arguments.length} args`);
                
                                let params = Array.from(arguments).map( (arg, index) => {
                                    if (paramMap[pTypes[index]] === undefined) return arg;
                                    return paramMap[pTypes[index]](arg);
                                });
                    
                                let result = fn.apply(null, params);
                                
                                if (retMap[entry.asRType] === undefined) return result;
                                return retMap[entry.asRType](result);
                            }
                        }
                    });
                }
        
                const loadPromise = new Promise((resolve, reject) => {
                    WebAssembly.instantiate(new Uint8Array(wasm), imports)
                    .then(obj => {
                        mem = obj.instance.exports.memory;
                        table = obj.instance.exports.table;
        
                        /** Allocates a new string in the module's memory and returns its pointer. */
                        obj.__newString = function(str) {
                            if (str == null) return 0;
                            const length = str.length;
                            const ptr = obj.instance.exports.__new(length << 1, 1);
                            const U16 = new Uint16Array(mem.buffer);
                            for (var i = 0, p = ptr >>> 1; i < length; ++i) U16[p + i] = str.charCodeAt(i);
                            return ptr;
                        }
        
                        window[id] = obj;
                        resolve(obj);
                    })
                    .catch( error => {
                        console.error('[AS] ' + error);
                        reject();
                    });
                });
            	
                // Wait for the wasm to be instantiated
                await loadPromise.catch(() => {});
            }
        
            function __callAssemblyScriptFunction(id, fnName, retType, args) {
                let params = Array.from(arguments);
                params.splice(0, 3);
                
                params = Array.from(params).map( (arg, index) => {
                    if (typeof arg === 'string') {
                        return window[id].__newString(arg);
                    }
                    return arg;
                });
                                    
                const fn = window[id].instance.exports[fnName];
                if (fn === undefined) {
                    throw new Error(`[AS] Function '${fnName}' does not exist! Has it been exported?`);
                }
        
                var result = fn(...params);
                if (retType === 'string') {
                    const mem = window[id].instance.exports.memory;
        
                    // Get length
                    var m = new Uint32Array(mem.buffer, result-4, 1);
                    const len = m[0];
        		
                    // Get actual string memory
                    m = new Uint8Array(mem.buffer, result, len);
        		
                    // Decode the memory to form the string!
                    var decoder = new TextDecoder("utf-16");
                    result = decoder.decode(m.slice(0, len));
                }
        
                return result;
            }
        ]==], true)
        webview.__loadAssemblyScriptWASM_Added = true
    end
    
    webview:call("__loadAssemblyScriptWASM", self.bin, id, imports)
    
    -- Return an instance of the AS module to track the id used
    return ASInstance(webview, id)
end

function ASInstance:init(webview, id)
    self.webview = webview
    self.id = id
end

function ASInstance:call(funcName, ...)
    local retType = funcName:match(": *([^ ]*)$") or "void"
    funcName = funcName:match("^ *([^ :]*)")
    return self.webview:call("__callAssemblyScriptFunction", self.id, funcName, retType, ...)
end

end
