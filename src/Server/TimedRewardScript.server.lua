--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Packages
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
-- Modules
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
local TimerRewardUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TimerRewardUtil"))
local PetsPet = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Pets"):WaitForChild("Pet"))

-- Types
-- Constants
local ON_REWARD_BASKET_OPEN = "OnOpenRewardBasket"
-- Variables
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PopUpEvents = RemoteEvents:WaitForChild("PopUp")
local MoneyPopUpEvent = PopUpEvents:WaitForChild("DisplayMoneyPopUp") :: RemoteEvent

-- Class
NetworkUtil.onServerEvent(ON_REWARD_BASKET_OPEN, function(player: Player, level: number)
	local didClaimSucceed = PlayerManager.claimTimerReward(player, level)
	if TimerRewardUtil.getIfRewardExists(level) and didClaimSucceed then
		-- cash reward
		local cashReward = assert(TimerRewardUtil.getCashReward(level, PlayerManager.getTotalMoney(player)))
		MoneyPopUpEvent:FireClient(player, cashReward)
		PlayerManager.setMoney(player, assert(PlayerManager.getMoney(player)) + cashReward)

		-- hatch rewards
		local hatchRewardType = TimerRewardUtil.getHatchRewardType(level)
		local hatchRewardAmount = assert(TimerRewardUtil.getHatchRewardAmount(level))
		if hatchRewardType and hatchRewardAmount > 0 then
			for i = 1, hatchRewardAmount do
				PetsPet.invokeHatch(player, hatchRewardType :: any, true)
			end
		end
	end
end)
