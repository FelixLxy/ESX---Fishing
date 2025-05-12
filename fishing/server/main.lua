local ox_inventory = exports.ox_inventory -- ox_inventory f�r Inventarhandling


print("Fishen von FelixL wurde gestartet :)")

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterUsableItem('turtlebait', function(source)
	local _source = source
	xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('fishingrod').count > 0 then
		TriggerClientEvent('fishing:setbait', _source, "turtle")
		xPlayer.removeInventoryItem('turtlebait', 1)
		TriggerClientEvent('fish:message', _source, "~g~Du hast einen Schildkrötenköder an deiner Angel angebracht!")
	else
		TriggerClientEvent('fish:message', _source, "~r~Du besitzt keine Angel.")
	end
end)

ESX.RegisterUsableItem('fishbait', function(source)

	local _source = source
	xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('fishingrod').count > 0 then
		TriggerClientEvent('fishing:setbait', _source, "fish")
		
		xPlayer.removeInventoryItem('fishbait', 1)
		TriggerClientEvent('fish:message', _source, "~g~Du hast einen Fischköder an deiner Angel angebracht!")
		
	else
		TriggerClientEvent('fish:message', _source, "~r~Du besitzt keine Angel.")
	end
	
end)

ESX.RegisterUsableItem('turtle', function(source)

	local _source = source
	xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('fishingrod').count > 0 then
		TriggerClientEvent('fishing:setbait', _source, "shark")
		
		xPlayer.removeInventoryItem('turtle', 1)
		TriggerClientEvent('fish:message', _source, "~g~Du hast Schildkrötenfleisch an deiner Angel befestigt!")
	else
		TriggerClientEvent('fish:message', _source, "~r~Du besitzt keine Angel.")
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
    local rnd = math.random(1, 100)  -- Zufallswert zwischen 1 und 100
    xPlayer = ESX.GetPlayerFromId(_source)

    -- �berpr�fen, ob der Spieler genug Platz f�r die Fische im Inventar hat
    local canCarry = ox_inventory:CanCarryItem(xPlayer.source, 'fish', quantity)
    if not canCarry then
        TriggerClientEvent('esx:showNotification', _source, '~r~Du hast nicht genug Platz in deinem Inventar!')
        return
    end

    -- Angeln mit Schildkr�tenk�der
    if bait == "turtle" then
        if rnd <= 5 then  -- 5% Wahrscheinlichkeit, dass der K�der besch�digt wird
            TriggerClientEvent('fishing:setbait', _source, "none")
            TriggerClientEvent('esx:showNotification', _source, "~r~Dein K�der wurde besch�digt und ist abgefallen.")
        elseif rnd > 5 and rnd < 98.5 then  -- Normaler Fischfang, kein Zerbrechen der Angel
            TriggerClientEvent('fishing:message', _source, "~g~Du hast " .. quantity .. " Fische gefangen!")
            xPlayer.addInventoryItem('fish', quantity)
        elseif rnd >= 98.5 then  -- 1.5% Wahrscheinlichkeit f�r "Angel zerbrochen"
            TriggerClientEvent('fishing:setbait', _source, "none")
            TriggerClientEvent('fishing:message', _source, "~r~Der Fisch war zu gro� und hat deine Angel zerbrochen.")
            TriggerClientEvent('fishing:break', _source)
            xPlayer.removeInventoryItem('fishingrod', 1)
        end
    -- Angeln mit Fischk�der
    elseif bait == "fish" then
        if rnd <= 5 then  -- 5% Wahrscheinlichkeit, dass der K�der besch�digt wird
            TriggerClientEvent('fishing:setbait', _source, "none")
            TriggerClientEvent('esx:showNotification', _source, "~r~Dein K�der wurde besch�digt und ist abgefallen.")
        else
            local fishType = math.random(1, 5)
            if fishType == 1 then
                TriggerClientEvent('fishing:message', _source, "~g~Du hast " .. quantity .. " Sardinen gefangen!")
                xPlayer.addInventoryItem('anchovy', quantity)
            elseif fishType == 2 then
                TriggerClientEvent('fishing:message', _source, "~g~Du hast " .. quantity .. " Forellen gefangen!")
                xPlayer.addInventoryItem('trout', quantity)
            elseif fishType == 3 then
                TriggerClientEvent('fishing:message', _source, "~g~Du hast " .. quantity .. " Kabeljau gefangen!")
                xPlayer.addInventoryItem('haddock', quantity)
            elseif fishType == 4 then
                TriggerClientEvent('fishing:message', _source, "~g~Du hast " .. quantity .. " Lachse gefangen!")
                xPlayer.addInventoryItem('salmon', quantity)
            elseif fishType == 5 then
                TriggerClientEvent('fishing:message', _source, "~g~Du hast " .. quantity .. " Zackenbarsche gefangen!")
                xPlayer.addInventoryItem('grouper', quantity)
            end
        end
    -- Angeln ohne K�der
    elseif bait == "none" then
        -- Wenn der Bait "none" ist, passiert nichts.
        TriggerClientEvent('fishing:message', _source, "~y~Du fischst momentan ohne einen K�der.")
        TriggerClientEvent('esx:showNotification', _source, "~y~Du fischst momentan ohne K�der!")
    end
end)
