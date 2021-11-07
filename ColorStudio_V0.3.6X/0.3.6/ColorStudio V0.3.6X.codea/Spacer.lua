Spacer = class()

function Spacer:horizontal(pos, size, gap, numberOfObjects)
    
    local position_and_size = {}
    
    for i = 0, numberOfObjects-1 do
        table.insert(position_and_size, vec4(pos.x+gap+(size.x-gap)/numberOfObjects*i, pos.y, (size.x-gap)/numberOfObjects-gap, size.y))
    end
    
    return position_and_size
    
end


function Spacer:vertical(pos, size, gap, numberOfObjects)
    
    local position_and_size = {}
    
    for i = 0, numberOfObjects-1 do
        table.insert(position_and_size, vec4(pos.x, pos.y+gap+(size.y-gap)/numberOfObjects*i, size.x, (size.y-gap)/numberOfObjects-gap))
    end
    
    return position_and_size
    
    
end