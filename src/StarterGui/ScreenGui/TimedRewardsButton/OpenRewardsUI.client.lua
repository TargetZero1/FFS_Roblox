--!strict
-- Services
local Players = game:GetService("Players")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local Button = assert(script.Parent) :: ImageButton
local Shop = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
local LeaderboardFrame = Shop:WaitForChild("Leaderboard") :: Frame
local MainShopFrame = Shop:WaitForChild("MainShopFrame") :: Frame
local PersonalStatsPage = Shop:WaitForChild("PersonalStatsPage") :: Frame
local ShopUI = Shop:WaitForChild("DailyRewardsPage") :: Frame
local ClaimButton = Button:WaitForChild("Claim Button") :: ImageButton

-- Private Functions
function playSound(soundName: string): ()
	local audio = game:GetService("SoundService"):FindFirstChild(soundName) :: Sound?
	if audio then
		if not audio.IsLoaded then
			audio.Loaded:Wait()
		end

		audio:Play()
	end
end

function onTriggered(): ()
	--make frame visible
	if ShopUI.Visible == false then
		--if leaderboard tab is open close it
		if LeaderboardFrame.Visible == true then
			LeaderboardFrame.Visible = false
		end

		--if shop tab is open close it
		if MainShopFrame.Visible == true then
			MainShopFrame.Visible = false
		end

		if PersonalStatsPage.Visible == true then
			PersonalStatsPage.Visible = false
		end

		ShopUI.Visible = true
		playSound("DropperSound")
	else
		ShopUI.Visible = false
	end
end

-- Class
----- FUNCTIONS -----
Button.Activated:Connect(function()
	onTriggered()
end)
ClaimButton.Activated:Connect(function()
	onTriggered()
end)
