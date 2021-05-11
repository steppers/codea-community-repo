GithubAPI = class()

function GithubAPI:init(api_token, user, repo, branch)    
    self.user = user
    self.repo = repo
    self.branch = branch or "main"
    self.token = api_token
    
    self.url_content = "https://api.github.com/repos/" .. user .. "/" .. repo .. "/contents"
    self.url_raw = "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/" .. branch .. "/"
end

-- Callback passes a table containing the result
-- or nil
function GithubAPI:getContent(path, callback)
    
    local headers = {
        ["Authorization"] = "token " .. self.token,
        ["Accept"] = "application/vnd.github.v3+json",
    }
    
    local request = URLRequest(self.url_content .. path .. "?ref=" .. self.branch, headers)
    
    request:issue(function(response)
        if response then
            -- Send data to the callback
            callback(json.decode(response.data))
            
            -- Flush the cache
            URLCache.shared:flush()
        end
    end, URLCache.shared)
end

-- Callback passes the result as a string
-- or nil
function GithubAPI:getFile(path, callback)
    local request = URLRequest(self.url_raw .. path)
    
    request:issue(function(response)
        if response then
            -- Send data to the callback
            callback(response.data)
            
            -- Flush the cache
            URLCache.shared:flush()
        end
    end) -- don't cache file downloads
end
