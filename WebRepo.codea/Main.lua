-- WebRepo

saveProjectData("Author",       "Steppers")
saveProjectData("Description",  "Load & run Codea projects from the internet!")
saveProjectData("Version",      "1.0")
saveProjectData("Date",         "06-May-2021")

-- Change this to 'main' for release builds.
-- 'dev' will prevent the autoupdate of this project.
GITHUB_BRANCH = "main"

local app_browser = nil

-- Perform the initial Web Repo setup and provide the user
-- with the project selection UI
function setup()

    -- Go fullscreen now we have a UI
    viewer.mode = FULLSCREEN

    -- Initialise the App browser
    app_browser = Browser()
    
    getAccessToken(function(token)
        
        -- Initialise the web repo system
        initWebRepo(token)
        
        -- List available projects
        local projects = getProjects()
        app_browser = Browser(projects)
        
        -- Update our cached list of available projects
        updateWebRepo(function()
            
            -- Update ourselves
            if projectCanBeUpdated("WebRepo") and GITHUB_BRANCH ~= "dev" then
                downloadProject("WebRepo", function(success)
                    if success then
                        viewer.close()
                    end
                end)
            end
            
            -- List available projects
            local projects = getProjects()
            app_browser:reinit(projects)
        end)
    end)
end

function draw()
    background(0)

    if projectIsDownloading("WebRepo") then
        fill(255)
        textMode(CENTER)
        textAlign(CENTER)
        text("Autoupdating\nWebRepo Project", WIDTH/2, HEIGHT/2)
    else
        app_browser:draw()
    end

    updateAccessToken()
end

function tap(pos)
    app_browser:tap(pos)
end

function pan(pos, delta, state)
    app_browser:pan(pos, delta, state)
end