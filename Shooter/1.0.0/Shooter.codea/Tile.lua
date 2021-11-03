--# Tile
Tile = class()

function Tile:init()
    self.tex = nil
    self.solid = 0
    self.pickup = nil
    self.decals = {}
    self.portal = nil
    -- only used for editor
    self.decal = nil
end