Explosion = class()

function Explosion:init(scene)
    -- you can accept and set parameters here
    self.cnt=0
    self.explode = false
    self.scene = scene
    self.locus = vec3(0,0,0)
    self.scale = vec3(1,1,1)
end

function Explosion:draw()
    if self.explode then
        self.cnt=80
        self.explode=false
        self:createSphere(self.locus)
    end
    if self.cnt>0 then
        self.cnt=self.cnt-1
        if self.cnt<1 then
            self.pt:destroy()
        end
    end
end

function Explosion:explodeAt(locus, scaling)
    self.locus = locus or self.locus
    self.scale = scaling or self.scale
    self.explode = true
end

function Explosion:createSphere(locus)
    if self.pt then
        self.pt:destroy()
    end
    self.pt=self.scene:entity()
    self.pt.position=vec3(locus.x, locus.y, locus.z)
    self.pt.model=craft.model.icosphere(1,2)
    self.pt.material=craft.material(asset.documents.Explosion)   
    self.pt.scale = self.scale
end

function Explosion:touched(t)
    --uncomment to test
    if t.state==BEGAN then
        self.scale = vec3(0.05, 0.05, 0.05)
        self.explode=true
    end
end