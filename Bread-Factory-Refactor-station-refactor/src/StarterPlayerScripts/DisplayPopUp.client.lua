--!strict
--script to control when to display a pop up for the player
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local PopUpFolder = RemoteEventsFolder:WaitForChild("PopUp")
local BindableEventFolder = ReplicatedStorage:WaitForChild("BindableEvents")
--reference to  rebirth Pop Up event
local RebirthPopUpEvent = PopUpFolder:WaitForChild("DisplayRebirthPopUp", 20) :: RemoteEvent
--reference to obby bindable event
local ObbyPopUpEvent = BindableEventFolder:WaitForChild("DisplayObbyPopUp", 20) :: BindableEvent
--reference to  Money Pop Up event
local MoneyPopUpEvent = PopUpFolder:WaitForChild("DisplayMoneyPopUp", 20) :: RemoteEvent
--reference to  Money Pop Up event
local BreadCoinPopUpEvent = PopUpFolder:WaitForChild("DisplayBreadPopUp", 20) :: RemoteEvent
--reference to  Money Pop Up event
local TimerPopUpEvent = PopUpFolder:WaitForChild("DisplayTimerPopUp", 20) :: RemoteEvent
-- Class
--reference to Pop Up UIs
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

function playSound(soundName)
	local audio = SoundService:FindFirstChild(soundName) :: Sound?
	if audio then
		if not audio.IsLoaded then
			audio.Loaded:Wait()
		end

		audio:Play()
	end
end

--pop up displays when rebirth option is available
function displayRebirth()
	--reference to Pop Up UIs
	local PopUpGUI = PlayerGui:WaitForChild("PopUpGui", 20)
	assert(PopUpGUI)
	local PopUps = PopUpGUI:WaitForChild("PopUps", 20) :: GuiObject?
	assert(PopUps)
	local RebirthPopUp = PopUps:WaitForChild("RebirthPopUp", 20) :: GuiObject?
	assert(RebirthPopUp)
	RebirthPopUp.Visible = true
	--trigger the sound effect
	playSound("RebirthSound")
	print("rebirth UI shown")

	--wait 2.5 seconds then close
	task.wait(2.5)
	RebirthPopUp.Visible = false
	print("rebirth ui hidden")
end
--pop up displays when the obbys have reset
function displayObbyReset()
	--reference to Pop Up UIs
	local PopUpGUI = PlayerGui:WaitForChild("PopUpGui", 20)
	assert(PopUpGUI)
	local PopUps = PopUpGUI:WaitForChild("PopUps", 20) :: GuiObject?
	assert(PopUps)
	local ObbyPopUp = PopUps:WaitForChild("ObbyPopUp", 20) :: GuiObject?
	assert(ObbyPopUp)

	ObbyPopUp.Visible = true
	--wait 2.5 seconds then close
	task.wait(2.5)
	ObbyPopUp.Visible = false
end
--pop up displays how much money they have just aquired from the last delivery
function displayMoney(money: string)
	--reference to Pop Up UIs
	local PopUpGUI = PlayerGui:WaitForChild("PopUpGui", 20)
	assert(PopUpGUI)
	local MoneyPopUp = PopUpGUI:WaitForChild("MoneyPopUp", 20) :: GuiObject?
	assert(MoneyPopUp)
	local MoneyUI = MoneyPopUp:WaitForChild("MoneyLabel", 20) :: TextLabel?
	assert(MoneyUI)
	MoneyUI.Text = "+$" .. money

	MoneyPopUp.Visible = true
	--wait 2.5 seconds then close
	task.wait(1.5)
	MoneyPopUp.Visible = false
	MoneyUI.Text = "+$0"
end
--pop up displays how much money they have just aquired from the last delivery
function displayBread(breadCoins: string)
	--reference to Pop Up UIs
	local PopUpGUI = PlayerGui:WaitForChild("PopUpGui", 20)
	assert(PopUpGUI)

	local PopUps = PopUpGUI:WaitForChild("PopUps", 20) :: GuiObject?
	assert(PopUps)

	local BreadPopUp = PopUps:WaitForChild("BreadCoinsPopUp", 20) :: GuiObject?
	assert(BreadPopUp)

	local BreadUI = BreadPopUp:WaitForChild("Lable", 20) :: TextLabel?
	assert(BreadUI)

	BreadUI.Text = "+" .. breadCoins .. "Bread Coins"

	BreadPopUp.Visible = true
	--wait 2.5 seconds then close
	task.wait(1.5)
	BreadPopUp.Visible = false
	BreadUI.Text = "+$0"
end
--pop up displays how much money they have just aquired from the last delivery
function displayTime(timeText: string)
	--reference to Pop Up UIs
	local PopUpGUI = PlayerGui:WaitForChild("PopUpGui", 20)
	assert(PopUpGUI)
	local PopUps = PopUpGUI:WaitForChild("PopUps", 20) :: GuiObject?
	assert(PopUps)
	local TimePopUp = PopUps:WaitForChild("TimerPopUp", 20) :: GuiObject?
	assert(TimePopUp)

	local TimeUI = TimePopUp:WaitForChild("Label", 20) :: TextLabel?
	assert(TimeUI)

	TimeUI.Text = "+ 2X for" .. timeText .. "s"

	TimePopUp.Visible = true
	--wait 2.5 seconds then close
	task.wait(1.5)
	TimePopUp.Visible = false
	TimeUI.Text = "+$0"
end

--listen for when server fires the resepective pop up events
RebirthPopUpEvent.OnClientEvent:Connect(displayRebirth)
ObbyPopUpEvent.Event:Connect(displayObbyReset)
MoneyPopUpEvent.OnClientEvent:Connect(function(...)
	displayMoney(...)
end)
BreadCoinPopUpEvent.OnClientEvent:Connect(function(...)
	displayBread(...)
end)
TimerPopUpEvent.OnClientEvent:Connect(function(...)
	displayTime(...)
end)
