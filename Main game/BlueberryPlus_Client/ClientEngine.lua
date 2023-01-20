print("🚀 This game uses Blueberry Plus to take moderation to another level.") -- Remove if you wish to hide the console watermark.

--// Dependencies \\--
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--// Action \\--
ReplicatedStorage:WaitForChild('BlueberryPlus_Replicated', 5):WaitForChild('TriggerTeleportMessage', 5).OnClientEvent:Connect(function()
	script.Parent.BlueberryPlus_Teleporting_Blur.Parent = game:GetService('Lighting')
	script.Parent.BlueberryPlus_Teleporting_Screen.MainFrame.Visible = true
end)
