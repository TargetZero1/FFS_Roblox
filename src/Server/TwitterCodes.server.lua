--!strict
-- Services
local DatastoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Packages
-- Modules
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
-- Types
-- Constants
local NSD_GROUP_ID = 0000000

-- Variables
-- References
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local RedeemCode = RemoteFunctions:WaitForChild("RedeemCode") :: RemoteFunction
-- Class

--require players to have leaderstats

local TwitterCodes = {
	--code to input// Attribute on leaderstats to change // Amount to change by
	Release = { "Money", 1000 :: any, GroupRequired = false } :: any,
	NorthSea = { "Money", 100 :: any, GroupRequired = false } :: any,
	--	Test = {"Money",0, GroupRequired = false},
	--	GroupTest = {"Money",0, GroupRequired = true},
	--	TimeTest = {"TimeRemaining",30, GroupRequired = false},
	--	TimerTest = {"TimeRemaining",90, GroupRequired = true},
	BREAD = { "Bread", 500 :: any, 240 :: any, GroupRequired = false } :: any,
	SUPERBREAD = { "Bread", 1500 :: any, 180 :: any, GroupRequired = false } :: any,
	MEGABREAD = { "Bread", 2000 :: any, 180 :: any, GroupRequired = false } :: any,
	-- like rewards
	ULTRABREAD = { "Bread", 3000 :: any, 240 :: any, GroupRequired = false } :: any,
	UBERBREAD = { "Bread", 1500 :: any, 180 :: any, GroupRequired = false } :: any,
	--UBERBREAD2 = {"Bread",2000,180, GroupRequired = false},
	--UBERBREAD3 = {"Bread",2500,180, GroupRequired = false},
	--UBERBREAD4 = {"Bread",3000,180, GroupRequired = false},
	--UBERBREAD5 = {"Bread",2500,240, GroupRequired = false},
	--UBERBREAD6 = {"Bread",2500,300, GroupRequired = false},
	--BAKED = {"Bread",2000,180, GroupRequired = false},
	--COOKED = {"Bread",2000,240, GroupRequired = false},
	--YUM = {"Bread",1000,300, GroupRequired = false},
}

-- local function updateRewardDisplay(player: Player, amountToGive: number, leaderboardValueName: string)
-- 	--variables for player reward box UI
-- 	local playerGui = assert(player:WaitForChild("PlayerGui", 20)) :: PlayerGui
-- 	local twitterUI = assert(playerGui:WaitForChild("TwitterUI", 20)) :: ScreenGui
-- 	local rewardFrame = assert(twitterUI:WaitForChild("RewardFrame", 20)) :: Frame
-- 	local rewardText = assert(rewardFrame:WaitForChild("Description", 20)) :: TextLabel

-- 	rewardText.Text = "+ ".. amountToGive .. " ".. leaderboardValueName
-- 	rewardFrame.Visible = true
-- end

--TODO: Probably update this with a proper frame so it doesn't say REWARD: at the top.
local function displayGroupWarningAboutCode(player: Player)
	--variables for player reward box UI
	local playerGui = assert(player:WaitForChild("PlayerGui", 20)) :: PlayerGui
	local twitterUI = assert(playerGui:WaitForChild("TwitterUI", 20)) :: ScreenGui
	local rewardFrame = assert(twitterUI:WaitForChild("RewardFrame", 20)) :: Frame
	local rewardText = assert(rewardFrame:WaitForChild("Description", 20)) :: TextLabel

	rewardText.Text = "Join the North Sea Games group to redeem this code."
	rewardFrame.Visible = true
end

local function displayWarningAboutCode(player: Player)
	--variables for player reward box UI
	local playerGui = assert(player:WaitForChild("PlayerGui", 20)) :: PlayerGui
	local twitterUI = assert(playerGui:WaitForChild("TwitterUI", 20)) :: ScreenGui
	local rewardFrame = assert(twitterUI:WaitForChild("RewardFrame", 20)) :: Frame
	local rewardText = assert(rewardFrame:WaitForChild("Description", 20)) :: TextLabel

	rewardText.Text = "Already Used that code"
	rewardFrame.Visible = true
end

RedeemCode.OnServerInvoke = function(player: Player, code: string)
	local TwitterCodeStore = DatastoreService:GetDataStore("TwitterCodesStore" .. code)
	local PlayerRedeemedCode = TwitterCodeStore:GetAsync(tostring(player.UserId))

	if TwitterCodes[code] and not PlayerRedeemedCode then
		--Check if the code requires you to be in the NSG group.
		if TwitterCodes[code].GroupRequired then
			if not player:IsInGroup(NSD_GROUP_ID) then
				displayGroupWarningAboutCode(player)
				--Return from the function as the player is not in the group and cannot redeem.
				return
			end
		end

		--redeem the code and reward player
		--track stat to change
		local leaderboardValueName: string = TwitterCodes[code][1]
		--track amount to change by
		local amountToGive = TwitterCodes[code][2]

		--check for special timed codes
		local timedRewards = assert(player:WaitForChild("TimedRewards", 20))
		local playerStats = assert(player:WaitForChild("PlayerStats", 20))

		if leaderboardValueName == "TimeRemaining" then
			--use timed rewards stats folder
			local leaderboardValue = assert(timedRewards:WaitForChild(leaderboardValueName, 20)) :: NumberValue

			--increment the value by the reward
			leaderboardValue.Value = leaderboardValue.Value + amountToGive
			PlayerManager.setTimeRemainingAmount(player, PlayerManager.getTimeRemainingAmount(player) + amountToGive)

			TwitterCodeStore:SetAsync(tostring(player.UserId), true)
			return true
			--if keyword is Bread and results in double bonus
		else
			if leaderboardValueName == "Bread" then
				--use timed rewards stats folder
				local leaderboardValue = assert(timedRewards:WaitForChild("TimeRemaining", 20)) :: NumberValue

				--increment the value by the reward
				leaderboardValue.Value = leaderboardValue.Value + TwitterCodes[code][3]
				PlayerManager.setTimeRemainingAmount(player, PlayerManager.getTimeRemainingAmount(player) + TwitterCodes[code][3])

				leaderboardValue.Value = (assert(playerStats:WaitForChild("Money", 20)) :: NumberValue).Value

				--increment the value by the reward
				leaderboardValue.Value = leaderboardValue.Value + amountToGive
				PlayerManager.setMoney(player, PlayerManager.getMoney(player) + amountToGive)

				--increase the total amount of money this player has earned
				-- if PlayerManager.getTotalMoney(player) ~= nil then
				-- 	PlayerManager.setTotalMoney(player, PlayerManager.getTotalMoney(player) + amountToGive)
				-- else
				-- 	PlayerManager.setTotalMoney(player, amountToGive)
				-- end

				TwitterCodeStore:SetAsync(tostring(player.UserId), true)
				return true
			else
				local leaderboardValue = assert(playerStats:WaitForChild(leaderboardValueName, 20)) :: NumberValue

				--increment the value by the reward
				leaderboardValue.Value = leaderboardValue.Value + amountToGive
				PlayerManager.setMoney(player, PlayerManager.getMoney(player) + amountToGive)

				--increase the total amount of money this player has earned
				-- if PlayerManager.getTotalMoney(player) ~= nil then
				-- 	PlayerManager.setTotalMoney(player, PlayerManager.getTotalMoney(player) + amountToGive)
				-- else
				-- 	PlayerManager.setTotalMoney(player, amountToGive)
				-- end

				TwitterCodeStore:SetAsync(tostring(player.UserId), true)
				return true
			end
		end
	else
		if TwitterCodes[code] and PlayerRedeemedCode then
			displayWarningAboutCode(player)
		end

		--error out and warn player they cannot redeem code
		return false
	end
end
