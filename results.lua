package.path = package.path .. ';./?.lua'
local json = require("json")
require 'tcp'
-- local http = require("http")
local ncluahttp = require "ncluahttp"
local apiUrl = "https://www.themealdb.com/api/json/v1/1/search.php?s="

local function searchRecipes(query)
    local response, status = http.request(apiUrl .. query)
    if status == 200 then
        return json.decode(response).meals
    else
        return nil
    end
end
local mock = {
    meals = {
        {
            idMeal = "52977",
            strMeal = "Corba",
            strDrinkAlternate = nil,
            strCategory = "Side",
            strArea = "Turkish",
            strInstructions = "Pick through your lentils for any foreign debris, rinse them 2 or 3 times, drain, and set aside.  Fair warning, this will probably turn your lentils into a solid block that you’ll have to break up later\r\nIn a large pot over medium-high heat, sauté the olive oil and the onion with a pinch of salt for about 3 minutes, then add the carrots and cook for another 3 minutes.\r\nAdd the tomato paste and stir it around for around 1 minute. Now add the cumin, paprika, mint, thyme, black pepper, and red pepper as quickly as you can and stir for 10 seconds to bloom the spices. Congratulate yourself on how amazing your house now smells.\r\nImmediately add the lentils, water, broth, and salt. Bring the soup to a (gentle) boil.\r\nAfter it has come to a boil, reduce heat to medium-low, cover the pot halfway, and cook for 15-20 minutes or until the lentils have fallen apart and the carrots are completely cooked.\r\nAfter the soup has cooked and the lentils are tender, blend the soup either in a blender or simply use a hand blender to reach the consistency you desire. Taste for seasoning and add more salt if necessary.\r\nServe with crushed-up crackers, torn up bread, or something else to add some extra thickness.  You could also use a traditional thickener (like cornstarch or flour), but I prefer to add crackers for some texture and saltiness.  Makes great leftovers, stays good in the fridge for about a week.",
            strMealThumb = "https://www.themealdb.com/images/media/meals/58oia61564916529.jpg",
            strTags = "Soup",
            strYoutube = "https://www.youtube.com/watch?v=VVnZd8A84z4",
            strIngredient1 = "Lentils",
            strIngredient2 = "Onion",
            strIngredient3 = "Carrots",
            strIngredient4 = "Tomato Puree",
            strIngredient5 = "Cumin",
            strIngredient6 = "Paprika",
            strIngredient7 = "Mint",
            strIngredient8 = "Thyme",
            strIngredient9 = "Black Pepper",
            strIngredient10 = "Red Pepper Flakes",
            strIngredient11 = "Vegetable Stock",
            strIngredient12 = "Water",
            strIngredient13 = "Sea Salt",
            strIngredient14 = "",
            strIngredient15 = "",
            strIngredient16 = "",
            strIngredient17 = "",
            strIngredient18 = "",
            strIngredient19 = "",
            strIngredient20 = "",
            strMeasure1 = "1 cup ",
            strMeasure2 = "1 large",
            strMeasure3 = "1 large",
            strMeasure4 = "1 tbs",
            strMeasure5 = "2 tsp",
            strMeasure6 = "1 tsp ",
            strMeasure7 = "1/2 tsp",
            strMeasure8 = "1/2 tsp",
            strMeasure9 = "1/4 tsp",
            strMeasure10 = "1/4 tsp",
            strMeasure11 = "4 cups ",
            strMeasure12 = "1 cup ",
            strMeasure13 = "Pinch",
            strMeasure14 = " ",
            strMeasure15 = " ",
            strMeasure16 = " ",
            strMeasure17 = " ",
            strMeasure18 = " ",
            strMeasure19 = " ",
            strMeasure20 = " ",
            strSource = "https://findingtimeforcooking.com/main-dishes/red-lentil-soup-corba/",
            strImageSource = nil,
            strCreativeCommonsConfirmed = nil,
            dateModified = nil
        }
    }
}
function wrap_text(text, max_line_length)
    local lines = {}
    local line = ""
    
    for word in text:gmatch("%S+") do
        if #line + #word + 1 <= max_line_length then
            line = line .. word .. " "
        else
            table.insert(lines, line)
            line = word .. " "
        end
    end
    
    -- Add the last line
    table.insert(lines, line)
    
    return lines
end

function displayMealDetails(meal)
    local y = 20
    local x = 20
    local lineSpacing = 30
    local textColor = canvas:attrColor(255, 255, 255, 255)

    canvas:clear()
    canvas:attrFont("vera", 8)
    canvas:attrColor("blue")
    canvas:drawText(x, y, "MEAL: " .. meal.strMeal)
    y = y + lineSpacing
    canvas:drawText(x, y, "CATEGORY: " .. meal.strCategory)
    y = y + lineSpacing
    canvas:drawText(x, y, "AREA: " .. meal.strArea)
    y = y + lineSpacing
    canvas:drawText(x, y, "INSTRUCTIONS: ")
    y = y + lineSpacing
     x = x + 10
    -- Display instructions in multiple lines if too long
    local instructionsLines = wrap_text(meal.strInstructions, 90)
    for _, line in ipairs(instructionsLines) do
        canvas:drawText(x, y, line)
        y = y + lineSpacing - 10
    end

    y = y + lineSpacing
    x = 550
    y = 20
    canvas:drawText(x, y, "INGREDIENTS: ")

    for i = 1, 20 do
        local ingredient = meal["strIngredient" .. i]
        local measure = meal["strMeasure" .. i]
        if ingredient and ingredient ~= "" then
            y = y + lineSpacing
            canvas:drawText(x, y, measure .. " " .. ingredient)
        end
    end

    canvas:flush()
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
            resultsRegion:new(meal.strMealThumb)
            y = y + 120
        end
    end
    resultsRegion:flush()
end

event.register(function(evt)
	if evt.class  ~= 'ncl'         then return end
    if evt.type   ~= 'attribution' then return end
    if evt.action ~= 'start'       then return end
    if evt.name   ~= 'search'      then return end
	event.post {
        class  = 'ncl',
        type   = 'attribution',
        name   = 'search',
        action = 'stop',
    }
    local query = evt.value

    function callback(header, body)
        if body then
           print("\n\n\n", header, "\n\n\n")
        end
      end
      
      ncluahttp.request("https://www.themealdb.com/api/json/v1/1/search.php?s=Corba", callback)
    -- tcp.execute(
    --     function ()
    --         tcp.connect('https://www.themealdb.com', 80)
    --         print("connected")
    --         tcp.send('GET /api/json/v1/1/search.php?s='..query..'\n')
    --         local result = tcp.receive()
    --         print("result", result)
    --         if result then
	-- 	        result = string.match(result, 'Location: http://(.-)\r?\n') or 'nao encontrado'
	--         else
	-- 	        result = 'error: ' .. evt.error
	--         end
	--         local evt = {
	-- 	        class = 'ncl',
	-- 	        type  = 'attribution',
	-- 	        name  = 'result',
	-- 	        value = result,
	--         }
	--         evt.action = 'start'; event.post(evt)
	--         evt.action = 'stop' ; event.post(evt)
    --         tcp.disconnect()
    --     end
    -- )

    -- local results = searchRecipes(query)
    -- print(results)
    displayMealDetails(mock.meals[1])
    local evt = {
        class = 'ncl',
        type  = 'attribution',
        name  = 'result',
        value = mock.meals,
    }
    evt.action = 'start'; event.post(evt)
    evt.action = 'stop' ; event.post(evt)
end)
