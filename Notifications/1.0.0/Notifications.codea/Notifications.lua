local random = math.random

Notifications = {}

local state = {
    nc = nil,
    hasPermission = false
}





local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local r = string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
    return r
end





function Notifications.setup(callback)
    state.nc = objc.cls.UNUserNotificationCenter.currentNotificationCenter
    
    local options = objc.enum.UNAuthorizationOptions.alert
    | objc.enum.UNAuthorizationOptions.badge
    | objc.enum.UNAuthorizationOptions.sound
    
    state.nc:requestAuthorizationWithOptions_completionHandler_(options, function(boolGranted, objError)
        state.hasPermission = boolGranted
        callback(boolGranted)
    end)
end





function Notifications.cancelNotifications(identifier)
    if not identifier then 
        objc.warning("identifier must be provided!")
        return
    end
    
    if type(identifier) == "table" then
        state.nc:removePendingNotificationRequestsWithIdentifiers_(identifier)
    else
        state.nc:removePendingNotificationRequestsWithIdentifiers_({ identifier })
    end
end





function Notifications.cancelAllNotifications(allProjects)
    
    -- If we've requested to clear for all projects just do it.
    if allProjects then
        state.nc:removeAllPendingNotificationRequests()
        return
    end
    
    -- By default, we should only remove pending notifications
    -- sent by the current project.
    local projectName = asset.name:gsub(".codea", "")
    
    Notifications.getPendingNotifications(function(notifications)
        local toRemove = {}
        for id,_ in pairs(notifications) do
            if id:match("^" .. projectName) then
                table.insert(toRemove, id)
            end
        end
        Notifications.cancelNotifications(toRemove)
    end)
end





function Notifications.getPendingNotifications(callback, allProjects)
    if not callback then
        objc.warning("Callback 'function(identifiers)' must be provided!")
        return
    end
    
    if allProjects then
        
        -- Get notifications from all projects
        state.nc:getPendingNotificationRequestsWithCompletionHandler_(function(objRequests)
            local notifications = {}
            for _, req in ipairs(objRequests) do
                notifications[req.identifier] = req.content.userInfo or {}
            end
            callback(notifications)
        end)
    else
        
        -- Only return notifications from the current project
        local projectName = asset.name:gsub(".codea", "")
        state.nc:getPendingNotificationRequestsWithCompletionHandler_(function(objRequests)
            local notifications = {}
            for _, req in ipairs(objRequests) do
                if req.identifier:match("^" .. projectName) then
                    notifications[req.identifier] = req.content.userInfo or {}
                end
            end
            callback(notifications)
        end)
    end
end





function Notifications.scheduleNotification(title, description, delay, info)
    if not state.hasPermission then
        objc.warning("Notification permission not available!")
        return
    end
    
    local projectName = asset.name:gsub(".codea", "")
    
    -- Random identifier to assign the notification request
    local identifier = projectName .. "::" .. uuid()
    
    -- Generate the content object
    local content = objc.cls.UNMutableNotificationContent()
    content.title = projectName .. ": " .. title
    content.body = description
    content.sound = objc.cls.UNNotificationSound.defaultSound
    content.userInfo = info or {}
    
    local trigger = objc.cls.UNTimeIntervalNotificationTrigger:triggerWithTimeInterval_repeats_(delay or 5, false)
    
    local request = objc.cls.UNNotificationRequest:requestWithIdentifier_content_trigger_(identifier, content, trigger)
    
    state.nc:addNotificationRequest_(request)
    
    return identifier
end





function Notifications.hasPermission()
    return state.hasPermission
end
