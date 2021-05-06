Fish = class()

function Fish:init(pos)
  -- you can accept and set parameters here
  self.pos=pos
  self.size=10+math.random(40)
  self.stripes=math.random(3)
  self.img=self:generateFish(self.size,color(255, math.random(255), 0))
  self.size = self.size * 5
  
  self.spd=math.random(50)/10
  self.dir=1
  if math.random(2)==1 then self.dir=-1 end
  self.burst=math.random(5)
  self.depth=math.random(2)
  
end

function Fish:draw(level)
  if self.depth==level then
    sprite(self.img,self.pos.x,self.pos.y,self.size*self.dir,self.size)
    --move
    self.pos.x = self.pos.x - (self.spd+math.sin(ElapsedTime*self.burst))*self.dir
    if self.pos.x<-150 or self.pos.x>WIDTH+150 then
      self.dir = self.dir * -1
      self.pos.y=ground+math.random(math.floor(HEIGHT-ground))
      self.spd=math.random(50)/10
    end
  end
end

function Fish:touched(touch)
  --set a sphere of influence for the touch
  local rad=300
  --check to see if the fish is within range of the touch
  if vec2(touch.x,touch.y):dist(vec2(self.pos.x,self.pos.y))<rad then
    --set the speed variable based on vertical distance from the touch - the further away the slower the fish will move
    local hspd=math.ceil((300-(math.abs(touch.y-self.pos.y)))/50)
    
    if self.pos.x>touch.x and self.dir==1 then
      self.dir=-1
      self.spd=math.max(self.spd,hspd+math.random(10)/10)
    elseif self.pos.x>touch.x and self.dir==-1 then
      self.spd=math.max(self.spd,hspd+math.random(10)/10)
    elseif self.pos.x<touch.x and self.dir==-1 then
      self.dir=1
      self.spd=math.max(self.spd,hspd+math.random(10)/10)
    elseif self.pos.x<touch.x and self.dir==1 then
      self.spd=math.max(self.spd,hspd+math.random(10)/10)
    end
  end
end


function Fish:generateFish(size,col)
  m=mesh()
  points={}
  w=size
  
  points={vec2(3.5*w,0),vec2(4*w,w),vec2(3.5*w,w),vec2(3*w,0.25*w),vec2(w,w),vec2(-w,w),vec2(-1.5*w,0.5*w),vec2(-1.75*w,0),vec2(-1.5*w,-0.5*w),vec2(-w,-w),vec2(w,-w),vec2(3*w,-0.25*w),vec2(3.5*w,-w),vec2(4*w,-w)}
  
  for i=#points-1,1,-1 do
    table.insert(points,i+1,self:addpoint(points[i],points[i+1]))
    i=i+1
  end
  --add end point
  table.insert(points,self:addpoint(points[#points],points[1]))
  
  for i=3,#points-1 do
    points[i]=self:subdivide(points[i-1],points[i],points[i+1])
  end
  
  tripoints=triangulate(points)
  m.vertices=tripoints
  strokeWidth(4)
  stroke(0)
  fill(col)
  fishimg=image(8*w,8*w)
  setContext(fishimg)
  pushMatrix()
  translate(4*w,4*w)
  
  m:draw()
  
  --stripes
  if self.stripes==1 then
    --straight lines
    strokeWidth(w/4)
    stroke(col.b,col.r,col.g)
    for i=7,10 do
      line(points[i].x,points[i].y-w*0.1,points[30-i].x,points[30-i].y+w*0.1)
    end
    
  elseif self.stripes==2 then
    --cheveron lines
    strokeWidth(w/4)
    stroke(col.b,col.r,col.g)
    for i=7,10 do
      mp=self:addpoint(points[i],points[30-i])
      line(points[i].x,points[i].y-w*0.1,mp.x+w*0.1,mp.y)
      line(mp.x+w*0.1,mp.y,points[30-i].x,points[30-i].y+w*0.1)
    end
  elseif self.stripes==3 then
    --no stripes
  end
  
  
  --outline
  stroke(0)
  strokeWidth(4)
  line(points[#points].x,points[#points].y,points[1].x,points[1].y)
  tailends={}
  for i=2,#points do
    line(points[i-1].x,points[i-1].y,points[i].x,points[i].y)
  end
  
  --eye
  stroke(0)
  strokeWidth(4)
  fill(255)
  ellipse(-w*1.1,w*0.3,1.2*w)
  fill(0)
  ellipse(-w*1.25,w*0.3,0.6*w)
  popMatrix()
  setContext()
  
  return fishimg
end

function Fish:subdivide(pp,p,pn)
  local mid1=(pp+p)/2
  local mid2=(pn+p)/2
  newp=(mid1+mid2)/2
  return newp
end

function Fish:addpoint(pp,pn)
  return((pp+pn)/2)
end
