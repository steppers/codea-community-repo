ProjectPanel = class()

-- Draws a large panel with additional information and
-- options for the selected project.
--
-- This allows us to launch, update, download, read
-- a longer description and access a forum link.

local ICON_SIZE = 96
local PADDING = 15
local DROP_SHADOW_OFFSET = 3
local TITLE_FONT_SIZE = 22
local BUTTON_WIDTH = 100

local PANEL_W = math.min(WIDTH - 20, 600)
local PANEL_H = HEIGHT - 180

function ProjectPanel:init()
    self.animating = false -- True when the panel is animating
    self.metadata = nil -- Set when the panel is displaying
    self.scale = 0
    
    self.install_btn = nil
    self.update_btn = nil
    self.launch_btn = nil
    self.delete_btn = nil
    self.forum_btn = nil
end

function ProjectPanel:draw()
    
    -- Don't draw if we have no project to draw
    if self.metadata == nil then
        return
    end
    
    pushMatrix()
    pushStyle()
    resetMatrix()
    
    tint(255)
    rectMode(CORNER)
    
    fill(0, 196 * self.scale)
    rect(-1, -1, WIDTH+2, HEIGHT+2)
    
    PANEL_W = math.min(WIDTH - 20, 600)
    PANEL_H = HEIGHT - 180
    
    translate(WIDTH/2, HEIGHT/2)
    scale(self.scale)
    translate(-PANEL_W/2, -PANEL_H/2)
    
    -- Draw background rect
    strokeWidth(5)
    if self.metadata.downloading then
        stroke(255, 181, 0)  
    else
        stroke(128)  
    end
    fill(64)
    rect(5, -5, PANEL_W-10, PANEL_H)
    
    -- Draw app Icon
    sprite(self.webrepo:getProjectIcon(self.metadata), PADDING, PANEL_H - PADDING - ICON_SIZE, ICON_SIZE, ICON_SIZE)
    
    -- Draw Title
    textWrapWidth(0)
    fontSize(TITLE_FONT_SIZE)
    textMode(CORNER)
    fill(255)
    text(self.metadata.name, PADDING*2 + ICON_SIZE, PANEL_H - PADDING - TITLE_FONT_SIZE)
    -- Draw short descr
    textWrapWidth(PANEL_W - (PADDING*3 + ICON_SIZE))
    local desc = self.metadata.desc
    if self.metadata.library then
        desc = "[Lib] " .. desc
    end
    text(desc, PADDING*2 + ICON_SIZE, PANEL_H - (PADDING + ICON_SIZE))
    
    -- Draw buttons
    local button_y = PANEL_H - (PADDING*2 + ICON_SIZE + 36)
    if self.metadata.downloading then
        -- Render no buttons
    elseif self.metadata.installed then
        
        -- Only allow launching if the project can be run standalone
        if self.metadata.executable then
            self.launch_btn:reinit(PADDING, button_y, BUTTON_WIDTH, 36)
            self.launch_btn:draw()
        end
        
        -- Draw Update button
        if self.metadata.update_available then
            self.update_btn:reinit(PANEL_W/2 - BUTTON_WIDTH/2, button_y, BUTTON_WIDTH, 36)
            self.update_btn:draw()
        end
    else
        -- Draw Install button
        self.install_btn.str = "Install"
        self.install_btn:reinit(PADDING, button_y, BUTTON_WIDTH, 36)
        self.install_btn:draw()
    end
            
    -- Draw Forum button
    self.forum_btn:reinit(PANEL_W - PADDING - BUTTON_WIDTH, button_y, BUTTON_WIDTH, 36)
    self.forum_btn:draw()
    
    -- Draw long description
    textAlign(LEFT)
    textWrapWidth(PANEL_W - PADDING*2)
    if self.metadata.long_desc then
        textMode(CORNER)
        -- Limit to 2010 characters as there's an odd limitation somehow
        local txt = string.sub(self.metadata.long_desc, 1, 2010)
        _, th = textSize(txt)
        text(txt, PADDING, button_y - PADDING - th)
    end
    
    -- Draw delete button if installed and not a bundle
    if self.metadata.installed then
        self.delete_btn:reinit(PANEL_W - BUTTON_WIDTH - PADDING, PADDING, BUTTON_WIDTH, 36)
        self.delete_btn:draw()
    end
    
    -- Draw authors
    fill(255)
    if self.metadata.installed then -- only wrap for delete button if installed
        textWrapWidth(PANEL_W - PADDING*3 - BUTTON_WIDTH)
    end
    textMode(CORNER)
    text("Creator(s): " .. self.metadata.author, PADDING, PADDING)
    
    -- Draw download progress
    if self.metadata.downloading then
        local progress = self.metadata.download_progress or 0
        resetStyle()
        fill(0, 255, 4, 118)
        rect(PADDING, PANEL_H - PADDING - ICON_SIZE, ICON_SIZE * progress, ICON_SIZE)
    end
    
    popStyle()
    popMatrix()
end

-- Returns true if the touch event was handled
function ProjectPanel:tap(pos)
    
    -- Not handled if not displayed
    if self.metadata == nil then
        return false
    end
    
    -- Handled if the panel is animating
    if self.animating then
        return true
    end
    
    -- Translate pos
    pos.x = pos.x - (WIDTH - PANEL_W)/2
    pos.y = pos.y - (HEIGHT - PANEL_H)/2
    
    -- Check buttons in panel
    if not self.metadata.installed and not self.metadata.downloading and self.install_btn and self.install_btn:tap(pos) then
        self.webrepo:downloadProject(self.metadata, nil)
        return true
    end
    
    if self.metadata.update_available and not self.metadata.downloading and self.update_btn and self.update_btn:tap(pos) then
        self.webrepo:downloadProject(self.metadata, nil)
        return true
    end
    
    if self.metadata.executable and not self.metadata.downloading and self.launch_btn and self.launch_btn:tap(pos) then
        -- This won't actually return
        self.webrepo:launchProject(self.metadata)
        return true
    end
    
    if self.metadata.installed and not self.metadata.downloading and self.delete_btn and self.delete_btn:tap(pos) then
        if self.metadata.bundle then
            viewer.alert("Please delete manually in the iOS Files app.", "Unable to delete multi-project bundles")
        else
            self.webrepo:deleteProject(self.metadata)
        end
        return true
    end
    
    if self.forum_btn and self.forum_btn:tap(pos) then
        openURL(self.metadata.link or "https://codea.io/talk/discussions", true)
        return true
    end
    
    -- Just close for now
    self.animating = true
    tween(0.15, self, { scale = 0.0 }, tween.easing.linear, function()
        self.metadata = nil
        self.animating = false
    end)
    return true
end

function ProjectPanel:pan(pos, delta, velocity, state)
    -- Not handled if not displayed
    if self.metadata == nil then
        return false
    end
    
    -- Handled if the panel is animating
    if self.animating then
        return true
    end
    
    return true
end

function ProjectPanel:open(project_metadata)
    
    -- Ignore invalid states
    if self.metadata or self.animating then
        return
    end
    
    self.animating = true
    self.metadata = project_metadata
    self.scale = 0
    
    tween(0.15, self, { scale = 1.0 }, tween.easing.linear, function()
        self.animating = false
    end)
    
    -- Init all the buttons
    local PANEL_W = math.min(WIDTH - 20, 600)
    local PANEL_H = HEIGHT - 70
    local button_y = PANEL_H - (PADDING*2 + ICON_SIZE)
    
    self.launch_btn = Button("Launch", PADDING, button_y, BUTTON_WIDTH, 36, color(22, 178, 94), color(255))          
    self.update_btn = Button("Update", PANEL_W/2 - BUTTON_WIDTH/2, button_y, BUTTON_WIDTH, 36, color(0, 155, 255), color(255))
    self.delete_btn = Button("Delete", PANEL_W - BUTTON_WIDTH - PADDING*2, PADDING + 36, BUTTON_WIDTH, 36, color(255, 0, 56), color(255))
    self.install_btn = Button("Install", PADDING, button_y, BUTTON_WIDTH, 36, color(0, 155, 255), color(255))
    self.forum_btn = Button("Forum", PANEL_W - PADDING*2 - BUTTON_WIDTH, button_y, BUTTON_WIDTH, 36, color(0, 155, 255), color(255))
end
