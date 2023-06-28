--!strict
--script to return what position the player is in on a specific leaderboard
-- Services
local DatastoreService = game:GetService("DataStoreService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Packages
-- Modules
-- Types
-- Constants
local REFRESH_RATE = 10

-- Variables
local DonateDataStore = DatastoreService:GetOrderedDataStore("DonateLeaderboard")
local BreadDataStore = DatastoreService:GetOrderedDataStore("BreadLeaderboard2")
local PlayTimeDataStore = DatastoreService:GetOrderedDataStore("TimeLeaderboard2")
local RebirthDataStore = DatastoreService:GetOrderedDataStore("RebirthsLeaderboard2")
local DonationTable: DataStorePages?
local MoneyTable: DataStorePages?
local PlayTimeTable: DataStorePages?
local RebirthTable: DataStorePages?

-- References
local AdminSettings = ReplicatedFirst:WaitForChild("AdminControls")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local GetRankEvent = RemoteFunctions:WaitForChild("GetRankEvent") :: RemoteFunction

------ ADMIN SETTINGS -----
if AdminSettings then
	if AdminSettings:GetAttribute("LeaderboardRefreshTimer") ~= nil then
		if AdminSettings:GetAttribute("LeaderboardRefreshTimer") >= 10 then
			REFRESH_RATE = AdminSettings:GetAttribute("LeaderboardRefreshTimer")
		end
	end
end

--function to update tables of leaderboard values
local function updateTables()
	--Donation table
	--avoid errors breaking game
	pcall(function()
		--variable for all player data, False = decending
		DonationTable = DonateDataStore:GetSortedAsync(false, 50, 0, math.huge)
		--returns all items on current page
	end)

	--Money table
	--avoid errors breaking game
	pcall(function()
		--variable for all player data, False = decending
		MoneyTable = BreadDataStore:GetSortedAsync(false, 50, 0, math.huge)
	end)

	--Play time table
	--avoid errors breaking game
	pcall(function()
		--variable for all player data, False = decending
		PlayTimeTable = PlayTimeDataStore:GetSortedAsync(false, 50, 0, math.huge)
	end)

	--Rebirth table
	--avoid errors breaking game
	pcall(function()
		--variable for all player data, False = decending
		RebirthTable = RebirthDataStore:GetSortedAsync(false, 50, 0, math.huge)
	end)
end

--functions to find player rank in each table
local function getPlayerDonationRank(player: Player): number?
	if not DonationTable then
		return nil
	end
	assert(DonationTable)
	local page = DonationTable:GetCurrentPage()

	for plrRank, data in ipairs(page) do -- you should use ipairs for numerical tables (arrays) which GetCurrentPage returns
		--	print(data.key, player.UserId, plrRank)
		if tonumber(data.key) == tonumber(player.UserId) then
			return plrRank -- returns the player's rank
		end
	end

	return nil
end

local function getPlayerMoneyRank(player: Player): number?
	if not MoneyTable then
		return nil
	end
	assert(MoneyTable)
	local page = MoneyTable:GetCurrentPage()

	for plrRank, data in ipairs(page) do -- you should use ipairs for numerical tables (arrays) which GetCurrentPage returns
		--	print(data.key, player.UserId, plrRank)
		if tonumber(data.key) == tonumber(player.UserId) then
			return plrRank -- returns the player's rank
		end
	end

	return nil
end

local function getPlayerTimeRank(player: Player): number?
	if not PlayTimeTable then
		return nil
	end
	assert(PlayTimeTable)
	local page = PlayTimeTable:GetCurrentPage()

	for plrRank, data in ipairs(page) do -- you should use ipairs for numerical tables (arrays) which GetCurrentPage returns
		--	print(data.key, player.UserId, plrRank)
		if tonumber(data.key) == tonumber(player.UserId) then
			return plrRank -- returns the player's rank
		end
	end

	return nil
end

local function getPlayerRebirthRank(player: Player): number?
	if not RebirthTable then
		return nil
	end
	assert(RebirthTable)
	local page = RebirthTable:GetCurrentPage()

	for plrRank, data in ipairs(page) do -- you should use ipairs for numerical tables (arrays) which GetCurrentPage returns
		--	print(data.key, player.UserId, plrRank)
		if tonumber(data.key) == tonumber(player.UserId) then
			return plrRank -- returns the player's rank
		end
	end

	return nil
end

spawn(function()
	updateTables()
	--only update if there are players worth updating

	while #Players:GetChildren() > 0 do
		wait(REFRESH_RATE)
	end
end)

--event to listen for to connect correct function call to
GetRankEvent.OnServerInvoke = function(player: Player, tableToSearch: number): number?
	local rank: number?

	--search the donation table
	if tableToSearch == 0 then
		rank = getPlayerDonationRank(player)
	end
	--search the Money table
	if tableToSearch == 1 then
		rank = getPlayerMoneyRank(player)
	end
	--search the PLayer time table
	if tableToSearch == 2 then
		rank = getPlayerTimeRank(player)
	end
	--search the rebirth table
	if tableToSearch == 3 then
		rank = getPlayerRebirthRank(player)
	end

	return rank
end
