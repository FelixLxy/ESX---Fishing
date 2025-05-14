local fishing, isBusy = false, false
local bait = 'none'

debugPrint = function(msg, type)
	if Config.Debug then 
		if type == 'info' then 
			print('['..GetCurrentResourceName()..'] [^5INFO^7] '..tostring(msg))
		elseif type == 'error' then 
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

			if IsPedInAnyVehicle(playerPed) or IsControlJustPressed(0, 252) or IsEntityDead(playerPed) or IsEntityInWater(playerPed) then
				debugPrint('Fishing activity got canceled.', 'info')
				fishing = false
				TriggerEvent('fishing:break')
				lib.notify({
					description = 'You reeled in your fishing rod', 
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
		isBusy = true
		local success
		if bait == 'shark' then 
			success = lib.skillCheck({'easy','hard','medium','medium','hard'})
		else
			success = lib.skillCheck({'easy','medium'})
		end 

		if success then
			debugPrint('Skillcheck is successful and script is not busy.', 'info')
			TriggerServerEvent('fishing:catch', bait)
		else
			lib.cancelSkillCheck()
			debugPrint('Skillcheck is failed or script is busy.', 'error')
			lib.notify({
				description = 'The fish got away', 
				type = 'error',
				showDuration = true,
				position = 'top',
			})
		end 
		isBusy = false
	end
end

RegisterNetEvent('fishing:break', function()
	fishing = false
	if lib.skillCheckActive() then 
		lib.cancelSkillCheck()
		debugPrint('Canceled skill check!', 'info')
	end
	StopFishingAnimation()
	TriggerServerEvent('fishing:stop')
end)

RegisterNetEvent('fishing:setbait', function(bool)
	bait = bool
	debugPrint('Bait enabled: '..tostring(bool), 'info')
end)

RegisterNetEvent('fishing:startClient', function()
	if fishing then
		lib.notify({ description = 'You are already fishing', type = 'error', position = 'top' })
		return
	end

	StartFishingAnimation()
	fishing = true
	debugPrint('Fishing started (client side confirmed)', 'info')
end)

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
	while not HasAnimDictLoaded(fishingAnimation.dict) do Wait(0) end
	TaskPlayAnim(PlayerPedId(), fishingAnimation.dict, fishingAnimation.anim, 8.0, -8.0, -1, fishingAnimation.emoteLoop, 0, false, false, false)
	local boneIndex = GetPedBoneIndex(PlayerPedId(), fishingAnimation.propBone)
	local coords = GetWorldPositionOfEntityBone(PlayerPedId(), boneIndex)
	fishingAnimation.propEntity = CreateObject(GetHashKey(fishingAnimation.propModel), coords.x, coords.y, coords.z, true, true, true)
	if DoesEntityExist(fishingAnimation.propEntity) then
		AttachEntityToEntity(fishingAnimation.propEntity, PlayerPedId(), boneIndex, fishingAnimation.propPlacement.x, fishingAnimation.propPlacement.y, fishingAnimation.propPlacement.z, fishingAnimation.propPlacement.xRot, fishingAnimation.propPlacement.yRot, fishingAnimation.propPlacement.zRot, true, true, false, true, 1, true)
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

RegisterNetEvent('fish:message', function(message)
	ESX.ShowNotification(message)
end)
