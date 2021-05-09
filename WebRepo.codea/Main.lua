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
            
            -- Update ourselves
            if projectCanBeUpdated("WebRepo") then
                downloadProject("WebRepo", function(success)
                    if success then
                        viewer.restart()
                    end
                end)
            end
            
            -- List available projects
            local projects = getProjects()
            for _,v in pairs(projects) do
                -- Ignore hidden projects
                if not v.hidden then
                    parameter.action(v.display_name, function()
                        downloadProject(v.project_name, function(success)
                            if success then
                                launchProject(v.project_name)
                            end
                        end)
                    end)
                end
            end
        end)
    end)
end
