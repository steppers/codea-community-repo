http.requestMany = class() --request multiple remote files, callback is triggered when all load

function http.requestMany:init(t) --url path to raw data, names of each file, success callback (required), fail callback (optional)
    self.onFinal = t.onFinal
    self.onEach = t.onEach or function() end
    self.fail = t.fail or function() end
    self.names = t.names
    self.data = {}
    self.completed = 0 -- {}
    for i,v in ipairs(self.names) do
        http.request(t.url..v, function(data) self:fileLoaded(data, i, v) end, function(error) self:fileFailed(error, i) end)
    end
    
end

function http.requestMany:fileLoaded(data, i, v)
    self.data[v] = data
   -- self.completed[i] = true
    self.completed = self.completed + 1
    self.onEach()
    self:consolidate()
end

function http.requestMany:fileFailed(error, i)
  --  self.completed[i] = true
    self.completed = self.completed + 1
    self.error = error
    print("error", error)
    self:consolidate()
end

function http.requestMany:consolidate()
    local count = 0
    for _,__ in pairs(self.data) do
        count = count + 1
    end
   -- print("cons", count, #self.names)
    if count == #self.names then
        self.onFinal(self.data)
    elseif self.completed == #self.names then
        alert(self.error) --i.."/"..#self.names.." failed",
        self.fail(self.data, self.error)
    end
end
