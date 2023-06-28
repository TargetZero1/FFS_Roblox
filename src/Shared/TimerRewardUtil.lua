--!strict
-- Services
-- Packages
-- Modules
local TimerRewardData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("TimerRewardData"))
local PetModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetModifierUtil"))
-- Types
type RewardData = TimerRewardData.EntryData
type PetClass = PetModifierUtil.PetClass

export type TimerSessionSaveData = {
	StartTimestamp: number,
	FinishTimestamp: number?,
	ClaimedAt: number?,
}
export type TimerRewardSaveData = {
	Level: number,
	IgnoreMultiplier: boolean,
	ClaimTimestamp: number,
	Sessions: { [number]: TimerSessionSaveData },
}

-- Constants
local RESET_DAY_DURATION = 1
local SECONDS_IN_MINUTE = 60
local SECONDS_IN_HOUR = 60 * SECONDS_IN_MINUTE
local SECONDS_IN_DAY = 24 * SECONDS_IN_HOUR
local RESET_SECONDS_DURATION = RESET_DAY_DURATION * SECONDS_IN_DAY
-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

Util.MAX_LEVEL = #TimerRewardData

function Util.getRewardData(level: number): RewardData?
	if TimerRewardData[level] then
		return TimerRewardData[level]
	end
	return nil
end

function Util.getIfRewardExists(level: number): boolean
	return TimerRewardData[level] ~= nil
end

function Util.getUnlockDuration(level: number): number?
	local data = Util.getRewardData(level)
	if data then
		return data.UnlockDuration
	end
	return nil
end

function Util.getCashReward(level: number, currentCashAmount: number): number?
	local data = Util.getRewardData(level)
	if data then
		if data.MinimumCashIncreasePercent == 0 then
			return data.CashReward
		else
			return math.max(math.round(data.MinimumCashIncreasePercent * currentCashAmount), data.CashReward)
		end
	end
	return nil
end

function Util.getMultiplierReward(level: number): number?
	local data = Util.getRewardData(level)
	if data then
		return data.MultiplierReward
	end
	return nil
end

function Util.getMultiplierRewardDuration(level: number): number?
	local data = Util.getRewardData(level)
	if data then
		return data.MultiplierRewardDuration
	end
	return nil
end

function Util.getHatchRewardType(level: number): PetClass?
	local data = Util.getRewardData(level)
	if data then
		if data.HatchRewardType == "None" then
			return nil
		else
			return data.HatchRewardType :: PetClass
		end
	end
	return nil
end

function Util.getHatchRewardAmount(level: number): number?
	local data = Util.getRewardData(level)
	if data then
		return data.HatchRewardAmount
	end
	return nil
end

function Util.getTimestamp(): number
	local dateTime = DateTime.now()
	return dateTime.UnixTimestamp
end

function Util.getLastClaimTimestamp(saveData: TimerRewardSaveData): number
	local lastClaimTimestamp = 0
	for i, sessionData in ipairs(saveData.Sessions) do
		if sessionData.ClaimedAt then
			lastClaimTimestamp = math.max(sessionData.ClaimedAt, lastClaimTimestamp)
		end
	end
	return lastClaimTimestamp
end

function Util.getTimeInGameSinceClaim(saveData: TimerRewardSaveData): number
	local lastClaimTimestamp = Util.getLastClaimTimestamp(saveData)
	local duration = 0
	for i, sessionData in ipairs(saveData.Sessions) do
		local start = if sessionData.ClaimedAt then math.max(sessionData.ClaimedAt, lastClaimTimestamp) else math.max(lastClaimTimestamp, sessionData.StartTimestamp)
		local finish = if sessionData.FinishTimestamp then sessionData.FinishTimestamp else Util.getTimestamp()
		if start < lastClaimTimestamp then
			start = lastClaimTimestamp
		end
		duration += math.max(finish - start, 0)
	end
	return duration
end

function Util.getTimeUntilClaimable(saveData: TimerRewardSaveData): number
	local timeInGame = Util.getTimeInGameSinceClaim(saveData)
	local unlockDuration = assert(Util.getUnlockDuration(saveData.Level))
	return math.max(unlockDuration - timeInGame, 0)
end

function Util.getTimeUntilReset(saveData: TimerRewardSaveData): number
	local claimTimestamp = Util.getLastClaimTimestamp(saveData)
	local currentTimestamp = Util.getTimestamp()
	local difference = currentTimestamp - claimTimestamp
	return math.max(RESET_SECONDS_DURATION - difference, 0)
end

function Util.getIfActivated(saveData: TimerRewardSaveData): boolean
	local timeSinceClaim = Util.getTimeInGameSinceClaim(saveData)
	local duration = assert(Util.getMultiplierRewardDuration(saveData.Level))
	return duration >= timeSinceClaim
end

function Util.getActivatedTimeRemaining(saveData: TimerRewardSaveData): number
	if Util.getIfActivated(saveData) and not saveData.IgnoreMultiplier then
		local timeSinceClaim = Util.getTimeInGameSinceClaim(saveData)
		local duration = assert(Util.getMultiplierRewardDuration(saveData.Level))
		return math.max(duration - timeSinceClaim, 0)
	else
		return 0
	end
end

function Util.getActivatedMultiplier(saveData: TimerRewardSaveData): number
	if Util.getIfActivated(saveData) and not saveData.IgnoreMultiplier then
		return assert(Util.getMultiplierReward(saveData.Level))
	else
		return 1
	end
end

return Util
