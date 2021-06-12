NavigationPad = class()

NavigationPad.ButtonSize = 64

function NavigationPad:init()
    
    local bs = NavigationPad.ButtonSize
    
    -- you can accept and set parameters here
    self.panel = ui.panel
    {
        x = WIDTH - bs*3 - 20,
        y = 100,
        w = bs*3,
        h = bs*3,
        pivot = vec2(1,0),
        align = {h = ui.RIGHT, v = ui.BOTTOM}
        --bg = readImage("Documents:grey_button11"),
        --fill = color(67, 67, 67, 107)
    }
    self.panel.interactive = true
    
    sprite(asset.builtin.Blocks.Blank_White)
    
    self.buttons =
    {
        forward = self:navButton(bs, bs*2, bs, bs, 2, "UI:Grey Arrow Up White", 0),
        right = self:navButton(bs*2, bs, bs, bs, 2, "UI:Grey Arrow Up White", -90),
        backward = self:navButton(bs, 0, bs, bs, 2, "UI:Grey Arrow Up White", -180),
        left = self:navButton(0, bs, bs, bs, 2 ,"UI:Grey Arrow Up White", 90),
        middle = self:navButton(bs, bs, bs, bs, 2, "UI:Grey Circle", 0),
        forwardLeft = self:navButton(0, bs*2, bs, bs, 2, "UI:Grey Arrow Up White", 45),
        forwardRight = self:navButton(bs*2, bs*2, bs, bs, 2, "UI:Grey Arrow Up White", -45)
    }
end

function NavigationPad:navButton(x,y,w,h,border,icon,r)
    local button = ui.button
    {
        x=x-5,
        y=y-5,
        w=w+10,
        h=h+10,
        align = {h = ui.STRETCH, v = ui.STRETCH},
        normalBg = "Blocks:Blank White",
        parent = self.panel,
        border = border + 5,
        normalFill = color(63, 63, 63, 255),
        highlightedFill = color(127, 127, 127, 255),
        inset = 0
    }
    
    if icon then
        button.icon.img = icon
        button.icon.rotation = r
    end
    
    button.share = true
    
    return button
end

function NavigationPad:draw()
    self.panel:update()
    self.panel:draw()
end
