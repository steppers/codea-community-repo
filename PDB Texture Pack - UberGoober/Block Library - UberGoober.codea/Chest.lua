-- A storage block
function chest(capacity)
    local chest = scene.voxels.blocks:new("Chest")
    chest.dynamic = true
    chest.geometry = TRANSPARENT

    function chest:created()
        e = self.entity
        self.base = scene:entity()
        self.base.parent = e
        self.base.position = vec3(0.5, 0.3, 0.5)
        local r = self.base:add(craft.renderer, craft.model.cube(vec3(0.8,0.6,0.8)))
        r.material = craft.material(asset.builtin.Materials.Specular)
        r.material.diffuse = color(133, 79, 30, 255)

        self.top = scene:entity()
        self.top.parent = e
        self.top.position = vec3(0.1, 0.6, 0.1)
        local r2 = self.top:add(craft.renderer, craft.model.cube(vec3(0.8,0.2,0.8), vec3(0.4,0.1,0.4)))
        r2.material = craft.material(asset.builtin.Materials.Specular)
        r2.material.diffuse = color(66, 47, 30, 255)
        self.angle = 0
    end

    function chest:update()
        self.top.rotation = quat.eulerAngles(0,  0, self.angle)
    end

    function chest:interact()
        if not self.open then
            self.open = true
            tween(0.6, self, {angle = 90}, tween.easing.backOut)
        else
            self.open = false
            tween(0.6, self, {angle = 0}, tween.easing.cubicIn)
        end
    end

    return chest
end
