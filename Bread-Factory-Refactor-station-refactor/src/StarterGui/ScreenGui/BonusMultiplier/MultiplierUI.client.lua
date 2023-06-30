--!strict
-- Services
local Players = game:GetService("Players")
-- Packages
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

-- Modules
-- Types
type Maid = Maid.Maid

-- Constants
local GET_MULTIPLIER = "GetMultiplier"
local ON_MULTIPLIER_UPDATE = "OnMultiplierUpdate"

-- Variables
-- References
local UIParent = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
local MultiplierUI = UIParent:WaitForChild("BonusMultiplier")
local MultiplierText = MultiplierUI:WaitForChild("Multiplier") :: TextLabel

----- FUNCTIONS -----
local function updateDisplay(multiplier: number)
	--round numbers down
	local function valueRound(number: number, places: number?): string
		places = places or 0
		assert(places)
		return string.format("%." .. tostring(places) .. "f", number)
	end

	--round to 2 decimal places
	MultiplierText.Text = "X " .. valueRound(multiplier, 2)
end

NetworkUtil.onClientEvent(ON_MULTIPLIER_UPDATE, updateDisplay)
updateDisplay(NetworkUtil.invokeServer(GET_MULTIPLIER))
-- coroutine.wrap(function()
-- 	while wait(1) do
-- 		updateDisplay()
-- 	end
-- end)()
