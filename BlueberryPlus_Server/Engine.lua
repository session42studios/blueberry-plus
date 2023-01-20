--[[

    ____  __           __                                
   / __ )/ /_  _____  / /_  ___  ____________  __     __ 
  / __  / / / / / _ \/ __ \/ _ \/ ___/ ___/ / / /  __/ /_
 / /_/ / / /_/ /  __/ /_/ /  __/ /  / /  / /_/ /  /_  __/
/_____/_/\__,_/\___/_.___/\___/_/  /_/   \__, /    /_/   
                                        /____/           
                                        
                    𝗛𝗼𝘀𝘁 𝗴𝗮𝗺𝗲 | Engine                    


]]--
--// Dependencies \\--
local ServerScriptService = game:GetService('ServerScriptService')
local Players = game:GetService('Players')
local DataStoreService = game:GetService('DataStoreService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local HttpService = game:GetService('HttpService')
local Settings = require(ServerScriptService:WaitForChild('BlueberryPlus', 3):WaitForChild('Settings', 3))
local API_runner = require(script.Parent:WaitForChild('API_runner'))
local BlueberryPlus_Replicated = ReplicatedStorage:WaitForChild('BlueberryPlus_Replicated', 3)
local Notification = require(BlueberryPlus_Replicated:WaitForChild('Notification'), 3)
local Webhook_runner = require(script.Parent:WaitForChild('Webhook_runner'))
local ClientPermissions = Settings["Client permissions"]
local GroupID = Settings["Group ID"]
local BlueberryPlus_Config_DataStore = DataStoreService:GetDataStore('BlueberryPlus_Config_DataStore')

--// Check(s) \\--
if not Settings or not API_runner or not Webhook_runner or not BlueberryPlus_Replicated or not Notification then warn("[404] Blueberry+: CRITICAL - failed to find core file. Make sure all the files names are the same as default.") return	end

--// Functions \\--
local function convertToUserId(value)
	if not value then warn("[404] Blueberry+: requested variable is nil, cannot convert to user ID.") return nil end
	if typeof(value) == "Instance" then if value.UserId then return value.UserId else warn("[500] Blueberry+: requested variable is an instance, cannot convert to user ID.") return nil end end
	if tonumber(value) ~= nil then return tonumber(value) end
	if tonumber(value) == nil then value = Players:GetUserIdFromNameAsync(value) if not value then warn("[500] Blueberry+: variable cannot be converted to user ID. Make sure it's a username, player istance, or user ID.") return nil else return value end end
	return nil	
end
local function getOfflinePlayerRankId(playerID)
	if not playerID then warn("[404] Blueberry+: requested variable is nil, cannot check rank.") return nil end
	if typeof(playerID) ~= "number" then warn("[500] Blueberry+: requested variable is not a number, cannot check rank.") return nil end
	local URL = "https://groups.roproxy.com/v2/users/"..tostring(playerID).."/groups/roles"
	local Data = nil
	local Success, Error = pcall(function()
		Data = HttpService:GetAsync(URL)
	end)
	if not Success then warn("[500] Blueberry+: error while attempting to get offline user rank. "..Error) return nil end
	if not Data then warn("[500] Blueberry+: error while attempting to get offline user rank. Data is nil.") return nil end
	Data = HttpService:JSONDecode(Data)
	for index, item in pairs(Data.data) do
		if item['group']['id'] == GroupID then
			return item['role']['rank']
		end
	end
	return 0
end

--// Replicated API fetcher \\--
if Settings["Use Replicated API"] == false then
	if BlueberryPlus_Replicated:FindFirstChild('API') then BlueberryPlus_Replicated:FindFirstChild('API'):Destroy() end
	if BlueberryPlus_Replicated:FindFirstChild('ClientPermissions') then BlueberryPlus_Replicated:FindFirstChild('ClientPermissions'):Destroy() end
else
	local ReplicatedAPI = BlueberryPlus_Replicated:WaitForChild('API', 5)
	local ReplicatedClientPermissions = BlueberryPlus_Replicated:WaitForChild('ClientPermissions', 5)
	if not ReplicatedAPI or not ReplicatedClientPermissions then warn("[404] Blueberry+: Couldn't find ReplicatedAPI folder.") end
	for index, value in pairs(ClientPermissions) do
		local NewValue = Instance.new("NumberValue",ReplicatedClientPermissions)
		NewValue.Name = index
		NewValue.Value = value
	end
	local NewValue = Instance.new("NumberValue", ReplicatedClientPermissions)
	NewValue.Name = "GroupID"
	NewValue.Value = GroupID
	local NewValue = Instance.new("StringValue", ReplicatedClientPermissions)
	NewValue.Name = "Keybind"
	NewValue.Value = Settings["Open keybind"]
	local NewValue = Instance.new("BoolValue", ReplicatedClientPermissions)
	NewValue.Name = "ScreenButton"
	NewValue.Value = Settings["Screen button"]
	
	--// Slock \\--
	ReplicatedAPI.slock.OnServerEvent:Connect(function(requester, min_rank, reason)
		Notification.notify(requester, "Loading", "Just give me a few seconds... Loading.", "default", 5.5)
		if requester:GetRankInGroup(GroupID) >= ClientPermissions['Slock'] then
			if not min_rank or typeof(min_rank) ~= "number" then
				Notification.notify(requester, "Missing value", "A minimum rank has to be specified to slock this server.", "warning", 3.5)
				return	
			end
			if tonumber(min_rank) >= requester:GetRankInGroup(GroupID) then
				Notification.notify(requester, "Rank too low", "The minimum rank you specified has to be lower than yours.", "warning", 3.5)
				return
			end
			if not reason then
				Notification.notify(requester, "Using default reason", "Seems like you didn't specify any reason. We will use the default one.", "info", 3.5)
				reason = Settings["Default slock reason"]
			end
			if API_runner:slock(tonumber(min_rank), reason, requester.UserId) == 200 then
				Notification.notify(requester, "Success", "Successfully locked the server for ranks below "..tostring(min_rank).."!", "info", 3.5)
				return
			else
				Notification.notify(requester, "Failed", "Could not lock the server. Ask someone with console permission to check for any errors.", "warning", 3.5)
				return	
			end
		else
			Notification.notify(requester, "Higher rank required", "Your rank is too low for this action.", "warning", 4)
			print("[403] Blueberry+: client requested action, but their rank was too low. Client: "..requester.Name..".")
		end
	end)
	
	--// Unslock \\--
	ReplicatedAPI.unslock.OnServerEvent:Connect(function(requester, reason)
		Notification.notify(requester, "Loading", "Just give me a few seconds... Loading.", "default", 5.5)
		if requester:GetRankInGroup(GroupID) >= ClientPermissions['Remove warnings'] then
			if not reason then
				Notification.notify(requester, "Using default reason", "Seems like you didn't specify any reason. We will use the default one.", "info", 3.5)
				reason = "Not specified"
			end
			local StatusCode = API_runner:unslock(reason, requester.UserId)
			if StatusCode == 200 then
				Notification.notify(requester, "Success", "Successfully unslocked this server!", "info", 5.5)
				return
			elseif StatusCode == 208 then
				Notification.notify(requester, "No data", "Doesn't seem like this server is locked. Action was successful.", "info", 3.5)
				return
			else
				Notification.notify(requester, "Failed", "Could not remove slock. Ask someone with console permission to check for any errors.", "warning", 3.5)
				return	
			end
		else
			Notification.notify(requester, "Higher rank required", "Your rank is too low for this action.", "warning", 4)
			print("[403] Blueberry+: client requested action, but their rank was too low. Client: "..requester.Name..".")
		end
	end)
	
	--// Create warning \\--
	ReplicatedAPI.addWarning.OnServerEvent:Connect(function(requester, target, reason)
		Notification.notify(requester, "Loading", "Just give me a few seconds... Loading.", "default", 5.5)
		if requester:GetRankInGroup(GroupID) >= ClientPermissions['Create warnings'] then
			if not target then
				Notification.notify(requester, "Missing value", "A target username or user ID has to be specified to issue a warning.", "warning", 3.5)
				return
			end
			target = convertToUserId(target)
			if not target or typeof(target) ~= "number" then
				Notification.notify(requester, "Error", "Seems like we couldn't process the target value.", "alert", 3.5)
				return
			end
			if getOfflinePlayerRankId(target) >= requester:GetRankInGroup(GroupID) then
				Notification.notify(requester, "Rank too low", "The minimum rank you specified has to be lower than yours.", "warning", 3.5)
				return
			end
			if not reason then
				Notification.notify(requester, "Using default reason", "Seems like you didn't specify any reason. We will use the default one.", "info", 3.5)
				reason = Settings["Default warning reason"]
			end
			if API_runner:addWarning(tonumber(target), reason, requester.UserId) == 200 then
				Notification.notify(requester, "Success", "Successfully added warning for "..tostring(target).."!", "info", 3.5)
				return
			else
				Notification.notify(requester, "Failed", "Could not issue warning. Ask someone with console permission to check for any errors.", "warning", 3.5)
				return	
			end
		else
			Notification.notify(requester, "Higher rank required", "Your rank is too low for this action.", "warning", 4)
			print("[403] Blueberry+: client requested action, but their rank was too low. Client: "..requester.Name..".")
		end
	end)
	
	--// Remove warning \\--
	ReplicatedAPI.removeWarning.OnServerEvent:Connect(function(requester, target, reason)
		Notification.notify(requester, "Loading", "Just give me a few seconds... Loading.", "default", 5.5)
		if requester:GetRankInGroup(GroupID) >= ClientPermissions['Remove warnings'] then
			if not target then
				Notification.notify(requester, "Missing value", "A target username or user ID has to be specified to remove a warning.", "warning", 3.5)
				return
			end
			target = convertToUserId(target)
			if not target or typeof(target) ~= "number" then
				Notification.notify(requester, "Error", "Seems like we couldn't process the target value.", "alert", 3.5)
				return
			end
			if getOfflinePlayerRankId(target) >= requester:GetRankInGroup(GroupID) then
				Notification.notify(requester, "Rank too low", "The minimum rank you specified has to be lower than yours.", "warning", 3.5)
				return
			end
			if not reason then
				Notification.notify(requester, "Using default reason", "Seems like you didn't specify any reason. We will use the default one.", "info", 3.5)
				reason = "Not specified"
			end
			local StatusCode = API_runner:removeWarning(tonumber(target), reason, requester.UserId)
			if StatusCode == 200 then
				Notification.notify(requester, "Success", "Successfully removed warning for "..tostring(target).."!", "info", 3.5)
				return
			elseif StatusCode == 208 then
				Notification.notify(requester, "No data", "No warnings were found for "..tostring(target)..". Action was successful.", "info", 3.5)
				return
			else
				Notification.notify(requester, "Failed", "Could not remove warning. Ask someone with console permission to check for any errors.", "warning", 3.5)
				return	
			end
		else
			Notification.notify(requester, "Higher rank required", "Your rank is too low for this action.", "warning", 4)
			print("[403] Blueberry+: client requested action, but their rank was too low. Client: "..requester.Name..".")
		end
	end)
	
	--// Create temp-ban \\--
	ReplicatedAPI.addTempBan.OnServerEvent:Connect(function(requester, target, duration, reason)
		Notification.notify(requester, "Loading", "Just give me a few seconds... Loading.", "default", 5.5)
		if requester:GetRankInGroup(GroupID) >= ClientPermissions['Create temp-bans'] then
			if not target then
				Notification.notify(requester, "Missing value", "A target username or user ID has to be specified to issue a warning.", "warning", 3.5)
				return
			end
			target = convertToUserId(target)
			if not target or typeof(target) ~= "number" then
				Notification.notify(requester, "Error", "Seems like we couldn't process the target value.", "alert", 3.5)
				return
			end
			if not duration or tonumber(duration) == nil then
				Notification.notify(requester, "Error", "Seems like we couldn't process the duration value.", "alert", 3.5)
				return
			end
			if getOfflinePlayerRankId(target) >= requester:GetRankInGroup(GroupID) then
				Notification.notify(requester, "Rank too low", "The minimum rank you specified has to be lower than yours.", "warning", 3.5)
				return
			end
			if not reason then
				Notification.notify(requester, "Using default reason", "Seems like you didn't specify any reason. We will use the default one.", "info", 3.5)
				reason = Settings["Default Default temporary ban reason"]
			end
			if API_runner:addTempBan(tonumber(target), tonumber(duration), reason, requester.UserId) == 200 then
				Notification.notify(requester, "Success", "Successfully added temp-ban for "..tostring(target).." ("..tostring(duration).." minute(s))!", "info", 3.5)
				return
			else
				Notification.notify(requester, "Failed", "Could not issue temp-ban. Ask someone with console permission to check for any errors.", "warning", 3.5)
				return	
			end
		else
			Notification.notify(requester, "Higher rank required", "Your rank is too low for this action.", "warning", 4)
			print("[403] Blueberry+: client requested action, but their rank was too low. Client: "..requester.Name..".")
		end
	end)
	
	--// Remove temp-ban \\--
	ReplicatedAPI.removeTempBan.OnServerEvent:Connect(function(requester, target, reason)
		Notification.notify(requester, "Loading", "Just give me a few seconds... Loading.", "default", 5.5)
		if requester:GetRankInGroup(GroupID) >= ClientPermissions['Remove temp-bans'] then
			if not target then
				Notification.notify(requester, "Missing value", "A target username or user ID has to be specified to remove a temp-ban.", "warning", 3.5)
				return
			end
			target = convertToUserId(target)
			if not target or typeof(target) ~= "number" then
				Notification.notify(requester, "Error", "Seems like we couldn't process the target value.", "alert", 3.5)
				return
			end
			if getOfflinePlayerRankId(target) >= requester:GetRankInGroup(GroupID) then
				Notification.notify(requester, "Rank too low", "The minimum rank you specified has to be lower than yours.", "warning", 3.5)
				return
			end
			if not reason then
				Notification.notify(requester, "Using default reason", "Seems like you didn't specify any reason. We will use the default one.", "info", 3.5)
				reason = "Not specified"
			end
			local StatusCode = API_runner:removeTempBan(tonumber(target), reason, requester.UserId)
			if StatusCode == 200 then
				Notification.notify(requester, "Success", "Successfully removed temp-ban for "..tostring(target).."!", "info", 3.5)
				return
			elseif StatusCode == 208 then
				Notification.notify(requester, "No data", "No temp-bans were found for "..tostring(target)..". Action was successful.", "info", 3.5)
				return
			else
				Notification.notify(requester, "Failed", "Could not remove perm-ban. Ask someone with console permission to check for any errors.", "warning", 3.5)
				return	
			end
		else
			Notification.notify(requester, "Higher rank required", "Your rank is too low for this action.", "warning", 4)
			print("[403] Blueberry+: client requested action, but their rank was too low. Client: "..requester.Name..".")
		end
	end)
	
	--// Create perm-ban \\--
	ReplicatedAPI.addPermBan.OnServerEvent:Connect(function(requester, target, reason)
		Notification.notify(requester, "Loading", "Just give me a few seconds... Loading.", "default", 5.5)
		if requester:GetRankInGroup(GroupID) >= ClientPermissions['Create perm-bans'] then
			if not target then
				Notification.notify(requester, "Missing value", "A target username or user ID has to be specified to issue a perm-ban.", "warning", 3.5)
				return
			end
			target = convertToUserId(target)
			if not target or typeof(target) ~= "number" then
				Notification.notify(requester, "Error", "Seems like we couldn't process the target value.", "alert", 3.5)
				return
			end
			if getOfflinePlayerRankId(target) >= requester:GetRankInGroup(GroupID) then
				Notification.notify(requester, "Rank too low", "The minimum rank you specified has to be lower than yours.", "warning", 3.5)
				return
			end
			if not reason then
				Notification.notify(requester, "Using default reason", "Seems like you didn't specify any reason. We will use the default one.", "info", 3.5)
				reason = Settings["Default permanent ban reason"]
			end
			if API_runner:addPermBan(tonumber(target), reason, requester.UserId) == 200 then
				Notification.notify(requester, "Success", "Successfully added perm-ban for "..tostring(target).."!", "info", 3.5)
				return
			else
				Notification.notify(requester, "Failed", "Could not issue perm-ban. Ask someone with console permission to check for any errors.", "warning", 3.5)
				return	
			end
		else
			Notification.notify(requester, "Higher rank required", "Your rank is too low for this action.", "warning", 4)
			print("[403] Blueberry+: client requested action, but their rank was too low. Client: "..requester.Name..".")
		end
	end)
	
	--// Remove perm-ban \\--
	ReplicatedAPI.removePermBan.OnServerEvent:Connect(function(requester, target, reason)
		Notification.notify(requester, "Loading", "Just give me a few seconds... Loading.", "default", 5.5)
		if requester:GetRankInGroup(GroupID) >= ClientPermissions['Remove perm-bans'] then
			if not target then
				Notification.notify(requester, "Missing value", "A target username or user ID has to be specified to remove a perm-ban.", "warning", 3.5)
				return
			end
			target = convertToUserId(target)
			if not target or typeof(target) ~= "number" then
				Notification.notify(requester, "Error", "Seems like we couldn't process the target value.", "alert", 3.5)
				return
			end
			if getOfflinePlayerRankId(target) >= requester:GetRankInGroup(GroupID) then
				Notification.notify(requester, "Rank too low", "The minimum rank you specified has to be lower than yours.", "warning", 3.5)
				return
			end
			if not reason then
				Notification.notify(requester, "Using default reason", "Seems like you didn't specify any reason. We will use the default one.", "info", 3.5)
				reason = "Not specified"
			end
			local StatusCode = API_runner:removePermBan(tonumber(target), reason, requester.UserId)
			if StatusCode == 200 then
				Notification.notify(requester, "Success", "Successfully removed perm-ban for "..tostring(target).."!", "info", 3.5)
				return
			elseif StatusCode == 208 then
				Notification.notify(requester, "No data", "No perm-bans were found for "..tostring(target)..". Action was successful.", "info", 3.5)
				return
			else
				Notification.notify(requester, "Failed", "Could not remove perm-ban. Ask someone with console permission to check for any errors.", "warning", 3.5)
				return	
			end
		else
			Notification.notify(requester, "Higher rank required", "Your rank is too low for this action.", "warning", 4)
			print("[403] Blueberry+: client requested action, but their rank was too low. Client: "..requester.Name..".")
		end
	end)
	
	--// Kick \\--
	ReplicatedAPI.kick.OnServerEvent:Connect(function(requester, target, reason)
		Notification.notify(requester, "Loading", "Just give me a few seconds... Loading.", "default", 5.5)
		if requester:GetRankInGroup(GroupID) >= ClientPermissions['Kick players'] then
			if not target then
				Notification.notify(requester, "Missing value", "A target username or user ID has to be specified to kick a user.", "warning", 3.5)
				return
			end
			target = convertToUserId(target)
			if not target or typeof(target) ~= "number" then
				Notification.notify(requester, "Error", "Seems like we couldn't process the target value.", "alert", 3.5)
				return
			end
			if getOfflinePlayerRankId(target) >= requester:GetRankInGroup(GroupID) then
				Notification.notify(requester, "Rank too low", "The minimum rank you specified has to be lower than yours.", "warning", 3.5)
				return
			end
			if not reason then
				Notification.notify(requester, "Using default reason", "Seems like you didn't specify any reason. We will use the default one.", "info", 3.5)
				reason = Settings["Default kick reason"]
			end
			local StatusCode = API_runner:kick(tonumber(target), reason, requester.UserId)
			if StatusCode == 200 then
				Notification.notify(requester, "Success", "Successfully kicked "..tostring(target).."!", "info", 3.5)
				return
			elseif StatusCode == 404 then
				Notification.notify(requester, "User not found", "User "..tostring(target).." was not found in this server!", "warning", 3.5)
				return
			else
				Notification.notify(requester, "Failed", "Could not kick user. Ask someone with console permission to check for any errors.", "warning", 3.5)
				return	
			end
		else
			Notification.notify(requester, "Higher rank required", "Your rank is too low for this action.", "warning", 4)
			print("[403] Blueberry+: client requested action, but their rank was too low. Client: "..requester.Name..".")
		end
	end)
end

--// Save remote configuration \\--
local Success, Error = pcall(function()
	BlueberryPlus_Config_DataStore:SetAsync("BlueberryPlus", Settings)
end)
if not Success then
	warn("[500] Blueberry+: CRITICAL - couldn't upload settings to DataStore. System will malfunction. ", Error)
end

--// Player actions \\--
local function playerAdded(player)
	task.wait(0.1)
	local GroupRank = player:GetRankInGroup(GroupID)
	
	--// Panel \\--
	local function addPanel()
		if Settings["Use panel"] and Settings["Use Replicated API"] and GroupRank >= ClientPermissions["View panel"] then
			local PanelClone = 	script.BlueberryPanel:Clone()
			if player.PlayerGui then
				local BlueberryPlus_Client = player.PlayerGui:WaitForChild('BlueberryPlus_Client', 5)
				if not BlueberryPlus_Client then 
					warn("[404] Blueberry+: unable to find client folder. Panel will be partented to PlayerGui.")
					PanelClone.Parent = player.PlayerGui
				else
					PanelClone.Parent = BlueberryPlus_Client
				end
				if Settings["Auto-open on start-up"] then
					task.wait(3)
					BlueberryPlus_Replicated:WaitForChild('OpenPanel', 5):FireClient(player)
				end
			else
				warn("[404] Blueberry+: couldn't find PlayerGui folder for "..player.Name..".")
			end
			print("[>] Blueberry+: added panel to "..player.Name..".")	
		end
	end
	addPanel()

	--// Re-add panel on reset \\--
	player.CharacterAdded:Connect(function()
		task.wait(1.5)
		addPanel()
	end)
end	

local GetPlayers = Players:GetPlayers()
for i = 1, #GetPlayers do
	local Player = GetPlayers[i]
	coroutine.resume(coroutine.create(function()
		playerAdded(Player)
	end))
end

Players.PlayerAdded:Connect(playerAdded)
