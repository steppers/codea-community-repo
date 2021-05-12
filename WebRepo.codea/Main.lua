-- WebRepo

-- Change this to 'main' for release builds.
-- 'dev' will prevent the autoupdate of this project.
GITHUB_BRANCH = "main"

GITHUB_USER = "steppers"
GITHUB_REPO = "codea-community-repo"

local app_browser = nil
local webrepo = nil

local webrepoDelegate = {}
function webrepoDelegate.onMetadataAdded(metadata)
    app_browser:addProject(metadata)
end

function webrepoDelegate.onProjectDownloaded(metadata)
    -- If we autoupdate ourself, close so we can reload
    if metadata.path == "WebRepo.codea" then
        viewer.close()
    end
end

-- Perform the initial Web Repo setup and provide the user
-- with the project selection UI
function setup()
    
    -- Go fullscreen now we have a UI
    viewer.mode = FULLSCREEN
    
    -- Initialise the App browser so the search bar appears
    app_browser = Browser()
    
    getAccessToken(function(token)
        
        -- Initialise Github API lib
        local github = GithubAPI(token, GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)
        
        -- Initialise the WebRepo and set it in the browser
        webrepo = WebRepo(github, webrepoDelegate)
        app_browser.webrepo = webrepo
    end)
end

function draw()
    background(32)
    
    if webrepo then
        local own_meta = webrepo:getProjectMetadata("WebRepo.codea")
        if own_meta and own_meta.downloading then
            fill(255)
            textMode(CENTER)
            textAlign(CENTER)
            text("Autoupdating\nWebRepo Project", WIDTH/2, HEIGHT/2)
        else
            app_browser:draw()
        end
    else
        app_browser:draw()
    end
    
    updateAccessToken()
end

function tap(pos)
    app_browser:tap(pos)
end

function pan(pos, delta, state)
    app_browser:pan(pos, delta)
end

function keyboard(key)
    app_browser:keyboard(key)
end

function scroll(gesture)
    -- Send scroll events to the browser so we can scroll with a mouse
    app_browser:pan(gesture.location, gesture.delta)
end
