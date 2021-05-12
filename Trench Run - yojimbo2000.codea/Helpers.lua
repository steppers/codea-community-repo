function getXRight(m)
    return vec3(m[1],m[2],m[3])
end

function getYUp(m)
    return vec3(m[5],m[6],m[7])
end

function getZForward(m)
    return vec3(m[9],m[10],m[11])
end

function clamp(v,low,high)
    return math.min(math.max(v, low), high)
end

function vecRotMat( m, v)
    return vec3(
    m[1]*v.x + m[5]*v.y + m[9]*v.z,
    m[2]*v.x + m[6]*v.y + m[10]*v.z,
    m[3]*v.x + m[7]*v.y + m[11]*v.z)
end