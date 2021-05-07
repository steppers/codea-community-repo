Particle = class()

function Particle:init(x,y,a,t,spd,dir,rot,bonus,sz)
    -- you can accept and set parameters here
    self.x = x
    self.y=y
    self.a=a --angle
    self.t=t --type
    self.spd=spd --speed
    self.rot=rot --rotational speed
    self.dir=dir
    self.yacc=0
    self.col=color(255,255,255)
    self.active=1
    self.size=sz
--    print(sz)
    self.bonus=bonus
    self.fade=255
self.img={"wasphead","waspthorax","waspwing","wasplegs","wasplegm","waslegl","blood","foggybodydamage","foggyheaad","foggywing","foggylegs","foggylegm","foggylegl","sparkle","rainbow","anthead","antthorax","antlegs","antlegm","antlegl"}
   -- print("img string count: "..#self.img)
    self.img = {22,21,26,25,23,24,88,17,3,5,6,1,4,77,84,36,35,38,37,39}
  --  print("img indexes count: "..#self.img)
  --  print("t: "..t)
    self.imgsel=t
    --    self.col=palette[math.random(#palette)]

    if t==15 then
        self.col=palette[math.random(#palette)]        
        self.fade=50
        self.size=60
        end

end

function Particle:draw()
    -- Codea does not automatically call this method
    tint(self.col.r,self.col.g,self.col.b,self.fade)
    pushMatrix()
    translate(self.x,self.y)
    rotate(self.a)
     -- sprite("Project:"..self.img[self.imgsel],0,0,self.size)  
    --print("self.img[self.imgsel]: "..self.img[self.imgsel])
    --print("spriteTable[self.img[self.imgsel]]: "..tostring(spriteTable[self.img[self.imgsel]]))
    sprite(spriteTable[self.img[self.imgsel]],0,0,self.size)   
popMatrix()
    self.x = self.x + self.spd*math.sin(math.rad(self.dir))
    self.y = self.y + self.spd*math.cos(math.rad(self.dir))    
   self.y = self.y - self.yacc
    if self.imgsel~=14 and self.imgsel~=15 then
    self.yacc = self.yacc + 0.2
        end
    self.a = self.a + self.rot    
    self.fade = self.fade - 5
    if self.y<0 or self.fade<0 then

        self.active=0
    end
    
    if self.imgsel==15 then
        self.size = self.size + 5
        
else
if math.random(10)==1 and self.imgsel~=7 then

        table.insert(exp,Explosion(self.x,self.y,math.random(360),self.fade/255))
            end
    end
    noTint()
end

function Particle:touched(touch)
    -- Codea does not automatically call this method
end
