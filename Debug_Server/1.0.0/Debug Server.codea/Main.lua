-- Demo

local counter = 0

function setup()
    -- Start the debug server
    DebugServer.start()
    
    -- Watch the 'DeltaTime' variable every frame
    DebugServer.watch("DeltaTime")
end

function draw()
    background(255, 201, 0)
    
    -- Increment the counter and log it this frame
    counter = counter + 1
    DebugServer.log("counter", counter)
    
    -- Update the debug server (should be done last)
    DebugServer.update()
end

