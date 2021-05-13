--# Button
Button = class()

function Button:init(img, x, y, type)
    self.img = img
    self.x = x
    self.y = y
    self.type = type
    self.size = 64
end

function Button:draw()
    local bg = ""
    if editor.activeButton == self.type then
        bg = "Project:buttonbg_on"
    else
        bg = "Project:buttonbg_off"
    end
    if self.type ~= "play"  and self.type ~= "save" and self.type ~= "load" then
        sprite(bg, self.x, self.y, 71, 71)
        sprite(self.img, self.x, self.y, self.size - 10, self.size - 10)
        sprite("Project:overlay", self.x, self.y, 71, 71)
    else
        sprite(self.img, self.x, self.y, self.size, self.size)
        if self.type == "save" and not editor.saved then
            fontSize(48)
            fill(255, 0, 0, 255)
            text("!!!", self.x, self.y)
        end
    end
    
end

function Button:touched(touch)
    local h = self.size/2
    if touch.x > self.x - h and touch.x < self.x + h and touch.y > self.y - h and touch.y < self.y + h then
        if self.type ~= "grid" then
            editor.activeButton = self.type
            editor.scrolling = false
        end
        
        if self.type == "tile" then
            editor.showTiles = true
            editor.tile.pickup = nil
            editor.tile.decal = nil
        end
        
        if self.type == "decal" then
            editor.showDecals = true
            editor.showPickups = nil
            editor.tile.tex = nil
        end
        
        if self.type == "pickup" then
            editor.showPickups = true
            editor.tile.tex = nil
            editor.tile.decal = nil
        end
        
        if self.type == "portal" then
            editor.tile.tex = nil
            editor.tile.pickup = nil
            editor.tile.decal = nil
        end
        
        if self.type == "play" then
            editor.editMode = not editor.editMode
            world:resize(3)
            if editor.editMode then
                music.stop()
                editor.activeButton = "move"
                editor.scrolling = true            
            else
                music("A Hero's Quest:Battle", true, .3)
                if not scene then
                    scene = Scene()
                else
                    scene:reset()
                end
            end
        end
        
        if self.type == "grid" then
            editor.showGrid = not editor.showGrid
            if self.img == "Project:showgrid_on" then
                self.img = "Project:showgrid_off"
            else
                self.img = "Project:showgrid_on"
            end
        end
        
        if self.type == "move" then
            editor.scrolling = true
        end
        
        if self.type == "load" then
            editor.showLoad = true
            editor.activeButton = "move"
            editor.scrolling = true
        end
        
        if self.type == "save" then
            editor.showSave = true
            editor.activeButton = "move"
            editor.scrolling = true
        end
    end
end