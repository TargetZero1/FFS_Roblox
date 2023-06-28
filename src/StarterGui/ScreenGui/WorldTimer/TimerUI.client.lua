--!strict
-- Services
local Players = game:GetService("Players")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local Player = Players.LocalPlayer
local TimerUI = assert(script.Parent) :: ImageButton
local TimerText = TimerUI:WaitForChild("Timer") :: TextLabel
-- local BonusUI = UIParent:WaitForChild("BonusActiveText"):FindFirstChild("x2ServerMultiplierActive") :: TextLabel
local _Leaderstats = Player:WaitForChild("leaderstats")

-- Clas

----- FUNCTIONS -----
local function updateDisplay(timerValue: number)
	--check if server timer is hidden
	if TimerUI.Visible == false then
		--display the timer
		TimerUI.Visible = true
	end

	-- --check if bonus UI  is hidden
	-- if(BonusUI.Visible == false) then
	-- 	--display the timer
	-- 	BonusUI.Visible = true
	-- end

	--update the displayed UI

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
		--check if someone has bought the buff for the server
		if Player:GetAttribute("FeedTheWorld") ~= nil then
			if Player:GetAttribute("FeedTheWorld") == true then
				--check if there is time remaining on the clock
				if Player:GetAttribute("TimeRemaining") ~= nil then
					if Player:GetAttribute("TimeRemaining") >= 1 then
						--update the UI
						local timerValue = Player:GetAttribute("TimeRemaining")
						updateDisplay(timerValue)
						--decrease the timer
						Player:SetAttribute("TimeRemaining", Player:GetAttribute("TimeRemaining") - 1)
					else
						--hide the UI
						TimerUI.Visible = false
						Player:SetAttribute("FeedTheWorld", false)
					end
				end
			end
		else
			--hide the UI
			TimerUI.Visible = false
			-- BonusUI.Visible = false
		end
	end
end)
