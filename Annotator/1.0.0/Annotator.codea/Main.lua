-- Annotator

createProject("AnnotatorImages:DeleteMe")
deleteProject("AnnotatorImages:DeleteMe")

local images = asset.documents.AnnotatorImages.all
local meta_path = asset.documents.AnnotatorImages .. "meta.json"

for i,img in ipairs(images) do
    if img.ext ~= "PNG" and img.ext ~= "JPG" then
        table.remove(images, i)
    end
end
for i,img in ipairs(images) do
    if img.ext == "json" then
        table.remove(images, i)
    end
end

local cur_img_i = 1
local cur_img = nil
local num_imgs = #images

local boxes = {}

local add_button = Button("+", WIDTH-50, HEIGHT-50, 40, 40, color(0, 156, 255), color(255))
local sub_button = Button("-", WIDTH-100, HEIGHT-50, 40, 40, color(0, 156, 255), color(255))
local prev_button = Button("Prev", WIDTH-200, 10, 90, 40, color(0, 156, 255), color(255))
local next_button = Button("Next", WIDTH-100, 10, 90, 40, color(0, 156, 255), color(255))
local export_button = Button("EXPORT", 10, HEIGHT-50, 130, 40, color(0, 156, 255), color(255))

local label_field = TextEntryField(WIDTH/2 - 40, 5, 80, 24, "Unlabelled", 20, true)

local function new_annotation()
    table.insert(boxes, { x = WIDTH/2 - 50, y = HEIGHT/2 - 50, w = 100, h = 100, label = TextEntryField(0, 0, 80, 24, "Unlabelled", 20, true) })
end

local function export_metadata()
    local metadata = {}
    
    for i,img in ipairs(images) do
        local json_str = readText(asset.documents.AnnotatorImages .. img.name .. ".json")
        if json_str ~= nil then
            print(img.name)
            local j = json.decode(json_str)
            table.insert(metadata, j)
        end
    end
    
    local json_str = json.encode(metadata, { indent = true, level = 4 })
    saveText(meta_path, json_str)
    
    -- Delete per image json
    for i,img in ipairs(images) do
        saveText(asset.documents.AnnotatorImages .. img.name .. ".json", nil)
    end
    
    alert("Exported")
end

local function import_metadata()
    local meta_json = readText(meta_path)
    if meta_json then
        local metadata = json.decode(meta_json)
        
        for _,entry in ipairs(metadata) do
            -- Only import an entry if it doesn't already exist
            if spriteSize(asset.documents.AnnotatorImages .. entry.image) and readText(asset.documents.AnnotatorImages .. entry.image .. ".json") == nil then
                print("Importing metadata for " .. entry.image)
                saveText(asset.documents.AnnotatorImages .. entry.image .. ".json", json.encode(entry))
            end
            
            -- maybe collect garbage
        end
    end
end

local function load_from_metadata(index)
    index = ((index-1) % num_imgs) + 1
    cur_img_i = index
    
    boxes = {} -- clear boxes
    
    local json_str = readText(asset.documents.AnnotatorImages .. images[index].name .. ".json")
    if json_str == nil then
        cur_img = readImage(images[index])
        return
    end
    local entry = json.decode(json_str)
    
    local img_path = asset.documents.AnnotatorImages .. entry.image
    cur_img = readImage(img_path)
    
    -- Load annotations
    local x_scale = cur_img.width / WIDTH
    local y_scale = cur_img.height / HEIGHT
    for _,annot in ipairs(entry.annotations) do
        local text_field = TextEntryField(0, 0, 80, 24, "Unlabelled", 20, true)
        text_field.buffer = annot.label

        local x = (annot.coordinates.x - annot.coordinates.width/2)/x_scale
        local y = HEIGHT - (annot.coordinates.y/y_scale)
        y = y - (annot.coordinates.height/2)/y_scale
        
        table.insert(boxes, { x = x, y = y, w = annot.coordinates.width/x_scale, h = annot.coordinates.height/y_scale, label = text_field })
    end
end

-- Write metadata for the current image
local function write_metadata()
    
    local x_scale = cur_img.width / WIDTH
    local y_scale = cur_img.height / HEIGHT
    
    local j = {
        ["image"] = images[cur_img_i].name,
        ["annotations"] = {}
    }
    
    for _,box in ipairs(boxes) do
        table.insert(j.annotations, {
            label = box.label.buffer,
            coordinates = {
                x = math.floor((box.x + box.w/2) * x_scale),
                y = math.floor((HEIGHT - (box.y + box.h/2)) * y_scale),
                width = math.floor(box.w * x_scale),
                height = math.floor(box.h * y_scale),
            }
        })
    end
    
    saveText(asset.documents.AnnotatorImages .. images[cur_img_i].name .. ".json", json.encode(j, { indent = true, level = 4 }))
end

function setup()
    viewer.mode = FULLSCREEN
    
    -- Try to import metadata from meta.json
    import_metadata()
    
    if num_imgs ~= 0 then
        load_from_metadata(1)
    end
end

function draw()
    
    if num_imgs == 0 then
        background(0)
        text("No images in documents/AnnotatorImages!", WIDTH/2, HEIGHT/2)
        return
    end
    
    if cur_img then
        -- Draw the current image fullscreen
        spriteMode(CORNER)
        sprite(cur_img, 0, 0, WIDTH, HEIGHT)
        
        fontSize(28)
        fill(255)
        text(tostring(cur_img_i) .. " / " .. tostring(num_imgs), WIDTH/2, HEIGHT - 30)
        
        -- Draw (+) button
        add_button:draw()
        
        -- Draw (-) button
        sub_button:draw()
        
        -- Draw (Next) button
        next_button:draw()
        -- Draw (Prev) button
        prev_button:draw()
        
        -- Draw (Export) button
        export_button:draw()
        
        -- Draw the annotation boxes
        fontSize(16) -- labels
        local num_boxes = #boxes
        for i,box in ipairs(boxes) do
            if i == num_boxes then
                noFill()
                strokeWidth(5)
                stroke(26, 255, 0)
                rect(box.x, box.y, box.w, box.h)

                fill(26, 255, 0)            
                stroke(255)
                ellipseMode(CENTER)
                ellipse(box.x + 2, box.y + 2, 20, 20)
                ellipse(box.x + box.w - 3, box.y + box.h - 3, 20, 20)
                
                -- Draw the label field
                box.label.x = box.x + (box.w / 2) - 40
                box.label.y = box.y + box.h + 2
                box.label:draw()
            else
                noFill()
                strokeWidth(5)
                stroke(220)
                rect(box.x, box.y, box.w, box.h)
                
                -- Draw the label field
                box.label.x = box.x + (box.w / 2) - 40
                box.label.y = box.y + box.h + 2
                box.label:draw()
            end
        end
    end
end

function tap(pos)
    
    for i,box in ipairs(boxes) do
        if box.label:tap(pos) then 
            table.remove(boxes, i)
            table.insert(boxes, box)
            return
        end
    end
    
    if add_button:tap(pos) then
        new_annotation()
        return
    end
    
    if sub_button:tap(pos) then
        table.remove(boxes)
        return
    end
    
    if prev_button:tap(pos) then
        -- Write this image's metadata
        write_metadata()
        
        -- Attempt to read new data from saved metadata
        load_from_metadata(cur_img_i - 1)
        return
    end
    
    if next_button:tap(pos) then
        -- Write this image's metadata
        write_metadata()
        
        -- Attempt to read new data from saved metadata
        load_from_metadata(cur_img_i + 1)
        return
    end
    
    if export_button:tap(pos) then
        export_metadata()
        print("Export to meta.json complete")
        return
    end
end

function pan(pos)
    local box = boxes[#boxes]
    if box == nil then
        return
    end
    
    local bl = vec2(box.x, box.y)
    local tr = vec2(box.x + box.w, box.y + box.h)
    
    if pos:dist(bl) < 40 and pos:dist(tr) > 40 then
        box.w = box.w + (box.x - pos.x)
        box.h = box.h + (box.y - pos.y)
        box.x = pos.x
        box.y = pos.y
    elseif pos:dist(tr) < 40 then
        box.w = pos.x - box.x
        box.h = pos.y - box.y
    end
end

function keyboard(key)
    for _,box in ipairs(boxes) do
        if box.label:keyboard(key) then return end
    end
end
