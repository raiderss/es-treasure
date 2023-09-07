local lootObjects = {}
local lootData = {}
RegisterNetEvent("spawnLoot")
AddEventHandler("spawnLoot", function(coords, index, items)
    local lootModel = "prop_box_wood02a_pu"
    RequestModel(lootModel)
    while not HasModelLoaded(lootModel) do
        Wait(500)
    end
    local lootObject = CreateObject(GetHashKey(lootModel), coords.x, coords.y, coords.z, true, false, true)
    SetEntityInvincible(lootObject, true)
    SetEntityCoordsNoOffset(lootObject,coords.x, coords.y, coords.z, true, true, true)
    FreezeEntityPosition(lootObject, true)
    SetEntityCollision(lootObject, false, false)
    lootObjects[index] = lootObject
    lootData[index] = items
end)

local isLooting = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = GetPlayerPed(-1)
        local pos = GetEntityCoords(playerPed)
        for index, lootObject in pairs(lootObjects) do
            local lootPos = GetEntityCoords(lootObject)
            local dist = GetDistanceBetweenCoords(lootPos.x, lootPos.y, lootPos.z, pos.x, pos.y, pos.z, true)
            if dist < 2.0 then
                DrawText3D(lootPos.x, lootPos.y, lootPos.z + 1.0, "Press [E] to loot: " .. table.concat(lootData[index], ", "))
                if IsControlJustReleased(0, 38) then
                    local heading = GetEntityHeading(lootObject)
                    local x, y, z = table.unpack(lootPos)
                    local propHeading = heading + 180.0  
                    local distanceToMoveAway = -1.0 
                    local newX = x + (distanceToMoveAway * math.sin(math.rad(propHeading)))
                    local newY = y + (distanceToMoveAway * math.cos(math.rad(propHeading)))
                    SetEntityCoordsNoOffset(playerPed, newX, newY, z + 1.0, true, true, true) 
                    SetEntityHeading(playerPed, propHeading)
                    if not isLooting then
                        isLooting = true
                        TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)  
                        Citizen.Wait(5000)  
                        ClearPedTasks(playerPed)  
                        TriggerServerEvent("giveItemsToPlayer", lootData[index])
                        TriggerServerEvent("lootTaken", index)
                        DeleteEntity(lootObject)
                        lootObjects[index] = nil
                        lootData[index] = nil
                        isLooting = false
                    end
                end
            end
        end
    end
end)


RegisterNetEvent("removeLoot")
AddEventHandler("removeLoot", function(index)
    DeleteEntity(lootObjects[index])
    lootObjects[index] = nil
    lootData[index] = nil
end)


local showRedZone = false
local zoneCoords = {x = 0.0, y = 0.0, z = 0.0} 
local redZoneBlips = {}

RegisterNetEvent("createEventBlip")
AddEventHandler("createEventBlip", function(x, y, z)
    showRedZone = true
    zoneCoords = {x = x, y = y, z = z}
    local blip = AddBlipForRadius(x, y, z, 1100.0)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 49)
    SetBlipAlpha(blip, 75)
    table.insert(redZoneBlips, blip)  
end)

RegisterNetEvent("removeRedZoneBlips")
AddEventHandler("removeRedZoneBlips", function()
    for _, blip in pairs(redZoneBlips) do
        RemoveBlip(blip)  
    end
    redZoneBlips = {}
end)

RegisterNetEvent("blipStatus")
AddEventHandler("blipStatus", function(status)
    showRedZone = false
    local blip = AddBlipForRadius(0, 0, 0, 0)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if showRedZone then
            local playerPed = GetPlayerPed(-1)
            local pos = GetEntityCoords(playerPed)
            local radius = 10.0
            local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, zoneCoords.x, zoneCoords.y, zoneCoords.z, true)
            if distance <= radius then
                DrawMarker(1, zoneCoords.x, zoneCoords.y, zoneCoords.z - 1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, radius * 2.0, radius * 2.0, 1.0, 255, 0, 0, 100, false, true, 2, true, false, false, false)
                DrawLightWithRange(zoneCoords.x, zoneCoords.y, zoneCoords.z + 1.0, 255, 0, 0, radius * 2.0, 1.0)
            end
        end
    end
end)

RegisterCommand('clearprops', function()
    local playerPed = GetPlayerPed(-1) 
    local pos = GetEntityCoords(playerPed)  
    local handle, object = FindFirstObject()
    local finished = false
    repeat
        local objPos = GetEntityCoords(object)
        if Vdist(pos.x, pos.y, pos.z, objPos.x, objPos.y, objPos.z) < 30.0 then
            DeleteEntity(object)
        end
        finished, object = FindNextObject(handle)
    until not finished
    EndFindObject(handle)
end, false)


function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(_x, _y)
end
