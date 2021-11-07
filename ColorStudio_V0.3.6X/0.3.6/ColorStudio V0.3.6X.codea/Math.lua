Math = class()

function Math:b2n(bool)
    if bool then
        return 1
    else
        return 0
    end
end

function Math:sgn(n)
    if n < 0.0 then
        return -1.0
    elseif n > 0.0 then
        return 1.0
    else
        return 0.0
    end
end

function Math:abs2(n)
    return vec2(math.abs(n.x), math.abs(n.y))
end

function Math:nsin(n)
    return (math.sin(n) * 0.5+0.5)
end

function Math:ncos(n)
    return (math.cos(n) * 0.5+0.5)
end

function Math:ntan(n)
    return (math.tan(n) * 0.5+0.5)
end

function Math:clamp(n, min, max)
    return math.min(math.max(n, min), max)
end

function Math:clamp2(n, min, max)
    return vec2(
        self:clamp(n.x, min, max),
        self:clamp(n.y, min, max)
    )
end

function Math:trunc(n, x)
    if n < 0 then
        return math.ceil(n * (10.0^x))/(10.0^x)
    else
        return math.floor(n * (10.0^x))/(10.0^x)
    end
end

function Math:mix(a, b, x)
    return (1.0-x) * a+b * x
end

function Math:multiMix(item, m)
    local n = table.maxn(item)
    local items = item[n];
    for i = 1, n do
        items = self:mix(item[i], items, self:smootherstep(i, i-1, m*n));
    end
    return items;
end

function Math:smoothstep(a, b, x)
    x = self:clamp((x-a)/(b-a), 0.0, 1.0)
    return math.pow(x, 2.0) * (3.0-2.0 * x)
end

function Math:smootherstep(a, b, x)
    x = self:clamp((x-a)/(b-a), 0.0, 1.0)
    return math.pow(x, 3.0) * (x * (x * 6.0-15.0)+10.0)
end

function Math:yaw(origin, target)
    return math.deg(-math.atan2((target-origin):unpack())+math.pi)
end

function Math:circularMotion(angle, length)
    angle = math.rad(angle)
    return vec2(math.cos(angle), math.sin(angle)) * length
end

function Math:factorial(n)
    local f = n
    for i = 1.0, n-1.0 do
        f = f * (n-i)
    end
    return f
end

function Math:binomialCoefficient(n, k)
    if k < 1.0 or k == n then
        return 1.0
    else
        return self:factorial(n)/(self:factorial(k) * self:factorial(n-k))
    end
end

function Math:polynomial(P, n, t)
    local B = vec2(0, 0)
    for i = 0.0, n-1.0 do
        B = B+self:binomialCoefficient(n, i) * math.pow(1-t, n-i) * math.pow(t, i) * P[i]
    end
    B = B+math.pow(t, n) * P[n-1]
    return B
end
