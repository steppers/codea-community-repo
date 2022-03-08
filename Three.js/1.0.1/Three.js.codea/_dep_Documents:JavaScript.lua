-- Contents:
--    Main.lua
--    WebView.lua

------------------------------
-- Main.lua
------------------------------
do

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

end
------------------------------
-- WebView.lua
------------------------------
do
---
-- @module JavaScript

local socket = require("socket")

WebView = class()
local WebViewMessageHandler = class()
local WebViewURLSchemeHandler = class()

-- Import STLib objects
assert(ST ~= nil, "WebView usage relies on STLib!")
local runMain = ST.runMain
local Promise = ST.Promise
local yield = ST.yield


function WebViewMessageHandler:init()
    self.handlers = {}
    local handlers = self.handlers

    local Handler = objc.delegate("WKScriptMessageHandlerWithReply")
    function Handler:userContentController_didReceiveScriptMessage_replyHandler_(objUserContentController, objMessage, p)
        -- TODO: support replyHandler function
        local msg = objMessage.body
        local handler = handlers[msg.__fn]
        local ret
        if handler then ret = handler(table.unpack(msg.args)) end
    end

    self.handler = Handler()
    
    self:setHandler("__print", function(...)
        print("[JS]", ...)
    end)
end

function WebViewMessageHandler:setHandler(name, func)
    self.handlers[name] = func
end

-- A content controller can only use 1 handler at a time in Codea currently.
-- All are given the name 'codea'
function WebViewMessageHandler:register(userContentController)
    userContentController:addScriptMessageHandlerWithReply_contentWorld_name_(self.handler, objc.cls.WKContentWorld.pageWorld, "codea")
end





-- Default URL scheme handler 'codea://' reads resources from the
-- current project's asset folder.
function WebViewURLSchemeHandler:init()
    if WebViewURLSchemeHandler.Handler == nil then
        WebViewURLSchemeHandler.Handler = objc.delegate("WKURLSchemeHandler")
        
        local mimeType = {
            txt         = "text/plain",
            png         = "image/png"
        }
        
        WebViewURLSchemeHandler.Handler.webView_startURLSchemeTask_ = function(self, objWebView, objUrlSchemeTask)
                
            local url = objUrlSchemeTask.request.URL
                
            -- Get the file path
            local path = url.absoluteString:gsub("codea://", "")
            path = socket.url.unescape(path)
            local ext = path:match("%.(.-)$")
                
            -- Read the file into NSData
            local data = objc.cls.NSData:dataWithContentsOfFile_(asset.path .. "/" .. path)
                
            -- Create the response
            local response = objc.cls.NSHTTPURLResponse:alloc()
            response:initWithURL_statusCode_HTTPVersion_headerFields_(url, 200, "HTTP/1.1", {
                ["Access-Control-Allow-Origin"] = "*",
                ["Content-Type"] = mimeType[ext] or "application/octet-stream"
            })
                
            objUrlSchemeTask:didReceiveResponse_(response)
            objUrlSchemeTask:didReceiveData_(data)
            objUrlSchemeTask:didFinish()
        end
    end
    self.handler = WebViewURLSchemeHandler.Handler()
end

function WebViewURLSchemeHandler:register(config)
    config:setURLSchemeHandler_forURLScheme_(self.handler, "codea")
end





local function importInternals(webview)
    -- Import some functions for internal use
    webview:import({
        ["__updateGlobal"] = function(key, value)
            local last = nil
            local cur = nil
            for k in key:gmatch("[^%.]*") do
                if cur == nil then
                    cur = _G
                else
                    cur = cur[last]
                end
                last = k
            end
            cur[last] = value
        end,
    })
end


--- Create a new WebView.
-- @param htmlAsset (optional) HTML string or Codea asset to load immediately
-- @return new WebView instance
-- @function WebView
-- @usage local webview = WebView()
-- @usage local webview = WebView([[
-- <body>
-- 	Hello World!
-- </body>	
-- ]])
-- @usage local webview = WebView(asset.index_html)


--- Object representing a single WKWebView.
-- @type WebView

function WebView:init(htmlAsset)
    
    assert(ST.IsSThread(), "WebView usage relies on STLib.\n\nPlease use 'main()' to handle project execution.\n")
    
    runMain(function()
        -- Add Codea message handler
        local controller = objc.cls.WKUserContentController()
        self.handler = WebViewMessageHandler()
        self.handler:register(controller)
        
        -- Create the WebView config
        local config = objc.cls.WKWebViewConfiguration()
        config.userContentController = controller
        self.urlSchemeHandler = WebViewURLSchemeHandler()
        self.urlSchemeHandler:register(config)
        
        -- New view
        self.view = objc.cls.WKWebView:alloc()
        self.view:initWithFrame_configuration_(objc.viewer.view.bounds, config)
        
        -- Avoid white flash
        self.view.opaque = false
        self.view.backgroundColor = objc.cls.UIColor.blackColor
        
        -- Enable input handling by default
        self:enableInputHandling(true)
    end)
    
    -- Trigger a page load
    if htmlAsset then
        self:loadHTML(htmlAsset)
    end
    
    -- Import functions for internal use
    importInternals(self)
end

local function loadJSFromSource(view, jsSource, async)
    local sem = ST.Semaphore()
    
    runMain(function()
        view:evaluateJavaScript_inFrame_inContentWorld_completionHandler_(
            jsSource,
            nil,
            objc.cls.WKContentWorld.pageWorld,
            function(objResult, objError)
                if objError then
                    local info = objError.userInfo
                    local err = string.format("%d:%d %s",
                        info.WKJavaScriptExceptionLineNumber,
                        info.WKJavaScriptExceptionColumnNumber,
                        info.WKJavaScriptExceptionMessage)
                    objc.warning(err)
                end
                sem:signal()
            end
        )
    end)
    
    -- Do we wait?
    if async == false then
        sem:wait()
    end
end

local function loadJSFromFile(view, jsAsset, async)
    local f = io.open(jsAsset.path, "r")
    local source = f:read("*a")
    f:close()
    loadJSFromSource(view, source, async)
end

local function loadJSFromURL(view, jsURL, async)
    local p = Promise()
    runMain(http.request, jsURL, function(data, status)
        p:resolve(data)
    end)
    loadJSFromSource(view, p:get(), async)
end

local function loadHTMLFromFile(view, htmlAsset)
    runMain(function()
        local request = objc.cls.NSURLRequest:requestWithURL_cachePolicy_timeoutInterval_(
            objc.cls.NSURL:URLWithString_("file://" .. htmlAsset.path),
            objc.enum.NSURLRequestCachePolicy.NSURLRequestReloadIgnoringCacheData,
            5.0)
        view:loadRequest_(request)
    end)
end

local function loadHTMLFromSource(view, htmlSource)
    runMain(function()
        view:loadHTMLString_baseURL_(htmlSource, objc.cls.NSURL:URLWithString_("file://" .. asset.path))
    end)
end

--- Evaluate JavaScript in the current page's JavaScript environment.
-- @param obj JavaScript source string or Codea asset containing JavaScript source to evaluate
-- @param async If true, returns immediately after handing JavaScript to WKWebView.
-- 		If false, returns only when the JavaScript is fully evaluated.
-- 		(default false)
function WebView:loadJS(obj, async)
    if type(obj) == "string" then
        if obj:match("^http") then
            loadJSFromURL(self.view, obj, async or false)
        else
            loadJSFromSource(self.view, obj, async or false)
        end
    elseif obj.path then
        loadJSFromFile(self.view, obj, async or false)
    end
end

--- Load HTML content into the WebView
-- Note: This resets the JavaScript environment.
-- @param obj HTML source or Codea asset containing HTML source
function WebView:loadHTML(obj)
    if type(obj) == "string" then
        loadHTMLFromSource(self.view, obj)
    elseif obj.path then
        loadHTMLFromFile(self.view, obj)
    end
	
	-- Wait for the load to complete
    while self.view.loading do
        yield()
    end
    
    -- Import functions for internal use
    importInternals(self)
end

--- Call a JavaScript function asynchronously.
-- @param funcName name of the JavaScript function to call
-- @param ... parameters to provide to the JavaScript function
-- @return Promise object that will return the result of the call once complete
function WebView:callAsync(funcName, ...)
    
    -- Form function call
    local call = {
        "return ", funcName, "("
    }
    
    -- Add args
    local args = {}
    for i,v in ipairs({...}) do
        local argName = "a" .. tostring(i)
        assert(type(v) ~= "userdata", "Userdata parameters cannot be passed to JS!")
        args[argName] = v
        if i > 1 then
            table.insert(call, ", ")
        end
        table.insert(call, argName)
    end
    
    -- Closing parenthesis
    table.insert(call, ");")
    
    -- Generate call string
    call = table.concat(call)
    
    local result = Promise()
    
    runMain(function()
        self.view:callAsyncJavaScript_arguments_inFrame_inContentWorld_completionHandler_(
            call,
            args,
            nil,
            objc.cls.WKContentWorld.pageWorld,
            function(objResult, objError)
                if objError then
                    local info = objError.userInfo
                    for k,v in pairs(info) do
                        objc.warning(k .. ": " .. v)
                    end
                end
                result:resolve(objResult)
            end
        )
    end)
    
    -- Return the promise
    return result
end

--- Call a JavaScript function.
-- @param funcName name of the JavaScript function to call
-- @param ... parameters to provide to the JavaScript function
-- @return The result of the call
function WebView:call(funcName, ...)
    return self:callAsync(funcName, ...):get()
end

--- Import Lua functions, tables or values into the JavaScript environment
--
-- Lua userdata types cannot be passed to JavaScript
--
-- @param name Name to give to the corresponsing object in JavaScript 
-- OR table of key-value pairs representing the values to import.
-- @param func Function, Value or Table to assign to the given object in JavaScript.
function WebView:import(name, func, _parent)
    
    -- Table of imports?
    if type(name) == "table" then
        for n,fn in pairs(name) do
            self:import(n, fn)
        end
        return
    end
    
    assert(type(name) == 'string')
    assert(type(func) ~= 'userdata', 'Userdata objects cannot be imported into JavaScript!')
    
    -- Is this a value rather than a function?
    if type(func) ~= "function" then
        if type(func) == "table" then
            
            if _parent == nil then
                self:loadJS(string.format([[
                    if (window['%s'] === undefined) {
                        window['%s'] = {};
                    }
                ]], name, name), true)
            else
                name = _parent .. "." .. name
                self:loadJS(string.format([[
                    if (%s === undefined) {
                        %s = {};
                    }
                ]], name, name), true)
            end
            
            for k,v in pairs(func) do
                self:import(k, v, name)
            end
        elseif _parent then
            self:callAsync("((v) => " .. _parent .. "." .. name .. " = v )", func)
        else 
            self:callAsync("((k,v) => window[k] = v )", name, func)
        end
        return
    end
    
    -- Append parent 
    if _parent then
        name = _parent .. "." .. name
    end

    -- Add our JS function wrapper
    self:loadJS(string.format([[
        %s = function(args) {
            return window.webkit.messageHandlers.codea.postMessage({
                "__fn": "%s",
                "args": Array.from(arguments)
            });
        }
    ]], name, name), true)
    
    -- Register the function with the message handler
    self.handler:setHandler(name, func)
end

--- Proxies assignments to a JavaScript table of the same name through
-- to the global table of the same name in Lua.
--
-- @param name Name of the global Lua table to proxy
function WebView:proxy(name)
    
    -- Deconstruct name & ensure parts are valid
    do 
        local tmp = ""
        for k in name:gmatch("[^%.]*") do
            if tmp == "" then
                tmp = k
                self:loadJS(string.format([[
                    if (window['%s'] === undefined) {
                        window['%s'] = {};
                    }
                ]], k, k), true)
            else
                tmp = tmp .. "." .. k
                self:loadJS(string.format([[
                    if (%s === undefined) {
                        %s = {};
                    }
                ]], tmp, tmp), true)
            end
        end
    end
    
    -- TODO: Generate a copy of the table we've been passed
    -- with only JS compatible values. Then have that forward
    -- value assignments to the actual table
    
    -- Add the variable proxy
    self:callAsync(string.format([[
        (() => {
            %s = new Proxy(%s, {
                set(target, prop, value) {
                    target[prop] = value;
                    __updateGlobal('%s.' + prop, value);
                }
            });
        })
    ]], name, name, name, name))
end

--- Imports a JavaScript ES Module into the JavaScript environment
--
-- @param url The URL of the module to import.
-- @param parts (optional) Array of module exports to be imported.
-- @param as (optional) Array of names that will refer to the names imports in 'parts' OR string to name entire import.
-- @usage webview:importJSModule('https://cdn.skypack.dev/three@0.136.0', nil, 'THREE')
-- @usage webview:importJSModule('https://cdn.skypack.dev/three@0.136.0/examples/jsm/controls/OrbitControls.js', { 'OrbitControls' })
-- @usage -- I rename the import to 'OrbControls':
-- webview:importJSModule('https://cdn.skypack.dev/three@0.136.0/examples/jsm/controls/OrbitControls.js', { 'OrbitControls' }, { 'OrbControls' })
function WebView:importJSModule(url, parts, as)
    
    assert(url ~= nil)
    
    -- If we only have one 'as' string then
    -- we should not be specifying parts
    if type(as) == 'string' then
        assert(parts == nil)
    elseif type(as) == 'table' then
        assert(parts ~= nil)
        assert(#as == #parts) -- as & parts tables must match
    end
    
    local call = [=[
        let module = await import(url);
        
        if (parts.length !== 0) {
            
            if (as.length !== 0) {
                
                for (var i = 0; i < parts.length; i++) {
                    window[as[i]] = module[parts[i]];
                }
                
            } else {
                
                for (const p of parts) {
                    window[p] = module[p];
                }
    
            }
    
        } else {
            window[as] = module
        }
    ]=]
    
    local args = {
        url = url,
        parts = parts or {},
        as = as or {}
    }
    
    local sem = ST.Semaphore()
    
    runMain(function()
        self.view:callAsyncJavaScript_arguments_inFrame_inContentWorld_completionHandler_(
            call,
            args,
            nil,
            objc.cls.WKContentWorld.pageWorld,
            function(objResult, objError)
                if objError then
                    local info = objError.userInfo
                    for k,v in pairs(info) do
                        objc.warning(k .. ": " .. v)
                    end
                end
                sem:signal()
            end
        )
    end)
    
    sem:wait()
end

--- Display the content of the WebView.
--
-- This places our WKWebView over Codea's OpenGL based EAGLView
function WebView:show()
    runMain(function()
        
        -- Remove old WKWebView view
        if objc.viewer.view.subviews[2].Class == "WKWebView" then
            objc.viewer.view.subviews[2]:removeFromSuperview()
        end
        
        -- Place the WKWebView over the EAGLView
        objc.viewer.view:insertSubview_atIndex_(self.view, 1)
        
        -- Ensure cleanup is done
        ST.registerTerminator(function()
            self.view:removeFromSuperview()
        end)
    end)
end

--- Hide the content of the WebView.
--
-- This removes our WebView from the UIView hierarchy
function WebView:hide()
    runMain(function()
        -- Remove WKWebView view
        if objc.viewer.view.subviews[2].Class == "WKWebView" then
            objc.viewer.view.subviews[2]:removeFromSuperview()
        end
    end)
end

--- Enables or Disables input handling for the WKWebView.
-- When input handling is DISABLED, Codea's usual touch & gesture callbacks are still triggered.
-- These can then be passed onto JavaScript as necessary.
--
-- When input handling is ENABLED, Codea's usual touch & gesture callbacks are not triggered.
-- This allows the Web content to register its own input handlers as it would in a browser.
--
-- Note: By default, input handling is ENABLED
-- @param enabled true or false
function WebView:enableInputHandling(enabled)
    if enabled then
        self.view.userInteractionEnabled = true
    else
        self.view.userInteractionEnabled = false
    end
end

end
