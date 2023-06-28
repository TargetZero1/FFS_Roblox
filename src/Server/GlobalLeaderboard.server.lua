--!strict
-- Services
local DatastoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Packages
-- Modules
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))

-- Types
type DataItem = {
	key: string,
	value: number,
}

-- Constants
local HUGE_INT = 1000000000
local REFRESH_RATE = 10
-- Variables
local PlayerStats = {}

local DonationTable = {} :: { [number]: DataItem }
local MoneyTable = {} :: { [number]: DataItem }
local PlayTimeTable = {} :: { [number]: DataItem }
local RebirthTable = {} :: { [number]: DataItem }

local DonateDataStore = DatastoreService:GetOrderedDataStore("DonateLeaderboard")
local BreadDataStore = DatastoreService:GetOrderedDataStore("BreadLeaderboard2")
local PlayTimeDataStore = DatastoreService:GetOrderedDataStore("TimeLeaderboard2")
local RebirthDataStore = DatastoreService:GetOrderedDataStore("RebirthsLeaderboard2")

-- References
local AdminSettings = ReplicatedFirst:WaitForChild("AdminControls")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local GlobalLeaderboardFunctions = RemoteFunctions:WaitForChild("GlobalLeaderboard")
local GlobalLeaderboardBindableEvents = BindableEvents:WaitForChild("GlobalLeaderboard")

local ShowDonationBoardEvent = GlobalLeaderboardFunctions:WaitForChild("ShowDonationBoard") :: RemoteFunction
local ShowMoneyBoardEvent = GlobalLeaderboardFunctions:WaitForChild("ShowMoneyBoard") :: RemoteFunction
local ShowPlayTimeBoardEvent = GlobalLeaderboardFunctions:WaitForChild("ShowPlayTimeBoard") :: RemoteFunction
local ShowRebirthBoardEvent = GlobalLeaderboardFunctions:WaitForChild("ShowRebirthBoard") :: RemoteFunction

local ShowDonationBoardBindableEvent = GlobalLeaderboardBindableEvents:WaitForChild("ShowDonationBoard") :: BindableEvent
local ShowMoneyBoardBindableEvent = GlobalLeaderboardBindableEvents:WaitForChild("ShowMoneyBoard") :: BindableEvent
local ShowPlayTimeBoardBindableEvent = GlobalLeaderboardBindableEvents:WaitForChild("ShowPlayTimeBoard") :: BindableEvent
local ShowRebirthBoardBindableEvent = GlobalLeaderboardBindableEvents:WaitForChild("ShowRebirthBoard") :: BindableEvent

if AdminSettings then
	if AdminSettings:GetAttribute("LeaderboardRefreshTimer") ~= nil then
		if AdminSettings:GetAttribute("LeaderboardRefreshTimer") >= 10 then
			REFRESH_RATE = AdminSettings:GetAttribute("LeaderboardRefreshTimer")
		end
	end
end

--function to update tables of leaderboard values
function updateTables()
	--Donation table
	--avoid errors breaking game
	local success1, msg1 = pcall(function()
		--variable for all player data, False = decending
		local data = DonateDataStore:GetSortedAsync(false, 50, 0, HUGE_INT)
		--returns all items on current page
		DonationTable = data:GetCurrentPage()
		--returns all items on current page
	end)
	if not success1 then
		warn(msg1)
	end

	--Money table
	--avoid errors breaking game
	local success2, msg2 = pcall(function()
		--variable for all player data, False = decending
		local data = BreadDataStore:GetSortedAsync(false, 50, 0, HUGE_INT)
		--returns all items on current page
		MoneyTable = data:GetCurrentPage()
		--returns all items on current page
	end)
	if not success2 then
		warn(msg2)
	end
	--Play time table
	--avoid errors breaking game
	local success3, msg3 = pcall(function()
		--variable for all player data, False = decending
		local data = PlayTimeDataStore:GetSortedAsync(false, 50, 0, HUGE_INT)
		--returns all items on current page
		PlayTimeTable = data:GetCurrentPage()
		--returns all items on current page
	end)
	if not success3 then
		warn(msg3)
	end
	--Rebirth table
	--avoid errors breaking game
	local success4, msg4 = pcall(function()
		--variable for all player data, False = decending
		local data = RebirthDataStore:GetSortedAsync(false, 50, 0, HUGE_INT)
		--returns all items on current page
		RebirthTable = data:GetCurrentPage()
		--returns all items on current page
	end)
	if not success4 then
		warn(msg4)
	end
end

--function used to update leaderboard to display top donaters
local function getDonateLeaderboard(player: Player?): { [number]: DataItem }
	return DonationTable
end

--function used to update leaderboard to display top Money
local function getMoneyLeaderboard(player: Player?): { [number]: DataItem }
	return MoneyTable
end

--function used to update leaderboard to display top play time
local function getPlayTimeLeaderboard(player: Player?): { [number]: DataItem }
	return PlayTimeTable
end

--function used to update leaderboard to display top Rebirth
local function getRebirthLeaderboard(player: Player?): { [number]: DataItem }
	return RebirthTable
end

ShowMoneyBoardEvent.OnServerInvoke = getMoneyLeaderboard
ShowDonationBoardEvent.OnServerInvoke = getDonateLeaderboard
ShowPlayTimeBoardEvent.OnServerInvoke = getPlayTimeLeaderboard
ShowRebirthBoardEvent.OnServerInvoke = getRebirthLeaderboard

--FUNCTION TO SAVE LEADERBOARD STATS
local function saveLeaderboards(player: Player)
	if player.UserId > 0 then
		--check if the player has a bread delivered amount already
		if PlayerManager.getBreadDeliveredAmount(player) ~= nil then
			--check if value has changed
			if PlayerStats[player.Name]["Bread"] ~= PlayerManager.getBreadDeliveredAmount(player) then
				--save the updated value
				PlayerStats[player.Name]["Bread"] = PlayerManager.getBreadDeliveredAmount(player)

				--save the data to the datastore
				pcall(function()
					BreadDataStore:SetAsync(tostring(player.UserId), PlayerManager.getBreadDeliveredAmount(player))
				end)
			end
		end
		--check if the player has a rebirth amount already
		if PlayerManager.getRebirths(player) ~= nil then
			--check if value has changed
			if PlayerStats[player.Name]["Rebirth"] ~= PlayerManager.getRebirths(player) then
				--save the updated value
				PlayerStats[player.Name]["Rebirth"] = PlayerManager.getRebirths(player)

				--save the data to the datastore
				pcall(function()
					RebirthDataStore:SetAsync(tostring(player.UserId), assert(PlayerManager.getRebirths(player)))
				end)
			end
		end
		--check if the player has a playtime amount already
		if PlayerManager.getPlayTime(player) ~= nil then
			--check if value has changed
			if PlayerStats[player.Name]["PlayTime"] ~= PlayerManager.getPlayTime(player) then
				--save the updated value
				PlayerStats[player.Name]["PlayTime"] = PlayerManager.getPlayTime(player)

				--save the data to the datastore
				pcall(function()
					PlayTimeDataStore:SetAsync(tostring(player.UserId), PlayerManager.getPlayTime(player))
				end)
			end
		end
		--check if the player has a Donated amount already
		if PlayerManager.getDonateAmount(player) ~= nil then
			--check if value has changed
			if PlayerStats[player.Name]["DonatedAmount"] ~= PlayerManager.getDonateAmount(player) then
				--save the updated value
				PlayerStats[player.Name]["DonatedAmount"] = PlayerManager.getDonateAmount(player)

				--save the data to the datastore
				pcall(function()
					DonateDataStore:SetAsync(tostring(player.UserId), PlayerManager.getDonateAmount(player))
				end)
			end
		end
	end
end
function boot()
	updateTables()

	--set up leaderboard parts on start
	ShowMoneyBoardBindableEvent:Fire(getMoneyLeaderboard(nil))
	ShowDonationBoardBindableEvent:Fire(getDonateLeaderboard(nil))
	ShowPlayTimeBoardBindableEvent:Fire(getPlayTimeLeaderboard(nil))
	ShowRebirthBoardBindableEvent:Fire(getRebirthLeaderboard(nil))

	--only update if there are players worth updating
	while true do
		wait(REFRESH_RATE)
		for i, player in pairs(Players:GetPlayers()) do
			saveLeaderboards(player)
		end
		updateTables()
		ShowMoneyBoardBindableEvent:Fire(getMoneyLeaderboard(nil))
		ShowDonationBoardBindableEvent:Fire(getDonateLeaderboard(nil))
		ShowPlayTimeBoardBindableEvent:Fire(getPlayTimeLeaderboard(nil))
		ShowRebirthBoardBindableEvent:Fire(getRebirthLeaderboard(nil))
	end
end

task.spawn(boot)

--function to run when player Joins
PlayerManager.PlayerAdded:Connect(function(player: Player)
	if not PlayerStats[player.Name] then
		PlayerStats[player.Name] = {
			["DonatedAmount"] = DonateDataStore:GetAsync(tostring(player.UserId)),
			["Bread"] = BreadDataStore:GetAsync(tostring(player.UserId)),
			["PlayTime"] = PlayTimeDataStore:GetAsync(tostring(player.UserId)),
			["Rebirth"] = RebirthDataStore:GetAsync(tostring(player.UserId)),
		}

		if PlayerStats[player.Name]["DonatedAmount"] == nil then
			PlayerStats[player.Name]["DonatedAmount"] = 0
		end
		if PlayerStats[player.Name]["Bread"] == nil then
			PlayerStats[player.Name]["Bread"] = 0
		end
		if PlayerStats[player.Name]["PlayTime"] == nil then
			PlayerStats[player.Name]["PlayTime"] = 0
		end
		if PlayerStats[player.Name]["Rebirth"] == nil then
			PlayerStats[player.Name]["Rebirth"] = 0
		end
	end
	saveLeaderboards(player)
end)

--function to run when player leaves
Players.PlayerRemoving:Connect(function(player: Player)
	saveLeaderboards(player)
end)
