---
description: J Text UI  Installation Document
---

# Installation
## How to use ?

## Creating Normal Zone (Only Client)
```lua
Put this on top of your client side and you don't need to do anything else. This is for classic cordinates

This is for spesific coord text-ui or player
CreateThread(function()
    -- For fixed coordinate
    exports['j-textui']:create3DTextUI("j-test", {
        coords = vector3(-1461.18, -31.48, 54.63),
        displayDist = 6.0,
        interactDist = 2.0,
        enableKeyClick = true, -- If true when you near it and click key it will trigger the event that you write inside triggerData
        keyNum = 38,
        key = "E",
        text = "Test",
        theme = "green", -- or red
        job = "all", -- or the job you want to show this for
        canInteract = function()
            return true
        end,
        triggerData = {
            triggerName = "",
            args = {}
        }
    })
    exports['j-textui']:delete3DTextUI("j-test")
    -- For Players
    exports['j-textui']:create3DTextUIOnPlayers("j-test", {
        id = targetId,
        ped = targetPed,
        displayDist = 6.0,
        interactDist = 2.0,
        enableKeyClick = true, -- If true when you near it and click key it will trigger the event that you write inside triggerData
        keyNum = 38,
        key = "E",
        text = "Test",
        theme = "green", -- or red
        triggerData = {
            triggerName = "",
            args = {}
        }
    })
    -- Delete Text UI for player
    exports['j-textui']:delete3DTextUIOnPlayers(targetId)
     -- For Entities, Vehicles, Peds (fixed coordinate)
    exports['j-textui']:create3DTextUIOnEntity(entity, {
        displayDist = 6.0,
        interactDist = 2.0,
        enableKeyClick = true, -- If true when you near it and click key it will trigger the event that you write inside triggerData
        keyNum = 38,
        key = "E",
        text = "Test",
        theme = "green", -- or red
        triggerData = {
            triggerName = "",
            args = {}
        }
    })
    -- Delete Text UI for entity, vehicle or ped
    exports['j-textui']:delete3DTextUI(entity)
end)
```

## qb-core/client/drawtext.lua | Find the file and replace everything
```lua
    local function hideText()
        exports["j-textui"]:hideTextUI()
    end

    local function drawText(text, position)
        if type(position) ~= 'string' then position = 'left' end
        exports["j-textui"]:displayTextUI(text, position)
    end

    local function changeText(text, position)
        if type(position) ~= 'string' then position = 'left' end
        exports['j-textui']:changeText(text, position)
    end

    local function keyPressed()
        CreateThread(function() -- Not sure if a thread is needed but why not eh?
            -- SendNUIMessage({
            --     action = 'KEY_PRESSED',
            -- })
            Wait(500)
            hideText()
        end)
    end

    RegisterNetEvent('qb-core:client:DrawText', function(text, position)
        drawText(text, position)
    end)

    RegisterNetEvent('qb-core:client:ChangeText', function(text, position)
        changeText(text, position)
    end)

    RegisterNetEvent('qb-core:client:HideText', function()
        hideText()
    end)

    RegisterNetEvent('qb-core:client:KeyPressed', function()
        keyPressed()
    end)

    exports('DrawText', drawText)
    exports('ChangeText', changeText)
    exports('HideText', hideText)
    exports('KeyPressed', keyPressed)
```

## es_extended/client/functions.lua | Find these functions and replace
```lua
    function ESX.TextUI(message, notifyType)
        if GetResourceState("j-textui") ~= "missing" then
            return exports["j-textui"]:displayTextUI(message, notifyType)
        end
        print("[^1ERROR^7] ^5j-textui^7 is Missing!")
    end

    function ESX.HideUI()
        if GetResourceState("j-textui") ~= "missing" then
            return exports["j-textui"]:hideTextUI()
        end
        print("[^1ERROR^7] ^5j-textui^7 is Missing!")
    end
```

# Credits
* [Hasib](https://github.com/Haaasib/) - Creator
* [QBCore Devs](https://github.com/qbcore-framework/) - For making an awesome framework and enabling me to do this.
* QBCore Community - Thank you so much for everyone who's been testing this!

# If You want to report bugs and want support Join Our Discord Server 

https://discord.com/invite/T7du2nJfyN
