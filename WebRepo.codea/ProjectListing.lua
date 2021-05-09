ProjectListing = class()

function ProjectListing:init(metadata)
    self.meta = metadata
end

function ProjectListing:draw(x, y, w, h)
    
    -- Offscreen?
    if y < -h or y > HEIGHT then
        return
    end
    
    local padding = 7
    local icon_size = h - (padding*2)
    
    local icon_offset_y = padding
    local title_offset_y = h - 22 - padding
    local desc_offset_y = (h - fontSize() - 4) / 2
    local author_offset_y = padding
    
    -- Fade the project listing as it scrolls offscreen
    local alpha = 255
    if y > HEIGHT - h then
        alpha = 255 * ((HEIGHT - y)/h)
    end
    tint(255, alpha)
    
    -- Draw the icon
    spriteMode(CORNER)
    sprite(asset.builtin.UI.Grey_Panel, x + padding, y + padding, icon_size, icon_size)
    
    -- Draw the title
    if self.meta.installed then
        fill(22, 255, 0)
    elseif self.meta.downloading then
        fill(255, 0, 224)
    else
        fill(0, 255, 224, alpha)
    end    
    fontSize(22)
    text(self.meta.display_name, x + h, y + title_offset_y)
    
    -- Draw the description & author
    fill(195, alpha)
    fontSize(17)
    text(self.meta.desc, x + h, y + desc_offset_y)
    text(self.meta.author, x + h, y + author_offset_y)
end
