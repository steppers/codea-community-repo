-- Main

local txt = nil

viewer.mode = FULLSCREEN

function setup()
    
    -- Make out http request
    local ok, data = http.requestSync("https://baconipsum.com/api/?type=meat-and-filler&paras=1&format=text")
    
    -- Check that the http request succeeded
    if ok then
        txt = data
    else
        print("Something went wrong!\n" .. data)
    end
    
    -- Initialise text drawing
    fill(255)
    textMode(CENTER)
    textAlign(CENTER)
    textWrapWidth(400)
    fontSize(20)
end
    
function draw()
    background(128)
    
    -- Draw the downloaded text
    text(txt or "Download failed!", WIDTH/2, HEIGHT/2)
end