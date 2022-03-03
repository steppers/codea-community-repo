
function main()
    local webview = WebView(asset.doc.index)
    webview:show()
    viewer.mode = FULLSCREEN
end
    
function demo1()
    
    -- JS only webview (no HTML provided)
    local webview = WebView()
    
    -- Registered functions made available to JS!
    -- (Return values not yet supported)
    webview:import({
        ["print"] = function(...)
            print(...)
        end,
        ["WIDTH"] = WIDTH,
        ["HEIGHT"] = HEIGHT,
        viewer = {
            mode = viewer.mode,
            isPresenting = viewer.isPresenting,
            warning = function(msg)
                objc.warning(msg)
            end
        },
        FULLSCREEN = FULLSCREEN,
        
        testFunc = function()
            print("Called testFunc")
            return 6
        end
    })
    
    webview:proxy("viewer", viewer)
    
    -- Load JavaScript string
    webview:loadJS([[
        // Functions can accept parameters from Lua!
        function main(num1, num2) {
    
            //viewer.mode = FULLSCREEN;
    
            // Can call registered Lua functions!
            print("Hello JavaScript!");
    
            // Access the global
            print(`Screen dimensions = ${WIDTH}x${HEIGHT}`);
    
            viewer.warning("I'm a warning!");
    
            testFunc()
                .then((r) => print(`${r}`))
            
            // Values can be returned to Lua!
            return num1 + num2;
        }
    ]])
    
    -- Can call a JS function with arguments and get the result!
    local result = webview:call("main", 9, 7)
    print("Result: ", result)
end

function demo2()
    
    -- Load and show a HTML page from disk
    local webview = WebView(asset.core)
    webview:show()
    
    -- Registered functions made available to JS!
    -- (Return values not yet supported)
    webview:import("print", function(...)
        print(...)
    end)
    
    webview:importJSModule('https://cdn.skypack.dev/three@0.132.2', nil, 'THREE')
    
    -- Call a function defined in the HTML file
    webview:call("htmlTest")
end

function demo3()
    -- Load and display a simple HTML page
    local webview = WebView([[
        <center>
            <br/>
            <br/>
            Hello Codea!
            <br/>
            I came from a string :)
        </center>
    ]])
    webview:show()
end

function demo4()
    -- JS only webview (no HTML provided)
    local webview = WebView()
    
    -- Registered functions made available to JS!
    -- (Return values not yet supported)
    local imports = {
        ["print"] = function(...)
            print(...)
        end,
        ["helloWorld"] = function()
            print("Hello Codea!")
        end
    }
    webview:import(imports)
    
    -- Load JavaScript string
    webview:loadJS([[
        // Functions can accept parameters from Lua!
        function main(num1, num2) {
    
            // Can call registered Lua functions!
            print("Demo 4 -----");
    
            // Call imported function!
            helloWorld();
            
            // Values can be returned to Lua!
            return num1 * num2;
        }
    ]])
    
    -- Can call a JS function with arguments and get the result!
    local result = webview:call("main", 9, 9)
    print("Result: ", result)
end

function touched(t)
    print("touch")
end
