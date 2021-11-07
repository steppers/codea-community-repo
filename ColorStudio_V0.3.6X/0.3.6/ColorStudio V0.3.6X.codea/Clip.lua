Clip = class()

local pos_n_size = {}
local N = 0

function Clip:on(pos, size)
    
    N = N+1
    
    if N > 1 then
        pos, size =
            vec2(
                math.min(math.max(pos.x, pos_n_size[N-1].x), pos_n_size[N-1].x+pos_n_size[N-1].z),
                math.min(math.max(pos.y, pos_n_size[N-1].y), pos_n_size[N-1].y+pos_n_size[N-1].w)
            ),
            vec2(
                math.max(math.min(math.min(size.x, size.x+pos.x-pos_n_size[N-1].x), math.min(pos_n_size[N-1].z, pos_n_size[N-1].z+pos_n_size[N-1].x-pos.x)), 0),
                math.max(math.min(math.min(size.y, size.y+pos.y-pos_n_size[N-1].y), math.min(pos_n_size[N-1].w, pos_n_size[N-1].w+pos_n_size[N-1].y-pos.y)), 0)
            )
    end
    pos_n_size[N] = vec4(pos.x, pos.y, size.x, size.y)
    
    clip(pos_n_size[N]:unpack())
    
end

function Clip:off()
    
    N = N-1
    
    if N < 1 then
        clip()
    else
        clip(pos_n_size[N]:unpack())
    end
    
end
