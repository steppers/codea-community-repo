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
    -- Draw project browser
    pushStyle()
    pushMatrix()
    
    local display_width = WIDTH
    local display_height = HEIGHT - layout.safeArea.bottom - layout.safeArea.top
    
    rectMode(CORNER)
    textMode(CORNER)
    
    local num_x = math.ceil(display_width / 400)
    local app_width = display_width / num_x
    
    local x = 0
    local y = (HEIGHT - layout.safeArea.top - app_height) + self.scroll
    for i,e in ipairs(self.all_entries) do
        e:draw(x * app_width, y, app_width, app_height)
        
        x = x + 1
        if x == num_x then
            x = 0
            y = y - app_height
        end
    end
    
    popMatrix()
    popStyle()
end

function Browser:tap(pos)
    -- Determine which project (if any) we've tapped
    local num_x = math.ceil(WIDTH / 400)
    local app_width = WIDTH / num_x
    
    local tapped_app_x = math.floor(pos.x / app_width)
    local tapped_app_y = math.floor(((HEIGHT-pos.y) + self.scroll) / app_height)
    
    local app_index = (tapped_app_y * num_x) + tapped_app_x + 1

    -- Is this app index valid?
    if app_index > #self.all_entries then
        return
    end
    
    -- Download or launch the project
    local proj = self.all_entries[app_index]
    if projectIsInstalled(proj.meta.project_name)then
        launchProject(proj.meta.project_name)
    elseif not projectIsDownloading(proj.meta.project_name) then
        downloadProject(proj.meta.project_name, nil)
    end
end

function Browser:pan(pos, delta, state)
    self.scroll = self.scroll + delta.y
    
    if self.scroll < 0 then
        self.scroll = 0
    end
end
