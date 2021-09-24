-- Async

local function demo1()
    -- Create new async object
    local async1 = Async()
    
    -- Add a new async task
    async1:job(function(cb)
        http.request("https://baconipsum.com/api/?type=meat-and-filler&paras=1&format=html", function(data)
            cb(data) -- passed as the 'html' arg in the continuation below
        end)
    end)
    
    -- Add another async task to run at the same time
    async1:job(function(cb)
        http.request("https://baconipsum.com/api/?type=meat-and-filler&paras=1&format=text", function(data)
            cb(data) -- passed as the 'txt' arg in the continuation below
        end)
    end)
    
    -- Create a continuation async object which will only execute after the previous
    -- ('async1') object has finished executing all of its functions.
    --
    -- Note: Multiple continuations are supported
    local async2 = async1:cont()
    
    -- Add a new job to the continuation.
    --
    -- Again, this will only run after both of the tasks above have called their
    -- callbacks ('cb()'). In this case, if a request fails leading to a callback
    -- not triggering, the chain will not fully execute allowing us to abort a chain
    -- if necessary.
    --
    -- Continuations also receive values passed to the callbacks in async1, in the
    -- order that they are added (html data first, then text)
    async2:job(function(cb, html, txt)
        print(html)
        print(txt)
        -- We're done so we don't call the callback (cb)
    end)
    
    -- Kick off execution of the async chain!
    async1:go()
end

local function demo2()
    -- Demo 2 does exactly the same as demo 1 but
    -- uses a more concise form.
    
    -- Create new async object
    local async = Async()
        
    -- Create the async chain
    async:job(function(cb)
        http.request("https://baconipsum.com/api/?type=meat-and-filler&paras=1&format=html", function(data)
            cb(data) -- passed as the 'html' arg in the continuation below
        end)
    end):job(function(cb)
        http.request("https://baconipsum.com/api/?type=meat-and-filler&paras=1&format=text", function(data)
            cb(data) -- passed as the 'txt' arg in the continuation below
        end)
    end):then_do(function(cb, html, txt)
        print(html)
        print(txt)
    end)
    
    -- Kick off execution of the async chain!
    async:go()
end

function setup()
    demo1()
    --demo2()
end

function draw()
    background(76, 0, 255)
end
