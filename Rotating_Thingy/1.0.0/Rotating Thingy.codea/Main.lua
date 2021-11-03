--displayMode(OVERLAY). --replaced by next line - not needed
displayMode(FULLSCREEN)
--this command is being used incorrectly - Landscape, portrait, etc are the correct parameters to use - look up the reference
-- supportedOrientations(WIDTH)

function setup()
    img=image(WIDTH,HEIGHT)
    --this next section replaces the second code and generates the image to be displayed
    setContext(img)
    translate(WIDTH/2,HEIGHT/2)
    z = 20
    zy = 25
    starship_table = {}
    lazer_table = {}
    background(0, 0, 0, 255)
    for x = -25, 25 do
        --    stars[x] = {} --doesn't do anything
        for y = -19, 18 do
            --         stars[x][y] = false - neither does this
            strokeWidth(2)
            stroke(255, 255, 255, 255)
            line(x * z, y * z - 2.5, x * z, y * z + 2.5)
            line(x * z - 2.5, y * z, x * z + 2.5, y * z)
        end
    end
    --starship
    sprite("Tyrian Remastered:Boss B")
    --lazer
    for y = 1, 14 do
        lazer_table[y] = false
        stroke(125, 200, 150, 255)
        strokeWidth(10)
        line(0, y * zy - 385, 0, y * zy - 375)
    end
    setContext()
    --end of image generation code
    rotation = 20
end

function draw()
    translate(WIDTH/2, HEIGHT/2)
    rotate(ElapsedTime * rotation)
    sprite(img, 0, 0)
end