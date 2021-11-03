-- GlobalOverrides - Steppers

-- Use this function to perform your initial setup
function setup()
    print("Hello World!")
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(40, 40, 50)

    -- This sets the line thickness
    strokeWidth(5)

    -- Do your drawing here
    textMode(CENTER)
    fontSize(512)
    fill(255)
    text("📚", WIDTH/2, HEIGHT/2)
end

