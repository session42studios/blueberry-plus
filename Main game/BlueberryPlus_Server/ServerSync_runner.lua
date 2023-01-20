--[[

    ____  __           __                                
   / __ )/ /_  _____  / /_  ___  ____________  __     __ 
  / __  / / / / / _ \/ __ \/ _ \/ ___/ ___/ / / /  __/ /_
 / /_/ / / /_/ /  __/ /_/ /  __/ /  / /  / /_/ /  /_  __/
/_____/_/\__,_/\___/_.___/\___/_/  /_/   \__, /    /_/   
                                        /____/           
                                        
                  𝗛𝗼𝘀𝘁 𝗴𝗮𝗺𝗲 | ServerSync                    


]]--
local runner = {}
--// Get services & dependencies \\--
local ServerScriptService = game:GetService('ServerScriptService')
local MessagingService = game:GetService('MessagingService')
local Players = game:GetService('Players')
local DataStoreService = game:GetService('DataStoreService')
local RunService = game:GetService('RunService')
local TeleportService = game:GetService('TeleportService')
local Settings = require(ServerScriptService:WaitForChild('BlueberryPlus'):WaitForChild('Settings'))
local ReservedPlaceId = Settings["Reserved place ID"] or game.PlaceId
local DataStoreKey = Settings["DataStore Key"]

--// Get DataStores \\--
local BlueberryPlus_Warnings_DataStore = DataStoreService:GetDataStore("BlueberryPlus_Warnings_DataStore")
local BlueberryPlus_TempBans_DataStore = DataStoreService:GetDataStore("BlueberryPlus_TempBans_DataStore")
local BlueberryPlus_PermBans_DataStore = DataStoreService:GetDataStore("BlueberryPlus_PermBans_DataStore")

--// Functions \\--
function runner:PostWarn(playerID)
	local Success, Error = pcall(function()
		local data = {"warning", playerID}
		MessagingService:PublishAsync("BlueberryPlus_ServerSync", data)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post new warning globally. ", Error)
		return 500
	else
		return 200
	end
end

function runner:PostTempBan(playerID)
	local Success, Error = pcall(function()
		local data = {"tempban", playerID}
		MessagingService:PublishAsync("BlueberryPlus_ServerSync", data)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post new temp-ban globally. ", Error)
		return 500
	else
		return 200
	end
end

function runner:PostPermBan(playerID)
	local Success, Error = pcall(function()
		local data = {"permban", playerID}
		MessagingService:PublishAsync("BlueberryPlus_ServerSync", data)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post new perm-ban globally. ", Error)
		return 500
	else
		return 200
	end
end

--// Events \\--
MessagingService:SubscribeAsync("BlueberryPlus_ServerSync", function(message)
	if not message.Data or not message.Data[1] or not message.Data[2] then
		warn("[500] Bluberry+: cross-server sync. failed. Data package was invalid.")
		return 500
	end
	local playerID = tonumber(message.Data[2])
	local action = message.Data[1]
	local Player = Players:GetPlayerByUserId(playerID)
	if Player then
		local SavedData = nil
		if action == "warning" then
			--// Warning \\--
			local Success, Error = pcall(function()
				SavedData = BlueberryPlus_Warnings_DataStore:GetAsync(playerID..DataStoreKey)
			end)
			if not Success then
				warn("[500] Blueberry+: Could not get data from DataStore. ", Error)
				return 500
			end
			if not SavedData then
				print("[!] Blueberry+: cross-server moderation request received, but DataStore doesn't contain any data. Ignoring.")
				return 200
			end
			if RunService:IsStudio() then
				print("[!] Blueberry+: exception when moderating "..tostring(playerID)..". Cannot reserve servers while running in Studio.")
			else
				local Player = Players:GetPlayerByUserId(playerID)
				local Success_, Error_ = pcall(function()
					local ReservedServerCode = TeleportService:ReserveServer(ReservedPlaceId)
					if Player then
						local Success, Error = pcall(function()
							TeleportService:TeleportToPrivateServer(ReservedPlaceId, ReservedServerCode, {Player}, nil, nil)
						end)
						if not Success then
							Player:Kick("Blueberry teleportation failed. Contact the developer for details. ", Error)
							warn("[500] Blueberry+: teleportation to reserved place failed. ", Error)
						end
					end
				end)
				if not Success_ then
					warn("[500] Blueberry+: could not teleport player to reserved server. "..Error_)
				else
					print("[>] Blueberry+: player cross-server moderation teleport successful. UserID: ", playerID)	
				end
			end			
		elseif action == "tempban" then
			--// Temp-ban \\--
			local Success, Error = pcall(function()
				SavedData = BlueberryPlus_TempBans_DataStore:GetAsync(playerID..DataStoreKey)
			end)
			if not Success then
				warn("[500] Blueberry+: Could not get data from DataStore. ", Error)
				return 500
			end
			if not SavedData then
				print("[!] Blueberry+: cross-server moderation request received, but DataStore doesn't contain any data. Ignoring.")
				return 200
			end
			if RunService:IsStudio() then
				print("[!] Blueberry+: exception when moderating "..tostring(playerID)..". Cannot reserve servers while running in Studio.")
			else
				local Player = Players:GetPlayerByUserId(playerID)
				local Success_, Error_ = pcall(function()
					local ReservedServerCode = TeleportService:ReserveServer(ReservedPlaceId)
					if Player then
						local Success, Error = pcall(function()
							TeleportService:TeleportToPrivateServer(ReservedPlaceId, ReservedServerCode, {Player}, nil, nil)
						end)
						if not Success then
							Player:Kick("Blueberry teleportation failed. Contact the developer for details. ", Error)
							warn("[500] Blueberry+: teleportation to reserved place failed. ", Error)
						end
					end
				end)
				if not Success_ then
					warn("[500] Blueberry+: could not teleport player to reserved server. "..Error_)
				else
					print("[>] Blueberry+: player cross-server moderation teleport successful. UserID: ", playerID)	
				end
			end
		elseif action == "permban" then
			--// Perm-ban \\--
			local Success, Error = pcall(function()
				SavedData = BlueberryPlus_PermBans_DataStore:GetAsync(playerID..DataStoreKey)
			end)
			if not Success then
				warn("[500] Blueberry+: Could not get data from DataStore. ", Error)
				return 500
			end
			if not SavedData then
				print("[!] Blueberry+: cross-server moderation request received, but DataStore doesn't contain any data. Ignoring.")
				return 200
			end
			if RunService:IsStudio() then
				print("[!] Blueberry+: exception when moderating "..tostring(playerID)..". Cannot reserve servers while running in Studio.")
			else
				local Player = Players:GetPlayerByUserId(playerID)
				local Success_, Error_ = pcall(function()
					local ReservedServerCode = TeleportService:ReserveServer(ReservedPlaceId)
					if Player then
						local Success, Error = pcall(function()
							TeleportService:TeleportToPrivateServer(ReservedPlaceId, ReservedServerCode, {Player}, nil, nil)
						end)
						if not Success then
							Player:Kick("Blueberry teleportation failed. Contact the developer for details. ", Error)
							warn("[500] Blueberry+: teleportation to reserved place failed. ", Error)
						end
					end
				end)
				if not Success_ then
					warn("[500] Blueberry+: could not teleport player to reserved server. "..Error_)
				else
					print("[>] Blueberry+: player cross-server moderation teleport successful. UserID: ", playerID)	
				end
			end
		else
			warn("[404] Blueberry+: cross-server action not recognized. Action: ", action)
		end
	end
end)
return runner
