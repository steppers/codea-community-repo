Browser = class()

local app_height = 80
local search_bar_height = 52

function Browser:init()
    self.all_entries = {}
    self.recents = {}
    self.scroll = 0
    self.search_bar = SearchBar()
    self.webrepo = nil
end

function Browser:setWebRepo(webrepo)
    self.webrepo = webrepo
end

function Browser:addProject(project_metadata)
    if not project_metadata.hidden then
        table.insert(self.all_entries, project_metadata)
        
        -- Sort into alphabetical order
        table.sort(self.all_entries, function(a, b)
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
    
    local x = 0
    local y = self.browser_top - app_height + self.scroll
    for _,e in ipairs(self.all_entries) do
        
        -- Fade the project listing as it scrolls offscreen
        local alpha = 255
        local fade_y_max = self.browser_top - app_height
        local fade_y_min = layout.safeArea.bottom
        if y > fade_y_max then
            alpha = 255 * ((fade_y_max + app_height - y)/app_height)
        elseif y < fade_y_min then
            alpha = 255 * ((y - (fade_y_min - app_height))/app_height)
        end
        
        -- Draw listing
        drawProjectListing(e, x * self.app_width + layout.safeArea.left, y, self.app_width, app_height, alpha)
        
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

function Browser:tap(pos)
    -- Tapped on the search bar?
    if pos.y > HEIGHT - search_bar_height then
        self.search_bar:select(true)
        return
    end
    
    -- Deselect the search bar
    self.search_bar:select(false)
    
    -- Determine which project (if any) we've tapped
    local tapped_app_x = math.floor((pos.x-layout.safeArea.left) / self.app_width)
    local tapped_app_y = math.floor(((self.browser_top-pos.y) + self.scroll) / app_height)
    
    local app_index = (tapped_app_y * self.num_x) + tapped_app_x + 1

    -- Is this app index valid?
    if app_index > #self.all_entries then
        return
    end
    
    -- Download or launch the project
    local proj = self.all_entries[app_index]
    if proj then
        -- Only non-library projects can be launched
        if proj.installed and not proj.library then
            self.webrepo:launchProject(proj)
        elseif not proj.downloading then
            self.webrepo:downloadProject(proj, nil)
        end
    end
end

function Browser:pan(pos, delta, state)
    self.scroll = self.scroll + delta.y
    
    if self.scroll < 0 then
        self.scroll = 0
    end
    
    -- Calculate the maximum scroll
    local max_scroll = math.max((math.ceil(#self.all_entries / self.num_x) * app_height) - self.browser_height, 0)
    
    if self.scroll > max_scroll then
        self.scroll = max_scroll
    end
    
    -- Deselect the search bar
    self.search_bar:select(false)
end

function Browser:keyboard(key)
    self.search_bar:keyboard(key)
end
