-- Zip

function write_demo()
    
    -- Get a list of all the files in this project
    local files = asset.all
    
    -- Create a new zip archive for writing
    local zip = Zip(asset.documents .. "test.zip", true)
    
    -- Add each file to the zip
    for _,file in ipairs(files) do
        zip:addFile(file)
    end
    
    -- Close the zip file
    zip:close()
end

function read_demo()
   
    -- Open a new zip archive for reading
    local zip = Zip(asset.documents .. "test.zip")
    
    -- Get all files in the zip
    local files = zip:listFiles()
    
    -- Print the paths of all files
    for _,file in ipairs(files) do
        print(file)
    end
    
    -- Print the contents of zipped 'Main.lua' (this file)
    print(zip:readFile("Main.lua"))
    
    -- Close the zip file
    zip:close()
end

function setup()
    write_demo()
    read_demo()
end

function draw()
    background(172, 45, 87)
end

