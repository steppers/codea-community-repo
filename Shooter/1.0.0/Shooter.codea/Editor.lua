--# Editor
Editor = class()

function Editor:init()
    self.buttons = {}
    self.showMenu = false
    self.showTiles = false
    self.showPickups = false
    self.showDecals = false
    self.showGrid = false
    self.saved = true
    self.activeButton = "move"
    self.scrolling = true
    self.editMode = true
    self.tile = Tile()
    
    self.saveSlot = 1
    
    	-- setup buttons
    table.insert(self.buttons, Button("Project:load", 50*(#self.buttons+1), HEIGHT - 50, "load"))
    table.insert(self.buttons, Button("Project:save", 60*(#self.buttons+1), HEIGHT - 50, "save"))
    table.insert(self.buttons, Button("Project:move", 74*(#self.buttons+1), HEIGHT - 50, "move"))
    self.tileButton = Button("Project:tiles_1", 74*(#self.buttons+1), HEIGHT - 50, "tile")
    table.insert(self.buttons, self.tileButton)
    self.decalButton = Button("Project:decals", 74*(#self.buttons+1), HEIGHT - 50, "decal")
    table.insert(self.buttons, self.decalButton)
    table.insert(self.buttons, Button("Project:showgrid_on", 74*(#self.buttons+1), HEIGHT - 50, "grid"))
    self.pickupButton = Button("Project:pickups", 74*(#self.buttons+1), HEIGHT - 50, "pickup")
    table.insert(self.buttons, self.pickupButton)
    table.insert(self.buttons, Button("Project:portal", 74*(#self.buttons+1), HEIGHT - 50, "portal"))
    self.playButton = Button("Project:play", WIDTH - 50, HEIGHT - 50, "play")
    table.insert(self.buttons, self.playButton)
    
    	-- portal specific
    self.portalA = { px=nil, py=nil, dx=nil, dy=nil }
    self.portalB = { px=nil, py=nil, dx=nil, dy=nil }
    self.nbPortals = 0
end

-- either adds an opening portal or a closing (and then links them together)
-- temporary until savePortal() is called
function Editor:addPortal(x, y)
    if not self.portalA.px then
        self.portalA.px = x
        self.portalA.py = y
        return self.portalA, false
    else
        self.portalA.dx = x
        self.portalA.dy = y
        self.portalB.px = x
        self.portalB.py = y
        self.portalB.dx = self.portalA.px
        self.portalB.dy = self.portalA.py
        return self.portalB, true
    end
end

-- removes linked portals
function Editor:removePortal(tile)
    local px, py = tile.portal.px, tile.portal.py
    local dx, dy = tile.portal.dx, tile.portal.dy
    if px then
        world.map[px][py].portal = nil
    end
    if dx then
        world.map[dx][dy].portal = nil
    end
end

-- actually adds the portals to the map
function Editor:savePortal(portal, tile)
    self.nbPortals = self.nbPortals + 1
    if self.nbPortals > #Colors then
        self.nbPortals = 1
    end
    local px, py = portal.dx, portal.dy
    local dx, dy = portal.px, portal.py
    
    self.portalA = { px=nil, py=nil, dx=nil, dy=nil }
    self.portalB = { px=nil, py=nil, dx=nil, dy=nil }
    
    if px == dx and py == dy then
        self:removePortal(tile)
        return
    end
    
    local source = world.map[px][py]
    
    local val = Colors[self.nbPortals]
    local r, g, b = val.r, val.g, val.b
    source.portal = { px=px, py=py, dx=dx, dy=dy, r=r, g=g, b=b }
    tile.portal = { px=dx, py=dy, dx=px, dy=py, r=r, g=g, b=b }
    
end

-- draws environments tileset
function Editor:drawTiles()
    local txt = ""
    rectMode(CENTER)
    resetMatrix()
    
    textWrapWidth(96)
    textAlign(CENTER)
    if self.tile.solid then
        fill(255, 0, 0, 194)
        txt = "Tile will act as wall"
    else
        fill(0, 255, 38, 176)
        txt = "Tile can be walked on"
    end
    rect(128, HEIGHT/2, 128, 128)
    stroke(127, 127, 127, 255)
    fill(0, 0, 0, 160)
    rect(WIDTH/2, HEIGHT/2, 518, 518)
    fill(255, 255, 255, 160)
    text(txt, 128, HEIGHT/2)
    
    rectMode(CORNER)
    sprite("Project:tiles_1", WIDTH/2, HEIGHT/2, 512, 512)
end

-- draws pickups tileset
function Editor:drawPickups()
    rectMode(CENTER)
    resetMatrix()
    
    stroke(127, 127, 127, 255)
    fill(0, 0, 0, 160)
    sprite("Project:erase", 128, HEIGHT/2, 128, 128)
    
    rect(WIDTH/2, HEIGHT/2, 518, 518)
    rectMode(CORNER)
    sprite("Project:pickups", WIDTH/2, HEIGHT/2, 512, 512)
end

-- draws decals tileset
function Editor:drawDecals()
    rectMode(CENTER)
    resetMatrix()
    
    stroke(127, 127, 127, 255)
    fill(127, 127, 127, 160)
    sprite("Project:erase", 128, HEIGHT/2, 128, 128)
    
    rect(WIDTH/2, HEIGHT/2, 518, 518)
    rectMode(CORNER)
    sprite("Project:decals", WIDTH/2, HEIGHT/2, 512, 512)
end

-- draws the Load menu
function Editor:drawLoad()
    rectMode(CENTER)
    resetMatrix()
    
    fill(0, 0, 0, 160)
    
    rect(WIDTH/2, HEIGHT/2, 512, 512)
    rectMode(CORNER)
    sprite("Project:loadmenu", WIDTH/2, HEIGHT/2, 512, 512)
    
    local L = WIDTH/2 - 208
    local W = 400
    
    fill(255, 0, 0, 118)
    rectMode(CORNER)
    if self.saveSlot == 1 then
        rect(L, HEIGHT/2 + 143, 416, 65)
    end
    if self.saveSlot == 2 then
        rect(L, HEIGHT/2 + 55, 416, 65)
    end
    if self.saveSlot == 3 then
        rect(L, HEIGHT/2 - 32, 416, 65)
    end
    if self.saveSlot == 4 then
        rect(L, HEIGHT/2 - 121, 416, 65)
    end
    if self.saveSlot == 5 then
        rect(L, HEIGHT/2 - 209, 416, 65)
    end
end

-- draws the Save menu
function Editor:drawSave()
    rectMode(CENTER)
    resetMatrix()
    
    fill(0, 0, 0, 160)
    
    rect(WIDTH/2, HEIGHT/2, 512, 512)
    rectMode(CORNER)
    sprite("Project:loadmenu", WIDTH/2, HEIGHT/2, 512, 512)
    
    local L = WIDTH/2 - 208
    local W = 400
    
    fill(255, 0, 0, 118)
    rectMode(CORNER)
    if self.saveSlot == 1 then
        rect(L, HEIGHT/2 + 143, 416, 65)
    end
    if self.saveSlot == 2 then
        rect(L, HEIGHT/2 + 55, 416, 65)
    end
    if self.saveSlot == 3 then
        rect(L, HEIGHT/2 - 32, 416, 65)
    end
    if self.saveSlot == 4 then
        rect(L, HEIGHT/2 - 121, 416, 65)
    end
    if self.saveSlot == 5 then
        rect(L, HEIGHT/2 - 209, 416, 65)
    end
end


function Editor:draw()
    world:drawEditor()
    
    if self.showMenu then
        self:drawMenu()
    elseif self.showLoad then
        self:drawLoad()
    elseif self.showSave then
        self:drawSave()
    elseif self.showTiles then
        self:drawTiles()
    elseif self.showPickups then
        self:drawPickups()
    elseif self.showDecals then
        self:drawDecals()
    end
    
    self.tileButton.img = self.tile.tex or "Project:tiles_1"
    self.pickupButton.img = self.tile.pickup or "Project:pickups"
    self.playButton.img = "Project:play"
    
    for _, button in ipairs(self.buttons) do
        button:draw()
    end
    
    if self.tile.solid then
        fill(255, 0, 0, 131)
    else
        fill(0, 255, 38, 83)
    end
    
    rect(self.tileButton.x, self.tileButton.y - 32, 32, 32)
    
end

-- handles input for environment tile selection
function Editor:touchTiles(touch)
    if touch.state == ENDED then
        local nb, txt = 8, "t1"
        
        local x = math.floor((touch.x - WIDTH/2+512/2)/512*nb) + 1
        local y = math.floor((touch.y - HEIGHT/2+512/2)/512*nb) + 1
        
        local tile = "Project:".. txt .. "_" .. x .. "_" .. y
        if readImage(tile) then
            self.tile.tex = tile
            self.showTiles = false
        elseif touch.x > 64 and touch.x < 192 and touch.y > HEIGHT/2 - 64 and touch.y < HEIGHT/2 + 64 then
            self.tile.solid = not self.tile.solid
        else
            self.showTiles = false
        end
    end
end

-- handles input for pickup selection
function Editor:touchPickups(touch)
    if touch.state == ENDED then
        local nb, txt = 8, "p1"
        
        local x = math.floor((touch.x - WIDTH/2+512/2)/512*nb) + 1
        local y = math.floor((touch.y - HEIGHT/2+512/2)/512*nb) + 1
        
        local tile = "Project:".. txt .. "_" .. x .. "_" .. y
        if readImage(tile) then
            self.tile.pickup = tile
        elseif touch.x > 64 and touch.x < 192 and touch.y > HEIGHT/2 - 64 and touch.y < HEIGHT/2 + 64 then
            self.tile.pickup = "Project:erase"
        end
        self.showPickups = false
    end
end

-- handles input for decals selection
function Editor:touchDecals(touch)
    if touch.state == ENDED then
        local nb, txt = 8, "d1"
        
        local x = math.floor((touch.x - WIDTH/2+512/2)/512*nb) + 1
        local y = math.floor((touch.y - HEIGHT/2+512/2)/512*nb) + 1
        
        local tile = "Project:".. txt .. "_" .. x .. "_" .. y
        if readImage(tile) then
            self.tile.decal = tile
        elseif touch.x > 64 and touch.x < 192 and touch.y > HEIGHT/2 - 64 and touch.y < HEIGHT/2 + 64 then
            self.tile.decal = "Project:erase"
        end
        self.showDecals = false
    end
end

-- handles input for load menu
function Editor:touchLoad(touch)
    if touch.x > WIDTH/2 - 208 and touch.x < WIDTH/2 + 208 then
        if touch.x > HEIGHT/2 - 209 and touch.x < HEIGHT/2 + 143+65 then
            if touch.y > HEIGHT/2 + 143 and touch.y < HEIGHT/2 + 143+65 then
                self.saveSlot = 1
                world:load()
            elseif touch.y > HEIGHT/2 + 55 and touch.y < HEIGHT/2 + 55+65 then
                self.saveSlot = 2
                world:load()
            elseif touch.y > HEIGHT/2 - 32 and touch.y < HEIGHT/2 + 32 then
                self.saveSlot = 3
                world:load()
            elseif touch.y > HEIGHT/2 - 121 and touch.y < HEIGHT/2 + (-121+65) then
                self.saveSlot = 4
                world:load()
            elseif touch.y > HEIGHT/2 - 209 and touch.y < HEIGHT/2 + (-209+65) then
                self.saveSlot = 5
                world:load()
            end
        end        
    end
    self.showLoad = false
end

-- handles input for save menu
function Editor:touchSave(touch)    
    if touch.x > WIDTH/2 - 208 and touch.x < WIDTH/2 + 208 then
        if touch.x > HEIGHT/2 - 209 and touch.x < HEIGHT/2 + 143+65 then
            if touch.y > HEIGHT/2 + 143 and touch.y < HEIGHT/2 + 143+65 then
                self.saveSlot = 1
                world:save()
            elseif touch.y > HEIGHT/2 + 55 and touch.y < HEIGHT/2 + 55+65 then
                self.saveSlot = 2
                world:save()
            elseif touch.y > HEIGHT/2 - 32 and touch.y < HEIGHT/2 + 32 then
                self.saveSlot = 3
                world:save()
            elseif touch.y > HEIGHT/2 - 121 and touch.y < HEIGHT/2 + (-121+65) then
                self.saveSlot = 4
                world:save()
            elseif touch.y > HEIGHT/2 - 209 and touch.y < HEIGHT/2 + (-209+65) then
                self.saveSlot = 5
                world:save()
            end
        end        
    end
    self.showSave = false
end

function Editor:scroll(touch)
    	-- regular scrolling if using single finger
    	if nbTouches == 1 then
        		if touch.state == BEGAN then
            			origin.x = touch.x
            			origin.y = touch.y
            			
            			if touch.tapCount == 2 then
                				world:resize()
            			end
            				
        		end
        		if touch.state == MOVING then
            			world.x = world.x + (origin.x - touch.x)/world.size
            			world.y = world.y + (origin.y - touch.y)/world.size
            			origin.x = touch.x
            			origin.y = touch.y
            			
            			world.x = math.max(1, math.min(world.x, world.maxW))
            			world.y = math.max(1, math.min(world.y, world.maxH))
        		end
        	-- zoom in/out if using two finger gesture
    	end
    if nbTouches == 2 then
        		local newPt = {}
        		local lastPt = {}
        		local ins = table.insert  
        		for _, p in pairs(touches) do
            			local px = p.x
            			local py = p.y
            			ins(newPt, vec2(px, py))
            			if touch.state == BEGAN then
                				ins(lastPt, vec2(px, py))
            			else
                				ins(lastPt, vec2(px - p.deltaX, py - p.deltaY))
            			end
        		end
        		local delta = lastPt[1]:dist(lastPt[2]) - newPt[1]:dist(newPt[2])
        		world.currentScale = world.currentScale + delta/200
        		world.currentScale = math.max(math.min(9, world.currentScale), 3)
        		world:resize()
    	end
    	
end

function Editor:paint(touch)
    	-- converts touch to map coordinates
    local ix, fx = math.modf(world.x)
    local iy, fy = math.modf(world.y)
    local x = math.floor(touch.x/world.size + fx)
    local y = math.floor(touch.y/world.size + fy)
    	
    if x <= world.maxW and y <= world.maxH then
        local tile = world.map[x+ix][y+iy]
        local change = false
        
        -- tile painting
        if not self.tile.pickup and self.activeButton ~= "portal" then
            if tile.tex ~= self.tile.tex or tile.solid ~= self.tile.solid then
                change = true
            end
            tile.tex = self.tile.tex or tile.tex
            tile.solid = self.tile.solid
        end
        
        
        if touch.state == ENDED then
            -- add portals
            if self.activeButton == "portal" then
                if tile.portal then
                    self:removePortal(tile)
                end
                
                tile.pickup = nil
                tile.solid = false
                local portal, done = self:addPortal(x+ix, y+iy)
                tile.portal = portal
                if done then
                    self:savePortal(portal, tile)
                end
                self.activeButton = "move"
                self.scrolling = true
                change = true
            end
            
            -- add pickups
            if self.tile.pickup  then
                if tile.portal then
                    self:removePortal(tile)
                end
                if self.tile.pickup == "Project:erase" then
                    tile.pickup = nil
                else
                    tile.solid = false
                    tile.pickup = self.tile.pickup
                end
                if tile.pickup == "Project:p1_1_7" then
                    world.p1flag = vec2(x+ix,y+iy)
                end
                if tile.pickup == "Project:p1_2_7" then
                    world.p2flag = vec2(x+ix,y+iy)
                end
                if tile.pickup == "Project:p1_3_7" then
                    world.p1spawn = vec2(x+ix,y+iy)
                end
                if tile.pickup == "Project:p1_4_7" then
                    world.p2spawn = vec2(x+ix,y+iy)
                end
                
                change = true
            end
            			
            -- add decals
            if self.tile.decal  then
                if self.tile.decal == "Project:erase" then
                    tile.decals = nil
                else
                    tile.solid = false
                    if not tile.decals then
                        tile.decals = {}
                    end
                    table.insert(tile.decals, self.tile.decal)
                end
                change = true
            end
            
        end
        
        self.saved = false
        
    end
end

function Editor:touched(touch)
    if self.showMenu then
        self:touchMenu(touch)
    elseif self.showLoad then
        self:touchLoad(touch)
    elseif self.showSave then
        self:touchSave(touch)
    elseif self.showTiles then
        self:touchTiles(touch)
    elseif self.showPickups then
        self:touchPickups(touch)
    elseif self.showDecals then
        self:touchDecals(touch)
    else
        if touch.y < HEIGHT-110 then
            if self.scrolling then
                self:scroll(touch)
            else
                self:paint(touch)
            end
        else
            if touch.state == ENDED then
                for _, button in ipairs(self.buttons) do
                    button:touched(touch)
                end
            end
        end
    end
end