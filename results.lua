-- results.lua
local json = require("json")
local http = require("socket.http")
local apiUrl = "https://www.themealdb.com/api/json/v1/1/search.php?s="
local resultsRegion = canvas:new(1920, 864)
resultsRegion:attrColor("black")
resultsRegion:drawRect("fill", 0, 0, 1920, 864)
resultsRegion:flush()

local function searchRecipes(query)
    local response, status = http.request(apiUrl .. query)
    if status == 200 then
        return json.decode(response).meals
    else
        return nil
    end
end

local function displayResults(results)
    resultsRegion:attrColor("black")
    resultsRegion:drawRect("fill", 0, 0, 1920, 864)
    resultsRegion:attrColor("white")
    local y = 10

    if not results or #results == 0 then
        resultsRegion:drawText(10, y, "No results found.")
    else
        for _, meal in ipairs(results) do
            resultsRegion:drawText(10, y, meal.strMeal)
            y = y + 40
            resultsRegion:drawImage(10, y, meal.strMealThumb)
            y = y + 120
        end
    end
    resultsRegion:flush()
end

event.register(function(evt)
    if evt.class == 'ncl' and evt.type == 'attribution' and evt.property  == 'searchEvent' then
        local query = evt.value
        local results = searchRecipes(query)
        displayResults(results)
    end
end)
