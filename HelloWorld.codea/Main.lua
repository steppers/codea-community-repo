-- HelloWorld

saveProjectData("Author",       "Steppers")
saveProjectData("Description",  "Basic Hello World demo project")
saveProjectData("Version",      "1.0")
saveProjectData("Date",         "05-May-2021")

function setup()
    print("Hello World!")
end

function draw()
    background(40, 40, 50)
    
    -- Draw Codea icon in the center of the screen
    spriteMode(CENTER)
    sprite(asset.codea_icon, WIDTH/2, HEIGHT/2)
end

