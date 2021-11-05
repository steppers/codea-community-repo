--Math

--Quaternions
Q={}

function Q.GetMatrixAndRotate(q,roll, pitch, yaw,x,y,z)
    local rr,pp,yy=math.rad(roll),math.rad(pitch),math.rad(yaw)
    local q1=Q.EulerToQuat(rr,pp,yy)
    local q2=Q.Multiply(q1,q):normalize()
    m=Q.QToMatrix(x,y,z,q2)
    return m,q
end

function Q.AddRotation(q,roll,pitch,yaw)
    local rr,pp,yy=math.rad(roll),math.rad(pitch),math.rad(yaw)
    local q1=Q.EulerToQuat(rr,pp,yy)
    return Q.Multiply(q1,q)
end

function Q.EulerToQuat(roll, pitch, yaw)
    -- compute all trigonometric values used to compute the quaternion
    local cr = math.cos(roll/2)
    local cp = math.cos(pitch/2)
    local cy = math.cos(yaw/2)
    
    local sr = math.sin(roll/2)
    local sp = math.sin(pitch/2)
    local sy = math.sin(yaw/2)
    
    cpcy = cp * cy
    spsy = sp * sy
    
    -- combine values to generate the vector and scalar for the quaternion
    local w = cr * cpcy + sr * spsy
    local x = sr * cpcy - cr * spsy
    local y = cr * sp * cy + sr * cp * sy
    local z = cr * cp * sy - sr * sp * cy
    return vec4(w,x,y,z):normalize()
end

function Q.Multiply(q1,q2)
    local w1,x1,y1,z1=q1.x,q1.y,q1.z,q1.w
    local w2,x2,y2,z2=q2.x,q2.y,q2.z,q2.w
    local w = w1*w2 - x1*x2 - y1*y2 - z1*z2
    local x = w1*x2 + x1*w2 + y1*z2 - z1*y2
    local y = w1*y2 - x1*z2 + y1*w2 + z1*x2
    local z = w1*z2 + x1*y2 - y1*x2 + z1*w2
    return vec4(w,x,y,z):normalize()
end

function Q.QToMatrix(px,py,pz,q)
    -- calculate coefficients used for building the matrix
    local w,x,y,z=q.x,q.y,q.z,q.w
    local x2 = x + x
    local y2 = y + y
    local z2 = z + z
    local xx = x * x2
    local xy = x * y2
    local xz = x * z2
    local yy = y * y2
    local yz = y * z2
    local zz = z * z2
    local wx = w * x2
    local wy = w * y2
    local wz = w * z2
    
    -- fill in matrix positions with them
    m=matrix() 
    m[1] = 1.0 - (yy + zz)
    m[2] = xy - wz
    m[3] = xz + wy
    m[4] = 0.0
    m[5] = xy + wz
    m[6] = 1.0 - (xx + zz)
    m[7] = yz - wx 
    m[8] = 0.0
    m[9] = xz - wy
    m[10] = yz + wx
    m[11] = 1.0 - (xx + yy)
    m[12] = 0.0
    m[13] = px
    m[14] = py
    m[15] = pz
    m[16] = 1
    return m
end




