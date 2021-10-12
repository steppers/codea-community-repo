-- Text renderer

OIL.RenderComponent.Text = class(OIL.RenderComponent)

function OIL.RenderComponent.Text:init(style)
    
    -- Render func
    OIL.RenderComponent.init(self, function(self, w, h, do_draw)
        if do_draw == false then return end -- skip rendering
        
        textMode(CENTER)
        self:apply_style("fontSize")
        self:apply_style("fillText")
        self:apply_style("textWrapWidth")
        local align = self:get_style("textAlign")
        if align == LEFT then
            local tw, th = textSize(self:get_style("text"))
            text(self:get_style("text"), (tw / 2) + 5, h/2)
        elseif align == RIGHT then
            local tw, th = textSize(self:get_style("text"))
            text(self:get_style("text"), w - (tw / 2) - 5, h/2)
        else
            text(self:get_style("text"), w/2, h/2)
        end
    end, style)
end
