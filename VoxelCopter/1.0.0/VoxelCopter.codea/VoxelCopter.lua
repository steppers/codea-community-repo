VoxelCopter = class()

function VoxelCopter:init(scene)

    self.copterModel = scene:entity()
    
    local framesTemp = {}
    
    for i, assetVal in ipairs({asset.VE_Copter_1, asset.VE_Copter_2, asset.VE_Copter_3,
    asset.VE_Copter_4, asset.VE_Copter_5, asset.VE_Copter_6, asset.VE_Copter_7,
    asset.VE_Copter_8}) do
        local frame = scene:entity()
        local vm = frame:add(craft.volume, 1,1,1)
        vm:load(assetVal)
        frame.active = false
        frame.position = vec3(0,0,-10.5)
        frame.parent = self.copterModel
        table.insert(framesTemp, frame)
    end
    
    local frame1, frame2, frame3, frame4, frame5, frame6, frame7, frame8 =
    framesTemp[1], framesTemp[2], framesTemp[3], framesTemp[4], framesTemp[5], 
    framesTemp[6], framesTemp[7], framesTemp[8]
    
    self.frameSequence = {frame1, frame2, frame3, frame6, frame5, frame8, frame7, frame6, frame3, frame4}
    
    self.currentFrame = 1
    self.animationTicker = ElapsedTime
    
    self.rotation = {y = 7}
    self.rotween = tween(3.85, self.rotation, {y = -7}, {easing = tween.easing.sineInOut, loop = tween.loop.pingpong})
end

function VoxelCopter:draw()
    if ElapsedTime - self.animationTicker > 0.08 then
        self.frameSequence[self.currentFrame].active = false
        if self.currentFrame == #self.frameSequence then
            self.currentFrame = 1
        else
            self.currentFrame = self.currentFrame + 1 
        end
        self.frameSequence[self.currentFrame].active = true
        self.animationTicker = ElapsedTime
    end
    self.copterModel.eulerAngles = vec3(0,self.rotation.y,0)
end
