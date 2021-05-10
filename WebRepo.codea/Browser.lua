Browser = class()

local app_height = 80

function Browser:init(projects)
    self.all_entries = {}
    self.recents = {}
    self.scroll = 0
    
    if projects then
        for _,v in pairs(projects) do
            if not v.hidden then
                table.insert(self.all_entries, ProjectListing(v))
            end
        end
        
        -- Sort into alphabetical order
        table.sort(self.all_entries, function(a, b)
            return a.meta.display_name < b.meta.display_name
        end)
    end
end

function Browser:reinit(projects)
    self.all_entries = {}
    self.recents = {}
    
    if projects then
        for _,v in pairs(projects) do
            if not v.hidden then
                table.insert(self.all_entries, ProjectListing(v))
            end
        end
        
        -- Sort into alphabetical order
        table.sort(self.all_entries, function(a, b)
            return a.meta.display_name < b.meta.display_name
        end)
    end
end

function Browser:draw()
    self.display_width = WIDTH - layout.safeArea.left - layout.safeArea.right
    self.display_height = HEIGHT - layout.safeArea.bottom - layout.safeArea.top
    
    self.num_x = math.ceil(self.display_width / 450)
    self.app_width = self.display_width / self.num_x
    
    -- Draw project browser
    pushStyle()
    pushMatrix()
    
    rectMode(CORNER)
    textMode(CORNER)
    
    local x = 0
    local y = (HEIGHT - layout.safeArea.top - app_height) + self.scroll
    for i,e in ipairs(self.all_entries) do
        
        -- Fade the project listing as it scrolls offscreen
        local alpha = 255
        local fade_y_max = HEIGHT - layout.safeArea.top - app_height
        local fade_y_min = layout.safeArea.bottom
        if y > fade_y_max then
            alpha = 255 * ((fade_y_max + app_height - y)/app_height)
        elseif y < fade_y_min then
            alpha = 255 * ((y - (fade_y_min - app_height))/app_height)
        end
        
        -- Draw listing
        e:draw(x * self.app_width + layout.safeArea.left, y, self.app_width, app_height, alpha)
        
        x = x + 1
        if x == self.num_x then
            x = 0
            y = y - app_height
        end
    end
    
    popMatrix()
    popStyle()
end

function Browser:tap(pos)
    -- Determine which project (if any) we've tapped
    local tapped_app_x = math.floor((pos.x-layout.safeArea.left) / self.app_width)
    local tapped_app_y = math.floor(((HEIGHT-layout.safeArea.top-pos.y) + self.scroll) / app_height)
    
    local app_index = (tapped_app_y * self.num_x) + tapped_app_x + 1

    -- Is this app index valid?
    if app_index > #self.all_entries then
        return
    end
    
    -- Download or launch the project
    local proj = self.all_entries[app_index]
    if proj then
        -- Only non-library projects can be launched
        if projectIsInstalled(proj.meta.project_name) and not proj.meta.is_library then
            launchProject(proj.meta.project_name)
        elseif not projectIsDownloading(proj.meta.project_name) then
            downloadProject(proj.meta.project_name, nil)
        end
    end
end

function Browser:pan(pos, delta, state)
    self.scroll = self.scroll + delta.y
    
    if self.scroll < 0 then
        self.scroll = 0
    end
    
    -- Calculate the maximum scroll
    local max_scroll = math.max((math.ceil(#self.all_entries / self.num_x) * app_height) - self.display_height, 0)
    
    if self.scroll > max_scroll then
        self.scroll = max_scroll
    end
end
