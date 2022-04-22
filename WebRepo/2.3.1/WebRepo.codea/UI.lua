UI = {}

UI.ENABLE_REVIEW = readLocalData("review_enabled") or false
UI.REVIEW_BUTTON = nil -- Stores the button when created

local theme = readLocalData("theme")
if theme == "light" then
    UI.THEME =  theme_light
elseif theme == "dark" then
    UI.THEME =  theme_dark
else
    UI.THEME =  theme_light
end