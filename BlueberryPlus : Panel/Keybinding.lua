--// Dependencies \\--
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local KeybindString = ReplicatedStorage:WaitForChild('BlueberryPlus_Replicated', 5):WaitForChild('ClientPermissions', 5):WaitForChild('Keybind', 5)
local ScreenButton = ReplicatedStorage:WaitForChild('BlueberryPlus_Replicated', 5):WaitForChild('ClientPermissions', 5):WaitForChild('ScreenButton', 5)
local OpenPanelEvent = ReplicatedStorage:WaitForChild('BlueberryPlus_Replicated', 5):WaitForChild('OpenPanel', 5)
local Runner = require(script.Parent.Runner)


--// Check \\--
if not KeybindString then warn("[!] Blueberry+: couldn't find keybinding string.") return end

--// Action \\--
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode[KeybindString.Value] then
		Runner:openPanel()
	end
end)

OpenPanelEvent.OnClientEvent:Connect(function()
	Runner:openPanel()
end)

script.Parent.OpenButton.MouseButton1Click:Connect(function()
	Runner:openPanel()
end)

if not ScreenButton.Value then
	script.Parent.OpenButton.TextTransparency = 1
	script.Parent.OpenButton.BackgroundTransparency = 1
	script.Parent.OpenButton.Position = UDim2.new(100, 0, 100, 0)
end
