-- Fish
viewer.mode=FULLSCREEN
-- Use this function to perform your initial setup
function setup()
  fish={}
  ground=HEIGHT*0.05
  for i=1,200 do
    table.insert(fish,Fish(vec2(math.random(WIDTH),ground+math.random(math.floor(HEIGHT-ground)))))
  end
end

function draw()
--Draw the sea
  background(38, 126, 175, 255)
--  draw the sand
  fill(222, 178, 10, 255)
  noStroke()
  rect(0,0,WIDTH,ground)
  
  --draw the fish in the background
  for i,f in pairs(fish) do
    f:draw(1)
  end
  --draw a title
  fill(114, 173, 38)
  font("ArialRoundedMTBold")
  fontSize(math.ceil(WIDTH/4))
  local title="FISH!"
  local ftextw,ftexth=textSize(title)
  text(title,WIDTH/2,ftexth/2)
  --draw the fish in the foreground
  for i,f in pairs(fish) do
    f:draw(2)
  end
end

function touched(touch)
  for i,f in pairs(fish) do
    f:touched(touch)
  end
  
end
