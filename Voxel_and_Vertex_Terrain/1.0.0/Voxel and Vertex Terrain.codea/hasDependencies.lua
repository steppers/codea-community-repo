function hasDependencies()
    errorText = ""
    if not joystickWalkerRig then 
        errorText = errorText.."Please include Joystick Player as a dependency\n\n" 
    end
    if not OrbitViewer then 
        errorText = errorText.."Please include Cameras as a dependency\n\n" 
    end  
    if errorText ~= "" then
        fontSize(fontSize()*2.5)
        fill(255)
        return false
    end
    return true
end
