Browser = class()

local app_height = 80
local search_bar_height = 52

function Browser:init()
    self.all_entries = {}
    self.displayed_entries = {}
    self.scroll = 0
    self.scroll_velocity = 0
    self.search_bar = SearchBar(self.all_entries, self.displayed_entries)
    self.webrepo = nil
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

function Browser:draw()
    self.display_left = layout.safeArea.left
    self.display_right = WIDTH - layout.safeArea.right
    self.display_top = HEIGHT - layout.safeArea.top
    self.display_bottom = layout.safeArea.bottom
    self.display_width = WIDTH - layout.safeArea.left - layout.safeArea.right
    self.display_height = HEIGHT - layout.safeArea.bottom - layout.safeArea.top
    
    -- Calculate the number of apps we can fit per row & their size
    self.num_x = math.ceil(self.display_width / 450)
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
    local max_scroll = math.max((math.ceil(#self.displayed_entries / self.num_x) * app_height) - self.browser_height, 0)
    if self.scroll > max_scroll then
        self.scroll = max_scroll
        self.scroll_velocity = 0
    end
    
    local x = 0
    local y = self.browser_top - app_height + self.scroll
    for _,e in ipairs(self.displayed_entries) do
            
        -- Fade the project listing as it scrolls offscreen
        local alpha = 255
        local fade_y_max = self.browser_top - app_height
        local fade_y_min = layout.safeArea.bottom
        if y > fade_y_max then
            alpha = 255 * ((fade_y_max + app_height - y)/app_height)
        elseif y < fade_y_min then
            alpha = 255 * ((y - (fade_y_min - app_height))/app_height)
        end
        
        -- Download the icon
        -- if #self.all_entries < 100 or (y > -app_height*3 and y < HEIGHT + app_height*2) then
        if y > -app_height*3 and y < HEIGHT + app_height*2 then
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
    
    popMatrix()
    popStyle()
end

function Browser:drawProjectListing(meta, x, y, w, h, alpha)
    
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
    local icon = self.webrepo:getProjectIcon(meta)
    if icon then -- Downloaded icon
        sprite(icon, x + padding, y + padding, icon_size, icon_size)
    else -- Or default blank icon
        sprite(asset.builtin.UI.Grey_Panel, x + padding, y + padding, icon_size, icon_size)
    end
    
    -- Draw the title
    if meta.installed then
        fill(22, 255, 0, alpha)
    elseif meta.downloading then
        fill(255, 0, 224, alpha)
    else
        fill(34, 165, 241, alpha)
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

function Browser:tap(pos)
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
                elseif proj.installed and not proj.library then
                    self.webrepo:launchProject(proj)
                end
            end
        end
    end
end

function Browser:pan(pos, delta, velocity, state)
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
    local max_scroll = math.max((math.ceil(#self.displayed_entries / self.num_x) * app_height) - self.browser_height, 0)
    
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
