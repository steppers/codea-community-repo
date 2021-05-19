-- Moving Image
-- by West
-- Inspired by this tweet from Jarom Vogel https://twitter.com/jaromvogel/status/1026464183380992001?s=21


viewer.mode=FULLSCREEN
function setup()
  bgx=WIDTH/2
  bgy=HEIGHT/2
  midx=WIDTH/2
  midy=HEIGHT/2
  
  bgz=1
  midz=1
  fgz=1
  
  
  
  fishimg={asset.tetra,asset.zebra}
  fishbodyimg={asset.tetrabody,asset.zebrabody}
  
  fish={} 
  for i=1,14 do
    local kind=math.random(#fishimg)
    local d=1
    if math.random(2)==1 then d=-1 end
    table.insert(fish,{img=fishimg[kind],imgbody=fishbodyimg[kind],w=readImage(fishimg[kind]).width,h=readImage(fishimg[kind]).height,x=-WIDTH/2+math.random(WIDTH),y=-HEIGHT/2+math.random(HEIGHT),spd=math.random(4),dir=d,level=math.random(2)})
  end
  
  
  tstart=nil
end

function draw()
  midx=midx-RotationRate.y/2
  midy=midy+RotationRate.x/2
  bgx=bgx-RotationRate.y
  bgy=bgy+RotationRate.x
  --background
  sprite(asset.waterbg2,bgx,bgy,WIDTH/2+WIDTH*bgz,HEIGHT/2+HEIGHT*bgz)
  
  --middle
  for i,f in pairs(fish) do
    if f.level==1 then
      tint(255,100)
      sprite(f.img,bgx+f.x,bgy+f.y,f.dir*2*f.w,2*f.h)
      noTint()
      sprite(f.imgbody,bgx+f.x,bgy+f.y,f.dir*2*f.w,2*f.h)
      f.x = f.x - f.dir*f.spd
      if f.x<-(1.3*(WIDTH/2)) or f.x>(1.3*(WIDTH/2)) then
        f.dir = f.dir * -1
        f.y=-HEIGHT/2+math.random(HEIGHT)
      end
    end
  end
  
  sprite(asset.plants2,midx,midy,WIDTH/4+WIDTH*midz,HEIGHT/4+HEIGHT*midz)
  
  for i,f in pairs(fish) do
    if f.level==2 then
      if midz<4 then
        tint(255,100)
        sprite(f.img,midx+f.x*midz,midy+f.y*midz,(f.dir*4*f.w)*midz,4*f.h*midz)
        noTint()
        sprite(f.imgbody,midx+f.x*midz,midy+f.y*midz,(f.dir*4*f.w)*midz,4*f.h*midz)
      end 
      f.x = f.x - f.dir*f.spd-f.dir*(f.spd*midz)
      
      if f.x<-(1.3*(WIDTH/2)) or f.x>(1.3*(WIDTH/2)) then
        f.dir = f.dir * -1
        f.y=-HEIGHT/2+math.random(HEIGHT)
      end
      
    end
  end
  
  
  --foreground
  sprite(asset.plants,WIDTH/2,HEIGHT/2,WIDTH*fgz,HEIGHT*fgz)
  --instructions
  font("Didot")
  fontSize(WIDTH/20)
  fill(95, 135, 37)
  text("Move the screen \n Touch to zoom",WIDTH/2,HEIGHT*0.8)
  
  if tstart~=nil then
    local zoom=(ElapsedTime-tstart)/100
    fgz=fgz+zoom
    midz=midz+zoom/2
  else
    fgz=fgz-(fgz-1)*0.1
    midz=midz-(midz-1)*0.1
  end
end

function touched(touch)
  if touch.state == ENDED or touch.state==CANCELLED then
    tstart=nil
  else
    if tstart==nil then
      tstart=ElapsedTime
    end
  end
end



