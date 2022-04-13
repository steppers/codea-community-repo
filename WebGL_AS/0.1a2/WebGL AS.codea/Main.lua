
--[[
    WebGL AssemblyScript
    ===============================================

    This a WIP example project utilising some
    of the more advanced features available to
    the AssemblyScript Codea project.

    -----------------------------------------------

    I hope to make this available eventually as a
    complete WebGL binding for AssemblyScript.
    
    -----------------------------------------------
    
    Icon from https://icons8.coms
]]--

local OPTIMISATION = 0 -- (0 - 3)

local USER_SRC = [==[
    export function main(): void {
        if (!glas.init()) {
            return;
        }
        glas.setLoopFunction(loop);

        let res = glas.getDisplayResolution();
        print(`Resolution: ${res.x} x ${res.y}`);
    }

    let time: f64 = 0.0;

    function loop(dt: f32): void {
        
        // Accumulate time values
        time += dt;

        // Generate 0 - 1 sin wave.
        let v = f32(Math.sin(time - Math.PI/2) / 2) + 0.5;
        
        // Clear screen with sin wave Black <-> White
        glClearColor(v, v, v, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
    }
]==]

function main()
        
    local asc = ASCompiler()
    
    -- Create our source object
    local source = ASSource(
        'user',             -- script name
        USER_SRC,           -- our AssemblyScript source
        nil,                -- No imports
        { GLAS }            -- Just GLAS as a dependency
    )
    
    -- Compile our sources!
    local asbin = asc:compile(source, OPTIMISATION)
    --asbin:save(asset .. "app")
    
    --local asbin = ASBinary(asset .. "app")
    
    -- Create the webview we'll use
    local webview = WebView()
    webview:show()
    
    -- Load the compiled AssemblyScript & call main()
    asbin:load(webview):call("main")
end
