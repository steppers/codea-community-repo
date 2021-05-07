-- GitHub OAuth Authorisation

local http_params_poll = {
    ["method"] = "POST",
    ["headers"] = {
        ["Accept"] = "application/json"
    }
}

local CLIENT_ID = "302a288e1747eb7cf052"

local function form_url(base, params)
    base = string.gsub(base, "%%2F", "/")
    base = string.gsub(base, "%%3A", ":")
    
    local p = ""
    
    for k,v in pairs(params) do
        p = p .. "&" .. k .. "=" .. v
    end
    
    if string.len(p) > 0 then
        p = string.gsub(p, "&", "?", 1)
    end
    
    return base .. p
end

local function parse_response(data)
    local t = {}
    
    for key, val in string.gmatch(data, "([^=]+)=([^&]+)&*") do
        t[key] = val
    end
    
    return t
end

local access_token = nil
local poll_info = nil

local function newToken(callback)
    -- Get the user code
    local url = form_url("https://github.com/login/device/code", { client_id = CLIENT_ID })
    http.request(url,
        function(data, status)
            data = parse_response(data)
        
            -- Display a message to the user containing their code
            viewer.alert("Please authenticate using a Github account to avoid rate limiting when accessing the repository.\n\nWhen asked, please enter the following code:\n" .. data.user_code .. "\n\nNote: Your code has also been added to your clipboard", "Allow Github Authentication")
            pasteboard.copy(data.user_code)
        
            -- Wait for a valid token
            poll_info = {
                url = form_url("https://github.com/login/oauth/access_token", {
                    client_id = CLIENT_ID,
                    device_code = data.device_code,
                    grant_type = "urn:ietf:params:oauth:grant-type:device_code"
                }),
                expiry_time = os.time() + data.expires_in,
                next_time = os.time() + data.interval,
                interval = data.interval + 1,
                callback = callback,
                verification_uri = data.verification_uri
            }
        end,
        function(error)
            print("newToken()", error)
        end,
        { ["method"] = "POST" })
end

local function validateToken(token, callback)
    local params = {
        ["method"] = "HEAD",
        ["headers"] = {
            ["Authorization"] = "token " .. token,
            ["Accept"] = "application/vnd.github.v3+json"
        }
    }
    
    http.request("https://api.github.com/repos/steppers/codea-community-repo/contents/",
        function(data, status)
            if status == 200 then
                callback(token)
            else
                newToken(callback)
            end
        end,
        function(error)
            if string.find(error, "401", 1, true) then
                newToken(callback)
            elseif string.find(error, "offline", 1, true) then
                callback(token) -- Assume it's ok, we can't do much else
            else
                print("newToken()", error)
            end
        end,
        params)
end

-- Starts the authorisation flow if no token has been received before
-- and checks any token we already have to make sure it hasn't expired
function getAccessToken(callback)
    local access_token = readGlobalData("github_access_token")
    
    if access_token then
        validateToken(access_token, callback)
    else
        newToken(callback)
    end
end

function updateAccessToken()
    if not poll_info then
        return
    end
    
    -- Have we expired or completed?
    if poll_info.next_time >= poll_info.expiry_time or access_token ~= nil then
        newToken(poll_info.callback) -- start again
        poll_info = nil
        return
    end
    
    local function on_success(data, status, headers)
        if status == 200 then
            local j = json.decode(data)
            access_token = j.access_token
            
            if access_token then
                -- Save the token to disk
                saveGlobalData("github_access_token", access_token)
                
                -- Inform the caller
                poll_info.callback(access_token)
                poll_info = nil
            else
                openURL(form_url(poll_info.verification_uri, {}), true)
            end
        else
            print("updateAccessToken() status", status)
        end
    end
    
    local function on_fail(error, headers)
        print("updateAccessToken()", error)
    end
    
    -- Check if we should make another request yet
    if os.time() >= poll_info.next_time then
        http.request(poll_info.url, on_success, on_fail, http_params_poll)
        poll_info.next_time = poll_info.next_time + poll_info.interval
    end
end
