function drawProjectListing(meta, x, y, w, h, alpha)
    
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
    
    tint(255, alpha)
    
    -- Draw the icon
    spriteMode(CORNER)
    if meta.icon then -- Downloaded icon
        sprite(meta.icon, x + padding, y + padding, icon_size, icon_size)
    else -- Or default blank icon
        sprite(asset.builtin.UI.Grey_Panel, x + padding, y + padding, icon_size, icon_size)
    end
    
    -- Draw the title
    if meta.installed then
        fill(22, 255, 0)
    elseif meta.downloading then
        fill(255, 0, 224)
    else
        fill(0, 255, 224, alpha)
    end    
    fontSize(22)
    text(meta.name, x + h, y + title_offset_y)
    
    -- Draw the description & author
    fill(195, alpha)
    fontSize(17)
    local desc = meta.desc
    if meta.library then
        desc = "[Lib] " .. desc
    end
    text(desc, x + h, y + desc_offset_y)
    text(meta.author, x + h, y + author_offset_y)
end