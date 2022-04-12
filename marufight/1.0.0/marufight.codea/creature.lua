
function NewCreature(xg,yg, braing,lineage,generation, radius,noselength, mutations)
    	local c = {}
        c.id = (math.random() * 1000) + os.time()
    	c.brain = braing
    	c.lineage = lineage
    	c.generation = generation
    	c.x = xg
    	c.y = yg
    	c.xSpeed = 0
    	c.ySpeed = 0
    	c.direction = math.random()*2*math.pi
    	c.speed = 0
    	c.radius = radius
    	c.noseLength = noseLength
    	c.mutations = mutations
    	c.noseOut = 1
    	c.noseOutCooldown = 0
    	c.brainOut = {0,0,0,0}
    	c.brainOutRaw = {0,0,0,0}
    	c.lifeTimer = 0
    	c.lifeTimerMax = lifespan * 60
    	c.name = "creature"
    	c.offspringCount = 0
    	c.lastChild = nil
    	c.murdered = false
    	c.iFrames = lifespan * 3
    	c.visionRange = visionRange
    
    	c.lastFoodDist = c.visionRange
    	c.lastFamilyDist = c.visionRange
    	c.lastThingDist = c.visionRange
    	c.lastDeadFoodDist = c.visionRange
    
    	c.map = {{xg,yg}}
    	c.mapTimer = 0
    	c.lastMapDist = WorldSize
    	c.shielding = false
    	c.shieldingCooldown = 0
    
    	c.mutate = function (self)
        		self.brain:mutate()
        		self.lineage.hue = (self.lineage.hue + math.random()*6*choose{1,-1})%255
        		self.lineage.sat = (self.lineage.sat + math.random()*6*choose{1,-1})%127 + 128
        		self.lineage.firstName = Name()
        		self.mutations = self.mutations + 1
        
        		if math.random()>0.95 then
            self.radius = smallest + (math.random() * (largest - smallest))
            self.noseLength = self.radius * noseMultiplier
        		end
        
    	end
    
    	c.update = function (self, dt)
        		if self.iFrames > 0 then self.iFrames = self.iFrames - 1 end
        		self.lifeTimer = self.lifeTimer + 1
        
        		if self.murdered then
            			if Visual then
                				for i=1, 16 do
                    					CreateThing(NewMurderAnim(self.x,self.y, {self.lineage.hue, self.lineage.sat}))
                				end
            			end
            
            			return false
        		end
        
        		self.mapTimer = self.mapTimer + 1
        		if self.mapTimer > 30 and SelectedThing == self then
            			self.lastMapDist = math.dist(self.x,self.y, self.map[#self.map][1],self.map[#self.map][2])
            			self.map[#self.map+1] = {self.x, self.y}
            			self.mapTimer = 0
        		end
        
        		local friction = 0.95
        		self.xSpeed = self.xSpeed*friction
        		self.ySpeed = self.ySpeed*friction
        
        		-- extend or retract nose
        		-- if self.noseOutCooldown > 0 then
        		-- 	self.noseOutCooldown = self.noseOutCooldown - 1
        		-- end
        		-- if self.brainOut[3] < 0 then
        		-- 	if self.noseOutCooldown <= 0 then
        		-- 		self.noseOutCooldown = 60
        		-- 		self.noseOut = 0
        		-- 	end
        		-- end
        		-- if self.brainOut[3] > 0 then
        		-- 	if self.noseOutCooldown <= 0 then
        		-- 		self.noseOutCooldown = 60
        		-- 		self.noseOut = 1
        		-- 	end
        		-- end
        
        		-- to prevent spinners
        		local maxTurnSpeed = 0.05
        --originally commented out, re-added and modified by UG:
        		 if self.noseOut == 1 then
            		 	maxTurnSpeed = 0.1
        		 end
        		-- if self.noseOut == 1 then
        		-- 	maxTurnSpeed = 0.05
        		-- end
        
        		self.speed = self.speed + self.brainOut[2]
        
        		local directionDelta = self.brainOut[1]
        		directionDelta = math.max(math.min(directionDelta, maxTurnSpeed), -1*maxTurnSpeed)
        
        		if self.shielding then
            			directionDelta = 0 --directionDelta/5
        		end
        
        		if math.abs(directionDelta) > maxTurnSpeed/2 then
            			self.noseOut = 0
            			self.noseOutCooldown = 60
        		else
            			self.noseOut = 1
        		end
        		self.noseLength = math.floor((16 * noseMultiplier * rel) - self.radius + 0.5)
        
        		self.direction = self.direction + directionDelta
        		self.direction = self.direction%(math.pi*2)
        
        
        		self.speed = math.max(math.min(self.speed, 1), -1)
        		self.xSpeed = self.xSpeed + math.cos(self.direction)*self.speed*0.05
        		self.ySpeed = self.ySpeed + math.sin(self.direction)*self.speed*0.05
        
        		if self.x+self.xSpeed < 0 or self.x+self.xSpeed > WIDTH then
            			self.xSpeed = self.xSpeed*-1
        		end
        		if self.y+self.ySpeed < 0 or self.y+self.ySpeed > HEIGHT then
            			self.ySpeed = self.ySpeed*-1
        		end
        
        		local moveSpeed = 0.1
        		self.x = self.x + self.xSpeed
        		self.y = self.y + self.ySpeed
        
        		local foodDist = self.visionRange
        		local foodDirection = self.direction
        		local foodSourceDist = self.visionRange
        		local deadFoodDist = self.visionRange
        		local deadFoodDirection = self.direction
        		local thingDist = self.visionRange
        		local thingDirection = self.direction
        		local thingPointDirection = self.direction
        		local familyDist = self.visionRange*3
        		local familyDirection = self.direction
        local thingShielding = 0
        		local thingCount = 0
        		local thingNoseOut = 0
        
        		local interactions = function (self, xx,yy)
            			local octreeGrid = WorldSize/OctreeSize
            			local cx,cy = math.floor(self.x/octreeGrid)+1 +xx, math.floor(self.y/octreeGrid)+1 +yy
            			if cx <= 0 or cy <= 0 or cx > #ThingOctree or cy > #ThingOctree then return end
            			local myOctree = ThingOctree[cx][cy]
            			if myOctree == nil then return end
            
            -- look through all the things in this sector of the octree
            			for i=1, #myOctree do
                				local thing = myOctree[i]
                				local dist = math.dist(thing.x,thing.y, self.x,self.y)
                
                -- if it is food, update my variables accordingly
                				if thing.name == "food" then
                    					local food = thing
                    
                    					if dist < foodDist then
                        						if not food.dead then
                            							foodDist = dist
                            							foodDirection = math.angle(self.x,self.y, food.x,food.y)
                        						else
                            							deadFoodDist = dist
                            							deadFoodDirection = math.angle(self.x,self.y, food.x,food.y)
                        						end
                    					end
                    
                    					if dist < foodSourceDist then
                        						foodSourceDist = dist
                    					end
                    
                    --check if eating is enabled and check if eating
                    if dist <= self.radius+1 then
                        if (canEatWhileAggressive == false) and (self.noseOut == 1) then 
                            goto skipEating
                        end
                        						food.growthTimer = 0
                        						if not food.dead and #ThingList < 1024 then
                            							food.dead = true
                            							self:reproduce()
                            							FoodSpawns = FoodSpawns + 1
                        						end
                    					end
                    ::skipEating::
                				end
                
                -- if thing is another creature, update variables accordingly and manage collisions
                				if thing.name == "creature" and thing ~= self then
                    					local isFamily = self.lineage.firstName == thing.lineage.firstName or self.lineage.middleName == thing.lineage.middleName
                    					local collisionAngle = math.angle(self.x+self.xSpeed,self.y+self.ySpeed, thing.x,thing.y)
                    					local isPoked = math.dist(self.x+math.cos(self.direction)*(self.radius+self.noseLength)*self.noseOut, self.y+math.sin(self.direction)*(self.radius+self.noseLength)*self.noseOut, thing.x,thing.y) <= thing.radius
                    
                    -- if is the current closest thing to me
                    					if dist < thingDist and not (cantKillFamily and isFamily) then
                        						thingCount = thingCount + 1
                        						thingDist = dist
                        						thingDirection = math.angle(self.x,self.y, thing.x,thing.y)
                        						thingPointDirection = thing.direction
                        						thingNoseOut = thing.noseOut
                        if thing.shielding then
                            thingShielding = 1
                        else
                            thingShielding = 0
                        end
                    					end
                    
                    -- closest family to me
                    					if dist < familyDist and isFamily then
                        						familyDist = dist
                        						familyDirection = math.angle(self.x,self.y, thing.x,thing.y)
                    					end
                    
                    -- kill other creatures
                    					if isPoked 
                    and self.noseOut > 0 
                    and not thing.shielding 
                    and not self.shielding 
                    and not (cantKillFamily and isFamily) then
                        						local winner = self
                        						local loser = thing
                        						local can = true
                        
                        						if can and not loser.murdered and loser.iFrames <= 0 then
                            							loser.murdered = true
                            if reproduceAfterKilling then
                                							winner:reproduce()
                                							DeathSpawns = DeathSpawns + 1 
                            end
                        						end
                    					end
                    
                    -- bump other creatures
                    					if dist <= self.radius+thing.radius then
                        						local bumpSpeed = 6*1.6/8
                        						self.xSpeed = math.cos(collisionAngle)*-bumpSpeed
                        						self.ySpeed = math.sin(collisionAngle)*-bumpSpeed
                        						thing.xSpeed = math.cos(collisionAngle)*bumpSpeed
                        						thing.ySpeed = math.sin(collisionAngle)*bumpSpeed
                    					end
                				end
            			end
        		end
        
        		-- do interactions for all octree chunks around me 3x3
        		local checkRange = 3
        		for xx=-checkRange, checkRange do
            			for yy =-checkRange, checkRange do
                				interactions(self,xx,yy)
            			end
        		end
        
        		local foodDirectionDiff = math.abs(self.direction%(math.pi*2)-foodDirection%(math.pi*2))
        		local thingDirectionDiff = math.abs(self.direction%(math.pi*2)-thingDirection%(math.pi*2))
        		local familyDirectionDiff = math.abs(self.direction%(math.pi*2)-familyDirection%(math.pi*2))
        local foodDistDelta = foodDist - self.lastFoodDist
        local thingDistDelta = thingDist - self.lastThingDist
        
        		self.brainOut = self.brain:cycle({
            			{foodDistDelta},
            			{thingShielding},
            			{thingDirectionDiff},--{thingDist - self.lastThingDist},
            			{thingDistDelta},
        		})
        		self.brainOutRaw = deepcopy(self.brainOut)
        		for i=1, #self.brainOut do
            			self.brainOut[i] = self.brainOut[i]*2 -1
        		end
        
        		self.lastThingDist = thingDist
        		self.lastFamilyDist = familyDist
        		self.lastFoodDist = foodDist
        		self.lastDeadFoodDist = deadFoodDist
        
        		local ret = self.lifeTimer < self.lifeTimerMax
        		if not ret and SelectedThing == self then
            			SelectedThing = self.lastChild
        		end
        
        		return ret
    	end
    
    	c.reproduce = function (self)
        		local child = CreateThing(NewCreature(self.x,self.y, deepcopy(self.brain),deepcopy(self.lineage),self.generation+1, self.radius, self.noseLength, self.mutations))
        		for j=1, choose{0,0,0,0,0,1,1,rand(0,10)} do
            			child:mutate()
        		end
        		self.lastChild = child
        		self.iFrames = 60
        		self.offspringCount = self.offspringCount+1
        		if child.mutations>15 then
            			child.generation = 0
            			child.mutations = 0
            			child.lineage.middleName = self.lineage.firstName
        		end
    	end
    
    	c.draw = function (self)
        		local dx,dy = self.x-Camera.x,self.y-Camera.y
        		local r,g,b = HSV(self.lineage.hue,self.lineage.sat,255)
        		SetColor(r,g,b)
        pushStyle()
        noStroke()
        ellipse(dx, dy, self.radius * 2, self.radius * 2)
        popStyle()
        		SetColor(255,255,255)
        		if self.noseOut == 0 then
            			SetColor(0,0,0)
        		end
        line(dx,dy, dx+math.cos(self.direction)*(self.radius+self.noseLength*self.noseOut),dy+math.sin(self.direction)*(self.radius+self.noseLength*self.noseOut))
        
        		if self.shielding then
            print("shielding")
            			SetColor(255,255,255)
            circle( dx,dy, (self.radius+4) * 2, (self.radius+4) * 2)
        		end
        
        		if SelectedThing == self then
            pushStyle()
            			SetColor(255,255,0, 40)
            stroke(255, 150)
            rect(dx-self.radius - 2, dy-self.radius - 2, (self.radius * 2) + 4, (self.radius * 2) + 4)
            popStyle()
            self.brain:draw()
            pushStyle()
            fill(76, 210, 233)
            textMode(CORNER)
            fontSize(fontSize() * rel * 1.5)
            local _, lineHeight = textSize("AZ!'g")
            local startText = WIDTH * 0.005
            			text("age: "..math.floor((self.lifeTimer/self.lifeTimerMax)*100).."%", startText, HEIGHT - (lineHeight * 6.5))
            			text("offspringCount: "..self.offspringCount, startText, HEIGHT - (lineHeight * 7.75))
            			text("family: "..self.lineage.firstName.." "..self.lineage.middleName.." "..self.lineage.lastName, startText, HEIGHT - (lineHeight * 9))
            			text("generation: "..self.generation, startText, HEIGHT - (lineHeight * 10.25))
            			text("radius: "..math.floor(self.radius).." noseLength: "..math.floor(self.noseLength), startText, HEIGHT - (lineHeight * 11.5))
            			text("mutations: "..math.floor(self.mutations), startText , HEIGHT - (lineHeight * 12.75))
            
            noStroke()
            local r,g,b = HSV(self.lineage.hue,self.lineage.sat,255)
            fill(r, g, b, 30)
            ellipse(dx,dy, (self.visionRange * 2), (self.visionRange * 2))
            popStyle()
            			local drawMap = {}
            			for i=1, #self.map do
                				drawMap[#drawMap+1] = self.map[i][1] -Camera.x
                				drawMap[#drawMap+1] = self.map[i][2] -Camera.y
            			end
            
            			if drawMap ~= nil and #drawMap%2 == 0 and #drawMap >= 4 then
                				line(drawMap)
            			end
        		end
    	end
    
    	if c.mutations == nil then
        		c.mutations = 0
    	end
    	if c.radius == nil then
        c.radius = smallest
    	end
    	if c.noseLength == nil then
        c.noseLength = c.radius * noseMultiplier
    	end
    	if c.lineage == nil then
        		c.lineage = {}
        		c.lineage.name = ""
        		c.lineage.hue = math.floor(math.random()*255 +0.5)
        		c.lineage.sat = math.floor(math.random()*128 +0.5) +128
        		c.lineage.lastName = Name()
        		c.lineage.middleName = Name()
        		c.lineage.firstName = Name()
    	end
    	if c.generation == nil then
        		c.generation = 1
    	end
    	if c.brain == nil then
        		c.brain = NewBrain()
        		for i=1, 30 do
            			c:mutate()
        		end
    	end
    	c.lineage.unique = math.floor(math.random()*100000000)
    
    c.serialize = function(self)
        return self.id
    end
    
    c.restore = function(self, serialization)
        self.id = serialization
    end
    
    return c
end