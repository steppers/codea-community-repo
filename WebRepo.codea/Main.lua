-- WebRepo

saveProjectData("Author",       "Steppers")
saveProjectData("Description",  "Load & run Codea projects from the internet!")
saveProjectData("Version",      "1.0")
saveProjectData("Date",         "06-May-2021")

-- Perform the initial Web Repo setup and provide the user
-- with the project selection UI
function setup()
    
    getAccessToken(function(token)
        
        -- Initialise the web repo system
        initWebRepo(token)
        
        -- Update our cached list of available projects
        updateWebRepo(function()
            -- Download or update all projects
            local projects = getProjects()
            for _,v in pairs(projects) do
                
                -- Ignore the WebRepo project itself
                -- We'll automatically update ourselves below anyway
                if v.name ~= "WebRepo" then
                    parameter.action(v.name, function()
                        downloadProject(v.name, function(success)
                            if success then
                                launchProject(v.name)
                            end
                        end)
                    end)
                end
            end
            
            -- Update ourselves
            downloadProject("WebRepo")
        end)
    end)
end
