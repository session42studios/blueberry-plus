game:GetService('Players').PlayerAdded:Connect(function(player)
	local API_runner = require(script.Parent.Parent.API_runner)
	local GroupID = require(game:GetService('ServerScriptService'):WaitForChild('BlueberryPlus', 1):WaitForChild('Settings'))["Group ID"]
	local GroupRank = player:GetRankInGroup(GroupID)
	--// Run player moderation check \\--
	if API_runner.ServerLocked(GroupRank) then
		API_runner:HandleLockedServerJoin(player)
	end
	local IsModerated = API_runner.IsModerated(player.UserId)
	if IsModerated == "permban" then
		print("[>] Blueberry+: player moderated for perm-ban...")
		API_runner:TeleportPlayer(player)
	elseif IsModerated == "tempban" then
		local Data = API_runner:getTempBanData(player.UserId)
		if Data and Data ~= 208 and Data ~= 500 then
			if Data['End'] then
				if os.time() >= Data['End'] then
					API_runner:removeTempBan(player.UserId, "Automatic removal: ban duration ended.", "BlueberryPlus System")
					print("[>] Blueberry+: removed temp-ban for user because duration ended.")
					return 200	
				end
			else
				warn("[500] Blueberry+: failed to check temp-ban from data store.")
				return 500
			end
		end
		API_runner:TeleportPlayer(player)
		print("[>] Blueberry+: player moderated for temp-ban...")
	elseif IsModerated == "warn" then
		API_runner:TeleportPlayer(player)	
		print("[>] Blueberry+: player moderated for warning...")
	else
		print("[>] Blueberry+: player not moderated.")
	end
end)
