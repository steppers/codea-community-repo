--------------------------------------------------------------------------------
-- URLRequest
--------------------------------------------------------------------------------
URLRequest = class()

function URLRequest:init(url, headers, method)
    -- Escape special characters
    self.url = string.gsub(url, "%%", "%%25")
    self.url = string.gsub(self.url, " ", "%%20")
    self.url = string.gsub(self.url, "!", "%%21")
    self.url = string.gsub(self.url, "#", "%%23")
    self.url = string.gsub(self.url, "%$", "%%24")
    self.url = string.gsub(self.url, "@", "%%40")
    
    self.headers = headers or {}
    self.method = method or "GET"
end

-- Issues the request
-- Callback is called with a URLResponse object or nil
function URLRequest:issue(callback, cache_to_use)
    
    -- Get the latest cached response
    local cached_response = nil
    if cache_to_use then
        cached_response = cache_to_use:getResponse(self)
    end
    
    -- Generate the request parameters
    local params = {}
    params.headers = self.headers
    params.method = self.method
    
    -- If we're using the cache use the current cached etag
    -- to ensure we only retrieve data if it has changed
    if cached_response then
        params.headers["If-None-Match"] = cached_response.headers.Etag
    end
    
    -- Local callbacks
    local function onSuccess(data, status, headers)
        if status == 200 then
            local response = URLResponse(data, headers)
            
            -- Check the rate limit header
            local rate_limit = response.headers["X-RateLimit-Remaining"]
            if rate_limit and tonumber(rate_limit) < 50 then
                viewer.alert("Approaching Github API Rate Limit! (<50 left)")
            end
            
            -- Cache the result
            if cache_to_use then
                cache_to_use:storeResponse(self, response)
            end
            
            callback(response) 
        else
            callback(nil)
        end
    end
    
    local function onFailure(err)
        if cached_response == nil then
            print(self.url, err)
            callback(nil)
        end
        callback(cached_response)
    end
    
    -- Make the request
    http.request(self.url, onSuccess, onFailure, params)
end





--------------------------------------------------------------------------------
-- URLResponse
--------------------------------------------------------------------------------
function URLResponse(data, headers, t)
    local t = t or {}
    
    t.data = data
    t.headers = headers
    
    return t
end





--------------------------------------------------------------------------------
-- URLCache
--------------------------------------------------------------------------------
URLCache = class()

function URLCache:init(local_data_id)
    self.local_data_id = local_data_id or "urlcache"
    self.cache = readLocalData(self.local_data_id)
    if self.cache then
        self.cache = json.decode(self.cache)
    else
        self.cache = {}
    end
end

function URLCache:getResponse(request)
    return self.cache[request.method .. request.url]
end

function URLCache:storeResponse(request, response)
    self.cache[request.method .. request.url] = response
end

function URLCache:flush()
    saveLocalData(self.local_data_id, json.encode(self.cache))
end

URLCache.shared = URLCache()
