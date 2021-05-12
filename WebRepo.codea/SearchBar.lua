SearchBar = class()

-- Sets the 'filtered' flag on entries that do not match 'str' using a fuzzy match
local function filter(entries, str)
    for _,v in ipairs(entries) do
        
        -- Search name, description and author for matches
        if fzy.has_match(str, v.name) then
            v.filtered = false
            v.filter_score = fzy.score(str, v.name)
            
        elseif fzy.has_match(str, v.desc) then
            v.filtered = false
            v.filter_score = fzy.score(str, v.desc)
            
        elseif fzy.has_match(str, v.author) then
            v.filtered = false
            v.filter_score = fzy.score(str, v.author)
            
        else
            v.filtered = true
            v.filter_score = nil
        end
    end
    
    -- Sort by fzy score
    table.sort(entries, function(a, b)
        if a.filtered then
            return false
        end
        
        if b.filtered then
            return true
        end
        
        return a.filter_score > b.filter_score
    end)
end

function SearchBar:init(browser_entries)
    self.browser_entries = browser_entries
    self.typing = false
    self.buffer = "Search"
    self.buffer_selected = false
end

function SearchBar:draw(y, w, h)
    pushStyle()
    
    -- Draw background
    fill(96)
    rectMode(CORNER)
    rect(0, y, WIDTH, h + 100)
    
    y = y + 6
    h = h - 12
    
    y = y + h/2
    
    -- Draw box
    strokeWidth(h)
    stroke(212)
    local half_w = (w - h)/2
    line(WIDTH/2 - half_w, y, WIDTH/2 + half_w, y)
    
    -- Draw text
    fontSize(24)
    if not self.buffer_selected then
        fill(128)
    else
        fill(32)        
    end
    
    textMode(CENTER)
    text(self.buffer, WIDTH/2, y)
    
    popStyle()
end

function SearchBar:select(enable)
    self.typing = enable
    
    -- Display the keyboard if necessary
    if self.typing then
        showKeyboard()
        self.buffer_selected = true
    else
        hideKeyboard()
        if string.len(self.buffer) == 0 then
            self.buffer = "Search"
        end
        self.buffer_selected = false
    end
end

function SearchBar:keyboard(key)
    self.typing = true
    
    if self.buffer == "Search" then
        self.buffer = ""
    end
    
    if string.len(self.buffer) > 0 and key == BACKSPACE then
        self.buffer = string.sub(self.buffer, 1, -2)
    else
        self.buffer = self.buffer .. key
    end
    
    if string.len(self.buffer) == 0 then
        self.buffer = "Search"
        
        -- Clear filters
        for _,v in ipairs(self.browser_entries) do
            v.filtered = false
            v.filter_score = nil
        end
        
        -- Sort back into alphabetical order
        table.sort(self.browser_entries, function(a, b)
            return a.name < b.name
        end)
    else
        filter(self.browser_entries, self.buffer)
    end
end
