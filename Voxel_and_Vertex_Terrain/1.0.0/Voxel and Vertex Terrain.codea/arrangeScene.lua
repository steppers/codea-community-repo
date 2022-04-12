function arrangeScene()
    if playerBody then
        playerBody:destroy()
        playerBody = nil
    end
    touches.removeHandler(viewer)
    scene.camera:remove(viewer)  v=scene.camera:add(OrbitViewer,vec3(275,0,200), 700, 0, 2000)
    v.camera.farPlane=10000
    v.rx,v.ry=50,-40
end
