Browser = class()

local app_width = 150
local app_height = 150
local app_icon_scale = 0.5
local app_font_scale = 0.11
local search_bar_height = 52

function Browser:init()
    self.all_entries = {}
    self.displayed_entries = {}
    self.scroll = 0
    self.scroll_velocity = 0
    self.search_bar = SearchBar(self.all_entries, self.displayed_entries)
    self.project_panel = ProjectPanel()
    self.webrepo = nil
end

function Browser:setWebRepo(webrepo)
    self.webrepo = webrepo
    self.project_panel.webrepo = webrepo
end

function Browser:addProject(project_metadata)
    if not project_metadata.hidden then
        table.insert(self.all_entries, project_metadata)
        table.insert(self.displayed_entries, project_metadata)
        
        -- Sort into alphabetical order
        table.sort(self.displayed_entries, function(a, b)
            return a.name < b.name
        end)
    end
end

function Browser:removeProject(project_metadata)
    -- Search for the project to remove.
    -- This is slow but hopefully we won't have to do this often
    if not project_metadata.hidden then
        for i,v in ipairs(self.all_entries) do
            if v == project_metadata then
                table.remove(self.all_entries, i)
                break
            end
        end
        
        for i,v in ipairs(self.displayed_entries) do
            if v == project_metadata then
                table.remove(self.displayed_entries, i)
                break
            end
        end
    end
end

function Browser:draw()
    self.display_left = layout.safeArea.left
    self.display_right = WIDTH - layout.safeArea.right
    self.display_top = HEIGHT - layout.safeArea.top
    self.display_bottom = layout.safeArea.bottom
    self.display_width = WIDTH - layout.safeArea.left - layout.safeArea.right
    self.display_height = HEIGHT - layout.safeArea.bottom - layout.safeArea.top
    
    -- Calculate the number of apps we can fit per row & their size
    self.num_x = math.ceil(self.display_width / app_width)
    self.app_width = self.display_width / self.num_x
    
    -- Draw project browser
    pushStyle()
    pushMatrix()
    
    rectMode(CORNER)
    textMode(CORNER)
    
    -- Top of the project browser
    self.browser_top = self.display_top - search_bar_height -- 52 for search bar
    self.browser_height = self.display_height - search_bar_height -- 52 for search bar
    
    -- Update scroll with velocity
    self.scroll = self.scroll + self.scroll_velocity * DeltaTime
    if self.scroll < 0 then
        self.scroll = 0
    end
    -- Limit the maximum scroll
    local max_scroll = math.max((math.ceil(#self.displayed_entries / self.num_x) * app_width) - self.browser_height, 0)
    if self.scroll > max_scroll then
        self.scroll = max_scroll
        self.scroll_velocity = 0
    end
    
    local x = 0
    local y = self.browser_top - app_width + self.scroll
    for _,e in ipairs(self.displayed_entries) do
            
        -- Fade the project listing as it scrolls offscreen
        local alpha = 255
        local fade_y_max = self.browser_top - app_width
        local fade_y_min = layout.safeArea.bottom
        if y > fade_y_max then
            alpha = 255 * ((fade_y_max + app_width - y)/app_width)
        elseif y < fade_y_min then
            alpha = 255 * ((y - (fade_y_min - app_width))/app_width)
        end
        
        -- Download the icon
        -- if #self.all_entries < 100 or (y > -app_width*3 and y < HEIGHT + app_width*2) then
        if y > -app_width*3 and y < HEIGHT + app_width*2 then
            self.webrepo:initProjectIcon(e)
        else
            self.webrepo:freeProjectIcon(e) -- Free the icon
        end
        
        -- Draw listing
        self:drawProjectListing(e, x * self.app_width + layout.safeArea.left, y, self.app_width, app_height, alpha)
        
        x = x + 1
        if x == self.num_x then
            x = 0
            y = y - app_height
        end
    end
    
    -- Draw search bar
    self.search_bar_y = self.display_top - search_bar_height
    self.search_bar:draw(self.search_bar_y, math.min(WIDTH - 40, 500), search_bar_height)
    
    -- Draw project panel
    self.project_panel:draw()
    
    popMatrix()
    popStyle()
end

function Browser:drawProjectListing(meta, x, y, w, h, alpha)
    
    -- Offscreen?
    if y < -h or y > HEIGHT then
        return
    end
    
    local padding = 7
    local icon_size = w * app_icon_scale
    local icon_x = x + (w - icon_size)/2
    local icon_y = y + w - padding - icon_size
    
    tint(255, alpha)
    
    -- Draw the icon
    spriteMode(CORNER)
    local icon = self.webrepo:getProjectIcon(meta)
    if icon then -- Downloaded icon
        sprite(icon, icon_x, icon_y, icon_size, icon_size)
    else -- Or default blank icon
        sprite(asset.builtin.UI.Grey_Panel, icon_x, icon_y, icon_size, icon_size)
    end
    
    -- Draw download progress
    if meta.downloading then
        pushStyle()
        local progress = meta.download_progress or 0
        resetStyle()
        fill(0, 255, 4, 118)
        rect(icon_x, icon_y, icon_size * progress, icon_size)
        popStyle()
    end
    
    -- Draw the title
    if meta.installed then
        fill(22, 255, 0, alpha)
    else
        fill(222)
    end    
    fontSize(w * app_font_scale)
    textMode(CENTER)
    textAlign(CENTER)
    textWrapWidth(w - padding*2)
    local _,th = textSize(meta.name)
    local title_y = icon_y - th/2 - 3
    text(meta.name, x + w/2, title_y)
    
    --[[
    -- Draw the description & author
    textWrapWidth(w - h)
    fill(195, alpha)
    fontSize(15)
    local desc = meta.desc
    if meta.library then
        desc = "[Lib] " .. desc
    end
    text(desc, x + h, y + desc_offset_y)
    fontSize(14)
    text(meta.author, x + h, y + author_offset_y)
    ]]
end

function Browser:tap(pos)
    
    -- Pass to the project panel
    if self.project_panel:tap(pos) then
        return
    end
    
    -- Tapped on the search bar?
    if pos.y > self.display_top - search_bar_height then
        self.search_bar:select(true)
        
        -- Stop scrolling
        self.scroll_velocity = 0
        return
    end
    
    -- Deselect the search bar
    self.search_bar:select(false)
    
    -- Determine which project (if any) we've tapped
    local tapped_app_x = math.floor((pos.x-layout.safeArea.left) / self.app_width)
    local tapped_app_y = math.floor(((self.browser_top-pos.y) + self.scroll) / app_height)
    
    local app_index = (tapped_app_y * self.num_x) + tapped_app_x + 1
    
    -- Is this app index valid?
    if app_index > #self.displayed_entries then
        return
    end
    
    -- Download or launch the project
    local proj = self.displayed_entries[app_index]
    if proj then
        
        -- Open the project panel and stop the scolling
        self.project_panel:open(proj)
        self.scroll_velocity = 0
        
        --[[
        if self.webrepo.connection_failure then
            -- Offline
            
            if proj.installed and not proj.library then
                self.webrepo:launchProject(proj)
            end
        else
            -- Online
            
            if not proj.downloading then -- Do nothing if downloading
                if proj.update_available then
                    self.webrepo:downloadProject(proj, nil)
                elseif proj.installed and proj.executable then
                    self.webrepo:launchProject(proj)
                end
            end
        end
        ]]
    end
end

function Browser:pan(pos, delta, velocity, state)
    
    -- Ignore if the project panel handles it
    if self.project_panel:pan(pos, delta, velocity, state) then
        return
    end
    
    if state == ENDED then
        self.scroll_velocity = velocity.y
        
        -- Slow down scroll over 1 second
        self.scroll_tween = tween(1, self, { scroll_velocity = 0 })
        tween.play(self.scroll_tween)
    else
        if self.scroll_tween then
            tween.stop(self.scroll_tween)
            self.scroll_tween = nil
        end
        self.scroll_velocity = 0
    end
        
    self.scroll = self.scroll + delta.y
    
    if self.scroll < 0 then
        self.scroll = 0
    end
    
    -- Calculate the maximum scroll
    local max_scroll = math.max((math.ceil(#self.displayed_entries / self.num_x) * app_width) - self.browser_height, 0)
    
    if self.scroll > max_scroll then
        self.scroll = max_scroll
    end
    
    -- Deselect the search bar
    self.search_bar:select(false)
end

function Browser:keyboard(key)
    self.scroll = 0
    self.search_bar:keyboard(key)
end
