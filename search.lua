local keyMap = {
    ["2"] = {"a", "b", "c"},
    ["3"] = {"d", "e", "f"},
    ["4"] = {"g", "h", "i"},
    ["5"] = {"j", "k", "l"},
    ["6"] = {"m", "n", "o"},
    ["7"] = {"p", "q", "r", "s"},
    ["8"] = {"t", "u", "v"},
    ["9"] = {"w", "x", "y", "z"}
}
-- Initialize input variables
local inputText = ""
local lastKey = ""
local lastKeyTime = 0
local tapIndex = 1
local tapTimeout = 1.0 

local searchString = ""
local searchRegion = canvas:new(1920, 108)
print("hello")
local function handleKeyPress(key)
    if keyMap[key] then
        local currentTime = os.time()
        
        -- Check if the same key is pressed within the tap timeout period
        if key == lastKey and (currentTime - lastKeyTime) < tapTimeout then
            -- Cycle to the next letter in the key map
            tapIndex = tapIndex % #keyMap[key] + 1
            -- Remove the last character
            inputText = inputText:sub(1, -2)
        else
            -- New key press, reset the tap index
            tapIndex = 1
        end
        
        -- Add the new character
        inputText = inputText .. keyMap[key][tapIndex]
        
        -- Update the last key and time
        lastKey = key
        lastKeyTime = currentTime
    elseif key == "0" then
        inputText = inputText .. " "
    end
end

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
            value = inputText
        }
    elseif key == "RED" then
        inputText = inputText:sub(1, -2)
    elseif key:match("%a") or key:match("%d") then
        handleKeyPress(key)
    end

    searchRegion:attrColor("black")
    searchRegion:drawRect("fill", 0, 50, 1920, 58)
    searchRegion:attrColor("white")
    searchRegion:drawText(10, 50, inputText)
    searchRegion:flush()
end

event.register(function(evt)
    print(evt.class)
    if evt.class == 'key' and evt.type == 'release' then
        updateSearchString(evt.key)
        print("key trigger")
    end
end)

event.register(function(evt)
    if evt.type == 'presentation' and evt.action == 'start' then 
        drawRegion()
    end
end)