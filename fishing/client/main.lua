-----------------------------------------------------
-----------------------[FISHING]---------------------
-----------------------------------------------------
local fishing, isBusy = false, false
local bait = 'none'

debugPrint = function(msg, type)
	if Config.Debug then 
		if 'info' then 
			print('['..GetCurrentResourceName()..'] [^5INFO^7] '..tostring(msg))
		elseif 'error' then 
			print('['..GetCurrentResourceName()..'] [^1ERROR^7] '..tostring(msg))
		else 
			print('['..GetCurrentResourceName()..'] [DEBUG] '..tostring(msg))
		end
	end
end

CreateThread(function()
	while true do
		local waiter = math.random(Config.FishTime.a , Config.FishTime.b)
		Wait(waiter)

		if fishing then
			debugPrint('Used following bait for this catch: '..tostring(bait), 'info')
			startFishingSkill()
		end
	end
end)

CreateThread(function()
	while true do
		if fishing then 	
			Wait(0)	
			local playerPed = PlayerPedId()
		
			if IsPedInAnyVehicle(playerPed) or IsControlJustPressed(0, 252) then
				debugPrint('Fishing activity got canceled.', 'info')
				fishing = false
				TriggerEvent('fishing:break')
				lib.notify({
					description = 'Du hast deine Angelrute eingeholt', 
					type = 'inform',
					
Duration = true,
    				position = 'top',
				})
			end

			if IsEntityDead(playerPed) or IsEntityInWater(playerPed) then
				fishing = false
				TriggerEvent('fishing:break')
				lib.notify({
					description = 'Du hast deine Angelrute eingeholt', 
					type = 'inform',
					showDuration = true,
    				position = 'top',
				})
			end
		else 
			Wait(1500)
		end
	end 
end)

startFishingSkill = function()
	if not isBusy then 
		debugPrint('Starting SkillCheck', 'info')
		if bait == 'shark' then 
			success = lib.skillCheck({'easy','hard','medium','medium','hard'})
		else
			success = lib.skillCheck({'easy','medium'})
		end 

		if success then
			debugPrint('Skillcheck is successful and script is not busy.', 'info')
			TriggerServerEvent('fishing:catch', bait)
			isBusy = false
		else
			lib.cancelSkillCheck()
			debugPrint('Skillcheck is failed or script is busy.', 'error')
			lib.notify({
				description = 'Der Fisch konnte sich losreißen', 
				type = 'error',
				showDuration = true,
				position = 'top',
			})
			isBusy = false
		end 
	end
end

RegisterNetEvent('fishing:break', function()
	fishing = false
	if lib.skillCheckActive() then 
		lib.cancelSkillCheck()
		debugPrint('Canceled skill check!', 'info')
	end

	StopFishingAnimation()
end)

RegisterNetEvent('fishing:setbait', function(bool)
	bait = bool
	debugPrint('Bait enabled: '..tostring(bool), 'info')
end)

RegisterNetEvent('fishing:fishstart', function()
	local playerPed = PlayerPedId()
	local playerPos = GetEntityCoords(playerPed)
	debugPrint('Started fishing at '..playerPos, 'info')

	if IsPedInAnyVehicle(playerPed) then
		lib.notify({description = 'Das fischen im Fahrzeug ist nicht möglich', position = 'top', type = 'error'})
	else
		if playerPos.y >= 8200 or playerPos.y <= -4000 or playerPos.x <= -3500 or playerPos.x >= 4200 then

			if fishing then 
				lib.notify({description = 'Du hast deine Angel bereits ausgeworfen', position = 'top', type = 'error'})
				return
			end

			lib.notify({description = 'Du hast deine Angel ausgeworfen', position = 'top', type = 'success'})

			StartFishingAnimation()
			
			fishing = true
			debugPrint('set fishing to: '..tostring(fishing), 'info')
		else
			lib.notify({description = 'Du bist zu nah an der Küste', position = 'top', type = 'error'})
		end
	end
end, false)

local fishingAnimation = {
    dict = "amb@world_human_stand_fishing@idle_a",
    anim = "idle_a",
    scenario = "Fishing 1",
    propModel = 'prop_fishing_rod_01',
    propBone = 60309,
    propPlacement = {x = 0.0, y = 0.0, z = 0.0, xRot = 0.0, yRot = 0.0, zRot = 0.0},
    emoteLoop = true,
    emoteMoving = false,
    propEntity = nil
}

function StartFishingAnimation()
    RequestAnimDict(fishingAnimation.dict)
    while not HasAnimDictLoaded(fishingAnimation.dict) do
        Wait(0)
    end

	debugPrint('starting animation', 'info')
    TaskPlayAnim(PlayerPedId(), fishingAnimation.dict, fishingAnimation.anim, 8.0, -8.0, -1, fishingAnimation.emoteLoop, 0, false, false, false)
    
    local playerPed = PlayerPedId()
    local boneIndex = GetPedBoneIndex(playerPed, fishingAnimation.propBone)
    
    if boneIndex ~= -1 then
        local boneCoords = GetWorldPositionOfEntityBone(playerPed, boneIndex)
        local propCoords = vector3(boneCoords.x, boneCoords.y, boneCoords.z)
        
        fishingAnimation.propEntity = CreateObject(GetHashKey(fishingAnimation.propModel), propCoords.x, propCoords.y, propCoords.z, true, true, true)
        
        if DoesEntityExist(fishingAnimation.propEntity) then
            AttachEntityToEntity(fishingAnimation.propEntity, playerPed, boneIndex, fishingAnimation.propPlacement.x, fishingAnimation.propPlacement.y, fishingAnimation.propPlacement.z, fishingAnimation.propPlacement.xRot, fishingAnimation.propPlacement.yRot, fishingAnimation.propPlacement.zRot, true, true, false, true, 1, true)
        end
    end
end

function StopFishingAnimation()
    if DoesEntityExist(fishingAnimation.propEntity) then
        DeleteEntity(fishingAnimation.propEntity)
        fishingAnimation.propEntity = nil
    end

    ClearPedTasks(PlayerPedId())
    RemoveAnimDict(fishingAnimation.dict)
end


RegisterNetEvent('fishing:spawnPed', function()
	RequestModel(GetHashKey("A_C_SharkTiger"))
		while (not HasModelLoaded(GetHashKey( "A_C_SharkTiger"))) do
			Wait(20)
		end
		
	local pos = GetEntityCoords(PlayerPedId())
	local ped = CreatePed(29, 0x06C3F072, pos.x, pos.y, pos.z, 90.0, true, false)
	SetEntityHealth(ped, 0)
end)

RegisterNetEvent('fish:message')
AddEventHandler('fish:message', function(message)
	ESX.ShowNotification(message)
end)