-- marufight adapted from:
--https://github.com/groverburger/marufight

function setup()

    rel = math.max(WIDTH, HEIGHT)/1366
    local smallSetting = math.ceil(15*rel)
    local largeSetting = math.ceil(30*rel)
    parameter.action("Reset", function() 
        Reset()
    end)
    parameter.boolean("highlightOldest", true)
    parameter.integer("minCreatures", 1, 400, 40)
    parameter.integer("largest", 1, largeSetting * 4, largeSetting)
    parameter.integer("smallest", 1, largeSetting * 4, smallSetting)
    parameter.integer("food", 1, 500, 150)
    parameter.number("noseMultiplier", 1, 5, 1.6)
    parameter.integer("visionRange", 1, 300, 156)
    parameter.integer("lifespan", 1, 600, 35)
    parameter.boolean("reproduceAfterKilling", true)
    parameter.boolean("canEatWhileAggressive", true)
    parameter.boolean("cantKillFamily", true)
    parameter.boolean("Visual", true)
    
    oldest = {}
    Reset()

end

function touched(touch)
    if touch.state == ENDED then
        local critterTouched = false
        for i, critter in ipairs(ThingList) do
            if critter.name == "creature" then
                if touch.x < critter.x + critter.radius and touch.x > critter.x - critter.radius then
                    if touch.y < critter.y + critter.radius and touch.y > critter.y - critter.radius then
                        critterTouched = true
                        if SelectedThing == critter then
                            SelectedThing = nil 
                        else
                            SelectedThing = critter 
                        end
                    end                   
                end
            end 
        end
        if not critterTouched then
            SelectedThing = nil 
        end
    end
end

function draw()
    background(40, 40, 50)

    if dt then
        local camSpeed = 150*dt 
    end

	if Paused then
		return
    end
    
    if YearTimer then
        YearTimer = YearTimer + 1
        	if YearTimer > 60*15 then
            		Year = Year + 1
            		YearTimer = 0
            		FoodSpawns = 0
            		DeathSpawns = 0
        	end
        
        	local nextOctree = {}
        	for i=1, OctreeSize do
            		nextOctree[i] = {}
            		for j=1, OctreeSize do
                nextOctree[i][j] = {}
            		end
        	end
        	local octreeGrid = WorldSize/OctreeSize
        	local fittestCreature = nil
        	local fittestCount = 0
        	local creatureCount = 0
        	local i=1
        	while i <= #ThingList do
            		local thing = ThingList[i]
            		if thing:update(dt) then
                i=i+1
                if thing.name == "creature" then
                    creatureCount = creatureCount + 1
                    if thing.offspringCount > fittestCount then
                        fittestCount = thing.offspringCount
                        fittestCreature = thing
                    end
                end
                
                local ox,oy = math.floor(thing.x/octreeGrid)+1, math.floor(thing.y/octreeGrid)+1
                ox = math.max(math.min(ox, OctreeSize), 1)
                oy = math.max(math.min(oy, OctreeSize), 1)
                if nextOctree ~= nil and thing ~= nil then
                    table.insert(nextOctree[ox][oy], thing)
                end
            		else
                table.remove(ThingList, i)
            		end
        	end
        	ThingOctree = nextOctree
        
        	if creatureCount and CreatureCount and (creatureCount < CreatureCount) and RandomSpawns then
            		CreateThing(NewCreature(math.random(WIDTH), math.random(HEIGHT)))
        	end
                
        	if Follow and fittestCreature ~= nil then
            		SelectedThing = fittestCreature
        	end     
    end
    
	if Visual then
		SetColor(255,255,255)
        oldest = {}
		for i=1, #ThingList do
            SetColor(255,255,255)
            thisThing = ThingList[i]
            thisThing:draw()
            if thisThing.name == "creature" then
                if #oldest == 0 or thisThing.generation > oldest[1].generation then
                    oldest = {thisThing}
                elseif thisThing.generation == oldest[1].generation then
                    oldest[#oldest + 1] = thisThing
                end                    
            		end 
        end
        if highlightOldest then
            pushStyle()
            noFill()
            strokeWidth(3)
            stroke(255, 255, 200)
            for _, thing in pairs(oldest) do
                ellipse(thing.x, thing.y, thing.radius * 2, thing.radius * 2) 
            end
        end
        SetColor(255,255,255)	
    end
            
    oldestText = oldest[1].generation.."  ("..#oldest..")"
    
    if FoodSpawns then
        local totalSpawns = FoodSpawns + DeathSpawns
        local fper = ""..math.round((FoodSpawns/totalSpawns)*100)
        local dper = ""..math.round((DeathSpawns/totalSpawns)*100)
        pushStyle()
        fontSize(fontSize() * rel * 1.5)
        local _, lineHeight = textSize("AZ!'g")
        textMode(CORNER)
        text("% born from food / kills: "..fper.." - "..dper,WIDTH * 0.005,HEIGHT-(lineHeight * 1.5))
        text("#ThingList: "..#ThingList,WIDTH * 0.005,HEIGHT-(lineHeight * 2.75))
            text("Oldest living generation: "..oldestText, WIDTH * 0.005,HEIGHT-(lineHeight * 4))
        text("Year: "..Year,WIDTH * 0.005,HEIGHT-(lineHeight * 5.25))
        popStyle()
    end
end

