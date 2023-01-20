--[[

    ____  __           __                                
   / __ )/ /_  _____  / /_  ___  ____________  __     __ 
  / __  / / / / / _ \/ __ \/ _ \/ ___/ ___/ / / /  __/ /_
 / /_/ / / /_/ /  __/ /_/ /  __/ /  / /  / /_/ /  /_  __/
/_____/_/\__,_/\___/_.___/\___/_/  /_/   \__, /    /_/   
                                        /____/           
                                        
                 𝗥𝗲𝘀𝗲𝗿𝘃𝗲𝗱 𝗽𝗹𝗮𝗰𝗲 | Engine                    


]]--

--// Dependencies \\--
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local ServerScriptService = game:GetService('ServerScriptService')
local DataStoreService = game:GetService('DataStoreService')
local TeleportService = game:GetService('TeleportService')
local HttpService = game:GetService('HttpService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Settings = require(ServerScriptService:WaitForChild('BlueberryPlus Reserved Place', 5):WaitForChild('Settings', 5))
local BlueberryPlus_Replicated = ReplicatedStorage:WaitForChild('BlueberryPlus_Replicated', 5)
local AcceptanceEvent = BlueberryPlus_Replicated:WaitForChild('UserAcceptedPunishment', 5)
local ModActionItem = {}

--// Get DataStores \\--
local BlueberryPlus_Config_DataStore = DataStoreService:GetDataStore('BlueberryPlus_Config_DataStore')
local BlueberryPlus_Warnings_DataStore = DataStoreService:GetDataStore("BlueberryPlus_Warnings_DataStore")
local BlueberryPlus_TempBans_DataStore = DataStoreService:GetDataStore("BlueberryPlus_TempBans_DataStore")
local BlueberryPlus_PermBans_DataStore = DataStoreService:GetDataStore("BlueberryPlus_PermBans_DataStore")

--// Check \\--
if not Settings or not BlueberryPlus_Replicated or not AcceptanceEvent then warn("[404] Couldn't find core file. Malfunction.") return 404 end

--// Set main game config \\--
local MainGameConfig = nil
local Success, Error = pcall(function()
	MainGameConfig = BlueberryPlus_Config_DataStore:GetAsync("BlueberryPlus")
end)
if not Success or not MainGameConfig then
	warn("[404] Blueberry+: couldn't get configuration data. ", Error)
	return 404
end
local WebhookEnabled = MainGameConfig['Enable webhook logging']
local WebhookURL = MainGameConfig['Webhook URL']

--// Update screens \\--
script.BlueberryPlus_Kick_Screen.MainFrame.PreHeader.Text = Settings["Preheader texts"]["Kick preheader text"]
script.BlueberryPlus_Warn_Screen.MainFrame.PreHeader.Text = Settings["Preheader texts"]["Warning preheader text"]
script.BlueberryPlus_Slock_Screen.MainFrame.PreHeader.Text = Settings["Preheader texts"]["Slock preheader text"]
script.BlueberryPlus_PermBan_Screen.MainFrame.PreHeader.Text = Settings["Preheader texts"]["Permanent ban preheader text"]
script.BlueberryPlus_TempBan_Screen.MainFrame.PreHeader.Text = Settings["Preheader texts"]["Temporary ban preheader text"]

script.BlueberryPlus_Kick_Screen.MainFrame.BottomNote.Text = Settings["Bottom notes"]["Kick bottom note"]
script.BlueberryPlus_Warn_Screen.MainFrame.BottomNote.Text = Settings["Bottom notes"]["Warning bottom note"]
script.BlueberryPlus_Slock_Screen.MainFrame.BottomNote.Text = Settings["Bottom notes"]["Slock bottom note"]
script.BlueberryPlus_PermBan_Screen.MainFrame.BottomNote.Text = Settings["Bottom notes"]["Permanent ban bottom note"]
script.BlueberryPlus_TempBan_Screen.MainFrame.BottomNote.Text = Settings["Bottom notes"]["Temporary ban bottom note"]

print(script.BlueberryPlus_Kick_Screen.MainFrame.BottomNote.Text)

--// Functions \\--
local function handleWarn(player, reason)
	if not reason then warn("[404] Blueberry+: couldn't find reason argument.") reason = "No reason specified." end
	if not player then warn("[404] Blueberry+: couldn't find player argument.") return 404 end
	local Screen = script.BlueberryPlus_Warn_Screen:Clone()
	Screen.MainFrame.ReasonBox.TextLabel.Text = reason
	if player.PlayerGui:FindFirstChild("BlueberryPlus_Client") then
		Screen.Parent = player.PlayerGui.BlueberryPlus_Client
	else
		Screen.Parent = player.PlayerGui
	end
	return 200
end

local function handleKick(player, reason)
	if not reason then warn("[404] Blueberry+: couldn't find reason argument.") reason = "No reason specified." end
	if not player then warn("[404] Blueberry+: couldn't find player argument.") return 404 end
	local Screen = script.BlueberryPlus_Kick_Screen:Clone()
	Screen.MainFrame.ReasonBox.TextLabel.Text = reason
	if player.PlayerGui:FindFirstChild("BlueberryPlus_Client") then
		Screen.Parent = player.PlayerGui.BlueberryPlus_Client
	else
		Screen.Parent = player.PlayerGui
	end
	return 200
end

local function handleSlock(player, reason)
	if not reason then warn("[404] Blueberry+: couldn't find reason argument.") reason = "No reason specified." end
	if not player then warn("[404] Blueberry+: couldn't find player argument.") return 404 end
	local Screen = script.BlueberryPlus_Slock_Screen:Clone()
	Screen.MainFrame.ReasonBox.TextLabel.Text = reason
	if player.PlayerGui:FindFirstChild("BlueberryPlus_Client") then
		Screen.Parent = player.PlayerGui.BlueberryPlus_Client
	else
		Screen.Parent = player.PlayerGui
	end
	return 200
end

local function handlePermBan(player, reason)
	if not reason then warn("[404] Blueberry+: couldn't find reason argument.") reason = "No reason specified." end
	if not player then warn("[404] Blueberry+: couldn't find player argument.") return 404 end
	local Screen = script.BlueberryPlus_PermBan_Screen:Clone()
	Screen.MainFrame.ReasonBox.TextLabel.Text = reason
	if player.PlayerGui:FindFirstChild("BlueberryPlus_Client") then
		Screen.Parent = player.PlayerGui.BlueberryPlus_Client
	else
		Screen.Parent = player.PlayerGui
	end
	return 200
end

local function handleTempBan(player, duration, reason)
	if not duration or tonumber(duration) == nil then warn("[404] Blueberry+: couldn't find duration argument.") return 404 end
	if not reason then warn("[404] Blueberry+: couldn't find reason argument.") reason = "No reason specified." end
	if not player then warn("[404] Blueberry+: couldn't find player argument.") return 404 end
	if duration < 1 then duration = " less than 1" end
	local Screen = script.BlueberryPlus_TempBan_Screen:Clone()
	Screen.MainFrame.Title.Text = "Banned for ~"..tostring(duration).." minute(s)"
	Screen.MainFrame.ReasonBox.TextLabel.Text = reason
	if player.PlayerGui:FindFirstChild("BlueberryPlus_Client") then
		Screen.Parent = player.PlayerGui.BlueberryPlus_Client
	else
		Screen.Parent = player.PlayerGui
	end
	return 200
end

local function moderatePlayerFromSavedData(player)
	if not player or typeof(player) ~= "Instance" or not player.UserId then warn("[404] Blueberry+: player value was invalid or not found while attempting to run moderation.") return 404 end
	local SavedData = nil
	local Success, Error = pcall(function()
		SavedData = BlueberryPlus_Warnings_DataStore:GetAsync(player.UserId..MainGameConfig['DataStore Key'])
	end)
	if not Success then
		warn("[500] Blueberry+: failed to get saved data. ", Error)
		return 500
	end
	if SavedData ~= nil then
		if handleWarn(player, SavedData['Reason']) ~= 200 then warn("[500] Blueberry+: failed to moderate player from saved data.") return 500 else table.insert(ModActionItem, SavedData) return 200 end	
	end
	SavedData = nil
	
	local Success, Error = pcall(function()
		SavedData = BlueberryPlus_TempBans_DataStore:GetAsync(player.UserId..MainGameConfig['DataStore Key'])
	end)
	if not Success then
		warn("[500] Blueberry+: failed to get saved data. ", Error)
		return 500
	end
	if SavedData ~= nil then
		local Start = SavedData.Start
		local End = SavedData.End
		local Duration = math.floor((End - os.time())/60)
		if handleTempBan(player, Duration, SavedData['Reason']) ~= 200 then warn("[500] Blueberry+: failed to moderate player from saved data.") return 500 else table.insert(ModActionItem, SavedData) return 200 end	
	end
	SavedData = nil
	
	local Success, Error = pcall(function()
		SavedData = BlueberryPlus_PermBans_DataStore:GetAsync(player.UserId..MainGameConfig['DataStore Key'])
	end)
	if not Success then
		warn("[500] Blueberry+: failed to get saved data. ", Error)
		return 500
	end
	if SavedData ~= nil then
		if handlePermBan(player, SavedData['Reason']) ~= 200 then warn("[500] Blueberry+: failed to moderate player from saved data.") return 500 else table.insert(ModActionItem, SavedData) return 200 end	
	end
	SavedData = nil
	
	return nil
end

local function teleportBack(player)
	if not player or typeof(player) ~= "Instance" or not player.UserId then warn("[404] Blueberry+: player value was invalid or not found while attempting to run teleportation.") return 404 end
	local PlaceID = Settings["Main place ID"]
	if RunService:IsStudio() then
		print("[>] Blueberry+: exception while teleporting - cannot teleport in Studio.")
		return 403
	else
		local Success, Error = pcall(function()
			TeleportService:TeleportAsync(PlaceID, {player})
		end)
		if not Success then
			warn("[500] Blueberry+: couldn't teleport player back to original place. ", Error)
			player:Kick("[ERROR] Couldn't teleport you back to the main place.   ~Blueberry")
			return
		end
	end
end

local function logRemovingWarning(target, reason, moderator)
	if not target or not reason or not moderator then warn("[404] Blueberry+: missing argument while attempting to log warning removal.") return 404 end
	local embed = 
		{
			["content"] = "<:blueberry_plus:1016430120032022598> Blueberry+ logging",
			["embeds"] = {{
				["title"] = "Warning removed",
				["description"] = "A warning has been removed via Blueberry+. All the details are displayed below.",
				["type"] = "rich",
				["color"] = tonumber(0x74F76F),
				["fields"] = {
					{
						["name"] = "From target (suspect)",
						["value"] = target,
						["inline"] = true
					},
					{
						["name"] = "Moderator",
						["value"] = moderator,
						["inline"] = true
					},
					{
						["name"] = "Reason",
						["value"] = reason,
						["inline"] = true
					},
					{
						["name"] = "Place ID",
						["value"] = game.PlaceId,
						["inline"] = true
					}
				},
				["footer"] = {
					["text"] = "Powerd by Blueberry Plus";
					["icon_url"] = "https://cdn.discordapp.com/attachments/897089045316919347/1016429880646311936/blueberryplus_logo.png"; -- The image icon you want your footer to have
				}
			}}
		}
	local Success, Error = pcall(function()
		embed = HttpService:JSONEncode(embed)
		HttpService:PostAsync(WebhookURL, embed)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post webhook. "..Error)
		return 500
	else
		return 200
	end
end

local function logRemovingTempBan(target, reason, moderator)
	if not target or not reason or not moderator then warn("[404] Blueberry+: missing argument while attempting to log temp-ban removal.") return 404 end
	local embed = 
		{
			["content"] = "<:blueberry_plus:1016430120032022598> Blueberry+ logging",
			["embeds"] = {{
				["title"] = "Temporary ban removed",
				["description"] = "A temporary ban has been removed via Blueberry+. All the details are displayed below.",
				["type"] = "rich",
				["color"] = tonumber(0x74F76F),
				["fields"] = {
					{
						["name"] = "From target (suspect)",
						["value"] = target,
						["inline"] = true
					},
					{
						["name"] = "Moderator",
						["value"] = moderator,
						["inline"] = true
					},
					{
						["name"] = "Reason",
						["value"] = reason,
						["inline"] = true
					},
					{
						["name"] = "Place ID",
						["value"] = game.PlaceId,
						["inline"] = true
					}
				},
				["footer"] = {
					["text"] = "Powerd by Blueberry Plus";
					["icon_url"] = "https://cdn.discordapp.com/attachments/897089045316919347/1016429880646311936/blueberryplus_logo.png"; -- The image icon you want your footer to have
				}
			}}
		}
	local Success, Error = pcall(function()
		embed = HttpService:JSONEncode(embed)
		HttpService:PostAsync(WebhookURL, embed)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post webhook. "..Error)
		return 500
	else
		return 200
	end
end

--// Handle joining \\--
Players.PlayerAdded:Connect(function(Player)
	--// Update screens \\--
	script.BlueberryPlus_Kick_Screen.MainFrame.PreHeader.Text = Settings["Preheader texts"]["Kick preheader text"]
	script.BlueberryPlus_Warn_Screen.MainFrame.PreHeader.Text = Settings["Preheader texts"]["Warning preheader text"]
	script.BlueberryPlus_Slock_Screen.MainFrame.PreHeader.Text = Settings["Preheader texts"]["Slock preheader text"]
	script.BlueberryPlus_PermBan_Screen.MainFrame.PreHeader.Text = Settings["Preheader texts"]["Permanent ban preheader text"]
	script.BlueberryPlus_TempBan_Screen.MainFrame.PreHeader.Text = Settings["Preheader texts"]["Temporary ban preheader text"]

	script.BlueberryPlus_Kick_Screen.MainFrame.BottomNote.Text = Settings["Bottom notes"]["Kick bottom note"]
	script.BlueberryPlus_Warn_Screen.MainFrame.BottomNote.Text = Settings["Bottom notes"]["Warning bottom note"]
	script.BlueberryPlus_Slock_Screen.MainFrame.BottomNote.Text = Settings["Bottom notes"]["Slock bottom note"]
	script.BlueberryPlus_PermBan_Screen.MainFrame.BottomNote.Text = Settings["Bottom notes"]["Permanent ban bottom note"]
	script.BlueberryPlus_TempBan_Screen.MainFrame.BottomNote.Text = Settings["Bottom notes"]["Temporary ban bottom note"]
	
	if RunService:IsStudio() then
		print("[!] Blueberry+: currently running in Studio. Moderation action disabled.")
	else		
		local JoinData = Player:GetJoinData()
		if JoinData['TeleportData'] ~= nil and JoinData['TeleportData'] ~= {} then
			local TeleportData = JoinData['TeleportData']
			local Success, Error = pcall(function()
				if TeleportData.Type == "warn" then
					if handleWarn(Player, TeleportData.Reason) ~= 200 then warn("[500] Blueberry+: user moderation failed.") else table.insert(ModActionItem, TeleportData) end
				elseif TeleportData.Type == "kick" then
					if handleKick(Player, TeleportData.Reason) ~= 200 then warn("[500] Blueberry+: user moderation failed.") else table.insert(ModActionItem, TeleportData) end
				elseif TeleportData.Type == "slock" then
					if handleSlock(Player, TeleportData.Reason) ~= 200 then warn("[500] Blueberry+: user moderation failed.") else table.insert(ModActionItem, TeleportData) end
				elseif TeleportData.Type == "tempban" then
					local Start = TeleportData.Start
					local End = TeleportData.End
					local Duration = math.floor((End - os.time())/60)
					if handleTempBan(Player, Duration, TeleportData.Reason) ~= 200 then warn("[500] Blueberry+: user moderation failed.") else table.insert(ModActionItem, TeleportData) end
				elseif TeleportData.Type == "permban" then
					if handlePermBan(Player, TeleportData.Reason) ~= 200 then warn("[500] Blueberry+: user moderation failed.") else table.insert(ModActionItem, TeleportData) end
				else
					warn("[500] Blueberry+: teleport data invalid.")
				end
			end)
		else
			local StatusCode = moderatePlayerFromSavedData(Player)
			if StatusCode ~= 200 then warn("[!] Blueberry+: failed to moderate. ", StatusCode) end
		end
		--// Remove temp-ban if time passed \\--
		local TempBanData = nil
		local Success, Error = pcall(function()
			TempBanData = BlueberryPlus_TempBans_DataStore:GetAsync(Player.UserId..MainGameConfig['DataStore Key'])
		end)
		if not Success then
			warn("[500] Blueberry+: failed to get temp-ban data. ", Error)
		end
		if TempBanData then
			if os.time() >= TempBanData.End then
				local Success, Error = pcall(function()
					BlueberryPlus_TempBans_DataStore:RemoveAsync(Player.UserId..MainGameConfig['DataStore Key'])
				end)
				if not Success then
					warn("[500] Blueberry+: failed to remove temp-ban data. ", Error)
				else
					if WebhookEnabled then logRemovingTempBan(Player.UserId, "Automatic removal: ban duration ended.", "BlueberryPlus System") end
					print("[200] Blueberry+: removed user temp-ban.")
				end
			end
		end
	end
end)

--// Receive acceptance \\--
AcceptanceEvent.OnServerEvent:Connect(function(player, punishment)
	if punishment == "warn" then
		local Success, Error = pcall(function()
			BlueberryPlus_Warnings_DataStore:RemoveAsync(player.UserId..MainGameConfig['DataStore Key'])
		end)
		if not Success then
			warn("[500] Blueberry+: failed to remove warning from data store. ", Error)
			player:Kick("[ERROR] Failed to remove data from DataStore. Ask an administrator to look into it.  ~Blueberry+")
			return
		else
			if WebhookEnabled then logRemovingWarning(player.UserId, "Automatic removal: user accepted warning.", "BlueberryPlus System") end
			teleportBack(player)
		end
	elseif punishment == "tempban" then
		if not ModActionItem[1].End then
			warn("[500] Blueberry+: failed to find end time for temp-ban.")
			player:Kick("[ERROR] Failed to find end time for temp-ban. Ask an administrator to look into it.  ~Blueberry+")
			return
		else
			local End = ModActionItem[1].End
			if os.time() < End then
				player:Kick("[TEMPORARY BANNED] "..ModActionItem[1].Reason.."   ~ Blueberry+")
			else
				local Success, Error = pcall(function()
					BlueberryPlus_TempBans_DataStore:RemoveAsync(player.UserId..MainGameConfig['DataStore Key'])
				end)
				if not Success then
					warn("[500] Blueberry+: failed to remove temp-ban from data store. ", Error)
					player:Kick("[ERROR] Failed to remove data from DataStore. Ask an administrator to look into it.  ~Blueberry+")
					return
				else
					if WebhookEnabled then logRemovingTempBan(player.UserId, "Automatic removal: ban duration ended.", "BlueberryPlus System") end
					teleportBack(player)
				end
			end
		end
	elseif punishment == "permban" then
		if not ModActionItem[1] then
			warn("[500] Blueberry+: failed to find data for perm-ban.")
			player:Kick("[ERROR] Failed to find data for perm-ban. Ask an administrator to look into it.  ~Blueberry+")
			return
		end
		player:Kick("[PERMANENTLY BANNED] "..ModActionItem[1].Reason.."   ~ Blueberry+")
	elseif punishment == "kick" then
		if not ModActionItem[1] then
			warn("[500] Blueberry+: failed to find data for kick.")
			player:Kick("[ERROR] Failed to find data for kick. Ask an administrator to look into it.  ~Blueberry+")
			return
		end
		player:Kick("[KICKED] "..ModActionItem[1].Reason.."   ~ Blueberry+")
	elseif punishment == "slock" then
		if not ModActionItem[1] then
			warn("[500] Blueberry+: failed to find data for slock.")
			player:Kick("[ERROR] Failed to find data for slock. Ask an administrator to look into it.  ~Blueberry+")
			return
		end
		player:Kick("[SLOCKED] "..ModActionItem[1].Reason.."   ~ Blueberry+")
	end
end)
