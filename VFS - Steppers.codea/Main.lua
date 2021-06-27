-- VFS

-- Show sidebar
viewer.mode = STANDARD

function setup()
    local vfs = VFS("demo")
    
    -- Make sure the vfs is formatted
    vfs:format()
    
    -- Change working directory to root
    -- (Not necessary as the VFS defaults
    -- to '/' as working dir).
    vfs:cd("/")
    
    -- Make a new directory at the root if it
    -- doesn't exist already (it won't as we've
    -- formatted)
    if not vfs:exists("demo_dir") then
        vfs:mkdir("demo_dir")
    end
    
    -- Change to our new directory
    vfs:cd("demo_dir")
    
    -- Make a new subdirectory
    vfs:mkdir("subdir")
    
    -- Create a file in our subdirectory
    local file = vfs:open("subdir/test.txt", "w")
    file:write("Hello Codea World!")
    file:close()
    
    -- Make a new directory at the root
    vfs:mkdir("/tmp")
    
    -- Change working directory back to the
    -- new dir
    vfs:cd("/tmp")
    
    -- Create a file in the root
    do
        local file = vfs:open("/root_test.txt", "w")
        file:write("Look at me, I'm a test file!")
        file:close()
    end
    
    -- List entries at root
    print("ls '/'")
    local files, dirs = vfs:ls("/")
    for _,e in ipairs(dirs) do
        print("Dir:", e)
    end
    for _,e in ipairs(files) do
        print("File:", e)
    end
    
    -- Read the content of the first test file
    do
        local file = vfs:open("/demo_dir/subdir/test.txt", "r")
        print("File content:", file:read("*a"))
        file:close()
    end
    
    -- Remove the second test file
    vfs:rm("/root_test.txt")
end

function draw()
    background(32, 32, 32)
end

