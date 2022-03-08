function importGlobals(webview)
    
    webview:import({
        
        -- Global variables
        WIDTH = WIDTH,
        HEIGHT = HEIGHT,
        
        BEGAN = BEGAN,
        CHANGED = CHANGED,
        ENDED = ENDED,
        CANCELLED = CANCELLED,
        
        DIRECT = DIRECT,
        INDIRECT = INDIRECT,
        STYLUS = STYLUS,
        POINTER = POINTER,
        
        FULLSCREEN = FULLSCREEN,
        STANDARD = STANDARD,
        OVERLAY = OVERLAY,
        FULLSCREEN_NO_BUTTONS = FULLSCREEN_NO_BUTTONS,
        
        PORTRAIT = PORTRAIT,
        PORTRAIT_UPSIDE_DOWN = PORTRAIT_UPSIDE_DOWN,
        LANDSCAPE_LEFT = LANDSCAPE_LEFT,
        LANDSCAPE_RIGHT = LANDSCAPE_RIGHT,
        
        ContentScaleFactor = ContentScaleFactor,
        
        -- Logging functions
        print = function(...)
            print("[JS]", ...)
        end,
        warning = function(msg)
            objc.warning("[JS] " .. msg)
        end,
        error = function(...)
            error("[JS]", ...)
        end,
        
        console = {
            log = function(...)
                print("[JS]", ...)
            end
        },
        
        -- Viewer object
        viewer = {
            -- Values
            mode = viewer.mode,
            preferredFPS = viewer.preferredFPS,
            isPresenting = viewer.isPresenting,
            
            -- Functions
            alert = viewer.alert,
            close = viewer.close,
            restart = viewer.restart
        },
        
        location = {
            enable = location.enable,
            disable = location.disable,
            
            -- TODO: Support returning functions
            --available = location.available,
            --distanceTo = location.distanceTo,
            --distanceBetween = location.distanceBetween
        }
    })
    
    -- Proxy assignments to 'viewer' in JS back to
    -- the viewer object in Lua
    webview:proxy("viewer")
    
    -- Global JS functions
    webview:loadJS([[
        function __touched(touch) {
            if (window.touched === undefined) {
                return;
            }
            touched(touch);
        }
        
        function __hover(gesture) {
            if (window.hover === undefined) {
                return;
            }
            hover(gesture);
        }
        
        function __scroll(gesture) {
            if (window.scroll === undefined) {
                return;
            }
            scroll(gesture);
        }
        
        function __pinch(gesture) {
            if (window.pinch === undefined) {
                return;
            }
            pinch(gesture);
        }
    
        function __willClose() {
            if (willClose === undefined) {
                return;
            }
            willClose();
        }
    
        function __resize(res) {
            if (resize === undefined) {
                return;
            }
            resize(res[0], res[1]);
        }
                        
        async function readText(path) {
            var response = await fetch('codea://' + encodeURIComponent(path));
            return await response.text();
        }
                                           
        async function readBinary(path) {
            var response = await fetch('codea://' + encodeURIComponent(path));
            return await response.arrayBuffer();
        }
    ]])
end
            
-- Variable update thread
ST.Thread(function()
    
    -- Wait until the webview is initialised
    while webview == nil do
        ST.yield()
    end
    
    ST.loop(function()
        webview:import({
            pasteboard = {
                --text = pasteboard.text
            },
                                
            WIDTH = WIDTH,
            HEIGHT = HEIGHT,
            
            Gravity = {
                x = Gravity.x,
                y = Gravity.y,
                z = Gravity.z
            },
            UserAcceleration = {
                x = UserAcceleration.x,
                y = UserAcceleration.y,
                z = UserAcceleration.z
            },
            RotationRate = {
                x = RotationRate.x,
                y = RotationRate.y,
                z = RotationRate.z
            },
            
            location = {
                latitude = location.latitude,
                longitude = location.longitude,
                altitude = location.altitude,
                horizontalAccuracy = location.horizontalAccuracy,
                verticalAccuracy = location.verticalAccuracy,
                speed = location.speed,
                course = location.course
            }
        })
    end)
end)