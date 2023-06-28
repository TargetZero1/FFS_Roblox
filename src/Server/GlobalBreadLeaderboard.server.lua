--!strict
-- script to control what leaderboards to display on the users UI
-- Services
local DatastoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
-- Modules
local BreadManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BreadManager"))
-- Types
type DataItem = {
	key: string,
	value: number,
}
-- Constants
local HUGE_INT = 1000000000
-- Variables
local BreadType1DataStore = DatastoreService:GetOrderedDataStore("BreadType1LeaderboardVersion2")
local BreadType2DataStore = DatastoreService:GetOrderedDataStore("BreadType2Leaderboard")
local BreadType3DataStore = DatastoreService:GetOrderedDataStore("BreadType3Leaderboard")
local BreadType4DataStore = DatastoreService:GetOrderedDataStore("BreadType4Leaderboard")

-- References
local AdminSettings = ReplicatedFirst:WaitForChild("AdminControls")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local BreadLeaderboardFunctions = RemoteFunctions:WaitForChild("BreadLeaderboard")
local BreadLeaderboardBindableEvents = BindableEvents:WaitForChild("BreadLeaderboard")

--remote events to change active leaderboard
local ShowBreadType1Event = BreadLeaderboardFunctions:WaitForChild("ShowBread1Board") :: RemoteFunction
local ShowBreadType2Event = BreadLeaderboardFunctions:WaitForChild("ShowBread2Board") :: RemoteFunction
local ShowBreadType3Event = BreadLeaderboardFunctions:WaitForChild("ShowBread3Board") :: RemoteFunction
local ShowBreadType4Event = BreadLeaderboardFunctions:WaitForChild("ShowBread4Board") :: RemoteFunction

--bindable events to change active leaderboard
local ShowBreadType1BindableEvent = BreadLeaderboardBindableEvents:WaitForChild("ShowBread1Board") :: BindableEvent
local ShowBreadType2BindableEvent = BreadLeaderboardBindableEvents:WaitForChild("ShowBread2Board") :: BindableEvent
local ShowBreadType3BindableEvent = BreadLeaderboardBindableEvents:WaitForChild("ShowBread3Board") :: BindableEvent
local ShowBreadType4BindableEvent = BreadLeaderboardBindableEvents:WaitForChild("ShowBread4Board") :: BindableEvent

local PlayerStats = {}

--tables of top 50 players for each leaderboard
local BreadType1Table = {} :: { [number]: DataItem }
local BreadType2Table = {} :: { [number]: DataItem }
local BreadType3Table = {} :: { [number]: DataItem }
local BreadType4Table = {} :: { [number]: DataItem }

--delay between updates
local RefreshRate = 10

------ ADMIN SETTINGS -----
--reference to the admin controls script that sets key data

if AdminSettings then
	if AdminSettings:GetAttribute("LeaderboardRefreshTimer") ~= nil then
		if AdminSettings:GetAttribute("LeaderboardRefreshTimer") >= 10 then
			RefreshRate = AdminSettings:GetAttribute("LeaderboardRefreshTimer")
		end
	end
end

--function to update tables of leaderboard values
local function UpdateTables()
	--Bread type 1 table
	--avoid errors breaking game
	local success1, msg1 = pcall(function()
		--variable for all player data, False = decending
		local data: DataStorePages = BreadType1DataStore:GetSortedAsync(false, 50, 0, HUGE_INT)
		--returns all items on current page
		BreadType1Table = data:GetCurrentPage()
		-- print("SOUR-DATA!", BreadType1Table)
		--returns all items on current page
	end)
	if not success1 then
		warn(msg1)
	end
	--Bread type 2 table
	--avoid errors breaking game
	local success2, msg2 = pcall(function()
		--variable for all player data, False = decending
		local data: DataStorePages = BreadType2DataStore:GetSortedAsync(false, 50, 0, HUGE_INT)
		--returns all items on current page
		BreadType2Table = data:GetCurrentPage()
		--returns all items on current page
	end)
	if not success2 then
		warn(msg2)
	end
	--Bread type 3 table
	--avoid errors breaking game
	local success3, msg3 = pcall(function()
		--variable for all player data, False = decending
		local data: DataStorePages = BreadType3DataStore:GetSortedAsync(false, 50, 0, HUGE_INT)
		--returns all items on current page
		BreadType3Table = data:GetCurrentPage()
		--returns all items on current page
	end)
	if not success3 then
		warn(msg3)
	end
	--Bread type 4 table
	--avoid errors breaking game
	local success4, msg4 = pcall(function()
		--variable for all player data, False = decending
		local data: DataStorePages = BreadType4DataStore:GetSortedAsync(false, 50, 0, HUGE_INT)
		--returns all items on current page
		BreadType4Table = data:GetCurrentPage()
		--returns all items on current page
	end)
	if not success4 then
		warn(msg4)
	end
end

--function used to update leaderboard to display top donaters
local function getDonateLeaderboard(player: Player?): { [number]: DataItem }
	return BreadType1Table
end

--function used to update leaderboard to display top Money
local function getMoneyLeaderboard(player: Player?): { [number]: DataItem }
	return BreadType2Table
end

--function used to update leaderboard to display top play time
local function getPlayTimeLeaderboard(player: Player?): { [number]: DataItem }
	return BreadType3Table
end

--function used to update leaderboard to display top Rebirth
local function getRebirthLeaderboard(player: Player?): { [number]: DataItem }
	return BreadType4Table
end

ShowBreadType1Event.OnServerInvoke = getDonateLeaderboard
ShowBreadType2Event.OnServerInvoke = getMoneyLeaderboard
ShowBreadType3Event.OnServerInvoke = getPlayTimeLeaderboard
ShowBreadType4Event.OnServerInvoke = getRebirthLeaderboard

--FUNCTION TO SAVE LEADERBOARD STATS
local function saveLeaderboards(player: Player)
	if player.UserId > 0 then
		--check if the player has a bread delivered amount already
		--sourdough
		if BreadManager.getBreadType1(player).Value ~= nil then
			--check if value has changed
			if PlayerStats[player.Name]["Bread1"] ~= BreadManager.getBreadType1(player).Value then
				--save the updated value
				PlayerStats[player.Name]["Bread1"] = BreadManager.getBreadType1(player).Value

				--save the data to the datastore
				pcall(function()
					BreadType1DataStore:SetAsync(
						tostring(player.UserId), 
						assert(
							BreadManager.getBreadType1(player).Value, 
							"assertion failed"
						) :: number
					)
				end)
			end
		end
		--Pitta
		--check if the player has a bread delivered amount already
		if BreadManager.getBreadType4(player).Value ~= nil then
			--check if value has changed
			if PlayerStats[player.Name]["Bread2"] ~= BreadManager.getBreadType4(player).Value then
				--save the updated value
				PlayerStats[player.Name]["Bread2"] = BreadManager.getBreadType4(player).Value

				--save the data to the datastore
				pcall(function()
					BreadType2DataStore:SetAsync(tostring(player.UserId), assert(BreadManager.getBreadType4(player).Value, "assertion failed") :: number)
				end)
			end
		end
		--Chiabatta
		--check if the player has a bread delivered amount already
		if BreadManager.getBreadType5(player).Value ~= nil then
			--check if value has changed
			if PlayerStats[player.Name]["Bread3"] ~= BreadManager.getBreadType5(player).Value then
				--save the updated value
				PlayerStats[player.Name]["Bread3"] = BreadManager.getBreadType5(player).Value

				--save the data to the datastore
				pcall(function()
					BreadType3DataStore:SetAsync(tostring(player.UserId), assert(BreadManager.getBreadType5(player).Value, "assertion failed") :: number)
				end)
			end
		end
		--BaguetteDeCampagne
		--check if the player has a bread delivered amount already
		if BreadManager.getBreadType9(player).Value ~= nil then
			--check if value has changed
			if PlayerStats[player.Name]["Bread4"] ~= BreadManager.getBreadType9(player).Value then
				--save the updated value
				PlayerStats[player.Name]["Bread4"] = BreadManager.getBreadType9(player).Value

				--save the data to the datastore
				pcall(function()
					BreadType4DataStore:SetAsync(tostring(player.UserId), assert(BreadManager.getBreadType9(player).Value, "assertion failed") :: number)
				end)
			end
		end
	end
end

task.spawn(function()
	task.spawn(function()
		UpdateTables()
		--set up leaderboard parts on start
		ShowBreadType1BindableEvent:Fire(getDonateLeaderboard(nil))
		ShowBreadType2BindableEvent:Fire(getMoneyLeaderboard(nil))
		ShowBreadType3BindableEvent:Fire(getPlayTimeLeaderboard(nil))
		ShowBreadType4BindableEvent:Fire(getRebirthLeaderboard(nil))
	end)


	--only update if there are players worth updating
	while true do
		wait(RefreshRate)
		local success, msg = pcall(function()
			for i, player in pairs(Players:GetPlayers()) do
				task.spawn(function()
					saveLeaderboards(player)
				end)
			end
			UpdateTables()
			ShowBreadType1BindableEvent:Fire(getDonateLeaderboard(nil))
			ShowBreadType2BindableEvent:Fire(getMoneyLeaderboard(nil))
			ShowBreadType3BindableEvent:Fire(getPlayTimeLeaderboard(nil))
			ShowBreadType4BindableEvent:Fire(getRebirthLeaderboard(nil))
		end)
		if not success then
			warn(msg)
		end
	end
end)

--function to run when player Joins
local function initPlayer(player: Player)
	if not PlayerStats[player.Name] then
		PlayerStats[player.Name] = {
			["Bread1"] = BreadType1DataStore:GetAsync(tostring(player.UserId)),
			["Bread2"] = BreadType2DataStore:GetAsync(tostring(player.UserId)),
			["Bread3"] = BreadType3DataStore:GetAsync(tostring(player.UserId)),
			["Bread4"] = BreadType4DataStore:GetAsync(tostring(player.UserId)),
		}
		--SourDough
		if PlayerStats[player.Name]["Bread1"] == nil then
			PlayerStats[player.Name]["Bread1"] = 0
		end
		--Pitta
		if PlayerStats[player.Name]["Bread2"] == nil then
			PlayerStats[player.Name]["Bread2"] = 0
		end
		--Ciabatta
		if PlayerStats[player.Name]["Bread3"] == nil then
			PlayerStats[player.Name]["Bread3"] = 0
		end
		--BaguetteDeCampagne
		if PlayerStats[player.Name]["Bread4"] == nil then
			PlayerStats[player.Name]["Bread4"] = 0
		end
	end
	saveLeaderboards(player)
end
BreadManager.PlayerAdded:Connect(initPlayer)
for i, player in ipairs(Players:GetChildren()) do
	assert(player:IsA("Player"))
	task.spawn(function()
		initPlayer(player)
	end)
end

--function to run when player leaves
Players.PlayerRemoving:Connect(function(player: Player)
	saveLeaderboards(player)
end)
