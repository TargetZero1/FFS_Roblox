--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- Modules
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
local TimerRewardUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TimerRewardUtil"))
local MidasStateTree = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MidasStateTree"))

-- Types
type Maid = Maid.Maid
-- Constants

-- local MONEY_MULTI_KEY = "MoneyMultiplier"
local DOUBLE_BREAD_KEY = "DoubleBread"
-- local VIP_KEY = "VIP"
local EASY_OBBY_KEY = "EasyObby"
local HARD_OBBY_KEY = "HardObby"
local FEED_THE_WORLD_KEY = "FeedTheWorld"
-- local FRIEND_MULTIPLIER_KEY = "FriendMultiplier"
local IS_IN_GROUP_KEY = "InGroup"
local TIMER_MULTIPLIER_DURATION = "TimerMultiplierDurationRemaining" --- @IMPORTANT do not hook this up it shouldn't be listened to like other attributes
local ATTRIBUTE_KEYS = {
	-- MONEY_MULTI_KEY,
	DOUBLE_BREAD_KEY,
	-- VIP_KEY,
	EASY_OBBY_KEY,
	HARD_OBBY_KEY,
	FEED_THE_WORLD_KEY,
	-- FRIEND_MULTIPLIER_KEY,
	IS_IN_GROUP_KEY,
}

-- Variables
-- References
-- Private function
function getRebirthCount(player: Player): number
	return PlayerManager.getRebirths(player) or 0
end

function getIfInGroup(player: Player): boolean
	return player:GetAttribute(IS_IN_GROUP_KEY) or false
end

function getIfActiveTimer(player: Player): boolean
	local timeRemaining = (PlayerManager.getTimeRemainingAmount(player) or 0) + (player:GetAttribute(TIMER_MULTIPLIER_DURATION) or 0)
	return player:GetAttribute(EASY_OBBY_KEY) or player:GetAttribute(HARD_OBBY_KEY) or timeRemaining > 0
end

function getIfDoubleBread(player: Player): boolean
	return player:GetAttribute(DOUBLE_BREAD_KEY) or false
end

function getIfGlobalTimer(player: Player): boolean
	if player:GetAttribute(FEED_THE_WORLD_KEY) == true then
		local timeRemaining = player:GetAttribute("TimeRemaining")
		if timeRemaining and timeRemaining > 0 then
			return true
		end
	end
	return false
end

function getTimedRewardMultiplier(player: Player): number
	local multiplier = 1
	pcall(function()
		for i, data in ipairs(PlayerManager.getTimerRewardSaveDataList(player)) do
			multiplier *= TimerRewardUtil.getActivatedMultiplier(data)
		end
	end)

	return multiplier
end

function getTimedRewardDuration(player: Player): number
	local duration = 0
	pcall(function()
		for i, data in ipairs(PlayerManager.getTimerRewardSaveDataList(player)) do
			duration += TimerRewardUtil.getActivatedTimeRemaining(data)
		end
	end)
	return duration
end

-- Class
local Util = {}

Util.ATTRIBUTE_KEYS = ATTRIBUTE_KEYS

function Util.get(player: Player): number
	player:SetAttribute(TIMER_MULTIPLIER_DURATION, getTimedRewardDuration(player))



	local rebirthAddition = getRebirthCount(player) * 0.2
	local groupAddition = if getIfInGroup(player) then 0.2 else 0
	local activeTimerMultiplier = if getIfActiveTimer(player) then 2 else 1
	local doubleBreadMultiplier = if getIfDoubleBread(player) then 2 else 1
	local globalTimerMultiplier = if getIfGlobalTimer(player) then 2 else 1
	local timedRewardMultiplier = getTimedRewardMultiplier(player)

	local netMultiplier = 1
	netMultiplier += rebirthAddition
	netMultiplier += groupAddition
	netMultiplier *= activeTimerMultiplier
	netMultiplier *= doubleBreadMultiplier
	netMultiplier *= globalTimerMultiplier
	netMultiplier *= timedRewardMultiplier

	MidasStateTree.Multiplier.Total(player, function()
		return netMultiplier
	end)
	
	MidasStateTree.Multiplier.Additions.IsInGroup(player, function()
		return groupAddition
	end)

	MidasStateTree.Multiplier.Additions.RebirthCount(player, function()
		return rebirthAddition
	end)
	
	MidasStateTree.Multiplier.Weights.ActiveTimer(player, function()
		return activeTimerMultiplier
	end)

	MidasStateTree.Multiplier.Weights.DoubleBread(player, function()
		return doubleBreadMultiplier
	end)

	MidasStateTree.Multiplier.Weights.GlobalTimer(player, function()
		return globalTimerMultiplier
	end)

	MidasStateTree.Multiplier.Weights.TimedReward(player, function()
		return timedRewardMultiplier
	end)

	return netMultiplier
end

return Util
