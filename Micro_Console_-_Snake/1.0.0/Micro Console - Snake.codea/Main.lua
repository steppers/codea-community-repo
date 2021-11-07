local grid_size = 16
local cell_size = 128 / grid_size
local play_area = grid_size - 2

local head = { x = grid_size/2, y = grid_size/2, dir = 0 }
local last_head_dir = 0
local segments = {
    { x = head.x, y = head.y - 1 },
    { x = head.x, y = head.y - 2 },
    { x = head.x - 1, y = head.y - 2 }
}


local update_timer = 0
local update_tick_period = 0.28
local update_tick_period_min = 0.08
local update_tick_period_step = 0.007

local mouse = { x = 3, y = 3 }

local score = 0

local function draw_score()
    fill(255)
    text(tostring(score), 64, 128 - (cell_size/2))
end

local function draw_snake()
    -- Tail
    fill(80, 150, 100)
    for i = 1, #segments do
        local s = segments[i]
        rect(cell_size * (s.x-1) + 1, cell_size * (s.y-1) + 1, cell_size-2, cell_size-2)
    end
    
    -- head
    fill(100, 255, 130)
    rect(cell_size * (head.x-1) + 1, cell_size * (head.y-1) + 1, cell_size-2, cell_size-2)
end

local function draw_mouse()
    fill(255, 100, 130)
    rect(cell_size * (mouse.x-1) + 1, cell_size * (mouse.y-1) + 1, cell_size-2, cell_size-2)
end

local function draw_grid()
    -- Center
    fill(64)
    for x = 2,grid_size-1 do
        for y = 2,grid_size-1 do
            rect(cell_size * (x-1) + 1, cell_size * (y-1) + 1, cell_size-2, cell_size-2)
        end 
    end

    fill(100, 140, 255)
    -- Left
    for y = 1,grid_size do
        rect(1, cell_size * (y-1) + 1, cell_size-2, cell_size-2)
    end
    
    -- Right
    for y = 1,grid_size do
        rect(129 - cell_size, cell_size * (y-1) + 1, cell_size-2, cell_size-2)
    end
    
    -- Top
    for x = 2,grid_size-1 do
        rect(cell_size * (x-1) + 1, 129 - cell_size, cell_size-2, cell_size-2)
    end
    
    -- Bottom
    for x = 2,grid_size-1 do
        rect(cell_size * (x-1) + 1, 1, cell_size-2, cell_size-2)
    end
end

local function add_segment()
    local last = segments[#segments]
    table.insert(segments, { x = last.x, y = last.y })
end

local function is_snake(x, y, no_head)
    if no_head ~= true then
        if head.x == x and head.y == y then
            return true
        end
    end
    
    for _, s in pairs(segments) do
        if s.x == x and s.y == y then
            return true
        end
    end

    return false
end

local function place_mouse()
    local valid_pos = false
    while valid_pos == false do
        mouse.x = math.ceil(math.random() * play_area) + 1
        mouse.y = math.ceil(math.random() * play_area) + 1
        valid_pos = (is_snake(mouse.x, mouse.y) == false)
    end
end

local function update_snake()
    -- Move main section of tail
    for i = #segments, 2, -1 do
        local s = segments[i]
        local ns = segments[i-1]
        s.x = ns.x
        s.y = ns.y
    end
    
    -- Move first tail piece
    segments[1].x = head.x
    segments[1].y = head.y
    
    -- Move head
    if head.dir == 0 then -- up
        head.y = head.y + 1
    elseif head.dir == 1 then -- right
        head.x = head.x + 1
    elseif head.dir == 2 then -- down
        head.y = head.y - 1
    else -- left
        head.x = head.x - 1
    end
    
    -- Wrap head
    if head.x == 1 then
        head.x = grid_size-1        
    elseif head.x == grid_size then
        head.x = 2
    elseif head.y == 1 then
        head.y = grid_size-1
    elseif head.y == grid_size then
        head.y = 2
    end
    
    last_head_dir = head.dir
    
    -- Check head for pickups
    if head.x == mouse.x and head.y == mouse.y then
        add_segment()
        place_mouse()
        score = score + 1
        
        update_tick_period = update_tick_period - update_tick_period_step
        if update_tick_period < update_tick_period_min then
            update_tick_period = update_tick_period_min
        end
    end
    
    -- Snake has bitten itself?
    if is_snake(head.x, head.y, true) then
        restart()
    end
end

function CartridgeSetup()
    ConsoleSetColorDepth(8)
    
    -- Seed the RNG
    math.randomseed(os.time())
    place_mouse()
    
    fontSize(cell_size)
end

function CartridgeUpdate()
    update_timer = update_timer + DeltaTime
    
    if update_timer > update_tick_period then
        update_snake()
        update_timer = update_timer - update_tick_period
    end
end

function CartridgeDraw()
    background(0)
    
    draw_grid()
    draw_mouse()
    draw_snake()
    draw_score()
end

function CartridgeOnButton(btn, state)
    if state == PRESSED then
        if btn == CONSOLE_A then
            
        elseif btn == CONSOLE_B then
            
        elseif btn == CONSOLE_UP then
            if last_head_dir ~= 2 then
                head.dir = 0
            end
        elseif btn == CONSOLE_DOWN then
            if last_head_dir ~= 0 then
                head.dir = 2
            end
        elseif btn == CONSOLE_LEFT then
            if last_head_dir ~= 1 then
                head.dir = 3
            end
        elseif btn == CONSOLE_RIGHT then
            if last_head_dir ~= 3 then
                head.dir = 1
            end          
        end
    end
end
