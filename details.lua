local json = require("json")
local detailsRegion = canvas:new(1920, 864)
detailsRegion:attrColor("black")
detailsRegion:drawRect("fill", 0, 0, 1920, 864)
detailsRegion:flush()

local function displayDetails(meal)
    detailsRegion:attrColor("black")
    detailsRegion:drawRect("fill", 0, 0, 1920, 864)
    detailsRegion:attrColor("white")
    local detailsText = meal.strInstructions
    for i = 1, 20 do
        local ingredient = meal["strIngredient" .. i]
        local measure = meal["strMeasure" .. i]
        if ingredient and ingredient ~= "" then
            detailsText = detailsText .. "\n" .. measure .. " " .. ingredient
        end
    end
    detailsRegion:drawText(10, 10, detailsText)
    detailsRegion:flush()
end

event.register(function(evt)
    if evt.class == 'ncl' and evt.type == 'attribution' and evt.name == 'selectRecipeEvent' then
        local meal = json.decode(evt.value)
        displayDetails(meal)
    end
end)
