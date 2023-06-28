--!strict
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
-- Packages
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
-- Modules
local TimerRewardUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TimerRewardUtil"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))

-- Types
type TimerRewardSaveData = TimerRewardUtil.TimerRewardSaveData
-- Constants
local ON_REWARD_BASKET_OPEN = "OnOpenRewardBasket"
local GET_PLAYER_TIMER_REWARD_DATA_LIST = "GET_PLAYER_TIMER_REWARD_DATA_LIST"
local ON_UPDATE_PLAYER_TIMER_REWARD_DATA_LIST = "ON_UPDATE_PLAYER_TIMER_REWARD_DATA_LIST"
local BUTTON_TRANSPARENCY = 0.7
local UPDATE_INTERVAL = 0.1
-- Variables
local TimerRewardDataList: {[number]: TimerRewardSaveData} = assert(NetworkUtil.invokeServer(GET_PLAYER_TIMER_REWARD_DATA_LIST), "Failed to get reward data")-- or {}
print("TimerRewardDataList", TimerRewardDataList)
local LevelIgnoreList: {[number]: boolean} = {}

-- References
local ParentFrame = assert(script.Parent) :: ScrollingFrame
local TimedRewardsButton = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("TimedRewardsButton") :: ImageButton
local TimerLabel = TimedRewardsButton:WaitForChild("Timer") :: TextLabel
-- Private Functions

-- Class
function playSound(soundName: string)
	local audio = game:GetService("SoundService"):FindFirstChild(soundName) :: Sound?

	if audio then

		if not audio.IsLoaded then
			audio.Loaded:Wait()
		end

		audio:Play()
	end
end

for i, v in ipairs(ParentFrame:GetChildren()) do
	local level = tonumber(v.Name)
	if level and v:IsA("ImageButton") then
		local mainButton = v:WaitForChild("Claim Button") :: ImageButton
		v.LayoutOrder = level
		mainButton.Activated:Connect(function()
			print(`activating level {level}`)
			LevelIgnoreList[level] = true
			playSound("ClaimReward")
			v.ImageTransparency = BUTTON_TRANSPARENCY
			mainButton.Visible = false
			NetworkUtil.fireServer(ON_REWARD_BASKET_OPEN, level)
		end)
	end
end

task.spawn(function()
	local minimumTimeRemaining = 0

	RunService.RenderStepped:Connect(function()
		if math.round(minimumTimeRemaining) == 0 then
			TimedRewardsButton.Rotation = math.sin(math.rad(180) * tick()*3) * 20
			TimerLabel.Visible = false
		else
			TimedRewardsButton.Rotation = 0
			TimerLabel.Visible = true
			TimerLabel.Text = FormatUtil.time(minimumTimeRemaining, true, false)
		end
	end)

	while true do	
		task.wait(UPDATE_INTERVAL)
		minimumTimeRemaining = 24*60*60
		for _, v in pairs (ParentFrame:GetChildren()) do
			local level = tonumber(v.Name)
			if level and v:IsA("ImageButton") and TimerRewardDataList[level] then
				local saveData = assert(TimerRewardDataList[level])
				local mainButton = v:WaitForChild("Claim Button") :: ImageButton
				local timerUI = v:WaitForChild("Timer") :: TextLabel
				local titleLabel = v:WaitForChild("Title") :: TextLabel
				local timeUntilClaimable = TimerRewardUtil.getTimeUntilClaimable(saveData) 
				local timeUntilReset = TimerRewardUtil.getTimeUntilReset(saveData)
				local isReset = timeUntilReset == 0 and not LevelIgnoreList[level]
				-- print(`IS_{level}_RESET: {isReset}, {timeUntilClaimable}`, "AND", timeUntilReset)
				local isAvailableToClaim = isReset and not LevelIgnoreList[level] and timeUntilClaimable == 0

				v.ImageTransparency = if isReset then 0 else BUTTON_TRANSPARENCY
				mainButton.Visible = isAvailableToClaim
				timerUI.Visible = not mainButton.Visible
				v.Selectable = not mainButton.Visible
				v.Active = v.Selectable
				if isReset then
					timerUI.Text = FormatUtil.time(timeUntilClaimable, true, false)
					titleLabel.Text = `Tier {level}`
					titleLabel.TextSize = 25
					minimumTimeRemaining = math.min(minimumTimeRemaining, timeUntilClaimable)
				else
					titleLabel.Text = "Available Again In:"
					titleLabel.TextSize = 18
					timerUI.Text = FormatUtil.time(timeUntilReset, true, false)
				end
			end			
		end
	end
end)

NetworkUtil.onClientEvent(ON_UPDATE_PLAYER_TIMER_REWARD_DATA_LIST, function(dataList: {[number]: TimerRewardSaveData})
	TimerRewardDataList = dataList
	LevelIgnoreList = {}
	print("Received new save data", dataList)
end)
