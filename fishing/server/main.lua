local ox_inventory = exports.ox_inventory
print("Fishing by FelixL has started :)")

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local fishingPlayers = {}

RegisterNetEvent('fishing:start')
AddEventHandler('fishing:start', function()
    local src = source
    if not fishingPlayers[src] then
        fishingPlayers[src] = true
    end
end)

RegisterNetEvent('fishing:stop')
AddEventHandler('fishing:stop', function()
    local src = source
    fishingPlayers[src] = nil
end)


AddEventHandler('playerDropped', function()
    local src = source
    fishingPlayers[src] = nil
end)

ESX.RegisterUsableItem('turtlebait', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.getInventoryItem('fishingrod').count > 0 then
        TriggerClientEvent('fishing:setbait', source, "turtle")
        xPlayer.removeInventoryItem('turtlebait', 1)
        TriggerClientEvent('fish:message', source, "~g~You attached turtle bait!")
    else
        TriggerClientEvent('fish:message', source, "~r~You don't have a fishing rod.")
    end
end)

ESX.RegisterUsableItem('fishbait', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.getInventoryItem('fishingrod').count > 0 then
        TriggerClientEvent('fishing:setbait', source, "fish")
        xPlayer.removeInventoryItem('fishbait', 1)
        TriggerClientEvent('fish:message', source, "~g~You attached fish bait!")
    else
        TriggerClientEvent('fish:message', source, "~r~You don't have a fishing rod.")
    end
end)

ESX.RegisterUsableItem('turtle', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.getInventoryItem('fishingrod').count > 0 then
        TriggerClientEvent('fishing:setbait', source, "shark")
        xPlayer.removeInventoryItem('turtle', 1)
        TriggerClientEvent('fish:message', source, "~g~You attached turtle meat!")
    else
        TriggerClientEvent('fish:message', source, "~r~You don't have a fishing rod.")
    end
end)

ESX.RegisterUsableItem('fishingrod', function(source)
    TriggerClientEvent('fishing:fishstart', source)
    TriggerEvent('fishing:start', source)
end)

RegisterNetEvent('fishing:catch')
AddEventHandler('fishing:catch', function(bait)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    -- Exploit protection
    if not fishingPlayers[src] then
        print(('[Exploit attempt] Player %s called fishing:catch without fishing:start'):format(src))
        DropPlayer(src, "Fishing exploit detected. You have been kicked.")
        return
    end

    fishingPlayers[src] = nil

    if not xPlayer then return end

    local quantity = math.random(1, 3)
    local rnd = math.random(1, 100)

    if bait == "turtle" then
        if rnd <= 5 then
            TriggerClientEvent('fishing:setbait', src, "none")
            TriggerClientEvent('esx:showNotification', src, "~r~Your bait fell off.")
        elseif rnd < 98.5 then
            if ox_inventory:CanCarryItem(src, 'fish', quantity) then
                xPlayer.addInventoryItem('fish', quantity)
                TriggerClientEvent('fish:message', src, "~g~You caught " .. quantity .. " fish!")
            else
                TriggerClientEvent('esx:showNotification', src, "~r~Not enough inventory space!")
            end
        else
            TriggerClientEvent('fishing:setbait', src, "none")
            TriggerClientEvent('fish:message', src, "~r~The fish was too strong and broke your rod.")
            TriggerClientEvent('fishing:break', src)
            xPlayer.removeInventoryItem('fishingrod', 1)
        end

    elseif bait == "fish" then
        if rnd <= 5 then
            TriggerClientEvent('fishing:setbait', src, "none")
            TriggerClientEvent('esx:showNotification', src, "~r~Your bait fell off.")
        else
            local fishType = math.random(1, 5)
            local item = ({'anchovy', 'trout', 'haddock', 'salmon', 'grouper'})[fishType]

            if ox_inventory:CanCarryItem(src, item, quantity) then
                xPlayer.addInventoryItem(item, quantity)
                TriggerClientEvent('fish:message', src, ("~g~You caught %s %s!"):format(quantity, item))
            else
                TriggerClientEvent('esx:showNotification', src, "~r~Not enough inventory space!")
            end
        end

    elseif bait == "none" then
        TriggerClientEvent('esx:showNotification', src, "~y~You are fishing without bait!")
    end
end)
