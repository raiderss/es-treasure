local spawnedLoot = {}
local lootIndex = 1
local totalLootCount = #Config.Coords 
local lootedCount = 0  

RegisterNetEvent("lootTaken")
AddEventHandler("lootTaken", function(index)
    spawnedLoot[index] = nil
    TriggerClientEvent("removeLoot", -1, index)
    lootedCount = lootedCount + 1  
    if lootedCount >= totalLootCount then
        TriggerClientEvent("removeRedZoneBlips", -1)
        print("Tüm lootlar alındı!")
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)  
    for _, loot in ipairs(Config.Coords) do
        print("Server: Creating a loot box...")  -- Debug
        TriggerClientEvent("spawnLoot", -1, {x = loot.x, y = loot.y, z = loot.z}, lootIndex, loot.items)
        TriggerClientEvent("createEventBlip", -1, loot.x, loot.y, loot.z)
        spawnedLoot[lootIndex] = loot
        lootIndex = lootIndex + 1
    end
end)

RegisterServerEvent("giveItemsToPlayer")
AddEventHandler("giveItemsToPlayer", function(items)
    print("The player received the following items:" .. table.concat(items, ", "))
end)

