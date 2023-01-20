--[[

    ____  __           __                                
   / __ )/ /_  _____  / /_  ___  ____________  __     __ 
  / __  / / / / / _ \/ __ \/ _ \/ ___/ ___/ / / /  __/ /_
 / /_/ / / /_/ /  __/ /_/ /  __/ /  / /  / /_/ /  /_  __/
/_____/_/\__,_/\___/_.___/\___/_/  /_/   \__, /    /_/   
                                        /____/           
                                        
                    𝗛𝗼𝘀𝘁 𝗴𝗮𝗺𝗲 | API runner                    


]]--
local runner = {}
--// Get services & dependencies \\--
local DataStoreService = game:GetService('DataStoreService')
local ServerScriptService = game:GetService('ServerScriptService')
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TeleportService = game:GetService('TeleportService')
local Players = game:GetService('Players')
local Settings = require(ServerScriptService:WaitForChild('BlueberryPlus'):WaitForChild('Settings'))
local ServerSync_runner = require(script.Parent.ServerSync_runner)
local Webhook_runner = require(script.Parent:WaitForChild('Webhook_runner'))
local DataStoreKey = Settings["DataStore Key"]
local ReservedPlaceId = Settings["Reserved place ID"] or game.PlaceId
local ServerLocked = {false, 0, nil}

--// Get DataStores \\--
local BlueberryPlus_Warnings_DataStore = DataStoreService:GetDataStore("BlueberryPlus_Warnings_DataStore")
local BlueberryPlus_TempBans_DataStore = DataStoreService:GetDataStore("BlueberryPlus_TempBans_DataStore")
local BlueberryPlus_PermBans_DataStore = DataStoreService:GetDataStore("BlueberryPlus_PermBans_DataStore")
local BlueberryPlus_Slocks_DataStore = DataStoreService:GetDataStore("BlueberryPlus_Slocks_DataStore")

--// Functions \\--
local function Reason(reason, action)
	if action == "warn" then
		if not reason then
			return Settings["Default warning reason"]
		else
			return reason
		end
	elseif action == "tempban" then
		if not reason then
			return Settings["Default temporary ban reason"]
		else
			return reason
		end
	elseif action == "permban" then
		if not reason then
			return Settings["Default permanent ban reason"]
		else
			return reason
		end
	elseif action == "kick" then
		if not reason then
			return Settings["Default kick reason"]
		else
			return reason
		end
	elseif action == "slock" then
		if not reason then
			return Settings["Defaultslock reason"]
		else
			return reason
		end
	elseif action == "remove" then
		if not reason then
			return "Not specified"
		else
			return reason
		end
	else
		if not reason then
			return "No reason found"
		else
			return reason
		end
	end
end
local function Moderator(moderator)
	if not moderator then
		return "None"
	else
		return moderator
	end
end

--// Add new warning \\--
function runner:addWarning(userID, reason, moderator)
	if not userID or tonumber(userID) == nil then
		warn("[404] Blueberry+: couldn't find the target user ID while attempting to create a warning.")
		return 404
	end
	local Data = {['Reason'] = Reason(reason, "warn"), ['Moderator'] = Moderator(moderator), ['Type'] = "warn"}
	local Success, Error = pcall(function()
		BlueberryPlus_Warnings_DataStore:SetAsync(userID..DataStoreKey, Data)
	end)
	if RunService:IsStudio() then
		print("[!] Blueberry+: exception when moderating "..tostring(userID)..". Cannot reserve servers while running in Studio.")
		return 403
	else
		local Player = Players:GetPlayerByUserId(userID)
		local Success_, Error_ = pcall(function()
			local ReservedServerCode = TeleportService:ReserveServer(ReservedPlaceId)
			if Player then
				local Success, Error = pcall(function()
					TeleportService:TeleportToPrivateServer(ReservedPlaceId, ReservedServerCode, {Player}, nil, Data)
				end)	
				if not Success then
					Player:Kick("Blueberry teleportation failed. Contact the developer for details. ", Error)
					warn("[500] Blueberry+: teleportation to reserved place failed. ", Error)
				end
			else
				ServerSync_runner:PostWarn(tonumber(userID))
			end
		end)
		if not Success_ then
			warn("[500] Blueberry+: could not teleport player to reserved server. "..Error_)
		end
	end
	if not Success then
		warn("[500] Blueberry+: Could not upload new data to DataStore. ", Error)
		return 500
	else
		print("[>] Blueberry+: new warning added for "..userID.." by "..Moderator(moderator).." with reason "..Reason(reason, "warn")..".")
		if Settings["Enable webhook logging"] then Webhook_runner:logNewWarning(tostring(userID), Reason(reason, "warn"), tostring(Moderator(moderator))) end
		return 200	
	end
end

--// Remove warning \\--
function runner:removeWarning(userID, reason, moderator)
	if not userID or tonumber(userID) == nil then
		warn("[404] Blueberry+: couldn't find the target user ID while attempting to remove a warning.")
		return 404
	end
	local SavedData = nil
	local Success, Error = pcall(function()
		SavedData = BlueberryPlus_Warnings_DataStore:GetAsync(userID..DataStoreKey)
	end)
	if not Success then
		warn("[500] Blueberry+: Could not check data from DataStore. ", Error)
		return 500
	end
	if not SavedData then
		print("[>] Blueberry+: warning removal request for "..userID.." by "..Moderator(moderator).." with reason "..Reason(reason, "remove")..". But no data exists.")
		return 208	
	end
	local Success, Error = pcall(function()
		BlueberryPlus_Warnings_DataStore:RemoveAsync(userID..DataStoreKey)
	end)
	if not Success then
		warn("[500] Blueberry+: Could not remove data from DataStore. ", Error)
		return 500
	else
		print("[>] Blueberry+: warning removed for "..userID.." by "..Moderator(moderator).." with reason "..Reason(reason, "remove")..".")
		if Settings["Enable webhook logging"] then Webhook_runner:logRemovingWarning(tostring(userID), Reason(reason, "remove"), tostring(Moderator(moderator))) end
		return 200
	end
end

--// Add new temp-ban \\--
function runner:addTempBan(userID, duration, reason, moderator)
	if not userID or tonumber(userID) == nil then
		warn("[404] Blueberry+: couldn't find the target user ID while attempting to create a temp-ban.")
		return 404
	end
	if not duration or tonumber(duration) == nil then
		warn("[404] Blueberry+: couldn't find the duration while attempting to create a temp-ban.")
		return 404
	end
	local Data = {['Reason'] = Reason(reason, "tempban"), ['Moderator'] = Moderator(moderator), ['Duration'] = tonumber(duration), ['Start'] = os.time(), ['End'] = (os.time() + tonumber(duration)*60), ['Type'] = "tempban"}
	local Success, Error = pcall(function()
		BlueberryPlus_TempBans_DataStore:SetAsync(userID..DataStoreKey, Data)
	end)
	if RunService:IsStudio() then
		print("[!] Blueberry+: exception when moderating "..tostring(userID)..". Cannot reserve servers while running in Studio.")
		return 403	
	else
		local Player = Players:GetPlayerByUserId(userID)
		local Success_, Error_ = pcall(function()
			local ReservedServerCode = TeleportService:ReserveServer(ReservedPlaceId)
			if Player then
				local Success, Error = pcall(function()
					TeleportService:TeleportToPrivateServer(ReservedPlaceId, ReservedServerCode, {Player}, nil, Data)
				end)
				if not Success then
					Player:Kick("Blueberry teleportation failed. Contact the developer for details. ", Error)
					warn("[500] Blueberry+: teleportation to reserved place failed. ", Error)
				end
			else
				ServerSync_runner:PostTempBan(tonumber(userID))
			end
		end)
		if not Success_ then
			warn("[500] Blueberry+: could not teleport player to reserved server. "..Error_)
		end
	end
	if not Success then
		warn("[500] Blueberry+: Could not upload new data to DataStore. ", Error)
		return 500
	else
		print("[>] Blueberry+: new temp-ban added for "..userID.." by "..Moderator(moderator).." with reason "..Reason(reason, "tempban").." for "..tostring(duration).." minute(s).")
		if Settings["Enable webhook logging"] then Webhook_runner:logNewTempBan(tostring(userID),  Reason(reason, "tempban"), tostring(duration), tostring(Moderator(moderator))) end
		return 200	
	end
end

--// Remove temp-ban \\--
function runner:removeTempBan(userID, reason, moderator)
	if not userID or tonumber(userID) == nil then
		warn("[404] Blueberry+: couldn't find the target user ID while attempting to remove a temp-ban.")
		return 404
	end
	local SavedData = nil
	local Success, Error = pcall(function()
		SavedData = BlueberryPlus_TempBans_DataStore:GetAsync(userID..DataStoreKey)
	end)
	if not Success then
		warn("[500] Blueberry+: Could not check data from DataStore. ", Error)
		return 500
	end
	if not SavedData then
		print("[>] Blueberry+: temp-ban removal request for "..userID.." by "..Moderator(moderator).." with reason "..Reason(reason, "remove")..". But no data exists.")
		return 208	
	end
	local Success, Error = pcall(function()
		BlueberryPlus_TempBans_DataStore:RemoveAsync(userID..DataStoreKey)
	end)
	if not Success then
		warn("[500] Blueberry+: Could not remove data from DataStore. ", Error)
		return 500
	else
		print("[>] Blueberry+: temp-ban removed for "..userID.." by "..Moderator(moderator).." with reason "..Reason(reason, "remove")..".")
		if Settings["Enable webhook logging"] then Webhook_runner:logRemovingTempBan(tostring(userID), Reason(reason, "remove"), tostring(Moderator(moderator))) end
		return 200
	end
end

--// Add new perm-ban \\--
function runner:addPermBan(userID, reason, moderator)
	if not userID or tonumber(userID) == nil then
		warn("[404] Blueberry+: couldn't find the target user ID while attempting to create a perm-ban.")
		return 404
	end
	local Data = {['Reason'] = Reason(reason, "permban"), ['Moderator'] = Moderator(moderator), ['Type'] = "permban"}
	local Success, Error = pcall(function()
		BlueberryPlus_PermBans_DataStore:SetAsync(userID..DataStoreKey, Data)
	end)
	if RunService:IsStudio() then
		print("[!] Blueberry+: exception when moderating "..tostring(userID)..". Cannot reserve servers while running in Studio.")
		return 403	
	else
		local Player = Players:GetPlayerByUserId(userID)
		local Success_, Error_ = pcall(function()
			local ReservedServerCode = TeleportService:ReserveServer(ReservedPlaceId)
			if Player then
				local Success, Error = pcall(function()
					TeleportService:TeleportToPrivateServer(ReservedPlaceId, ReservedServerCode, {Player}, nil, Data)
				end)
				if not Success then
					Player:Kick("Blueberry teleportation failed. Contact the developer for details. ", Error)
					warn("[500] Blueberry+: teleportation to reserved place failed. ", Error)
				end
			else
				ServerSync_runner:PostPermBan(tonumber(userID))
			end
		end)
		if not Success_ then
			warn("[500] Blueberry+: could not teleport player to reserved server. "..Error_)
		end
	end
	if not Success then
		warn("[500] Blueberry+: Could not upload new data to DataStore. ", Error)
		return 500
	else
		print("[>] Blueberry+: new perm-ban added for "..userID.." by "..Moderator(moderator).." with reason "..Reason(reason, "permban")..".")
		if Settings["Enable webhook logging"] then Webhook_runner:logNewPermBan(tostring(userID), Reason(reason, "permban"), tostring(Moderator(moderator))) end
		return 200	
	end
end

--// Remove perm-ban \\--
function runner:removePermBan(userID, reason, moderator)
	if not userID or tonumber(userID) == nil then
		warn("[404] Blueberry+: couldn't find the target user ID while attempting to remove a perm-ban.")
		return 404
	end
	local SavedData = nil
	local Success, Error = pcall(function()
		SavedData = BlueberryPlus_PermBans_DataStore:GetAsync(userID..DataStoreKey)
	end)
	if not Success then
		warn("[500] Blueberry+: Could not check data from DataStore. ", Error)
		return 500
	end
	if not SavedData then
		print("[>] Blueberry+: temp-ban removal request for "..userID.." by "..Moderator(moderator).." with reason "..Reason(reason, "remove")..". But no data exists.")
		return 208	
	end
	local Success, Error = pcall(function()
		BlueberryPlus_PermBans_DataStore:RemoveAsync(userID..DataStoreKey)
	end)
	if not Success then
		warn("[500] Blueberry+: Could not remove data from DataStore. ", Error)
		return 500
	else
		print("[>] Blueberry+: perm-ban removed for "..userID.." by "..Moderator(moderator).." with reason "..Reason(reason, "remove")..".")
		if Settings["Enable webhook logging"] then Webhook_runner:logRemovingPermBan(tostring(userID), Reason(reason, "remove"), tostring(Moderator(moderator))) end
		return 200
	end
end

--// Kick \\--
function runner:kick(userID, reason, moderator)
	if not userID or tonumber(userID) == nil then
		warn("[404] Blueberry+: couldn't find the target user ID while attempting to kick.")
		return 404
	end
	local Data = {['Reason'] = Reason(reason, "kick"), ['Moderator'] = Moderator(moderator), ["Provenance server"] = game.JobId, ['Type'] = "kick"}
	if RunService:IsStudio() then
		print("[!] Blueberry+: exception when moderating "..tostring(userID)..". Cannot reserve servers while running in Studio.")
		return 403
	else
		local Player = Players:GetPlayerByUserId(userID)
		local Success, Error = pcall(function()
			local ReservedServerCode = TeleportService:ReserveServer(ReservedPlaceId)
			if Player then
				local Success, Error = pcall(function()
					TeleportService:TeleportToPrivateServer(ReservedPlaceId, ReservedServerCode, {Player}, nil, Data)
				end)
				if not Success then
					Player:Kick("Blueberry teleportation failed. Contact the developer for details. ", Error)
					warn("[500] Blueberry+: teleportation to reserved place failed. ", Error)
				end
			else
				warn("[404] Blueberry+: Requested player couldn't be found.")
				return 404
			end
		end)
		if not Success then
			warn("[500] Blueberry+: Could not teleport player to reserved server. ", Error)
			return 500
		else
			print("[>] Blueberry+: new kick for "..userID.." by "..Moderator(moderator).." with reason "..Reason(reason, "kick")..".")
			if Settings["Enable webhook logging"] then Webhook_runner:logNewKick(tostring(userID), Reason(reason, "kick"), tostring(Moderator(moderator))) end
			return 200	
		end
	end
end

--// Slock \\--
function runner:slock(min_rank, reason, moderator)
	if not min_rank or tonumber(min_rank) == nil then
		warn("[404] Blueberry+: couldn't find the minimum rank while attempting to slock.")
		return 404
	end
	local Data = {['Min. rank'] = tonumber(min_rank), ['Reason'] = Reason(reason, "slock"), ['Moderator'] = Moderator(moderator), ['Type'] = "slock"}
	ServerLocked[1] = true
	ServerLocked[2] = min_rank
	ServerLocked[3] = Data
	local Success, Error = pcall(function()
		BlueberryPlus_Slocks_DataStore:SetAsync(game.JobId, Data)
	end)
	if not Success then
		warn("[500] Blueberry+: Could not upload new data to DataStore. ", Error)
		return 500
	else
		print("[>] Blueberry+: new slock for "..game.JobId.." by "..Moderator(moderator).." with reason "..Reason(reason, "slock")..".")
		if Settings["Enable webhook logging"] then Webhook_runner:logSlock(tostring(min_rank), Reason(reason, "slock"), tostring(Moderator(moderator))) end
		return 200	
	end
end

--// Unslock \\--
function runner:unslock(reason, moderator)
	local SavedData = nil
	local Success, Error = pcall(function()
		SavedData = BlueberryPlus_Slocks_DataStore:GetAsync(game.JobId)
	end)
	if not Success then
		warn("[500] Blueberry+: Could not check data from DataStore. ", Error)
		return 500
	end
	if not SavedData then
		print("[>] Blueberry+: unslock request for "..game.JobId.." by "..Moderator(moderator).." with reason "..Reason(reason, "remove")..". But no data exists.")
		return 208	
	end
	ServerLocked[1] = false
	ServerLocked[2] = 0
	ServerLocked[3] = nil
	local Success, Error = pcall(function()
		BlueberryPlus_Slocks_DataStore:RemoveAsync(game.JobId)
	end)
	if not Success then
		warn("[500] Blueberry+: Could not remove data from DataStore. ", Error)
		return 500
	else
		print("[>] Blueberry+: slock removed for "..game.JobId.." by "..Moderator(moderator).." with reason "..Reason(reason, "remove")..".")
		if Settings["Enable webhook logging"] then Webhook_runner:logUnslock(Reason(reason, "remove"), tostring(Moderator(moderator))) end
		return 200
	end
end

--=======================================================================================--
function runner.ServerLocked(rank)
	if not rank or tonumber(rank) == nil then
		warn("[404] Blueberry+: couldn't find the minimum rank while attempting to check lock.")
		return 404
	end
	if ServerLocked[1] == false then
		return false
	else
		if rank < ServerLocked[2] then
			return true
		else
			return false
		end
	end
end

function runner:HandleLockedServerJoin(Player)
	if not Player or typeof(Player) ~= "Instance" then
		warn("[404] Blueberry+: couldn't find the player instance while attempting to check run slock drill.")
		return 404
	end
	if ServerLocked[1] == false then
		print("[!] Blueberry+: player slock drill aborded. Server is not locked.")
		return 403
	end
	local userID = Player.UserId
	if RunService:IsStudio() then
		print("[!] Blueberry+: exception when moderating "..tostring(userID)..". Cannot reserve servers while running in Studio.")
		return 403
	else
		local Success, Error = pcall(function()
			local ReservedServerCode = TeleportService:ReserveServer(ReservedPlaceId)
			if Player then
				local Success, Error = pcall(function()
					TeleportService:TeleportToPrivateServer(ReservedPlaceId, ReservedServerCode, {Player}, nil, ServerLocked[3])
				end)
				if not Success then
					Player:Kick("Blueberry teleportation failed. Contact the developer for details. ", Error)
					warn("[500] Blueberry+: teleportation to reserved place failed. ", Error)
				end
			else
				warn("[404] Blueberry+: Requested player couldn't be found.")
				return 404
			end
		end)
		if not Success then
			warn("[500] Blueberry+: Could not teleport player to reserved server. ", Error)
			return 500
		else
			print("[>] Blueberry+: new player was teleported because of the server locking. Player: "..Player.UserId)
			return 200	
		end
	end
end

function runner.IsModerated(userID)
	if not userID or tonumber(userID) == nil then
		warn("[404] Blueberry+: couldn't find the target user ID while attempting to check moderation status.")
		return 404
	end
	local WarnData = nil
	local TempBanData = nil
	local PermBanData = nil
	local Success, Error = pcall(function()
		WarnData = BlueberryPlus_Warnings_DataStore:GetAsync(userID..DataStoreKey)
		TempBanData = BlueberryPlus_TempBans_DataStore:GetAsync(userID..DataStoreKey)
		PermBanData = BlueberryPlus_PermBans_DataStore:GetAsync(userID..DataStoreKey)
	end)
	if not Success then
		warn("[500] Blueberry+: Could not get data from DataStore. ", Error)
		return 500
	end
	if PermBanData then return "permban" end
	if TempBanData then return "tempban" end
	if WarnData then return "warn" end
	return "none"
end

function runner:TeleportPlayer(Player)
	if not Player or typeof(Player) ~= "Instance" then
		warn("[404] Blueberry+: couldn't find the player instance while attempting to check run teleportation.")
		return 404
	end
	local userID = Player.UserId
	if RunService:IsStudio() then
		print("[!] Blueberry+: exception when moderating "..tostring(userID)..". Cannot reserve servers while running in Studio.")
		return 403	
	else
		local Success, Error = pcall(function()
			local ReservedServerCode = TeleportService:ReserveServer(ReservedPlaceId)
			if Player then
				ReplicatedStorage:WaitForChild('BlueberryPlus_Replicated', 2):WaitForChild('TriggerTeleportMessage'):FireClient(Player)
				local Success, Error = pcall(function()
					TeleportService:TeleportToPrivateServer(ReservedPlaceId, ReservedServerCode, {Player}, nil, nil)
				end)
				if not Success then
					Player:Kick("Blueberry teleportation failed. Contact the developer for details. ", Error)
					warn("[500] Blueberry+: teleportation to reserved place failed. ", Error)
				end
			else
				warn("[404] Blueberry+: Requested player couldn't be found.")
				return 404
			end
		end)
		if not Success then
			warn("[500] Blueberry+: Could not teleport player to reserved server. ", Error)
			return 500
		else
			print("[>] Blueberry+: new player was teleported due to moderation rules. Player: "..Player.UserId)
			return 200
		end
	end
end

--// Get temp-ban data \\--
function runner:getTempBanData(userID)
	if not userID or tonumber(userID) == nil then
		warn("[404] Blueberry+: couldn't find the target user ID while attempting to remove a perm-ban.")
		return 404
	end
	local SavedData = nil
	local Success, Error = pcall(function()
		SavedData = BlueberryPlus_TempBans_DataStore:GetAsync(userID..DataStoreKey)
	end)
	if not Success then
		warn("[500] Blueberry+: Could not check data from DataStore. ", Error)
		return 500
	end
	if not SavedData then
		print("[>] Blueberry+: temp-ban get request for "..userID..". But no data exists.")
		return 208
	else
		return SavedData
	end
end


return runner
