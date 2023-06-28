--!strict
-- Services
-- Packages
-- Modules
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
-- Types
-- Constants
-- Variables
-- References
-- Class

--function for decreasing time reminaing amount for bonuses
local function DecreaseTimeRemaining(player: Player)
	if PlayerManager.getTimeRemainingAmount(player) ~= nil then
		if assert(PlayerManager.getTimeRemainingAmount(player)) >= 1 then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) - 1)
		end
	end
end

--wait for player manager to finish setting up before begining to track time remaining
PlayerManager.PlayerAdded:Connect(function(player: Player)
	--decrement the timer every second
	spawn(function()
		while true do
			wait(1)
			--track time played
			DecreaseTimeRemaining(player)
		end
	end)
end)
