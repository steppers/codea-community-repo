-- Web Server
-- By Steppers

local server = nil      -- Web Server

viewer.mode = FULLSCREEN

function setup()
    -- Change the 'asset' value to point to another
    -- folder in your Codea Documents directory if
    -- you want to create your own website.
    --
    -- This is technically the only line you need to
    -- create a simple static website!
    server = WebServer(asset)
end

function draw()
    -- Clear and init style settings
    background(49, 84, 65)
    textMode(CENTER)
    textAlign(CENTER)
    fill(255)
    
    -- Print connection info
    text("Web Server running at:\nhttp://" .. server.ip .. ":" .. server.port .. "\nand\nhttp://localhost:" .. server.port, WIDTH/2, HEIGHT/2)
end

