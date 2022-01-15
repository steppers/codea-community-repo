-- Notifications Demo
--
-- To verify that this is performing as expected:
-- 1) Execute this project
-- 2) Minimise Codea
-- 3) 7 seconds from project execution, 2 notifications
--      should appear in iOS' notification center.
--
--
-- NOTE: If the above fails please ensure Notifications
-- are enabled for Codea!
-- You can check this from the iOS Settings app under 'Codea'.


function setup()
    
    Notifications.setup(function(hasPermission)
        
        -- Title, Description & Delay (seconds)
        local id1 = Notifications.scheduleNotification("Demo", "Look at this amazing demo", 5)
        
        -- Title, Description, Delay (seconds) & UserInfo (key-value table)
        local id2 = Notifications.scheduleNotification("Demo 2", "I'll be cancelled below", 3, { x = 9 })
        
        -- List all currently pending notifications
        --
        -- This returns a table with notification identifiers as keys
        -- and UserInfo tables as the values.
        Notifications.getPendingNotifications(function(notifications)
            
            print("Pending Notifications:")
            for id,info in pairs(notifications) do
                
                -- Print the ID & UserInfo values
                local printInfo = { id }
                for k,v in pairs(info) do
                    table.insert(printInfo, k .. " = " .. tostring(v))
                end
                print(table.concat(printInfo, "\n"))
                
                -- Remove pending notifications where x == 9 in UserInfo
                if info.x == 9 then
                    Notifications.cancelNotifications(id)
                end
            end
        end)
        
        -- Cancel all notifications sent by the current project
        Notifications.cancelAllNotifications()
        
        -- Send a final notification that will get through to Notification Center
        Notifications.scheduleNotification("Demo 3", "I got through!", 7)
    end)
end
    

-- Post setup() demo
local sent = false
function draw()
    
    -- Only send a notification once when we have been given permission
    if not sent and Notifications.hasPermission() then
        
        Notifications.scheduleNotification("Demo4", "I was sent from within draw()", 7)
        sent = true
    end
    
    background(91, 31, 114)
end

