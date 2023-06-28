--!strict
-- Services
local Players = game:GetService("Players")
-- Packages
-- Modules
-- Types
-- Constants
local TIMER_MULTIPLIER_DURATION = "TimerMultiplierDurationRemaining"

-- Variables
-- References
local Player = Players.LocalPlayer
local TimerUI = assert(script.Parent) :: ImageButton
local TimerText = TimerUI:WaitForChild("Timer") :: TextLabel
local TimedRewards = Player:WaitForChild("TimedRewards") :: Folder
local TimeRemaining = TimedRewards:WaitForChild("TimeRemaining") :: NumberValue

-- local BonusUI = UIParent:WaitForChild("BonusActiveText"):FindFirstChild("x2ServerMultiplierActive") :: TextLabel
local _Leaderstats = Player:WaitForChild("leaderstats")

function getTimeRemaining(): number
	return TimeRemaining.Value + (Player:GetAttribute(TIMER_MULTIPLIER_DURATION) or 0)
end

function updateDisplay()
	local timerValue = getTimeRemaining()
	--check if server timer is hidden
	TimerUI.Visible = timerValue > 0

	--check if timer has less than 1 minute left
	if timerValue <= 59 then
		--format the UI correctly
		if timerValue > 9 then
			TimerText.Text = "00:" .. tostring(timerValue)
		else
			TimerText.Text = "0:0" .. tostring(timerValue)
		end
	else
		--format the Ui correctly
		local timeformat = math.floor(timerValue / 60) .. ":" .. (timerValue % 60)
		if timerValue % 60 >= 0 and timerValue % 60 <= 9 then
			timeformat = math.floor(timerValue / 60) .. ":0" .. (timerValue % 60)
		end
		--display the UI
		TimerText.Text = timeformat
	end
end

task.spawn(function()
	while true do
		wait(1)
		updateDisplay()
	end
end)
