local ox_inventory = exports.ox_inventory -- ox_inventory for inventory handling

print("Fishing by FelixL has started :)")

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('turtlebait', function(source)
	local _source = source
	xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('fishingrod').count > 0 then
		TriggerClientEvent('fishing:setbait', _source, "turtle")
		xPlayer.removeInventoryItem('turtlebait', 1)
		TriggerClientEvent('fish:message', _source, "~g~You attached a turtle bait to your fishing rod!")
	else
		TriggerClientEvent('fish:message', _source, "~r~You don't have a fishing rod.")
	end
end)

ESX.RegisterUsableItem('fishbait', function(source)
	local _source = source
	xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('fishingrod').count > 0 then
		TriggerClientEvent('fishing:setbait', _source, "fish")
		xPlayer.removeInventoryItem('fishbait', 1)
		TriggerClientEvent('fish:message', _source, "~g~You attached a fish bait to your fishing rod!")
	else
		TriggerClientEvent('fish:message', _source, "~r~You don't have a fishing rod.")
	end
end)

ESX.RegisterUsableItem('turtle', function(source)
	local _source = source
	xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('fishingrod').count > 0 then
		TriggerClientEvent('fishing:setbait', _source, "shark")
		xPlayer.removeInventoryItem('turtle', 1)
		TriggerClientEvent('fish:message', _source, "~g~You attached turtle meat to your fishing rod!")
	else
		TriggerClientEvent('fish:message', _source, "~r~You don't have a fishing rod.")
	end
end)

ESX.RegisterUsableItem('fishingrod', function(source)
	local _source = source
	TriggerClientEvent('fishing:fishstart', _source)
end)

RegisterNetEvent('fishing:catch')
AddEventHandler('fishing:catch', function(bait)
    _source = source
    local quantity = math.random(1, 3)
    local rnd = math.random(1, 100)
    xPlayer = ESX.GetPlayerFromId(_source)

    local canCarry = ox_inventory:CanCarryItem(xPlayer.source, 'fish', quantity)
    if not canCarry then
        TriggerClientEvent('esx:showNotification', _source, '~r~You don\'t have enough space in your inventory!')
        return
    end

    if bait == "turtle" then
        if rnd <= 5 then
            TriggerClientEvent('fishing:setbait', _source, "none")
            TriggerClientEvent('esx:showNotification', _source, "~r~Your bait was damaged and fell off.")
        elseif rnd > 5 and rnd < 98.5 then
            TriggerClientEvent('fishing:message', _source, "~g~You caught " .. quantity .. " fish!")
            xPlayer.addInventoryItem('fish', quantity)
        elseif rnd >= 98.5 then
            TriggerClientEvent('fishing:setbait', _source, "none")
            TriggerClientEvent('fishing:message', _source, "~r~The fish was too big and broke your fishing rod.")
            TriggerClientEvent('fishing:break', _source)
            xPlayer.removeInventoryItem('fishingrod', 1)
        end
    elseif bait == "fish" then
        if rnd <= 5 then
            TriggerClientEvent('fishing:setbait', _source, "none")
            TriggerClientEvent('esx:showNotification', _source, "~r~Your bait was damaged and fell off.")
        else
            local fishType = math.random(1, 5)
            if fishType == 1 then
                TriggerClientEvent('fishing:message', _source, "~g~You caught " .. quantity .. " anchovies!")
                xPlayer.addInventoryItem('anchovy', quantity)
            elseif fishType == 2 then
                TriggerClientEvent('fishing:message', _source, "~g~You caught " .. quantity .. " trouts!")
                xPlayer.addInventoryItem('trout', quantity)
            elseif fishType == 3 then
                TriggerClientEvent('fishing:message', _source, "~g~You caught " .. quantity .. " haddocks!")
                xPlayer.addInventoryItem('haddock', quantity)
            elseif fishType == 4 then
                TriggerClientEvent('fishing:message', _source, "~g~You caught " .. quantity .. " salmons!")
                xPlayer.addInventoryItem('salmon', quantity)
            elseif fishType == 5 then
                TriggerClientEvent('fishing:message', _source, "~g~You caught " .. quantity .. " groupers!")
                xPlayer.addInventoryItem('grouper', quantity)
            end
        end
    elseif bait == "none" then
        TriggerClientEvent('fishing:message', _source, "~y~You're currently fishing without bait.")
        TriggerClientEvent('esx:showNotification', _source, "~y~You're currently fishing without bait!")
    end
end)
