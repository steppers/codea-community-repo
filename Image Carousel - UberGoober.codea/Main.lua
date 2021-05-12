--UberGoober modification of Dwin's carousel with collaboration from skar and West
viewer.mode=FULLSCREEN

function setup()
    --a few image tables for the carousels to use
    local images = {
        asset.builtin.Environments.Night_Back,
        asset.builtin.Environments.Sunny_Front,
        asset.builtin.Patterns.Icon,
        asset.builtin.Environments.Sunny_Up,
        asset.builtin.Environments.Icon,
        asset.builtin.Blocks.Icon,
        asset.builtin.Planet_Cute.Brown_Block,
        asset.builtin.Planet_Cute.Icon,
        asset.builtin.SpaceKit.Icon,
        asset.builtin.Environments.Icon,
        asset.builtin.Blocks.Cactus_Inside
    }
    local images2 = {
        asset.builtin.Cargo_Bot.Crate_Goal_Blue, 
        asset.builtin.Cargo_Bot.Claw_Right,
        asset.builtin.Cargo_Bot.Condition_Any,
        asset.builtin.Cargo_Bot.Toolbox,
        asset.builtin.Cargo_Bot.Title_Large_Crate_1}
    
    local images3 = {
        asset.builtin.Platformer_Art.Crate,
        asset.builtin.Platformer_Art.Cloud_1,
        asset.builtin.Platformer_Art.Bush,
        asset.builtin.Platformer_Art.Mushroom        
    }
    
    --the most basic carousel
    --defaults to drawing all images full-screen
    --the second parameter controls how and if the navigation dots are drawn (true means dots with thumbnails, false means just dots, nil means no dots at all)
    imgCarousel = ImageCarousel(images, true)
    
    --next, three carousels at different sizes and locations and with different dot settings
    imgCarousel2 = ImageCarousel(images2, false, WIDTH*0.01,HEIGHT*0.53, WIDTH*0.27, HEIGHT*0.25)
    
    imgCarousel3 = ImageCarousel(images3, true, WIDTH*0.30,HEIGHT*0.49, WIDTH*0.39, HEIGHT*0.32)
    
    imgCarousel4 = ImageCarousel(images, nil, WIDTH*0.71,HEIGHT*0.53, WIDTH*0.27, HEIGHT*0.25)
    
end

function draw()
    background(16)
    imgCarousel:draw()
    imgCarousel2:draw()
    imgCarousel3:draw()
    imgCarousel4:draw()
end

function touched(touch)
    imgCarousel:touched(touch)
    imgCarousel2:touched(touch)
    imgCarousel3:touched(touch)
    imgCarousel4:touched(touch)
end
