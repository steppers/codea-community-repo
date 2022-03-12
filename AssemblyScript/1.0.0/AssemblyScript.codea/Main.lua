
local webview
local asc

function main()
    
    -- Initialise a shared compiler
    asc = ASCompiler()
    
    -- Initialise a shared WebView
    webview = WebView()
    
    -- Run the demos
    demo_simple()
    print() -- blank line
    
    demo_compile_and_save()
    print() -- blank line
    
    demo_load_and_run()
    print() -- blank line
    
    demo_multi_source()
    print() -- blank line
    
    demo_imports()
end


function demo_simple()
    
    -- Compile a simple script
    local bin = asc:compile([[
        export function main(): u32 {
            print("[demo_simple] Hello Codea!");
            return 5;
        }
    ]])
    print("[demo_simple] compiled")
    
    -- Load it into the webview
    local module = bin:load(webview)
    
    -- Call the exported main() function
    print("[demo_simple] returned: " .. module:call("main"))
end




function demo_compile_and_save()
    
    -- Compile a simple script
    local bin = asc:compile([[
        export function main(): u32 {
            print("[demo_load_and_run] Hello Codea!");
            return 9;
        }
    ]])
    print("[demo_compile_and_save] compiled")
    
    -- Save it to disk
    bin:save(asset .. "app.wasm")
    
    print("[demo_compile_and_save] Saved to disk")
end




function demo_load_and_run()
    
    -- Load script from disk
    local bin = ASBinary(asset .. "app.wasm")
    
    print("[demo_load_and_run] Loaded from disk")
    
    -- Load it into the webview
    local module = bin:load(webview)
    
    -- Call the exported main() function
    print("[demo_load_and_run] returned: " .. module:call("main"))
end




function demo_multi_source()
    
    -- Sources
    local src_lib1 = ASSource(
        'lib1',                             -- Source name
        "export const DEMO_VAL: u32 = 32;"  -- Source
    )
    
    local src_lib2 = ASSource('lib2', [[
        export function Times4(val: u32): u32 {
            return val * 4;
        }
    ]])
    
    local src_main = ASSource('main', [[
        import { DEMO_VAL } from 'lib1';
        import { Times4 } from 'lib2';
    
        export function main(): u32 {
            return Times4(DEMO_VAL);
        }
    ]],
    nil, -- No imports
    { src_lib1, src_lib2 }) -- 2 dependencies
    
    -- Compile a the main script
    local bin = asc:compile(src_main)
    print("[demo_multi_source] compiled")
    
    -- Load it into the webview
    local module = bin:load(webview)
    
    -- Call the exported main() function
    print("[demo_multi_source] returned: " .. module:call("main"))
end




function demo_imports()
    
    -- Source
    local src_main = ASSource('main', [[
        declare function getLuaVersion(): string;
        declare const LUA_VERSION: string;
        declare const IMPORT_VAL: u32;
    
        export function main(): void {
            print(`[demo_imports] Lua: ${getLuaVersion()}`);
            print(`[demo_imports] Imported val: ${IMPORT_VAL}`);
            print(`[demo_imports] Lua string: ${LUA_VERSION}`);
        }
    ]],
    {
        -- Imports, these map values declared in AssemblyScript
        -- to values provided by JavaScript.
        --
        -- These can provide functions
        ["getLuaVersion(): string"] = [[
            () => codea.lua_version // Read JS imported value
        ]],
        
        -- Or values directly
        ["IMPORT_VAL: u32"] = 970932,
        
        -- String values are NOT currently supported
        -- and will always evaluate to 'undefined'
        ["LUA_VERSION: string"] = "codea.lua_version"
    })
    
    -- Import the Lua version into JS
    webview:import("codea", {
        lua_version = _VERSION
    })
    
    -- Compile a the main script
    local bin = asc:compile(src_main)
    print("[demo_imports] compiled")
    
    -- Load it into the webview
    local module = bin:load(webview)
    
    -- Call the exported main() function
    module:call("main")
end
