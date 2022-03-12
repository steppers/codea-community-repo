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
