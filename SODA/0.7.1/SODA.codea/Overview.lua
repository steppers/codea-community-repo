function overview(t)
    local win =Soda.Window{
        title = "Soda v"..Soda.version.." Overview",
        w = 0.97, h = 0.7,
         blurred = true, 
        shadow = true, 
      --  style = Soda.style.darkBlurred, 
    }
    
    local aboutPanel = Soda.Frame{
        parent = win,
        x = 10, y = 10, w = -10, h = -110, 
    }
    
    local about = Soda.Frame{
        parent = aboutPanel,
        x = 0, y = -0.001, w = 1, h = 0.7,
        shape = Soda.RoundedRectangle, --style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16},
        title = "About Soda",
         label = { x = 0.5, y = 0.5},
        title = 
    [[Soda is a library for producing graphic user interfaces like 
    the one you are looking at now.
    
    Press the segment buttons above to see the interface elements Soda produces.   
    ]]..(t.content or "")
    }
    
    Soda.Button{
        parent = about, 
        x = 10, y = 10, h = 40,
        title = "Online Documentation",
        callback = function() openURL("https://github.com/Utsira/Soda/blob/master/README.md", true) end
    }
   
    if t.ok then 
    Soda.Button{
        parent = about,
        x = -10, y = 10, h = 40,
      --  shapeArgs = {radius = 16},
          subStyle = {"warning"}, --style = Soda.style.warning,
        title = t.ok,
        callback = t.callback
    }
    end
    
    local demo = Soda.Frame{
        parent = aboutPanel,
        x = 0, y = 0, w = 1, h = 0.29,
        shape = Soda.RoundedRectangle, --style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16},
        title = "Demos",        
    }
    
    Soda.Button{
        parent = demo,
        x = 0.3, y = 0.4, w = 250, h = 40,
        title = "Calculator",
        callback = function() calculator.window:show(RIGHT) end
    }
    
    local buttonPanel = Soda.Frame{
        parent = win,
        x = 10, y = 10, w = -10, h = -110,
       -- shape = Soda.RoundedRectangle, style = Soda.style.translucent,
        --shapeArgs = {radius = 16}
    }
           
    local switchPanel = Soda.Frame{
        parent = win,
        x = 10, y = 10, w = -10, h = -110,
      --  shape = Soda.RoundedRectangle, style = Soda.style.translucent,
      --  shapeArgs = {radius = 16}
    }
    
    local sliderPanel = Soda.Frame{
        parent = win,
        title = "Sliders. At slow slide speeds movement becomes more fine-grained",
        x = 10, y = 10, w = -10, h = -110,
        shape = Soda.RoundedRectangle, -- style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16}
    }
    
    local dialogPanel = Soda.Frame{
        parent = win,
        x = 10, y = 10, w = -10, h = -110,
       -- shape = Soda.RoundedRectangle, style = Soda.style.translucent,
      --  shapeArgs = {radius = 16}
    }
    
    local textEntryPanel = Soda.Frame{
        parent = win,
        title = "Text Entry fields with a draggable cursor",
        x = 10, y = -110, w = -10, h = 0.6,
        shape = Soda.RoundedRectangle, -- style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16}
    }
    
    local listPanel = Soda.Frame{
        parent = win,
        title = "Vertically scrolling lists are another way of selecting one choice from many",
        x = 10, y = 10, w = -10, h = -110,
        shape = Soda.RoundedRectangle, -- style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16}
    }
    
    scrollPanel = Soda.TextScroll{
        parent = win,
        title = "Text Scrolls for scrolling through large bodies of text",
    
        textBody = string.rep([[
    
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus vitae massa in sem mattis ullamcorper a eget metus. Nam ac maximus nulla, vel faucibus sapien. Aenean faucibus volutpat tristique. Curabitur condimentum volutpat velit, sit amet commodo tellus placerat a. 
    
    Sed vitae metus quis mauris congue tincidunt vel sit amet lorem. Mauris lectus lorem, facilisis in dapibus et, congue quis nunc. Fusce convallis mi urna, vitae mattis felis sodales et. Aliquam et fringilla purus, eu vehicula diam. Sed facilisis mauris vitae augue sodales aliquam. In ultrices metus ut eleifend condimentum. Praesent venenatis rhoncus felis, eget vehicula orci ornare non. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Vivamus eget vulputate mauris. Pellentesque id tempus sapien.
    ]], 100),
        x = 10, y = 10, w = -10, h = -110,
        shape = Soda.RoundedRectangle, --style = Soda.style.default,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16}    
    }
    
    Soda.Segment{
        parent = win,
        x = 12, y = -60, w = -12, h = 40,
        text = {"About", "Buttons", "Switches", "Sliders", "Dialogs", "Text Entry", "Lists", "Scrolls"}, 
        panels = {aboutPanel, buttonPanel, switchPanel, sliderPanel, dialogPanel, textEntryPanel, listPanel, scrollPanel}, 
    }
    
    --button panel!
    
    local buttonPresets = Soda.Frame{
        parent = buttonPanel,
        title = "Presets for frequently-used buttons",
        x = 0, y = 0.5, w = 1, h = 0.32,
          shape = Soda.RoundedRectangle, --style = Soda.style.translucent,
        subStyle = {"translucent"},
          shapeArgs = {radius = 16}
    }
    
    local div = 1/9
    local div2 = div/2
    
    Soda.BackButton{
    parent = buttonPresets,
    subStyle = {"darkIcon"},
    x = div2, y = 0.4}
    
    Soda.ForwardButton{
    parent = buttonPresets,
    subStyle = {"darkIcon"},
    x = div2 + div, y = 0.4}
    
    Soda.SettingsButton{
    parent = buttonPresets,
    subStyle = {"darkIcon"},
    x = div2 + div * 2, y = 0.4}
    
    Soda.AddButton{
    parent = buttonPresets,
    subStyle = {"icon"},
    x = div2 + div * 3, y = 0.4}
    
    Soda.QueryButton{
    parent = buttonPresets,
    subStyle = {"icon"},
    x = div2 + div * 4, y = 0.4}
    
    Soda.MenuButton{
    parent = buttonPresets,
    subStyle = {"icon"},
    x = div2 + div * 5, y = 0.4}
    
    Soda.DropdownButton{
    parent = buttonPresets,
    x = div2 + div * 6, y = 0.4}
    
    Soda.CloseButton{
    parent = buttonPresets,
    x = div2 + div * 7, y = 0.4
    }
    
    Soda.DeleteButton{
    parent = buttonPresets,
    x = div2 + div * 8, y = 0.4
    }
    
    local textButtons = Soda.Frame{
        parent = buttonPanel,
        title = "Text and symbol based buttons in various shapes and styles",
        x = 0, y = -0.001, w = 1, h = 0.32,
        shape = Soda.RoundedRectangle, --style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16}
    }
    
    div = 1/5
    div2 = div/2
    local w = div -0.01
    
    Soda.Button{
        parent = textButtons, 
        title = "Standard", 
        x = div2, y = 0.4, w = w, h = 40,
    }
    
    --[[
    Soda.Button{
        parent = textButtons, 
        title = "Dark", 
        --style = Soda.style.dark,
        subStyle = {"listItem"},
        x = div2 + div, y = 0.4, w = w, h = 40,
    }
      ]]
    
    Soda.Button{
        parent = textButtons, 
        title = "Warning", 
        subStyle = {"warning"}, --style = Soda.style.warning, 
        x = div2 + div , y = 0.4, w = w, h = 40, 
    }
    
    Soda.Button{
        parent = textButtons, 
        title = "Square", 
        shape = Soda.rect,
        x = div2 + div * 2, y = 0.4, w = w, h = 40,
    }
    
    Soda.Button{
        parent = textButtons, 
        title = "Lozenge", 
        shapeArgs = {radius = 20},
        x = div2 + div * 3, y = 0.4, w = w, h = 40,
    }
    
    local div3 = div/5
    local base = div2 + div * 4
    
    Soda.Button{
        parent = textButtons, 
        title = "\u{1f310}", 
       -- style = Soda.style.darkIcon,
        subStyle = {"listItem"},
        shape = Soda.ellipse,
        x = base - div3, y = 0.4, w = 40, h = 40,
    }
    
    --[[
    Soda.Button{
        parent = textButtons, 
        title = "\u{267b}", 
     --   shape = Soda.ellipse,
     --   style = Soda.style.icon,
        x = base, y = 0.4, w = 40, h = 40,
    }
      ]]
    
    Soda.Button{
        parent = textButtons, 
        title = "\u{1f374}", 
      --  shape = Soda.ellipse,
       -- style = Soda.style.darkIcon,
        subStyle = {"listItem"},
        x = base + div3, y = 0.4, w = 40, h = 40,
    }
    
    local segmentPanel = Soda.Frame{
        parent = buttonPanel,
        title = "Segmented buttons for selecting one option from many",
        x = 0, y = 0, w = 1, h = 0.32,
        shape = Soda.RoundedRectangle,-- style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16}
    }
    
    Soda.Segment{
        parent = segmentPanel, 
        x = 20, y = 0.4, w = -20, h = 40,
        text = {"Only one", "segmented", "button can", "be selected", "at a time"}
    }
    
    --switch panel
    
    local switches = Soda.Frame{
        parent = switchPanel,
        title = "iOS-style switches",
        x = 0, y = -10, w = 0.49, h = 0.75,
        shape = Soda.RoundedRectangle,-- style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16}
    }
    
    Soda.Switch{ --a switch to toggle the profiler stats panel
        parent = switches,
        x = 20, y = 0.75,
        title = "Use switches to toggle",

    }
    
    Soda.Switch{
        parent = switches,
        x = 20, y = 0.5,
        title = "...between two states",
        on = true
    }
    
    Soda.Switch{
        parent = switches,
        x = 20, y = 0.25,
        title = "...on and off",
    }
    
    local toggles = Soda.Frame{
        parent = switchPanel,
        title = "Text and preset-based toggles",
        x = -0.001, y = -10, w = 0.49, h = 0.75,
        shape = Soda.RoundedRectangle,-- style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16}
    }
    
    Soda.Toggle{
        parent = toggles,
        x = 20, y = 0.8, w = -20, h = 40,
        title = "Standard" 
    }
    
    Soda.Toggle{
        parent = toggles,
        x = 20, y = 0.6, w = -20, h = 40,
        shape = Soda.rect,
        title = "Square" 
    }
    
    Soda.Toggle{
        parent = toggles,
        x = 20, y = 0.4, w = -20, h = 40,
        shapeArgs = {radius = 20},
        title = "Over-rounded" 
    }
    
    Soda.MenuToggle{
        parent = toggles,
        x = 20, y = 0.2,
        on = true,
    }
    
    --[[
    local sliders = Soda.Frame{
        parent = switchPanel,
        title = "Sliders",
        x = 0.5, y = 0, w = 0.49, h = 0.32,
        shape = Soda.RoundedRectangle, style = Soda.style.translucent,
        shapeArgs = {radius = 16}
    }
      ]]
    
    --slider panel 
    
    Soda.Slider{
        parent = sliderPanel,
        title = "Integer slider",
        x = 0.5, y = 0.8, w = 300,
        min = 1000, max = 2000, start = 1500,
    }
    
    Soda.Slider{
        parent = sliderPanel,
        title = "Floating point slider (3 decimal places)",
        x = 0.5, y = 0.6, w = 400,
        min = -10, max = 10, start = 0,
        decimalPlaces = 3
    }
    
    Soda.Slider{
        parent = sliderPanel,
        title = "Slider with snap points",
        x = 0.5, y = 0.4, w = 500,
        min = -50, max = 150,
        decimalPlaces = 1,
        snapPoints = {0, 100}
    }
    
    Soda.Slider{
        parent = sliderPanel,
        title = "Make fine +/- adjustments by tapping either side of the lever",
        x = 0.5, y = 0.2, w = 0.9,
        min = -10000, max = 10000, start = 0,
        snapPoints = {0}
    }
    
    --dialog panel!
    
    local regularAlert = Soda.Frame{
        parent = dialogPanel,
        title = "Press the buttons to trigger alerts in the default style",
        x = 0, y = -0.001, w = 1, h = 0.32,
        shape = Soda.RoundedRectangle, --style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16}
    }
    
    Soda.Button{
        parent = regularAlert, 
        title = "Proceed dialog", 
        x = 10, y = 0.4, w = 0.4, h = 40,
        callback = function() 
            Soda.Alert2{
                title = "Alert",
                content = "A 2-button\nProceed or cancel dialog",
            }
        end
    }
    
    Soda.Button{
    parent = regularAlert, 
    title = "Alert", 
    subStyle = {"warning"}, --style = Soda.style.warning, 
    x = -10, y = 0.4, w = 0.4, h = 40, 
    callback = 
        function()
            Soda.Alert{ --an alert box with a single button
                title = "Alert",
                content = "A one-button\nalert", 
                y=0.6, h = 0.3,
            }
        end
    }
    
    local blurAlert = Soda.Frame{
        parent = dialogPanel,
        title = "Press the buttons to trigger alerts with dark, blurred panels",
        x = 0, y = 0.5, w = 1, h = 0.32,
        shape = Soda.RoundedRectangle, --style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16}
    }
    
    Soda.Button{
        parent = blurAlert, 
        title = "Proceed dialog (blurred)", 
        x = 10, y = 0.4, w = 0.4, h = 40,
        callback = function() 
            Soda.Alert2{
                title = "Alert",
                content = "A 2-button\nProceed or cancel dialog",
              --  style = Soda.style.darkBlurred, 
                blurred = true, 
            }
        end
    }
    
    Soda.Button{
    parent = blurAlert, 
    title = "Alert (blurred)", 
    subStyle = {"warning"}, --style = Soda.style.warning, 
    x = -10, y = 0.4, w = 0.4, h = 40, 
    callback = 
        function()
            Soda.Alert{ --an alert box with a single button
                title = "Alert",
                content = "A one-button\nalert", 
                y=0.6, h = 0.3,
             --   style = Soda.style.darkBlurred, 
                blurred = true, 
            }
        end
    }
    
    --window panel
    local windowPresets = Soda.Frame{
        parent = dialogPanel,
        title = "Press the buttons to see the window presets",
        x = 0, y = 0, w = 1, h = 0.32,
        shape = Soda.RoundedRectangle, --style = Soda.style.translucent,
        subStyle = {"translucent"},
        shapeArgs = {radius = 16}
    }
    
    Soda.Button{
        parent = windowPresets, 
        title = "Window", 
        x = 10, y = 0.4, w = 0.4, h = 40,
        callback = function() 
            Soda.Window{
                title = "Window",
                content = "A regular window with optional ok, cancel, and close buttons and optional drop-shadow",
                ok = true, cancel = true, close = true, shadow = true
            }
        end
    }
    
    Soda.Button{
        parent = windowPresets, 
        title = "Blurred Window", 
        x = -10, y = 0.4, w = 0.4, h = 40,
        callback = function() 
            Soda.Window{
                title = "Blurred Window",
                content = "A blurred window with ok, cancel, and close buttons",
                blurred = true,
                ok = true, cancel = true, close = true
            }
        end
    }
    --text entry panel
    
    Soda.TextEntry{ --text entry box
        parent = textEntryPanel,
        x = 10, y = -50, w = -10, h = 40,
        title = "Text Entry:",
        default = "Tap here to start editing this text",
    }    
    
    Soda.TextEntry{
        parent = textEntryPanel,
        x = 10, y = 0.45, w = -10, h = 40,
        title = "Text Entry:",
        default = "Double-tap a word to select it and open the selection menu"
    }
    
    Soda.TextEntry{
        parent = textEntryPanel,
        x = 10, y = 10, w = -10, h = 40,
        title = "Text Entry:",
        default = "Scroll the text left and right by pulling the cursor over to either end of the box and holding your finger there. Also, note that the interface scrolls up if the text entry box is below the height of the keyboard."
    }
    
    --list panel
    
    Soda.List{
        parent = listPanel,
        x = 10, y = 10, h = -50, w = 0.45,
        text = {"Lists", "allow", "the", "user", "to", "select", "one", "option", "from", "a", "vertically", "scrolling", "list."}
    }
    
    Soda.DropdownList{
        parent = listPanel,
        x = -10, y = -110, w = 0.45, h = 40,
        title = "A numbered list",
        enumerate = true,
        text = {"Lists", "and", "dropdown lists", "can", "be", "automatically", "enumerated", "if", "you", "wish"}
    }
      
    Soda.DropdownList{
        parent = listPanel,
        x = -10, y = -50, w = 0.45, h = 40,
        title = "A dropdown list",
        text = {"Dropdown", "lists", "are", "lists", "that", "dropdown", "from", "a", "button.", "Note", "that", "the", "button", "reports", "the", "selection", "made"}
    }
    calculator.init()
end

