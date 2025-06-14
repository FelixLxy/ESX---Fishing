local ox_inventory = exports.ox_inventory
print("Fishing by FelixL has started :)")

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local fishingPlayers = {}

RegisterNetEvent('fishing:start')
AddEventHandler('fishing:start', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end

	if xPlayer.getInventoryItem('fishingrod').count <= 0 then
		TriggerClientEvent('esx:showNotification', src, "~r~You don't have a fishing rod.")
		return
	end

	local ped = GetPlayerPed(src)
	local pos = GetEntityCoords(ped)
	if IsPedInAnyVehicle(ped) or not IsEntityInWater(ped) then
		TriggerClientEvent('esx:showNotification', src, "~r~You can only fish in water and not from a vehicle.")
		return
	end

	if pos.y < -4000 or pos.y > 8200 or pos.x < -3500 or pos.x > 4200 then
		fishingPlayers[src] = true
		TriggerClientEvent('fishing:startClient', src)
	else
		TriggerClientEvent('esx:showNotification', src, "~r~You are too close to the shore.")
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

ESX.RegisterUsableItem('fishingrod', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end


    if not fishingPlayers[source] then
        fishingPlayers[source] = true
        TriggerClientEvent('fishing:startClient', source) -- Nur wenn Server es erlaubt!
    else
        print(('Player %s tried to start fishing while already fishing'):format(source))
    end
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

RegisterNetEvent('fishing:catch')
AddEventHandler('fishing:catch', function(bait)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not fishingPlayers[src] then
        print(('[Exploit attempt] Player %s called fishing:catch without fishing:start'):format(src))
        DropPlayer(src, "Fishing exploit detected. You have been kicked.")
        return
    end

    if not xPlayer then return end

    local quantity = math.random(1, 3)
    local rnd = math.random(1, 100)
    local fishTypes = { 'anchovy', 'trout', 'haddock', 'salmon', 'grouper' }

if bait == "turtle" then
    if rnd <= 5 then
        TriggerClientEvent('fishing:setbait', src, "none")
        TriggerClientEvent('esx:showNotification', src, "~r~Your bait fell off.")
    elseif rnd < 98.5 then
        local caughtFish = fishTypes[math.random(#fishTypes)]
        if ox_inventory:CanCarryItem(src, caughtFish, quantity) then
            xPlayer.addInventoryItem(caughtFish, quantity)
            TriggerClientEvent('fish:message', src, "~g~You caught " .. quantity .. " " .. caughtFish .. "!")
        else
            TriggerClientEvent('esx:showNotification', src, "~r~Not enough inventory space!")
        end
    else
        TriggerClientEvent('fishing:setbait', src, "none")
        TriggerClientEvent('fish:message', src, "~r~The fish was too strong and broke your rod.")
        TriggerClientEvent('fishing:break', src)
        xPlayer.removeInventoryItem('fishingrod', 1)
        TriggerEvent('fishing:stop', src)
    end
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
