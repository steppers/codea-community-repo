--# World
World = class()

function World:init(w, h)
    self.w = w
    self.h = h
    self.maxW = w*3
    self.maxH = h*3
    self.currentScale = 3
    self.size = WIDTH/w
    
    	-- attempts to load last map
    self:load()
end

-- resizes tiles for zoom in/out using editor
function World:resize(s)
    if s then
        self.w = 4*s
        self.h = 3*s
        		self.size = WIDTH/self.w
    	else
        self.w = 4*self.currentScale
        self.h = 3*self.currentScale
    	end
    	self.size = WIDTH/self.w
end

function World:load()
    local slot = "Project:save_" .. editor.saveSlot
    local backup = readText(slot)
    self.timers = {}
    
    self.p1flag = vec2()
    self.p1spawn = vec2()
    self.p2flag = vec2()
    self.p2spawn = vec2()
    
    
    self.x = 1
    self.y = 1
    
    if backup then
        self.map = json.decode(backup)
        		self.maxW = #self.map
        		self.maxH = #self.map[1]
    else
        self.map = {}
        for x=1, self.maxW do
            self.map[x] = {}
            for y=1, self.maxH do
                self.map[x][y] = Tile()
            end
        end
    end
    
    self.maxW = #self.map
    self.maxH = #self.map[1]
    
    	
    	-- reads map info (flags, spawns, etc)
    local block
    for x=1, self.maxW do
        for y=1, self.maxH do
            block = self.map[x][y]
            --      if block.tex and not readImage(block.tex) then
            --          block.tex = nil
            --       end
            --      if block.decal then
            --          block.decals = {block.decal}
            --       end
            
            if block.pickup == "Project:p1_1_7" then self.p1flag = vec2(x,y) end
            if block.pickup == "Project:p1_2_7" then self.p2flag = vec2(x,y) end
            if block.pickup == "Project:p1_3_7" then self.p1spawn = vec2(x,y) end
            if block.pickup == "Project:p1_4_7" then self.p2spawn = vec2(x,y) end
            
            
        end
    end    
end

function World:save()
    local slot = "Project:save_" .. editor.saveSlot
    saveText(slot, json.encode(self.map))
    editor.saved = true
end

-- process timers
function World:processTimer(timer)
    	-- respawn timer done, repop pickup
    if timer.type == "pickup" then
        self.map[timer.obj.pos.x][timer.obj.pos.y].pickup = timer.obj.item
    end
end

function World:addRespawnTimer(i, p)
    table.insert(self.timers, Timer(15, "pickup", {item = i, pos = vec2(p.x, p.y)} ))
end

-- update timers
function World:update()
    for _, timer in ipairs(self.timers) do
        timer:update()
    end
    
    local timer = self.timers[1]
    if timer and timer.done then
        self:processTimer(timer)
        table.remove(self.timers, 1)
    end
end

function World:drawEditor()
    local ix, fx = math.modf(self.x)
    local fx = fx * self.size
    local iy, fy = math.modf(self.y)
    local fy = fy * self.size
    local px, py = 0, 0
    
    pushMatrix()
    
    translate(self.size/2 - fx, self.size/2 - fy)
    
    for x=ix, ix + self.w do
        for y=iy, iy + self.h do
            if x <= self.maxW and y <= self.maxH and x>=1 and y>=1 then
                block = self.map[x][y]
                if block.tex then
                    sprite(block.tex, px, py, self.size)
                end
                if block.decals then
                    for i=1, #block.decals do
                        sprite(block.decals[i], px, py, self.size)
                    end
                end
                if block.portal then
                    if block.portal.dx then
                        tint(block.portal.r, block.portal.g, block.portal.b, 140)
                    end
                    sprite("Project:portal", px, py, self.size)
                    tint(255)
                end
                if block.pickup then
                    sprite("Project:light", px, py, self.size)
                    sprite(block.pickup, px, py, self.size)
                end
                if editor.showGrid then
                    if block.solid then
                        fill(255, 0, 0, 30)
                    else
                        fill(0, 255, 0, 30)
                    end
                    rect(px - self.size/2, py - self.size/2, self.size, self.size)
                end
            end
            py = py + self.size
        end
        px = px + self.size
        py = 0
    end
    popMatrix()
end

function World:draw(player)
    local block = nil
    strokeWidth(1)
    
    local bigfastmorph = self.size - math.abs(math.sin(ElapsedTime*5)*20)
    local bigslowmorph = self.size - math.abs(math.sin(ElapsedTime*2)*20)
    local smallfastmorph = self.size - math.abs(math.sin(ElapsedTime*5)*10)
    local smallslowmorph = self.size - math.abs(math.sin(ElapsedTime*2)*10)
    
    local mx, my = player.pos.x/world.size + 1, player.pos.y/world.size + 1
    local ix, fx = math.modf(mx)
    local fx = fx * self.size
    local iy, fy = math.modf(my)
    local fy = fy * self.size
    local px, py = 0, 0
    
    pushMatrix()
    local w = 3
    if scene.multi then
        translate(WIDTH/4 + world.size/2 - fx, HEIGHT/2 + world.size/2 - fy)
    else
        w = 6
        translate(WIDTH/2 + world.size/2 - fx, HEIGHT/2 + world.size/2 - fy)
    end
    
    if player.side == 1 then
        px = -w*self.size
    else
        px = -3*self.size + WIDTH/2
    end
    py = -5*self.size
    
    
    for x=ix-w, ix + w do
        for y=iy-5, iy + 5 do
            if x <= self.maxW and y <= self.maxH and x>0 and y>0 then
                block = self.map[x][y]
                				
                				-- read and display tile content
                if block.tex then
                    sprite(block.tex, px, py, self.size)
                end
                
                if block.decals then
                    for i=1, #block.decals do
                        sprite(block.decals[i], px, py, self.size)
                    end
                end
                
                if block.portal then
                    tint(block.portal.r, block.portal.g, block.portal.b, 140)
                    pushMatrix()
                    translate(px, py)
                    rotate(ElapsedTime*300)
                    sprite("Project:portal", 0, 0, bigslowmorph)
                    popMatrix()
                    tint(255)
                end
                if block.pickup then
                    sprite("Project:light", px, py, bigfastmorph)
                    sprite(block.pickup, px, py, smallslowmorph)
                end
            end
            py = py + self.size
        end
        px = px + self.size
        py = -5*self.size
    end
    
    
    popMatrix()
end