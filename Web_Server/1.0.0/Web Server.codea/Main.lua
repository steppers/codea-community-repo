-- Demo

function setup()
    -- Open up this project as a webserver
    local server = WebServer(asset, 80)
    print("Web Server running!")
    
    -- Print the access URLs
    print("Connect at:\n\nhttp://localhost\n\nor\n\nhttp://" .. server.ip .. ":" .. server.port .. "\n(for other devices on the local network)")
end

function draw()
    background(113, 206, 155)
end

