--!strict
-- Services
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

-- Packages
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))

-- Modules
-- Types
-- Constants
local GET_IF_RUNNING = "GetIfRunning"

-- Variables
local LastPress = 0
-- References
-- Private Functions
-- Class
ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, player: Player)
	if prompt.Name == "DropTrigger" and player.UserId == Players.LocalPlayer.UserId then
		LastPress = tick()
	end
end)

NetworkUtil.onClientInvoke(GET_IF_RUNNING, function()
	return tick() - LastPress > 10
end)