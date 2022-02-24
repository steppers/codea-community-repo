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
    function Handler:userContentController_didReceiveScriptMessage_replyHandler_(objUserContentController, objMessage)
        -- TODO: support replyHandler function
        local msg = objMessage.body
        local handler = handlers[msg.__fn]
        if handler then handler(table.unpack(msg.args)) end
    end

    self.handler = Handler()
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
            ["wasm"]    = "application/wasm",
            ["plist"]   = "application/xml",
            ["ts"]      = "text/plain"
        }
        
        WebViewURLSchemeHandler.Handler.webView_startURLSchemeTask_ = function(self, objWebView, objUrlSchemeTask)
                
            local url = objUrlSchemeTask.request.URL
                
            -- Get the file path
            local path = url.absoluteString:gsub("codea://", "")
            local ext = path:match("%.(.-)$")
                
            -- Read the file into NSData
            local data = objc.cls.NSData:dataWithContentsOfFile_(asset.path .. "/" .. path)
                
            -- Create the response
            local response = objc.cls.NSHTTPURLResponse:alloc()
            response:initWithURL_statusCode_HTTPVersion_headerFields_(url, 200, "HTTP/1.1", {
                ["Access-Control-Allow-Origin"] = "*",
                ["Content-Type"] = mimeType[ext] or "text/plain"
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
        self.view.backgroundColor = objc.cls.UIColor.grayColor
        
        -- Disable input handling by default
        self:enableInputHandling(false)
    end)
    
    -- Trigger a page load
    if htmlAsset then
        self:loadHTML(htmlAsset)
        self:waitForLoad()
    end
end

local function loadJSFromSource(view, jsSource)
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
        end
    )
end

local function loadJSFromFile(view, jsAsset)
    local source = readText(jsAsset)
    loadJSFromSource(view, source)
end

local function loadHTMLFromFile(view, htmlAsset)
    local request = objc.cls.NSURLRequest:requestWithURL_cachePolicy_timeoutInterval_(
        objc.cls.NSURL:URLWithString_("file://" .. htmlAsset.path),
        objc.enum.NSURLRequestCachePolicy.NSURLRequestReloadIgnoringCacheData,
        5.0)
    view:loadRequest_(request)
end

local function loadHTMLFromSource(view, htmlSource)
    view:loadHTMLString_baseURL_(htmlSource, objc.cls.NSURL:URLWithString_("file://" .. asset.path))
end

function WebView:loadJS(obj)
    runMain(function()
        if type(obj) == "string" then
            loadJSFromSource(self.view, obj)
        elseif obj.path then
            loadJSFromFile(self.view, obj)
        end
    end)
end

function WebView:loadHTML(obj)
    runMain(function()
        if type(obj) == "string" then
            loadHTMLFromSource(self.view, obj)
        elseif obj.path then
            loadHTMLFromFile(self.view, obj)
        end
    end)
end

function WebView:call(funcName, ...)
    
    -- Form function call
    local call = {
        "return ", funcName, "("
    }
    
    -- Add args
    local args = {}
    for i,v in ipairs({...}) do
        local argName = "a" .. tostring(i)
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
                    local err = string.format("%d:%d %s",
                        info.WKJavaScriptExceptionLineNumber,
                        info.WKJavaScriptExceptionColumnNumber,
                        info.WKJavaScriptExceptionMessage)
                    objc.warning(err)
                else
                    result:resolve(objResult)
                end
            end
        )
    end)
    
    -- Wait for a result
    return result:get()
end

function WebView:import(name, func)
    
    if type(name) == "table" then
        for n,fn in pairs(name) do
            self:import(n, fn)
        end
        return
    end
    
    -- Add the __codea function to JS
    if not self.__codeaAdded then
        self:loadJS([[
            function __codea(fnName, args) {
                return window.webkit.messageHandlers.codea.postMessage({
                    "__fn": fnName,
                    "args": args
                });
            }
        ]])
        self.__codeaAdded = true
    end
    
    -- Add our JS function wrapper
    self:loadJS(string.format([[
        function %s(args) {
            return window.webkit.messageHandlers.codea.postMessage({
                "__fn": "%s",
                "args": Array.from(arguments)
            });
        }
    ]], name, name))
    
    -- Register the function with the message handler
    self.handler:setHandler(name, func)
end

function WebView:waitForLoad()
    while self.view.loading do
        yield()
    end
end

function WebView:show()
    runMain(function()
        -- Place the WKWebView over the EAGLView
        objc.viewer.view:insertSubview_atIndex_(self.view, 1)
        
        -- Ensure cleanup is done
        ST.registerTerminator(function()
            self.view:removeFromSuperview()
        end)
    end)
end

function WebView:enableInputHandling(enabled)
    if enabled then
        self.view.userInteractionEnabled = true
    else
        self.view.userInteractionEnabled = false
    end
end
