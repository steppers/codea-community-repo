AsyncCoordinator = class()

function AsyncCoordinator:init(callback)
    self.count = 1
    self.callback = callback
end

function AsyncCoordinator:inc(val)
    self.count = self.count + (val or 1)
end

function AsyncCoordinator:dec()
    self.count = self.count - 1
    if self.count == 0 then
        self.callback()
    end
end

function AsyncCoordinator:done()
    self:dec()
end





Async = class()

function Async:init()
    self.funcs = {}
    self.continuations = {}
    self.results = {}
end

function Async:job(func)
    table.insert(self.funcs, func)
    table.insert(self.results, {})
    return self
end

function Async:go(...)
    
    local count = #self.funcs
    local function update_count()
        count = count - 1
        if count == 0 then
            -- Generate results list
            local results = {}
            for _,cr in ipairs(self.results) do
                for _,r in ipairs(cr) do
                    table.insert(results, r)
                end
            end
            
            -- Start continuations
            for _,c in ipairs(self.continuations) do
                c:go(table.unpack(results))
            end
        end
    end
    
    -- Execute the functions, passing the previous results
    for i,f in ipairs(self.funcs) do
        local function cb(...)
            self.results[i] = {...}
            update_count()
        end
        
        if #{...} > 0 then
            f(cb, ...)
        else
            f(cb)
        end
    end
end

function Async:cont()
    local async = Async()
    table.insert(self.continuations, async)
    return async
end

function Async:then_do(func)
    return self:cont():job(func)
end
