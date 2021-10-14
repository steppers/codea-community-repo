local style_stack = {}

-- Adds a style table to the stack
function Oil.stylePush(...)
    local styles = table.pack(...)
    for i = 1, styles.n do
        table.insert(style_stack, styles[i] or {})
    end
end

-- Removes the top style table from the stack
function Oil.stylePop(count)
    for i = 1, (count or 1) do
        table.remove(style_stack)
    end
end

-- Search the stack top to bottom for the style value
-- at key.
function Oil.styleGet(key)
    for i=#style_stack, 1, -1 do
        local v = style_stack[i][key]
        if v then
            return v
        end
    end
    
    -- Found nothing
    return nil
end

-- Search the top table of the stack for key.
function Oil.styleGetTop(key)
    return style_stack[#style_stack][key]
end

-- Retrieves the style value for key and passes
-- it to the provided function or a global function
-- of the same name.
function Oil.styleApply(key, func)
    local v = Oil.styleGet(key)
    assert(v, "No style value for key: " .. key)
    
    if func then
        -- Call the func we're given
        func(v)
    else
        -- Call global function by the same name
        _G[key](v)
    end
end
