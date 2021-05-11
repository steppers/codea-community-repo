-- WebRepo

-- Change this to 'main' for release builds.
-- 'dev' will prevent the autoupdate of this project.
GITHUB_BRANCH = "dev"

GITHUB_USER = "steppers"
GITHUB_REPO = "codea-community-repo"

local app_browser = nil
local webrepo = nil

local webrepoDelegate = {}
function webrepoDelegate.onMetadataAdded(metadata)
    app_browser:addProject(metadata)
end

-- Perform the initial Web Repo setup and provide the user
-- with the project selection UI
function setup()
    
    -- Go fullscreen now we have a UI
    --viewer.mode = FULLSCREEN
    
    -- Initialise the App browser so the search bar appears
    app_browser = Browser()
    
    getAccessToken(function(token)
        
        -- Initialise Github API lib
        local github = GithubAPI(token, GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)
        
        -- Initialise the WebRepo and set it in the browser
        webrepo = WebRepo(github, webrepoDelegate)
        app_browser.webrepo = webrepo
        
        --[[
        if webrepo:updateAvailableFor("WebRepo") and GITHUB_BRANCH ~= "dev" then
            webrepo:downloadProject("WebRepo", function(success)
                if success then
                    viewer.close()
                end
            end)
        end
        ]]
    end)
end

function draw()
    background(32)
    
    --[[
    if projectIsDownloading("WebRepo") then
        fill(255)
        textMode(CENTER)
        textAlign(CENTER)
        text("Autoupdating\nWebRepo Project", WIDTH/2, HEIGHT/2)
    else
    ]]
        app_browser:draw()
    --end
    
    updateAccessToken()
end

function tap(pos)
    app_browser:tap(pos)
end

function pan(pos, delta, state)
    app_browser:pan(pos, delta, state)
end

function keyboard(key)
    app_browser:keyboard(key)
end