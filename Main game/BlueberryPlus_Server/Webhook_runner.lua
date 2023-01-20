--[[

    ____  __           __                                
   / __ )/ /_  _____  / /_  ___  ____________  __     __ 
  / __  / / / / / _ \/ __ \/ _ \/ ___/ ___/ / / /  __/ /_
 / /_/ / / /_/ /  __/ /_/ /  __/ /  / /  / /_/ /  /_  __/
/_____/_/\__,_/\___/_.___/\___/_/  /_/   \__, /    /_/   
                                        /____/           
                                        
               𝗛𝗼𝘀𝘁 𝗴𝗮𝗺𝗲 | Webhook runner                    


]]--
local runner = {}
--// Get services & dependencies \\--
local HttpService = game:GetService('HttpService')
local ServerScriptService = game:GetService('ServerScriptService')
local Settings = require(ServerScriptService:WaitForChild('BlueberryPlus'):WaitForChild('Settings'))
local URL = Settings["Webhook URL"]

--// Check \\--
if not Settings then warn("[404] Blueberry+: the setting module couldn't be requested.") return 404 end
if not URL then warn("[404] Blueberry+: the webhook URL couldn't be found.") return 404 end

--// Log new warning \\--
function runner:logNewWarning(target, reason, moderator)
	if not target or not reason or not moderator then warn("[404] Blueberry+: missing argument while attempting to log warning.") return 404 end
	local embed = 
		{
			["content"] = "<:blueberry_plus:1016430120032022598> Blueberry+ logging",
			["embeds"] = {{
				["title"] = "New warning created",
				["description"] = "A new warning has been issued via Blueberry+. All the details are displayed below.",
				["type"] = "rich",
				["color"] = tonumber(0xEBEB07),
				["fields"] = {
					{
						["name"] = "Target (suspect)",
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
		HttpService:PostAsync(URL, embed)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post webhook. "..Error)
		return 500
	else
		return 200
	end
end

--// Log new temp-ban \\--
function runner:logNewTempBan(target, reason, duration, moderator)
	if not target or not reason or not moderator or not duration then warn("[404] Blueberry+: missing argument while attempting to log tem-ban.") return 404 end
	local embed = 
		{
			["content"] = "<:blueberry_plus:1016430120032022598> Blueberry+ logging",
			["embeds"] = {{
				["title"] = "New temporary ban created",
				["description"] = "A new temporary ban has been issued via Blueberry+. All the details are displayed below.",
				["type"] = "rich",
				["color"] = tonumber(0xEBEB07),
				["fields"] = {
					{
						["name"] = "Target (suspect)",
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
						["name"] = "Duration",
						["value"] = duration.. " minute(s)",
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
		HttpService:PostAsync(URL, embed)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post webhook. "..Error)
		return 500
	else
		return 200
	end
end

--// Log new perm-ban \\--
function runner:logNewPermBan(target, reason, moderator)
	if not target or not reason or not moderator then warn("[404] Blueberry+: missing argument while attempting to log perm-ban.") return 404 end
	local embed = 
		{
			["content"] = "<:blueberry_plus:1016430120032022598> Blueberry+ logging",
			["embeds"] = {{
				["title"] = "New permanent ban created",
				["description"] = "A new permanent ban has been issued via Blueberry+. All the details are displayed below.",
				["type"] = "rich",
				["color"] = tonumber(0xEBEB07),
				["fields"] = {
					{
						["name"] = "Target (suspect)",
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
		HttpService:PostAsync(URL, embed)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post webhook. "..Error)
		return 500
	else
		return 200
	end
end

--// Log new kick \\--
function runner:logNewKick(target, reason, moderator)
	if not target or not reason or not moderator then warn("[404] Blueberry+: missing argument while attempting to log kick.") return 404 end
	local embed = 
		{
			["content"] = "<:blueberry_plus:1016430120032022598> Blueberry+ logging",
			["embeds"] = {{
				["title"] = "User kicked",
				["description"] = "A user has been kicked via Blueberry+. All the details are displayed below.",
				["type"] = "rich",
				["color"] = tonumber(0xEBEB07),
				["fields"] = {
					{
						["name"] = "Target (suspect)",
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
					},
					{
						["name"] = "Server ID",
						["value"] = game.JobId,
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
		HttpService:PostAsync(URL, embed)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post webhook. "..Error)
		return 500
	else
		return 200
	end
end

--// Log slock \\--
function runner:logSlock(min_rank, reason, moderator)
	if not reason or not min_rank or not moderator then warn("[404] Blueberry+: missing argument while attempting to log slock.") return 404 end
	local embed = 
		{
			["content"] = "<:blueberry_plus:1016430120032022598> Blueberry+ logging",
			["embeds"] = {{
				["title"] = "Server locked",
				["description"] = "A server has been slocked via Blueberry+. All the details are displayed below.",
				["type"] = "rich",
				["color"] = tonumber(0xEBEB07),
				["fields"] = {
					{
						["name"] = "Minimum rank",
						["value"] = min_rank,
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
					},
					{
						["name"] = "Server ID",
						["value"] = game.JobId,
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
		HttpService:PostAsync(URL, embed)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post webhook. "..Error)
		return 500
	else
		return 200
	end
end

--// Log warning removal \\--
function runner:logRemovingWarning(target, reason, moderator)
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
		HttpService:PostAsync(URL, embed)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post webhook. "..Error)
		return 500
	else
		return 200
	end
end

--// Log temp-ban removal \\--
function runner:logRemovingTempBan(target, reason, moderator)
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
		HttpService:PostAsync(URL, embed)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post webhook. "..Error)
		return 500
	else
		return 200
	end
end

--// Log perm-ban removal \\--
function runner:logRemovingPermBan(target, reason, moderator)
	if not target or not reason or not moderator then warn("[404] Blueberry+: missing argument while attempting to log perm-ban removal.") return 404 end
	local embed = 
		{
			["content"] = "<:blueberry_plus:1016430120032022598> Blueberry+ logging",
			["embeds"] = {{
				["title"] = "Permanent ban removed",
				["description"] = "A permanent ban has been removed via Blueberry+. All the details are displayed below.",
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
		HttpService:PostAsync(URL, embed)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post webhook. "..Error)
		return 500
	else
		return 200
	end
end

--// Log unslock \\--
function runner:logUnslock(reason, moderator)
	if not reason or not moderator then warn("[404] Blueberry+: missing argument while attempting to log warning removal.") return 404 end
	local embed = 
		{
			["content"] = "<:blueberry_plus:1016430120032022598> Blueberry+ logging",
			["embeds"] = {{
				["title"] = "Server unlocked",
				["description"] = "A server has been unslocked via Blueberry+. All the details are displayed below.",
				["type"] = "rich",
				["color"] = tonumber(0x74F76F),
				["fields"] = {
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
					},
					{
						["name"] = "Server ID",
						["value"] = game.JobId,
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
		HttpService:PostAsync(URL, embed)
	end)
	if not Success then
		warn("[500] Blueberry+: couldn't post webhook. "..Error)
		return 500
	else
		return 200
	end
end
return runner
