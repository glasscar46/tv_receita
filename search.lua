local searchString = ""
local searchRegion = canvas:new(1920, 108)
-- searchRegion:attrColor("black")

local function drawRegion()
    
    canvas:attrColor('white')
    canvas:drawRect("fill", 0, 0, 1920, 108)
    searchRegion:drawText(10, 10, "Enter search query:")
    canvas:compose(0,0,searchRegion)
    canvas:flush()
end

local function updateSearchString(key)
    if key == "GREEN" then
        event.post {
            class = 'ncl',
            type = 'attribution',
            property  = 'searchEvent',
            action = 'start',
            value = searchString
        }
    elseif key == "RED" then
        searchString = searchString:sub(1, -2)
    elseif key:match("%a") or key:match("%d") then
        searchString = searchString .. key
    end

    searchRegion:attrColor("black")
    searchRegion:drawRect("fill", 0, 50, 1920, 58)
    searchRegion:attrColor("white")
    searchRegion:drawText(10, 50, searchString)
    searchRegion:flush()
end

event.register(function(evt)
    if evt.class == 'key' and evt.type == 'press' then
        updateSearchString(evt.key)
    end
end)

event.register(function(evt)
    if evt.type == 'presentation' and evt.action == 'start' then 
        drawRegion()
    end
end)