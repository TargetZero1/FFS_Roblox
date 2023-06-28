--!strict
local Players = game:GetService("Players")
-- Services
-- Packages
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- Modules
local MultiplierUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("MultiplierUtil"))
-- Types
type Maid = Maid.Maid

-- Constants
local ATTRIBUTE_KEYS = MultiplierUtil.ATTRIBUTE_KEYS
local GET_MULTIPLIER = "GetMultiplier"
local ON_MULTIPLIER_UPDATE = "OnMultiplierUpdate"

-- Variables
-- References
-- Class

function trackPlayer(player: Player): ()
	print("Tracking player multipliers")
	local maid = Maid.new()
	maid:GiveTask(player.Destroying:Connect(function()
		maid:Destroy()
	end))

	local function updateClient(): ()
		local multiplier = MultiplierUtil.get(player)
		print("UPDATE MULTI", multiplier)
		NetworkUtil.fireClient(ON_MULTIPLIER_UPDATE, player, multiplier)
	end

	for i, key in ipairs(ATTRIBUTE_KEYS) do
		maid:GiveTask(player:GetAttributeChangedSignal(key):Connect(updateClient))
	end
	updateClient()
end

NetworkUtil.onServerInvoke(GET_MULTIPLIER, function(player: Player): number
	return MultiplierUtil.get(player)
end)
NetworkUtil.getRemoteEvent(ON_MULTIPLIER_UPDATE)
Players.PlayerAdded:Connect(trackPlayer)
