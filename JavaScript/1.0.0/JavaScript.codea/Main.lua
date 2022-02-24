
function main()
    demo1()
    --demo2()
    --demo3()
    --demo4()
end
    
function demo1()
    
    -- JS only webview (no HTML provided)
    local webview = WebView()
    
    -- Registered functions made available to JS!
    -- (Return values not yet supported)
    webview:register("print", function(...)
        print(...)
    end)
    
    -- Load JavaScript string
    webview:loadJS([[
        // Functions can accept parameters from Lua!
        function main(num1, num2) {
    
            // Can call registered Lua functions!
            print("Hello JavaScript!");
            
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
    webview:register("print", function(...)
        print(...)
    end)

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
    webview:register(imports)
    
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
