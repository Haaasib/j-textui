-- Textures
Textures = { -- Do not change
    pin = 'pin',
    interact = 'interact',
    interactRed = 'interactRed',
    bg = 'bg',
    bgRed = 'bgRed'
}

local txdLoaded = false
Citizen.CreateThread(function()
    loadTxd()
end)

function loadTxd()
    local txd = CreateRuntimeTxd('interactions_txd')
    for _, v in pairs(Textures) do
        CreateRuntimeTextureFromImage(txd, tostring(v), "assets/" .. v .. ".png")
    end
end

Config.Players = {}
function displayTextUI(text, key, hide)
    local key = key
    if Config.DefaultKey and key == nil then
        key = Config.DefaultKey.Key
    end
    SendNUIMessage({action = "textUI", show = true, key = key, text = text, hide = hide})
end

function changeText(text, key)
    local key = key
    if Config.DefaultKey and key == nil then
        key = Config.DefaultKey.Key
    end
    SendNUIMessage({action = "textUIUpdate", key = key, text = text})
end

function hideTextUI()
    SendNUIMessage({action = "textUI", show = false})
end

function create3DTextUIOnPlayers(id, data)
    if Config.Players[id] then
        print(id .. " already exist.")
    else
        local targetPlayerId = GetPlayerFromServerId(data.id)
        local targetPed = GetPlayerPed(targetPlayerId)
        Config.Players[id] = {
            data = {
                id = id,
                ped = targetPed, 
                displayDist = data.displayDist,
                interactDist = data.interactDist,
                enableKeyClick = data.enableKeyClick,
                keyNum = data.keyNum, -- Key number
                keyNum2 = data.keyNum2,
                key = data.key, -- Key name
                text = data.text,
                theme = data.theme or "green"
            },
            onKeyClick = function()
                if data.triggerData then
                    if data.triggerData.isServer then
                        TriggerServerEvent(data.triggerData.triggerName, data.triggerData.args)
                    else
                        TriggerEvent(data.triggerData.triggerName, data.triggerData.args)
                    end
                end
            end,
            onKeyClick2 = function()
                if data.triggerData2 then
                    if data.triggerData2.isServer then
                        TriggerServerEvent(data.triggerData2.triggerName, data.triggerData2.args)
                    else
                        TriggerEvent(data.triggerData2.triggerName, data.triggerData2.args)
                    end
                end
            end
        }
    end
end

function delete3DTextUIOnPlayers(id)
    if Config.Players[id] then
        Config.Players[id] = nil
    else
        print(id .. " doesnt exist.")
    end
end

function create3DTextUI(id, data)
    if Config.Areas[id] then
        print(id .. " already exist.")
    else
        if data.canInteract then
            Config.Areas[id] = {
                data = {
                    id = id,
                    type = "3dtext", -- 3dtext or textui
                    coords = vector3(data.coords.x, data.coords.y, data.coords.z), 
                    displayDist = data.displayDist,
                    interactDist = data.interactDist,
                    enableKeyClick = data.enableKeyClick,
                    keyNum = data.keyNum, -- Key number
                    key = data.key, -- Key name
                    text = data.text,
                    theme = data.theme or "green",
                    job = data.job or "all",
                    canInteract = data.canInteract
                },
                onKeyClick = function()
                    if data.triggerData then
                        if data.triggerData.isServer then
                            TriggerServerEvent(data.triggerData.triggerName, data.triggerData.args)
                        else
                            TriggerEvent(data.triggerData.triggerName, data.triggerData.args)
                        end
                    end
                end
            }
        else
            Config.Areas[id] = {
                data = {
                    id = id,
                    type = data.type or "3dtext", -- 3dtext or textui
                    coords = vector3(data.coords.x, data.coords.y, data.coords.z), 
                    displayDist = data.displayDist,
                    interactDist = data.interactDist,
                    enableKeyClick = data.enableKeyClick,
                    keyNum = data.keyNum, -- Key number
                    key = data.key, -- Key name
                    text = data.text,
                    theme = data.theme or "green",
                    job = data.job or "all",
                    canInteract = function()
                        return true
                    end
                },
                onKeyClick = function()
                    if data.triggerData then
                        if data.triggerData.isServer then
                            TriggerServerEvent(data.triggerData.triggerName, data.triggerData.args)
                        else
                            TriggerEvent(data.triggerData.triggerName, data.triggerData.args)
                        end
                    end
                end
            }
        end
    end
end

function create3DTextUIOnEntity(id, data)
    if Config.Areas[id] then
        print(id .. " already exist.")
    else
        local entity = nil
        local type = nil
        local coords = nil
        if IsEntityAVehicle(id) then
            entity = id
            coords = GetEntityCoords(id)
        end
        if IsEntityAnObject(id) then
            entity = id
            coords = GetEntityCoords(id)
        end
        if IsEntityAPed(id) then
            entity = id
            coords = GetEntityCoords(id)
        end
        type = "3dtextentity"
        if entity == nil then type = "3dtexthash" entity = id end
        data.id = entity
        if coords then
            data.coords = vector3(coords.x, coords.y, coords.z + 1.0)
        else
            data.coords = vector3(0, 0, 0)
        end
        data.type = type
        create3DTextUI(entity, data)
    end
end

function delete3DTextUI(id)
    if Config.Areas[id] then
        Config.Areas[id] = nil
    else
        print(id .. " doesnt exist.")
    end
end

function update3DTextUI(id, text, theme)
    if Config.Areas[id] then
        Config.Areas[id].data.text = text
        Config.Areas[id].data.theme = theme
    else
        print(id .. " doesnt exist.")
    end
end

closestTextUIArea = {}
local showTextUI = false
Citizen.CreateThread(function()
    loadTxd()
	while true do
		local sleep = 100
        if not closestTextUIArea.id then
            playerCoords = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Areas) do
                local dist = #(vector3(v.data.coords.x, v.data.coords.y, v.data.coords.z) - playerCoords)
                if v.data.type == "textui" then
                    if dist <= v.data.dist then
                        if v.data.job == "all" or v.data.job == GetPlayerJob() then
                            function currentKeyClick()
                                v.onKeyClick()
                            end
                            function currentShow()
                                SendNUIMessage({action = "textUI", show = true, key = v.data.key, text = v.data.text})
                                showTextUI = true
                            end
                            function currentHide()
                                SendNUIMessage({action = "textUI", show = false})
                            end
                            closestTextUIArea = {id = k, distance = dist, maxDist = v.data.dist, data = {coords = vector3(v.data.coords.x, v.data.coords.y, v.data.coords.z), keyNum = v.data.keyNum}}
                        end
                    end
                end
            end
        end
        if closestTextUIArea.id then
            while true do
                playerCoords = GetEntityCoords(PlayerPedId())
                closestTextUIArea.distance = #(closestTextUIArea.data.coords - playerCoords)
                if closestTextUIArea.distance < closestTextUIArea.maxDist then
                    if IsControlJustReleased(0, closestTextUIArea.data.keyNum) then
                        currentKeyClick()
                    end
                    if not showTextUI then
                        currentShow()
                    end
                else
                    currentHide()
                    break
                end
                Citizen.Wait(0)
            end
            showTextUI = false
            closestTextUIArea = {}
            sleep = 0
        end
		Citizen.Wait(sleep)
	end
end)

local showTextUI = false
Citizen.CreateThread(function()
    while not CoreReady do Citizen.Wait(0) end
    while not next(GetPlayerData()) do Citizen.Wait(0) end
    loadTxd()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        local ratio = GetAspectRatio(true)
        for k, v in pairs(Config.Areas) do
            local dist = #(v.data.coords - playerCoords)
            if v.data.type == "3dtext" then
                if dist <= v.data.displayDist then
                    sleep = 0
                    if v.data.canInteract == nil then
                        v.data.canInteract = function()
                            return true
                        end
                    end
                    local canInteract = v.data.canInteract()
                    if canInteract then
                        if v.data.job == "all" or v.data.job == GetPlayerJob() then
                            if dist <= v.data.interactDist then
                                -- Main Text
                                local factor = (string.len(v.data.text)) / 370
                                local width = 0.03 + factor
                                -- Key Text
                                local factor2 = (string.len(v.data.key)) / 370
                                local width2 = 0.016 + factor2
                                local onScreen, _x, _y = World3dToScreen2d(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                                if onScreen then
                                    local interact, bg = 'interact', 'bg'
                                    if v.data.theme == "red" then
                                        interact, bg = 'interactRed', 'bgRed'
                                    end
                                    -- E
                                    SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                                    SetTextScale(0, 0.35)
                                    SetTextFont(2)
                                    SetTextColour(255, 255, 255, 255)
                                    BeginTextCommandDisplayText("STRING")
                                    SetTextCentre(true)
                                    SetTextJustification(0)
                                    AddTextComponentSubstringPlayerName(v.data.key)
                                    SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                                    EndTextCommandDisplayText(0.0, -0.0115)
                                    ResetScriptGfxAlign()
                                    SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                                    DrawSprite('interactions_txd', interact, 0.0, 0.0, width2, 0.03133333333333333, 0.0, 255, 255, 255, 255)
                                    ResetScriptGfxAlign()
                                    ClearDrawOrigin()
                                    -- Bg
                                    SetScriptGfxAlignParams(0.018 + (width / 2), 0 * 0.03 - 0.0125, 0.0, 0.0)
                                    SetTextScale(0, 0.3)
                                    SetTextFont(4)
                                    SetTextColour(255, 255, 255, 255)
                                    BeginTextCommandDisplayText("STRING")
                                    SetTextCentre(1)
                                    AddTextComponentSubstringPlayerName(v.data.text)
                                    SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                                    SetTextJustification(0)
                                    EndTextCommandDisplayText(-0.01, 0.001)
                                    ResetScriptGfxAlign()
                                    SetScriptGfxAlignParams(0.018 + (width / 2), 0 * 0.03 - 0.015, 0.0, 0.0)
                                    DrawSprite('interactions_txd', bg, 0.0, 0.015, width, 0.025, 0.0, 255, 255, 255, 255)
                                    ResetScriptGfxAlign()
                                    ClearDrawOrigin()
                                    if v.data.enableKeyClick then
                                        if v.data.keyNum then
                                            if IsControlJustReleased(0, v.data.keyNum) then
                                                v.onKeyClick()
                                            end
                                        end
                                    end
                                end
                            else
                                SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                                SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                                DrawSprite('interactions_txd', 'pin', 0, 0, 0.0125, 0.02333333333333333, 0, 255, 255, 255, 255)
                                ResetScriptGfxAlign()
                            end
                        end
                    end
                end
            end
            if v.data.type == "3dtextentity" then
                local obj = v.data.id
                if DoesEntityExist(obj) then
                    v.data.coords = GetEntityCoords(obj)
                    if v.data.canInteract == nil then
                        v.data.canInteract = function()
                            return true
                        end
                    end
                    local canInteract = v.data.canInteract()
                    if canInteract then
                        if dist <= v.data.displayDist then
                            sleep = 0
                            if v.data.job == "all" or v.data.job == GetPlayerJob() then
                                if dist <= v.data.interactDist then
                                    -- Main Text
                                    local factor = (string.len(v.data.text)) / 370
                                    local width = 0.03 + factor
                                    -- Key Text
                                    local factor2 = (string.len(v.data.key)) / 370
                                    local width2 = 0.016 + factor2
                                    local onScreen, _x, _y = World3dToScreen2d(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                                    if onScreen then
                                        local interact, bg = 'interact', 'bg'
                                        if v.data.theme == "red" then
                                            interact, bg = 'interactRed', 'bgRed'
                                        end
                                        -- E
                                        SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                                        SetTextScale(0, 0.35)
                                        SetTextFont(2)
                                        SetTextColour(255, 255, 255, 255)
                                        BeginTextCommandDisplayText("STRING")
                                        SetTextCentre(true)
                                        SetTextJustification(0)
                                        AddTextComponentSubstringPlayerName(v.data.key)
                                        SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                                        EndTextCommandDisplayText(0.0, -0.0115)
                                        ResetScriptGfxAlign()
                                        SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                                        DrawSprite('interactions_txd', interact, 0.0, 0.0, width2, 0.03133333333333333, 0.0, 255, 255, 255, 255)
                                        ResetScriptGfxAlign()
                                        ClearDrawOrigin()
                                        -- Bg
                                        SetScriptGfxAlignParams(0.018 + (width / 2), 0 * 0.03 - 0.0125, 0.0, 0.0)
                                        SetTextScale(0, 0.3)
                                        SetTextFont(4)
                                        SetTextColour(255, 255, 255, 255)
                                        BeginTextCommandDisplayText("STRING")
                                        SetTextCentre(1)
                                        AddTextComponentSubstringPlayerName(v.data.text)
                                        SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                                        SetTextJustification(0)
                                        EndTextCommandDisplayText(-0.01, 0.001)
                                        ResetScriptGfxAlign()
                                        SetScriptGfxAlignParams(0.018 + (width / 2), 0 * 0.03 - 0.015, 0.0, 0.0)
                                        DrawSprite('interactions_txd', bg, 0.0, 0.015, width, 0.025, 0.0, 255, 255, 255, 255)
                                        ResetScriptGfxAlign()
                                        ClearDrawOrigin()
                                        if v.data.enableKeyClick then
                                            if v.data.keyNum then
                                                if IsControlJustReleased(0, v.data.keyNum) then
                                                    v.onKeyClick()
                                                end
                                            end
                                        end
                                    end
                                else
                                    SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                                    SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                                    DrawSprite('interactions_txd', 'pin', 0, 0, 0.0125, 0.02333333333333333, 0, 255, 255, 255, 255)
                                    ResetScriptGfxAlign()
                                end
                            end
                        end
                    end
                end
            end
            if v.data.type == "3dtexthash" then
                local objHash = type(v.data.id) == "number" and v.data.id or joaat(v.data.id)
                local obj = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 10.0, objHash, false, 0, 0)
                if DoesEntityExist(obj) then
                    v.data.coords = GetEntityCoords(obj)
                    if v.data.canInteract == nil then
                        v.data.canInteract = function()
                            return true
                        end
                    end
                    local canInteract = v.data.canInteract()
                    if canInteract then
                        if dist <= v.data.displayDist then
                            sleep = 0
                            if v.data.job == "all" or v.data.job == GetPlayerJob() then
                                if dist <= v.data.interactDist then
                                    -- Main Text
                                    local factor = (string.len(v.data.text)) / 370
                                    local width = 0.03 + factor
                                    -- Key Text
                                    local factor2 = (string.len(v.data.key)) / 370
                                    local width2 = 0.016 + factor2
                                    local onScreen, _x, _y = World3dToScreen2d(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                                    if onScreen then
                                        local interact, bg = 'interact', 'bg'
                                        if v.data.theme == "red" then
                                            interact, bg = 'interactRed', 'bgRed'
                                        end
                                        -- E
                                        SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                                        SetTextScale(0, 0.35)
                                        SetTextFont(2)
                                        SetTextColour(255, 255, 255, 255)
                                        BeginTextCommandDisplayText("STRING")
                                        SetTextCentre(true)
                                        SetTextJustification(0)
                                        AddTextComponentSubstringPlayerName(v.data.key)
                                        SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z + 1.0)
                                        EndTextCommandDisplayText(0.0, -0.0115)
                                        ResetScriptGfxAlign()
                                        SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                                        DrawSprite('interactions_txd', interact, 0.0, 0.0, width2, 0.03133333333333333, 0.0, 255, 255, 255, 255)
                                        ResetScriptGfxAlign()
                                        ClearDrawOrigin()
                                        -- Bg
                                        SetScriptGfxAlignParams(0.018 + (width / 2), 0 * 0.03 - 0.0125, 0.0, 0.0)
                                        SetTextScale(0, 0.3)
                                        SetTextFont(4)
                                        SetTextColour(255, 255, 255, 255)
                                        BeginTextCommandDisplayText("STRING")
                                        SetTextCentre(1)
                                        AddTextComponentSubstringPlayerName(v.data.text)
                                        SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z + 1.0)
                                        SetTextJustification(0)
                                        EndTextCommandDisplayText(-0.01, 0.001)
                                        ResetScriptGfxAlign()
                                        SetScriptGfxAlignParams(0.018 + (width / 2), 0 * 0.03 - 0.015, 0.0, 0.0)
                                        DrawSprite('interactions_txd', bg, 0.0, 0.015, width, 0.025, 0.0, 255, 255, 255, 255)
                                        ResetScriptGfxAlign()
                                        ClearDrawOrigin()
                                        if v.data.enableKeyClick then
                                            if v.data.keyNum then
                                                if IsControlJustReleased(0, v.data.keyNum) then
                                                    v.onKeyClick()
                                                end
                                            end
                                        end
                                    end
                                else
                                    SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                                    SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z + 1.0)
                                    DrawSprite('interactions_txd', 'pin', 0, 0, 0.0125, 0.02333333333333333, 0, 255, 255, 255, 255)
                                    ResetScriptGfxAlign()
                                end
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

local showTextUI2 = false
Citizen.CreateThread(function()
    loadTxd()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.Players) do
            v.data.coords = GetEntityCoords(v.data.ped)
            local dist = #(v.data.coords - playerCoords)
            if dist <= v.data.displayDist then
                sleep = 0
                if dist <= v.data.interactDist then
                    -- Main Text
                    local factor = (string.len(v.data.text)) / 370
                    local width = 0.03 + factor
                    -- Key Text
                    local factor2 = (string.len(v.data.key)) / 370
                    local width2 = 0.016 + factor2
                    local onScreen, _x, _y = World3dToScreen2d(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                    if onScreen then
                        local interact, bg = 'interact', 'bg'
                        if v.data.theme == "red" then
                            interact, bg = 'interactRed', 'bgRed'
                        end
                        -- E
                        SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                        SetTextScale(0, 0.35)
                        SetTextFont(4)
                        SetTextColour(255, 255, 255, 255)
                        BeginTextCommandDisplayText("STRING")
                        SetTextCentre(true)
                        SetTextJustification(0)
                        AddTextComponentSubstringPlayerName(v.data.key)
                        SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                        EndTextCommandDisplayText(0.0, -0.0115)
                        ResetScriptGfxAlign()
                        SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                        DrawSprite('interactions_txd', interact, 0.0, 0.0, width2, 0.03133333333333333, 0.0, 255, 255, 255, 255)
                        ResetScriptGfxAlign()
                        ClearDrawOrigin()
                        -- Bg
                        SetScriptGfxAlignParams(0.018 + (width / 2), 0 * 0.03 - 0.0125, 0.0, 0.0)
                        SetTextScale(0, 0.3)
                        SetTextFont(4)
                        SetTextColour(255, 255, 255, 255)
                        BeginTextCommandDisplayText("STRING")
                        SetTextCentre(1)
                        AddTextComponentSubstringPlayerName(v.data.text)
                        SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                        SetTextJustification(0)
                        EndTextCommandDisplayText(-0.01, 0.001)
                        ResetScriptGfxAlign()
                        SetScriptGfxAlignParams(0.018 + (width / 2), 0 * 0.03 - 0.015, 0.0, 0.0)
                        DrawSprite('interactions_txd', bg, 0.0, 0.015, width, 0.025, 0.0, 255, 255, 255, 255)
                        ResetScriptGfxAlign()
                        ClearDrawOrigin()
                        if v.data.enableKeyClick then
                            if v.data.keyNum then
                                if IsControlJustReleased(0, v.data.keyNum) then
                                    v.onKeyClick()
                                end
                            end
                            if v.data.keyNum2 then
                                if IsControlJustReleased(0, v.data.keyNum2) then
                                    v.onKeyClick2()
                                end
                            end
                        end
                    end
                else
                    SetScriptGfxAlignParams(0.0, 0.0, 0.0, 0.0)
                    SetDrawOrigin(v.data.coords.x, v.data.coords.y, v.data.coords.z)
                    DrawSprite('interactions_txd', 'pin', 0, 0, 0.0125, 0.02333333333333333, 0, 255, 255, 255, 255)
                    ResetScriptGfxAlign()
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)