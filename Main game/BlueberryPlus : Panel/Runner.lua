--// Variables \\--
local runner = {}
local Menu = script.Parent.MainFrame.Menu
local Screens = script.Parent.MainFrame.Screens
local IntroFrames = script.Parent.MainFrame.IntroFrames

--// Presets \\--
Menu.Size = UDim2.new(0, 0, 0.87, 0)
Menu.Visible = false
script.Parent.MainFrame.Size = UDim2.new(0, 0, 0.353, 0)
script.Parent.MainFrame.Visible = false

--// Functions \\--
function runner:openPanel()
	if script.Parent.OpenButton then script.Parent.OpenButton.Visible = false end
	IntroFrames.IntroFrame1.Size = UDim2.new(0, 0, 1, 0)
	IntroFrames.IntroFrame2.Size = UDim2.new(0, 0, 1, 0)
	IntroFrames.IntroFrame3.Size = UDim2.new(0, 0, 1, 0)
	IntroFrames.IntroFrame2.Visible = false
	IntroFrames.IntroFrame3.Visible = false
	IntroFrames.IntroFrame1.Visible = true
	IntroFrames.IntroFrame1.Size = UDim2.new(1, 0, 1, 0)
	script.Parent.MainFrame.Visible = true
	script.Parent.MainFrame:TweenSize(UDim2.new(0.431, 0, 0.353, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.7)
	script.Parent.MainFrame.Position = UDim2.new(0.231, 0, 0.623, 0)
	IntroFrames.IntroFrame2.Visible = true
	IntroFrames.IntroFrame2.Size = UDim2.new(0, 0, 1, 0)
	IntroFrames.IntroFrame3.Visible = true
	IntroFrames.IntroFrame3.Size = UDim2.new(0, 0, 1, 0)
	IntroFrames.IntroFrame2:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.4)
	task.wait(0.2)
	IntroFrames.IntroFrame3:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.4)
	task.wait(1.3)
	IntroFrames.IntroFrame3:TweenSize(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.4)
	task.wait(0.2)
	IntroFrames.IntroFrame2:TweenSize(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.4)
	task.wait(0.2)
	IntroFrames.IntroFrame1:TweenSize(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.4)
	task.wait(0.55)
	IntroFrames.IntroFrame1.Visible = false
	IntroFrames.IntroFrame2.Visible = false
	IntroFrames.IntroFrame3.Visible = false
end

function runner:closePanel()
	if script.Parent.OpenButton then script.Parent.OpenButton.Visible = true end
	IntroFrames.IntroFrame3.Visible = true
	IntroFrames.IntroFrame3:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.5)
	task.wait(0.7)
	script.Parent.MainFrame:TweenSize(UDim2.new(0, 0, 0.353, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.5)
	task.wait(0.6)
	script.Parent.MainFrame.Visible = false
	IntroFrames.IntroFrame3.Visible = false
end

function runner:openMenu()
	Menu.Visible = true
	Menu:TweenSize(UDim2.new(0.22, 0, 0.87, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.7)
	for index, screen in pairs(Screens:GetChildren()) do
		if screen:IsA("Frame") then
			screen:TweenSize(UDim2.new(0.78, 0, 0.9, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.7)
		end
	end
end

function runner:closeMenu()
	script.Parent.MainFrame.Menu.IsOpen.Value = false
	Menu:TweenSize(UDim2.new(0, 0, 0.87, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.7)
	for index, screen in pairs(Screens:GetChildren()) do
		if screen:IsA("Frame") then
			screen:TweenSize(UDim2.new(1, 0, 0.9, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.7)
		end
	end
	task.wait(0.6)
	Menu.Visible = false
end

function runner:showScreen(name)
	if not name then warn("[404] Blueberry+: missing screen name to show.") return end
	local Screen = Screens[name]
	if not Screen then warn("[404] Blueberry+: screen wasn't found.") return end
	for index, screen in pairs(Screens:GetChildren()) do
		if screen:IsA("Frame") then
			screen.Visible = false
		end
	end
	Screen.Visible = true
end
return runner
