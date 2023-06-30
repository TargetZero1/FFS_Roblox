--!strict
-- Services
local Players = game:GetService("Players")
local DatastoreService = game:GetService("DataStoreService")
-- local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
-- Packages
local TableUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("TableUtil"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))

-- Modules
local Gamepass = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Gamepass"))
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))
local TimerRewardUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TimerRewardUtil"))
local Config = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Config"))
-- local GamepassUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("GamepassUtil"))

-- Types
export type ComponentName = "Windmill" | "Oven" | "Rack" | "Kneader" | "Wrapper"
type Signal = Signal.Signal
export type PetSaveData = {
	Id: string,
	BalanceId: string,
	Assignment: ComponentName?,
}

export type RebirthData = {
	rebirthCoins: number,
	rebirthCoinsSpent: number,
	rebirthCoinsRemaining: number,
}
export type OnboardingData = {
	Knead: {
		Knead0: boolean,
		Knead1: boolean,
		Knead2: boolean,
		Knead3: boolean,
		Knead4: boolean,
		[any]: nil,
	},
	Bake: {
		Bake0: boolean,
		Bake1: boolean,
		Bake2: boolean,
		Bake3: boolean,
		Bake4: boolean,
		[any]: nil,
	},
	Wrap: {
		Wrap0: boolean,
		Wrap1: boolean,
		Wrap2: boolean,
		Wrap3: boolean,
		Wrap4: boolean,
		[any]: nil,
	},
	Collect: {
		Collect: boolean,
		[any]: nil,
	},
	Deposit: {
		Deposit: boolean,
		[any]: nil,
	},
	Deliver: {
		Deliver: boolean,
		[any]: nil,
	},
	Hatch: {
		GoTo: boolean,
		Hatch: boolean,
		[any]: nil,
	},
	Assign: {
		GoToKneader: boolean,
		Assign: boolean,
		[any]: nil,
	},
}

type TimerRewardSaveData = TimerRewardUtil.TimerRewardSaveData
export type PlayerData = {
	CareerCash: number,
	TotalMoney: number,
	Money: number,
	UnlockIds: { [number]: number },
	Modifiers: {
		Windmill: {
			Recharge: number,
			Value: number,
		},
		Oven: {
			Recharge: number,
			Value: number,
		},
		Rack: {
			Storage: number,
		},
		Kneader: {
			Recharge: number,
			Multiplier: number,
		},
		Wrapper: {
			Recharge: number,
			Multiplier: number,
		},
	},
	Onboarding: OnboardingData,
	PetRegistry: {
		[string]: PetSaveData,
	},
	SessionStartTimestamp: number,
	TimerRewardList: { [number]: TimerRewardSaveData },
	Multiplier: number,
	Rebirth: number,
	PlayTime: number,
	DonatedAmount: number,
	HighestBreadRackValue: number,
	--dough stats
	doughCreated: number,
	wheatCreated: number,
	BreadShaped: number,
	breadCooked: number,
	breadDelivered: number,
	TruckMoney: number,
	TruckBreadCount: number,
	TrayStorageLimit: number,
	TruckDeliveryLimit: number,
	--Rebirth Coins Stats
	rebirthCoins: number,
	rebirthCoinsRemaining: number,
	rebirthCoinsSpent: number,
	--Timed bonus
	multiplierBonus: number,
	timeRemaining: number,
}
-- Constants
local DATASTORE_NAME = Config.Datastore
local DO_NOT_SAVE_TAG = "DO_NOT_SAVE_PLAYER_DATA"
local GET_ONBOARDING_PROGRESS_KEY = "GET_ONBOARDING_PROGRESS"
local SET_STAGE_COMPLETE = "SET_STAGE_COMPLETE"
local GET_PLAYER_TIMER_REWARD_DATA_LIST = "GET_PLAYER_TIMER_REWARD_DATA_LIST"
local ON_UPDATE_PLAYER_TIMER_REWARD_DATA_LIST = "ON_UPDATE_PLAYER_TIMER_REWARD_DATA_LIST"
local GROUP_ID = 11827920 --your group id
local DATA_TEMPLATE: PlayerData = { --template table
	CareerCash = 0,
	TotalMoney = 0,
	Money = 0,
	UnlockIds = {},
	Modifiers = {
		Windmill = {
			Recharge = 1,
			Value = 1,
		},
		Oven = {
			Recharge = 1,
			Value = 1,
		},
		Rack = {
			Storage = 1,
		},
		Kneader = {
			Multiplier = 1,
			Recharge = 1,
		},
		Wrapper = {
			Recharge = 1,
			Multiplier = 1,
		},
	},
	Onboarding = {
		Knead = {
			Knead0 = false,
			Knead1 = false,
			Knead2 = false,
			Knead3 = false,
			Knead4 = false,
		},
		Bake = {
			Bake0 = false,
			Bake1 = false,
			Bake2 = false,
			Bake3 = false,
			Bake4 = false,
		},
		Wrap = {
			Wrap0 = false,
			Wrap1 = false,
			Wrap2 = false,
			Wrap3 = false,
			Wrap4 = false,
		},
		Collect = {
			Collect = false,
		},
		Deposit = {
			Deposit = false,
		},
		Deliver = {
			Deliver = false,
		},
		Hatch = {
			GoTo = false,
			Hatch = false,
		},
		Assign = {
			GoToKneader = false,
			Assign = false,
		},
	},
	SessionStartTimestamp = TimerRewardUtil.getTimestamp(),
	Multiplier = 1,
	Rebirth = 0,
	PlayTime = 0,
	DonatedAmount = 0,
	HighestBreadRackValue = 100,
	TimerRewardList = {},
	--dough stats
	doughCreated = 0,
	wheatCreated = 0,
	BreadShaped = 0,
	breadCooked = 0,
	breadDelivered = 0,
	--Truck Stats
	TruckMoney = 0,
	TruckBreadCount = 0,
	TrayStorageLimit = 10,
	TruckDeliveryLimit = 10,
	--Rebirth Coins Stats
	rebirthCoins = 0,
	rebirthCoinsRemaining = 0,
	rebirthCoinsSpent = 0,
	--Timed bonus
	multiplierBonus = 0,
	timeRemaining = 0,
	--Pet Data
	PetRegistry = {},
}
local HUMANOID_SCALE = 1.25

-- Variables
local PlayerData = DatastoreService:GetDataStore(DATASTORE_NAME)
local SessionData: { [number]: PlayerData } = {}
local PetSignalRegistry: { [number]: Signal } = {}

-- References
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents") :: RemoteEvent
local AFKRewardEvent = BindableEvents:WaitForChild("AFKRewardEvent") :: BindableEvent
local GetHighestBreadRackValue = RemoteFunctions:WaitForChild("GetHighestBreadRackValue") :: RemoteFunction
local HighestBreadRackNotifier = RemoteEvents:WaitForChild("HighestBreadRackNotify") :: RemoteEvent
local PlayerAdded = Instance.new("BindableEvent") :: BindableEvent
local PlayerRemoving = Instance.new("BindableEvent") :: BindableEvent
local PlayerCharacterAdded = Instance.new("BindableEvent") :: BindableEvent

function getRebirthKey(userId: number): string
	return tostring(userId) .. "Rebirths"
end

function getDataKey(userId: number): string
	return tostring(userId)
end

--function to reconcile any discrepencies in the datastore
function reconcile(source: PlayerData, template: PlayerData): PlayerData
	--loop through the template table and put all the values from this into the source table if they don't exists
	for k, v in pairs(template) do
		--if this entry does not exist in source table
		if not source[k] then
			--insert it
			source[k] = v
		end
	end
	--send the new source table back
	return source
end

--player leaderstats
function leaderboardSetUp(value: number, rebirths: number): Folder
	--create leaderstats folder
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	--create Bread value in leaderstats folder
	local delivered = Instance.new("IntValue")
	delivered.Name = "Bread Delivered"
	delivered.Value = value
	delivered.Parent = leaderstats

	--create Rebirth value in leaderstats folder
	local rebirth = Instance.new("IntValue")
	rebirth.Name = "Rebirths"
	rebirth.Value = rebirths
	rebirth.Parent = leaderstats

	return leaderstats
end

function playerStatsSetUp(timeVal: number, donated: number, cash: number, careerCashVal: number, totalCashVal: number): Folder
	--create PlayerStats folder
	local playerStats = Instance.new("Folder")
	playerStats.Name = "PlayerStats"

	--create money value in leaderstats folder
	local timePlayed = Instance.new("IntValue")
	timePlayed.Name = "TimePlayed"
	timePlayed.Value = timeVal
	timePlayed.Parent = playerStats

	local donatedAmount = Instance.new("IntValue")
	donatedAmount.Name = "DonatedAmount"
	donatedAmount.Value = donated
	donatedAmount.Parent = playerStats

	--create money value in leaderstats folder
	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = cash
	money.Parent = playerStats

	--create CareerCash value in leaderstats folder
	local careerCash = Instance.new("IntValue")
	careerCash.Name = "CareerCash"
	careerCash.Value = careerCashVal
	careerCash.Parent = playerStats

	--create TotalCash value in leaderstats folder
	local totalCash = Instance.new("IntValue")
	totalCash.Name = "TotalCash"
	totalCash.Value = totalCashVal
	totalCash.Parent = playerStats

	return playerStats
end

function breadStatsSetUp(doughCreatedVal: number, wheatCreatedVal: number, breadShapedVal: number, breadCookedVal: number, breadDeliveredVal: number): Folder
	--create BreadStats folder
	local breadStats = Instance.new("Folder")
	breadStats.Name = "BreadStats"

	--create DoughCreated value in leaderstats folder
	local doughCreated = Instance.new("IntValue")
	doughCreated.Name = "DoughCreated"
	doughCreated.Value = doughCreatedVal
	doughCreated.Parent = breadStats

	--create WheatCreated value in leaderstats folder
	local wheatCreated = Instance.new("IntValue")
	wheatCreated.Name = "WheatCreated"
	wheatCreated.Value = wheatCreatedVal
	wheatCreated.Parent = breadStats

	local breadShaped = Instance.new("IntValue")
	breadShaped.Name = "BreadShaped"
	breadShaped.Value = breadShapedVal
	breadShaped.Parent = breadStats

	local breadCooked = Instance.new("IntValue")
	breadCooked.Name = "BreadCooked"
	breadCooked.Value = breadCookedVal
	breadCooked.Parent = breadStats

	local breadDelivered = Instance.new("IntValue")
	breadDelivered.Name = "BreadDelivered"
	breadDelivered.Value = breadDeliveredVal
	breadDelivered.Parent = breadStats

	return breadStats
end

function rebirthStatsSetUp(rebirthCoinsVal: number, rebirthCoinsSpentVal: number, rebirthCoinsRemainingVal: number): Folder
	--create RebirthStats folder
	local rebirthStats = Instance.new("Folder")
	rebirthStats.Name = "RebirthStats"

	--create RebirthCoins value in leaderstats folder
	local rebirthCoins = Instance.new("IntValue")
	rebirthCoins.Name = "RebirthCoins"
	rebirthCoins.Value = rebirthCoinsVal
	rebirthCoins.Parent = rebirthStats

	local rebirthCoinsSpent = Instance.new("IntValue")
	rebirthCoinsSpent.Name = "RebirthCoinsSpent"
	rebirthCoinsSpent.Value = rebirthCoinsSpentVal
	rebirthCoinsSpent.Parent = rebirthStats

	local rebirthCoinsRemaining = Instance.new("IntValue")
	rebirthCoinsRemaining.Name = "RebirthCoinsRemaining"
	rebirthCoinsRemaining.Value = rebirthCoinsRemainingVal
	rebirthCoinsRemaining.Parent = rebirthStats

	return rebirthStats
end

function timedRewardsStatsSetUp(multiplierBonusVal: number, timeRemainingVal: number): Folder
	--create TimedRewards folder
	local timedRewards = Instance.new("Folder")
	timedRewards.Name = "TimedRewards"

	--create MultiplierBonus value in leaderstats folder
	local multiplierBonus = Instance.new("IntValue")
	multiplierBonus.Name = "MultiplierBonus"
	multiplierBonus.Value = multiplierBonusVal
	multiplierBonus.Parent = timedRewards

	local timeRemaining = Instance.new("IntValue")
	timeRemaining.Name = "TimeRemaining"
	timeRemaining.Value = timeRemainingVal
	timeRemaining.Parent = timedRewards

	return timedRewards
end

--function to save Rebirth data separately
function saveRebirthData(player: Player, rebirthData: number): boolean
	if CollectionService:HasTag(player, DO_NOT_SAVE_TAG) then
		print("SKIPPING REBIRTH SAVE", player.Name)
		return true
	end
	print("SAVING REBIRTH DATA", player.Name)
	--wrap the save data into a pcall for safety
	local success, result = pcall(function()
		--overwrite previous data
		return PlayerData:SetAsync(getRebirthKey(player.UserId), rebirthData)
	end)
	--if data retreival is not successful
	if not success then
		--display a warning in the log
		warn(result)
	end

	--return if it was successful
	return success
end
--function to rereive Rebirth data separately
function loadRebirthData(player: Player): (boolean, number)
	print("LOADING REBIRTH DATA", player.Name)
	--wrap the load data into a pcall for safety
	local success, result = pcall(function()
		return PlayerData:GetAsync(getRebirthKey(player.UserId))
	end)
	--if data retreival is not successful
	if not success then
		--display a warning in the log
		warn(result)
	end

	--return the retreived data if it was successful
	return success, result
end

local function loadData(player: Player): (boolean, PlayerData)
	print("LOADING PLAYER DATA", player.Name)
	--wrap the load data into a pcall for safety
	local success, result = pcall(function()
		return PlayerData:GetAsync(getDataKey(player.UserId))
	end)
	--if data retreival is not successful
	if not success then
		--display a warning in the log
		warn(result)
	end

	--retreive the data for this player from the roblox cloud server
	local RetreivedRebirthData, RebirthData = loadRebirthData(player)

	--check that the server has received the correct data from the cloud storage
	if RetreivedRebirthData == true then
		--if the value it received isn't nill
		if RebirthData ~= nil then
			--set the rebirth value in the results table to match what was recived
			result.Rebirth = RebirthData
		end
	end

	--return the retreived data if it was successful
	return success, result
end

local function saveData(player: Player, data: PlayerData): boolean
	if CollectionService:HasTag(player, DO_NOT_SAVE_TAG) then
		print("SKIPPING DATA SAVE", player.Name)
		return true
	end
	print("SAVING USER DATA", player.Name)
	--reset dough created when player leaves
	data.doughCreated = 0
	data.wheatCreated = 0

	--wrap the save data into a pcall for safety
	local success, result = pcall(function()
		--overwrite previous data
		return PlayerData:SetAsync(getDataKey(player.UserId), data)
	end)
	--if data save is not successful
	if not success then
		--display a warning in the log
		warn(result)
	end

	--save the rebirth data
	saveRebirthData(player, data.Rebirth)

	--return if it was successful
	return success
end

-- --function for printing the Players data
-- function printData()
-- 	--retreive the specific Players data
-- 	local success,result = pcall(function()
-- 		return PlayerData:GetAsync(tostring(2784745129))
-- 	end)
-- 	--print out all data
-- 	for i, v in ipairs(result) do
-- 		if(v == nil) then
-- 			print("key:".. i .. ":".. v)
-- 		end
-- 	end
-- end
-- --function for resteting a specific Players data
-- function resetSpecificPlayer()
-- 	local data = { --template table
-- 		CareerCash = 0,
-- 		TotalMoney = 0,
-- 		Money = 0,
-- 		UnlockIds = {},
-- 		ModifierIds = {},
-- 		Multiplier = 1,
-- 		Rebirth = 0,
-- 		PlayTime =0,
-- 		DonatedAmount = 0,
-- 		HighestBreadRackValue = 100,
-- 		--dough stats
-- 		doughCreated = 0,
-- 		wheatCreated = 0,
-- 		BreadShaped = 0,
-- 		breadCooked = 0,
-- 		breadDelivered = 0,
-- 		--Truck Stats
-- 		TruckMoney = 0,
-- 		TruckBreadCount = 0,
-- 		TrayStorageLimit = 10,
-- 		TruckDeliveryLimit = 10,
-- 		--Rebirth Coins Stats
-- 		rebirthCoins = 0,
-- 		rebirthCoinsRemaining = 0,
-- 		rebirthCoinsSpent = 0,
-- 		--Timed bonus
-- 		multiplierBonus = 0,
-- 		timeRemaining = 0,
-- 		--Multiplier Levels
-- 		ModifierLevels = {
-- 			["KneadingModifiers"] = { Speed = 1 },
-- 			["Windmill1Modifiers"] = {Speed = 1, Wheat = 1},
-- 			["Windmill2Modifiers"] = {Speed = 1, Wheat = 1},
-- 			["Windmill3Modifiers"] = {Speed = 1, Wheat = 1},
-- 			["BakingModifiers"] = {Speed = 1, Value = 1, Multiplier = 1},
-- 			["WrappingModifiers"] = {Speed = 1, Multiplier = 1},
-- 			["ConveyorModifiers"] = { Speed = 1, Multiplier = 1, Value = 1},
-- 			["CollectorModifiers"] = {Storage = 1}
-- 		}
-- 	}

-- 	--overwrite the previous data with the default values
-- 	pcall(function()
-- 		--overwrite previous data
-- 		return PlayerData:SetAsync(tostring(2784745129), data)
-- 	end)
-- end

local PlayerManager = {}

PlayerManager.PlayerAdded = PlayerAdded.Event
PlayerManager.PlayerRemoving = PlayerRemoving.Event
PlayerManager.CharacterAdded = PlayerCharacterAdded.Event

--connect the defeault player added event to the new functionality below
function PlayerManager.start()
	--just in case someone joins before the following event can run
	for _, player in ipairs(Players:GetPlayers()) do
		--run the On player added event on another thread for each player
		coroutine.wrap(PlayerManager.onPlayerAdded)(player)
	end
	--connect the new events to trigger the correct functions when fired
	Players.PlayerAdded:Connect(PlayerManager.onPlayerAdded)
	Players.PlayerRemoving:Connect(PlayerManager.onPlayerRemoving)

	--when game is about to quit save all the Players data
	game:BindToClose(PlayerManager.onClose)
end

function PlayerManager.getPetDataChangedSignal(player: Player): Signal
	local signal = PetSignalRegistry[player.UserId]
	assert(signal, "pet signal missing for " .. tostring(player.UserId))
	return signal
end

function PlayerManager.onPlayerAdded(player: Player)
	--printData()
	--resetSpecificPlayer()

	--local midas = Analytics:GetMidas(player, "Player")

	--set attribute on player to trigger machine updates
	player:SetAttribute("UltimateWindmill", false)
	player:SetAttribute("UltimateKneader", false)
	player:SetAttribute("UltimateOven", false)
	player:SetAttribute("UltimateWrapper", false)

	local userId = player.UserId
	local maid = Maid.new()
	maid:GiveTask(player.Destroying:Connect(function()
		maid:Destroy()
		PetSignalRegistry[userId] = nil
	end))
	local petDataSignal = maid:GiveTask(Signal.new())
	PetSignalRegistry[userId] = petDataSignal

	--midas:SetState("Gamepass/UltimateWindmill", function()
	--return player:GetAttribute("UltimateWindmill")
	--end)
	--midas:SetState("Gamepass/UltimateKneader", function()
	--return player:GetAttribute("UltimateKneader")
	--end)
	--midas:SetState("Gamepass/UltimateOven", function()
	--return player:GetAttribute("UltimateOven")
	--end)
	--midas:SetState("Gamepass/UltimateWrapper", function()
	--return player:GetAttribute("UltimateWrapper")
	--end)

	--check for any owned gamepasses
	PlayerManager.registerGamepasses(player)

	--when a Players character is added to the game
	player.CharacterAdded:Connect(function(character: Model)
		--call this function
		PlayerManager.onCharacterAdded(player, character)
	end)

	--check if player is in the group
	local groupSuccess, groupMessage = pcall(function()
		if player:IsInGroup(GROUP_ID) then
			player:SetAttribute("InGroup", true)
		end
	end)
	if not groupSuccess then
		warn(groupMessage)
	end

	--retreive the data for this player from the roblox cloud server
	local success, data = loadData(player)
	--retreive the Rebirth data for this player from the roblox cloud server
	loadRebirthData(player)

	repeat
		wait(0.1)

	until success == false or success == true

	--if data retreival worked and it's not nil
	if success and data ~= nil then
		if data.CareerCash == nil then
			data.CareerCash = 0
		end

		if data.TotalMoney == nil then
			data.TotalMoney = 0
		end

		if data.Money == nil then
			data.Money = 0
		end
		if data.UnlockIds == nil then
			data.UnlockIds = {}
		end
		if data.Multiplier == nil then
			data.Multiplier = 1
		end

		if data.Rebirth == nil then
			data.Rebirth = 0
		end

		--player stats
		if data.PlayTime == nil then
			data.PlayTime = 0
		end
		if data.DonatedAmount == nil then
			data.DonatedAmount = 0
		end

		if data.HighestBreadRackValue == nil then
			data.HighestBreadRackValue = 100
		end
		--bread stats
		if data.doughCreated == nil then
			data.doughCreated = 0
		end
		if data.wheatCreated == nil then
			data.wheatCreated = 0
		end
		if data.BreadShaped == nil then
			data.BreadShaped = 0
		end
		if data.breadCooked == nil then
			data.breadCooked = 0
		end
		if data.breadDelivered == nil then
			data.breadDelivered = 0
		end
		if data.TruckMoney == nil then
			data.TruckMoney = 0
		end
		if data.TruckBreadCount == nil then
			data.TruckBreadCount = 0
		end
		if data.TrayStorageLimit == nil then
			data.TrayStorageLimit = 10
		end
		if data.TruckDeliveryLimit == nil then
			data.TruckDeliveryLimit = 10
		end
		--Rebirth Stats
		if data.rebirthCoins == nil then
			data.rebirthCoins = 0
		end
		if data.rebirthCoinsSpent == nil then
			data.rebirthCoinsSpent = 0
		end
		if data.rebirthCoinsRemaining == nil then
			data.rebirthCoinsRemaining = 0
		end

		--Timed Rewards
		if data.multiplierBonus == nil then
			data.multiplierBonus = 0
		end
		if data.timeRemaining == nil then
			data.timeRemaining = 0
		end

		data.SessionStartTimestamp = TimerRewardUtil.getTimestamp()

		--check if data is nill
	else
		if success and data == nil then
			data = TableUtil.deepCopy(DATA_TEMPLATE)
		end
	end

	--create session data from existsing data or brand new default values
	SessionData[player.UserId] = reconcile(
		--if data retreival was successful
		if success
			then data
			else
				--use a blank table
				{} :: any,
		TableUtil.deepCopy(DATA_TEMPLATE)
	)

	--SessionData[player.UserId] = data
	--midas:SetState("CareerCash", function()
	--return SessionData[player.UserId].CareerCash
	--end)
	--midas:SetState("TotalMoney", function()
	--return SessionData[player.UserId].TotalMoney
	--end)
	--midas:SetState("Money", function()
	--return SessionData[player.UserId].Money
	--end)
	--midas:SetState("Multiplier", function()
	--return SessionData[player.UserId].Multiplier
	--end)

	--midas:SetState("DonatedAmount", function()
	--return SessionData[player.UserId].DonatedAmount
	--end)
	--midas:SetState("HighestBreadRackValue", function()
	--return SessionData[player.UserId].HighestBreadRackValue
	--end)
	--midas:SetState("Created/Dough", function()
	--return SessionData[player.UserId].doughCreated
	--end)
	--midas:SetState("Created/Wheat", function()
	--return SessionData[player.UserId].wheatCreated
	--end)
	--midas:SetState("Created/Wheat", function()
	--return SessionData[player.UserId].wheatCreated
	--end)
	--midas:SetState("Bread/Shaped", function()
	--return SessionData[player.UserId].BreadShaped
	--end)
	--midas:SetState("Bread/Cooked", function()
	--return SessionData[player.UserId].BreadCooked
	--end)
	--midas:SetState("Bread/Delivered", function()
	--return SessionData[player.UserId].breadDelivered
	--end)
	--midas:SetState("Tray/StorageLimit", function()
	--return SessionData[player.UserId].TrayStorageLimit
	--end)
	--midas:SetState("Rebirth/Count", function()
	--return SessionData[player.UserId].Rebirth
	--end)
	--midas:SetState("Rebirth/Coins/Initial", function()
	--return SessionData[player.UserId].rebirthCoins
	--end)
	--midas:SetState("Rebirth/Coins/Current", function()
	--return SessionData[player.UserId].rebirthCoinsRemaining
	--end)
	--midas:SetState("Rebirth/Coins/Spent", function()
	--return SessionData[player.UserId].rebirthCoinsSpent
	--end)
	--midas:SetState("Bonus/TimeRemaining", function()
	--return SessionData[player.UserId].timeRemaining
	--end)
	--midas:SetState("Bonus/Value", function()
	--return SessionData[player.UserId].multiplierBonus
	--end)

	--create leaderstats from template above
	local leaderstats = leaderboardSetUp(0, 0)
	local rb = PlayerManager.getRebirths(player)
	if PlayerManager.getBreadDeliveredAmount(player) ~= nil and rb then
		leaderstats = leaderboardSetUp(PlayerManager.getBreadDeliveredAmount(player), rb)
	else
		if PlayerManager.getBreadDeliveredAmount(player) ~= nil then
			leaderstats = leaderboardSetUp(PlayerManager.getBreadDeliveredAmount(player), 0)
		end

		if rb ~= nil then
			leaderstats = leaderboardSetUp(0, rb)
		end
	end

	--re-parent the folder to the player who joined
	leaderstats.Parent = player

	--create playerstats from template above
	local PlayerStats = playerStatsSetUp(0, 0, 0, 0, 0)

	if
		PlayerManager.getPlayTime(player) ~= nil
		and PlayerManager.getDonateAmount(player)
		and PlayerManager.getMoney(player) ~= nil
		and PlayerManager.getCareerCash(player) ~= nil
		and PlayerManager.getTotalMoney(player) ~= nil
	then
		PlayerStats = playerStatsSetUp(
			PlayerManager.getPlayTime(player),
			PlayerManager.getDonateAmount(player),
			PlayerManager.getMoney(player),
			PlayerManager.getCareerCash(player),
			PlayerManager.getTotalMoney(player)
		)
	else
		if PlayerManager.getPlayTime(player) ~= nil then
			PlayerStats = playerStatsSetUp(PlayerManager.getPlayTime(player), 0, 0, 0, 0)
		end

		if PlayerManager.getDonateAmount(player) ~= nil then
			PlayerStats = playerStatsSetUp(0, PlayerManager.getDonateAmount(player), 0, 0, 0)
		end

		if PlayerManager.getMoney(player) ~= nil then
			PlayerStats = playerStatsSetUp(0, 0, PlayerManager.getMoney(player), 0, 0)
		end

		if PlayerManager.getCareerCash(player) ~= nil then
			PlayerStats = playerStatsSetUp(0, 0, 0, PlayerManager.getCareerCash(player), 0)
		end

		if PlayerManager.getTotalMoney(player) ~= nil then
			PlayerStats = playerStatsSetUp(0, 0, 0, 0, PlayerManager.getTotalMoney(player))
		end
	end

	--re-parent the folder to the player who joined
	PlayerStats.Parent = player

	--create breadstats from template above
	local BreadStats = breadStatsSetUp(0, 0, 0, 0, 0)
	local BreadData = {
		--template table
		doughCreated = 0,
		wheatCreated = 0,
		breadShaped = 0,
		breadCooked = 0,
		breadDelivered = 0,
	}

	if PlayerManager.getDoughCreatedAmount(player) ~= nil then
		BreadData.doughCreated = PlayerManager.getDoughCreatedAmount(player)
	end

	if PlayerManager.getBreadShapedAmount(player) ~= nil then
		BreadData.breadShaped = PlayerManager.getBreadShapedAmount(player)
	end

	if PlayerManager.getBreadCookedAmount(player) ~= nil then
		BreadData.breadCooked = PlayerManager.getBreadCookedAmount(player)
	end

	if PlayerManager.getBreadDeliveredAmount(player) ~= nil then
		BreadData.breadDelivered = PlayerManager.getBreadDeliveredAmount(player)
	end

	BreadStats = breadStatsSetUp(BreadData.doughCreated, BreadData.wheatCreated, BreadData.breadShaped, BreadData.breadCooked, BreadData.breadDelivered)

	--re-parent the folder to the player who joined
	BreadStats.Parent = player

	--create RebirthStats from template above
	local rebirthStats = rebirthStatsSetUp(0, 0, 0)
	local rebirthData: RebirthData = {
		--template table
		rebirthCoins = 0,
		rebirthCoinsSpent = 0,
		rebirthCoinsRemaining = 0,
	}

	if PlayerManager.getRebirthCoinsAmount(player) ~= nil then
		--default value
		rebirthData.rebirthCoins = PlayerManager.getRebirthCoinsAmount(player)
	end

	if PlayerManager.getRebirthCoinsSpentAmount(player) ~= nil then
		rebirthData.rebirthCoinsSpent = PlayerManager.getRebirthCoinsSpentAmount(player)
	end

	if PlayerManager.getRebirthCoinsRemainingAmount(player) ~= nil then
		--default value
		rebirthData.rebirthCoinsRemaining = PlayerManager.getRebirthCoinsRemainingAmount(player)

		if rebirthData.rebirthCoinsRemaining ~= rebirthData.rebirthCoins - rebirthData.rebirthCoinsSpent then
			rebirthData.rebirthCoinsRemaining = rebirthData.rebirthCoins - rebirthData.rebirthCoinsSpent
		end
	end

	rebirthStats = rebirthStatsSetUp(rebirthData.rebirthCoins, rebirthData.rebirthCoinsSpent, rebirthData.rebirthCoinsRemaining)

	--re-parent the folder to the player who joined
	rebirthStats.Parent = player

	--create TimedRewards from template above
	local timedRewardsStats = timedRewardsStatsSetUp(0, 0)
	local timedRewardsData = {
		--template table
		multiplierBonus = 0,
		timeRemaining = 0,
	}

	if PlayerManager.getMultiplierBonusAmount(player) ~= nil then
		timedRewardsData.multiplierBonus = PlayerManager.getMultiplierBonusAmount(player)
	end

	local tRemain = PlayerManager.getTimeRemainingAmount(player)

	if tRemain ~= nil then
		timedRewardsData.timeRemaining = tRemain
	end

	timedRewardsStats = timedRewardsStatsSetUp(timedRewardsData.multiplierBonus, timedRewardsData.timeRemaining)

	--re-parent the folder to the player who joined
	timedRewardsStats.Parent = player

	--Set the player's truck delivering attribute.
	player:SetAttribute("TruckDelivering", false)

	--fire the player added event that is created at the top of this script
	PlayerAdded:Fire(player)

	-- load character
	player:LoadCharacter()

	if player.Name == "aryoseno11" then
		PlayerManager.setMoney(player, 100000000)
	end

	maid:GiveTask(NetworkUtil.onServerEvent(SET_STAGE_COMPLETE, function(plr: Player, questName: string, stepName: string)
		if plr.UserId == player.UserId then
			print("STAGE COMPLETE", plr, questName, stepName)
			if not SessionData[player.UserId].Onboarding[questName][stepName] then
				if questName == "Deliver" and stepName == "Deliver" then
					print("Giving reward")
					PlayerManager.setMoney(plr, PlayerManager.getMoney(plr) + 150)
				elseif questName == "Assign" and stepName == "Assign" then
					print("Giving reward")
					PlayerManager.setMoney(plr, PlayerManager.getMoney(plr) + 300)
				end
			end
			SessionData[player.UserId].Onboarding[questName][stepName] = true
		end
	end))

	-- if player.Name == "aryoseno11" or player.Name == "CJ_Oyer" or player.Name == "BWhite_NSG" then
	-- 	for i, v in ipairs(PlayerManager.getSavedPets(player)) do
	-- 		PlayerManager.deletePet(player, v.Id)
	-- 	end
	-- 	-- for i=1, 10 do
	-- 	-- 	PlayerManager.savePet(player, {
	-- 	-- 		Id = HttpService:GenerateGUID(false),
	-- 	-- 		BalanceId = ModifierUtil.getPetBalanceId(if math.random() < 0.5 then "Cat" else "Dog", "Normal", math.random(1,3)),
	-- 	-- 		Assignment = nil
	-- 	-- 	})
	-- 	-- end

	-- end

	-- boot reward data
	PlayerManager.getTimerRewardSaveDataList(player)
end

function PlayerManager.onCharacterAdded(player: Player, character: Model)
	--get the characters humanoid
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?

	--check humanoid exists
	if humanoid ~= nil then
		--wait till player somehow dies
		humanoid.Died:Connect(function()
			wait(2)
			--respawn them
			player:LoadCharacter()
			wait(0.5)
			PlayerCharacterAdded:Fire(player)
		end)
	end

	--loads character
	print(character, humanoid)
	if humanoid then
		local bds = humanoid:FindFirstChild("BodyDepthScale") :: IntValue
		local bhs = humanoid:FindFirstChild("BodyHeightScale") :: IntValue
		local bps = humanoid:FindFirstChild("BodyProportionScale") :: IntValue
		local bts = humanoid:FindFirstChild("BodyTypeScale") :: IntValue
		local bws = humanoid:FindFirstChild("BodyWidthScale") :: IntValue
		local hs = humanoid:FindFirstChild("HeadScale") :: IntValue

		bds.Value *= HUMANOID_SCALE
		bhs.Value *= HUMANOID_SCALE
		bps.Value *= HUMANOID_SCALE
		bts.Value *= HUMANOID_SCALE
		bws.Value *= HUMANOID_SCALE
		hs.Value *= HUMANOID_SCALE

		humanoid.WalkSpeed *= HUMANOID_SCALE
	end
end

function PlayerManager.getMoney(player: Player)
	--get the Players current money and give it back to them
	return SessionData[player.UserId].Money
end

function PlayerManager.setMoney(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data money to the same value as the leaderstats when it updates
		SessionData[player.UserId].Money = value

		--find leaderstats folder on player
		local leaderstats = player:FindFirstChild("PlayerStats")

		--check leaderstats not invalid
		if leaderstats ~= nil then
			local money = leaderstats:FindFirstChild("Money") :: NumberValue?
			--check the player has money
			if money ~= nil then
				--check the player has money
				if money.Value >= 0 then
					money.Value = value
				end
			end
		end
	end
end

function PlayerManager.getTotalMoney(player: Player): number
	--get the Players current money and give it back to them
	return SessionData[player.UserId].TotalMoney
end

function PlayerManager.setTotalMoney(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data money to the same value as the leaderstats when it updates
		SessionData[player.UserId].TotalMoney = value

		--find leaderstats folder on player
		local leaderstats = player:FindFirstChild("PlayerStats")

		--check leaderstats not invalid
		if leaderstats ~= nil then
			local money = leaderstats:FindFirstChild("TotalCash") :: NumberValue?
			--check the player has money
			if money ~= nil then
				--check the player has money
				if money.Value >= 0 then
					money.Value = value
				end
			end
		end
	end
end

function PlayerManager.getCareerCash(player: Player): number
	--get the Players current money and give it back to them
	return SessionData[player.UserId].CareerCash
end

function PlayerManager.setCareerCash(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data money to the same value as the leaderstats when it updates
		SessionData[player.UserId].CareerCash = value

		--find leaderstats folder on player
		local leaderstats = player:FindFirstChild("PlayerStats")

		--check leaderstats not invalid
		if leaderstats ~= nil then
			local money = leaderstats:FindFirstChild("CareerCash") :: NumberValue?
			--check the player has money
			if money ~= nil then
				--check the player has money
				if money.Value >= 0 then
					money.Value = value
				end
			end
		end
	end
end

function PlayerManager.setTruckBreadCount(player: Player, value: number)
	if value ~= nil then
		SessionData[player.UserId].TruckBreadCount = value
	end
end

function PlayerManager.getTruckBreadCount(player: Player): number
	return SessionData[player.UserId].TruckBreadCount
end

function PlayerManager.setTruckMoney(player: Player, value: number)
	if value ~= nil then
		SessionData[player.UserId].TruckMoney = value
	end
end

function PlayerManager.getTruckMoney(player: Player): number
	return SessionData[player.UserId].TruckMoney
end

function PlayerManager.setTruckDeliveryLimit(player: Player, value: number)
	if value ~= nil then
		SessionData[player.UserId].TruckDeliveryLimit = value
	end
end

function PlayerManager.getTruckDeliveryLimit(player: Player): number
	return SessionData[player.UserId].TruckDeliveryLimit
end
function PlayerManager.setRebirths(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data Rebirth to the same value as the leaderstats when it updates
		SessionData[player.UserId].Rebirth = value

		--find leaderstats folder on player
		local leaderstats = player:FindFirstChild("leaderstats")

		--check leaderstats not invalid
		if leaderstats ~= nil then
			local rebirth = leaderstats:FindFirstChild("Rebirths") :: NumberValue?
			--check the player has Rebirthed
			if rebirth ~= nil then
				rebirth.Value = value
			end
		end
	end
end

function PlayerManager.getRebirths(player: Player): number?
	--get the Players current Rebirth value and give it back to them
	if SessionData[player.UserId] then
		return SessionData[player.UserId].Rebirth
	end
	return nil
end

function PlayerManager.setMultiplier(player: Player, multiplier: number)
	--increment the multplier and they stack
	SessionData[player.UserId].Multiplier = multiplier
end

function PlayerManager.getMultiplier(player: Player): number
	--return the multplier for this player
	return SessionData[player.UserId].Multiplier
end

function PlayerManager.getPlayTime(player: Player): number
	--get the Players current PlayTime and give it back to them
	return if SessionData[player.UserId] then SessionData[player.UserId].PlayTime else 0
end

function PlayerManager.setPlayTime(player: Player, value: number)
	if not SessionData[player.UserId] then return end
	--check value exists
	if value ~= nil then
		--set the session data PlayTime to the same value as the leaderstats when it updates
		SessionData[player.UserId].PlayTime = value

		--find PlayerStats folder on player
		local PlayerStats = player:FindFirstChild("PlayerStats")

		--check leaderstats not invalid
		if PlayerStats ~= nil then
			local timePlayed = PlayerStats:FindFirstChild("TimePlayed") :: NumberValue?
			--check the player has money
			if timePlayed ~= nil then
				timePlayed.Value = value
			end
		end
	end
end

function PlayerManager.getDonateAmount(player: Player): number
	--get the Players current DonateAmount and give it back to them
	return SessionData[player.UserId].DonatedAmount
end

function PlayerManager.setDonateAmount(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data DonateAmount to the same value as the leaderstats when it updates
		SessionData[player.UserId].DonatedAmount = value

		--find PlayerStats folder on player
		local PlayerStats = player:FindFirstChild("PlayerStats")

		--check leaderstats not invalid
		if PlayerStats ~= nil then
			local donatedAmount = PlayerStats:FindFirstChild("DonatedAmount") :: NumberValue?
			--check the player has money
			if donatedAmount ~= nil then
				donatedAmount.Value = value
			end
		end
	end
end

function PlayerManager.getDoughCreatedAmount(player: Player): number
	--get the Players current doughCreated and give it back to them
	return SessionData[player.UserId].doughCreated
end

function PlayerManager.setDoughCreatedAmount(player: Player, value: number)
	local NumberCreated = 0
	if value ~= nil then
		NumberCreated = value
	end
	--check value exists
	if NumberCreated ~= nil then
		--set the session data doughCreated to the same value as the leaderstats when it updates
		SessionData[player.UserId].doughCreated = value

		--find PlayerStats folder on player
		local BreadStats = player:FindFirstChild("BreadStats")

		--check leaderstats not invalid
		if BreadStats ~= nil then
			local doughCreated = BreadStats:FindFirstChild("DoughCreated") :: NumberValue?
			--check the player has money
			if doughCreated ~= nil then
				doughCreated.Value = value
			end
		end
	end
end

function PlayerManager.getWheatCreatedAmount(player: Player): number
	--get the Players current wheatCreated and give it back to them
	return SessionData[player.UserId].wheatCreated
end

function PlayerManager.setWheatCreatedAmount(player: Player, value: number)
	local NumberCreated = 0
	if value ~= nil then
		NumberCreated = value
	end
	--check value exists
	if NumberCreated ~= nil then
		--set the session data wheatCreated to the same value as the leaderstats when it updates
		SessionData[player.UserId].wheatCreated = value

		--find PlayerStats folder on player
		local BreadStats = player:FindFirstChild("BreadStats")

		--check leaderstats not invalid
		if BreadStats ~= nil then
			local wheatCreated = BreadStats:FindFirstChild("WheatCreated") :: NumberValue?
			--check the player has money
			if wheatCreated ~= nil then
				wheatCreated.Value = value
			end
		end
	end
end

function PlayerManager.getBreadShapedAmount(player: Player): number
	--get the Players current breadBaked and give it back to them
	return SessionData[player.UserId].BreadShaped
end

function PlayerManager.setBreadShapedAmount(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data breadShaped to the same value as the leaderstats when it updates
		SessionData[player.UserId].BreadShaped = value

		--find PlayerStats folder on player
		local BreadStats = player:FindFirstChild("BreadStats")

		--check leaderstats not invalid
		if BreadStats ~= nil then
			local doughCreated = BreadStats:FindFirstChild("BreadShaped") :: NumberValue?
			--check the player has money
			if doughCreated ~= nil then
				doughCreated.Value = value
			end
		end
	end
end

function PlayerManager.getBreadCookedAmount(player: Player): number
	--get the Players current breadCooked and give it back to them
	return SessionData[player.UserId].breadCooked
end

function PlayerManager.setBreadCookedAmount(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data doughCreated to the same value as the leaderstats when it updates
		SessionData[player.UserId].breadCooked = value

		--find PlayerStats folder on player
		local BreadStats = player:FindFirstChild("BreadStats")

		--check leaderstats not invalid
		if BreadStats ~= nil then
			local breadCooked = BreadStats:FindFirstChild("BreadCooked") :: NumberValue?
			--check the player has money
			if breadCooked ~= nil then
				breadCooked.Value = value
			end
		end
	end
end

function PlayerManager.getBreadDeliveredAmount(player: Player): number
	--get the Players current BreadDelivered and give it back to them
	return SessionData[player.UserId].breadDelivered
end

function PlayerManager.setBreadDeliveredAmount(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data BreadDelivered to the same value as the leaderstats when it updates
		SessionData[player.UserId].breadDelivered = value

		--find PlayerStats folder on player
		local breadStats = player:FindFirstChild("BreadStats")

		--check leaderstats not invalid
		if breadStats ~= nil then
			local breadDelivered = breadStats:FindFirstChild("BreadDelivered") :: NumberValue?
			--check the player has money
			if breadDelivered ~= nil then
				breadDelivered.Value = value
			end
		end

		--find PlayerStats folder on player
		local leaderStats = player:FindFirstChild("leaderstats")

		--check leaderstats not invalid
		if leaderStats ~= nil then
			local breadDeliveredLocal = leaderStats:FindFirstChild("Bread Delivered") :: NumberValue?
			--check the player has money
			if breadDeliveredLocal ~= nil then
				breadDeliveredLocal.Value = value
			end
		end
	end
end

function PlayerManager.addUnlockId(player: Player, id: number)
	--get the Players data
	local data = SessionData[player.UserId]

	--check if the Id is not already in the table
	if not table.find(data.UnlockIds, id) then
		--add this Id to the table
		table.insert(data.UnlockIds, id)
	end
end

function PlayerManager.getUnlockIDs(player: Player): { [number]: number }
	--return a copy of the table of unlocks
	return SessionData[player.UserId].UnlockIds
end

function PlayerManager.getHighestBreadRackValue(player: Player): number
	--check the value isn't somehow nill
	if SessionData[player.UserId] and SessionData[player.UserId].HighestBreadRackValue ~= nil then
		--return the correct value
		return SessionData[player.UserId].HighestBreadRackValue
	else
		--return the default value
		return 100
	end
end

function PlayerManager.setHighestBreadRackValue(player: Player, value: number?)
	--check the value isn't somehow nill
	if SessionData[player.UserId].HighestBreadRackValue == nil then
		--if it is, then set to default value before continuing
		SessionData[player.UserId].HighestBreadRackValue = 100
	end

	if value ~= nil then
		SessionData[player.UserId].HighestBreadRackValue = value
		HighestBreadRackNotifier:FireClient(player, value)
	end
end

function PlayerManager.getModifierLevel(player: Player, category: string, propertyName: string): number
	local sessionData = SessionData[player.UserId]
	assert(sessionData.Modifiers[category], "no category at " .. tostring(category))
	local lvl = sessionData.Modifiers[category][propertyName]
	assert(lvl, "no level at " .. tostring(category) .. "," .. tostring(propertyName))
	-- if category == "Kneader" and GamepassUtil.getIfSuperKneaderOwned(player.UserId) then
	-- 	lvl = math.max(lvl, 5)
	-- elseif category == "Oven" and GamepassUtil.getIfSuperOvenOwned(player.UserId) then
	-- 	lvl = math.max(lvl, 5)
	-- elseif category == "Wrapper" and GamepassUtil.getIfSuperWrapperOwned(player.UserId) then
	-- 	lvl = math.max(lvl, 5)
	-- end
	return lvl
end

function PlayerManager.setModifierLevel(player: Player, modifierId: string)
	local category = StationModifierUtil.getCategory(modifierId)
	local propertyName = StationModifierUtil.getPropertyName(modifierId)
	local level = StationModifierUtil.getLevel(modifierId)
	-- if category == "Kneader" and GamepassUtil.getIfSuperKneaderOwned(player.UserId) then
	-- 	level = math.max(level, 5)
	-- elseif category == "Oven" and GamepassUtil.getIfSuperOvenOwned(player.UserId) then
	-- 	level = math.max(level, 5)
	-- elseif category == "Wrapper" and GamepassUtil.getIfSuperWrapperOwned(player.UserId) then
	-- 	level = math.max(level, 5)
	-- end
	assert(level, "no level at " .. tostring(modifierId))
	local sessionData = SessionData[player.UserId]
	sessionData.Modifiers[category][propertyName] = level
end

function PlayerManager.getSavedPets(player: Player): TableUtil.List<PetSaveData>
	local sessionData = SessionData[player.UserId]
	if not sessionData then
		local start = tick()
		repeat
			task.wait(1)
			sessionData = SessionData[player.UserId]
		until sessionData or tick() - start > 120
	end
	assert(sessionData)
	return TableUtil.values(TableUtil.deepCopy(sessionData.PetRegistry))
end

function PlayerManager.savePet(player: Player, petSaveData: PetSaveData)
	local sessionData = SessionData[player.UserId]
	sessionData.PetRegistry[petSaveData.Id] = TableUtil.deepCopy(petSaveData)

	--make it so that no other pets automate the same component
	if petSaveData.Assignment then
		for id, v in pairs(sessionData.PetRegistry) do
			if v.Assignment == petSaveData.Assignment and (v.Id ~= petSaveData.Id) then
				local alteredPetSaveData = v
				alteredPetSaveData.Assignment = nil
				sessionData.PetRegistry[id] = alteredPetSaveData
			end
		end
	end
	PetSignalRegistry[player.UserId]:Fire(petSaveData)
end

function PlayerManager.deletePet(player: Player, petId: string)
	local sessionData = SessionData[player.UserId]
	sessionData.PetRegistry[petId] = nil
	PetSignalRegistry[player.UserId]:Fire(nil)
end

function PlayerManager.getAssignedPet(player: Player, componentName: ComponentName): PetSaveData?
	for i, pet in ipairs(PlayerManager.getSavedPets(player)) do
		if pet.Assignment == componentName then
			return pet
		end
	end
	return nil
end

function PlayerManager.dumpModifierIds(player: Player): { [number]: string }
	local sessionData = SessionData[player.UserId]
	local idList = {}
	for category, propReg in pairs(sessionData.Modifiers) do
		for propName, lvl in pairs(propReg) do
			local modId = StationModifierUtil.getId(category, propName, lvl)
			table.insert(idList, modId)
		end
	end
	return idList
end

function PlayerManager.resetModifierLevels(player: Player)
	local data = SessionData[player.UserId]
	--Multiplier Levels
	data.Modifiers = {
		Windmill = {
			Recharge = 1,
			Value = 1,
		},
		Oven = {
			Recharge = 1,
			Value = 1,
		},
		Rack = {
			Storage = 1,
		},
		Kneader = {
			Multiplier = 1,
			Recharge = 1,
		},
		Wrapper = {
			Recharge = 1,
			Multiplier = 1,
		},
	}
end

function PlayerManager.clearUnlockIds(player: Player)
	--reset the Players unlocked Ids table
	--get the Players saved data on the server
	local data = SessionData[player.UserId]

	--wipe the table of unlocks
	table.clear(data.UnlockIds)
end

--Rebirth Stats functions
function PlayerManager.getRebirthCoinsAmount(player: Player): number
	--get the Players current money and give it back to them
	return SessionData[player.UserId].rebirthCoins
end

function PlayerManager.setTrayStorageLimit(player: Player, value: number)
	SessionData[player.UserId].TrayStorageLimit = value
end

function PlayerManager.getTrayStorageLimit(player: Player): number
	return SessionData[player.UserId].TrayStorageLimit
end
function PlayerManager.setRebirthCoinsAmount(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data money to the same value as the leaderstats when it updates
		SessionData[player.UserId].rebirthCoins = value

		--find RebirthStats folder on player
		local RebirthStats = player:FindFirstChild("RebirthStats")

		--check RebirthStats not invalid
		if RebirthStats ~= nil then
			local rebirthCoins = RebirthStats:FindFirstChild("RebirthCoins") :: NumberValue?
			--check the player has money
			if rebirthCoins ~= nil then
				rebirthCoins.Value = value
			end
		end
	end
end

function PlayerManager.getRebirthCoinsSpentAmount(player: Player): number
	--get the Players current money and give it back to them
	return SessionData[player.UserId].rebirthCoinsSpent
end

function PlayerManager.setRebirthCoinsSpentAmount(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data money to the same value as the leaderstats when it updates
		SessionData[player.UserId].rebirthCoinsSpent = value

		--find RebirthStats folder on player
		local RebirthStats = player:FindFirstChild("RebirthStats")

		--check RebirthStats not invalid
		if RebirthStats ~= nil then
			local rebirthCoinsRemaining = RebirthStats:FindFirstChild("RebirthCoinsSpent") :: NumberValue?
			--check the player has money
			if rebirthCoinsRemaining ~= nil then
				rebirthCoinsRemaining.Value = value
			end
		end
	end
end

function PlayerManager.getRebirthCoinsRemainingAmount(player: Player): number
	--get the Players current money and give it back to them
	return SessionData[player.UserId].rebirthCoinsRemaining
end

function PlayerManager.setRebirthCoinsRemainingAmount(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data money to the same value as the leaderstats when it updates
		SessionData[player.UserId].rebirthCoinsRemaining = value

		--find RebirthStats folder on player
		local RebirthStats = player:FindFirstChild("RebirthStats")

		--check RebirthStats not invalid
		if RebirthStats ~= nil then
			local rebirthCoinsRemaining = RebirthStats:FindFirstChild("RebirthCoinsRemaining") :: NumberValue?
			--check the player has money
			if rebirthCoinsRemaining ~= nil then
				rebirthCoinsRemaining.Value = value
			end
		end
	end
end

--Bonus Multiplier functions
function PlayerManager.getMultiplierBonusAmount(player: Player): number
	--get the Players current money and give it back to them
	return SessionData[player.UserId].multiplierBonus
end

function PlayerManager.setMultiplierBonusAmount(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data money to the same value as the leaderstats when it updates
		SessionData[player.UserId].multiplierBonus = value

		--find TimedRewards folder on player
		local timedRewards = player:FindFirstChild("TimedRewards")

		--check TimedRewards not invalid
		if timedRewards ~= nil then
			local multiplayerBonus = timedRewards:FindFirstChild("MultiplierBonus") :: NumberValue?
			--check the player has money
			if multiplayerBonus ~= nil then
				multiplayerBonus.Value = value
			end
		end
	end
end

function PlayerManager.getTimeRemainingAmount(player: Player): number?
	--get the Players current money and give it back to them
	if SessionData[player.UserId] then
		return SessionData[player.UserId].timeRemaining
	end
	return nil
end

function PlayerManager.setTimeRemainingAmount(player: Player, value: number)
	--check value exists
	if value ~= nil then
		--set the session data money to the same value as the leaderstats when it updates
		SessionData[player.UserId].timeRemaining = value

		--find TimedRewards folder on player
		local timedRewards = player:FindFirstChild("TimedRewards")

		--check TimedRewards not invalid
		if timedRewards ~= nil then
			local timeRemaining = timedRewards:FindFirstChild("TimeRemaining") :: IntValue?
			--check the player has money
			if timeRemaining ~= nil then
				timeRemaining.Value = value
			end
		end
	end
end

function PlayerManager.claimTimerReward(player: Player, level: number): boolean
	if SessionData[player.UserId] then
		local sessionStartTimestamp = SessionData[player.UserId].SessionStartTimestamp
		local data: TimerRewardSaveData? = PlayerManager.getTimerRewardSaveData(player, level)
		print("Claiming")
		if data and TimerRewardUtil.getTimeUntilReset(data) == 0 and TimerRewardUtil.getTimeUntilClaimable(data) == 0 then
			data.ClaimTimestamp = TimerRewardUtil.getTimestamp()
			data.IgnoreMultiplier = false
			data.Sessions = {
				{
					StartTimestamp = sessionStartTimestamp,
					ClaimedAt = TimerRewardUtil.getTimestamp(),
				},
			}
			SessionData[player.UserId].TimerRewardList[level] = data
			NetworkUtil.fireClient(ON_UPDATE_PLAYER_TIMER_REWARD_DATA_LIST, player, PlayerManager.getTimerRewardSaveDataList(player))
			return true
		end
	end
	NetworkUtil.fireClient(ON_UPDATE_PLAYER_TIMER_REWARD_DATA_LIST, player, PlayerManager.getTimerRewardSaveDataList(player))
	return false
end

function PlayerManager.getTimerRewardSaveDataList(player: Player): { [number]: TimerRewardSaveData }
	local list = {}
	for lvl = 1, TimerRewardUtil.MAX_LEVEL do
		list[lvl] = assert(PlayerManager.getTimerRewardSaveData(player, lvl))
	end
	return list
end

function PlayerManager.getTimerRewardSaveData(player: Player, level: number): TimerRewardSaveData?
	if SessionData[player.UserId] then
		local data: TimerRewardSaveData? = SessionData[player.UserId].TimerRewardList[level]
		local sessionStartTimestamp = SessionData[player.UserId].SessionStartTimestamp
		if not data then
			print("reconstructing data: ", level)
			data = {
				Level = level,
				ClaimTimestamp = TimerRewardUtil.getTimestamp(),
				IgnoreMultiplier = true,
				Sessions = {},
			}
			assert(data)
			SessionData[player.UserId].TimerRewardList[level] = data
		end

		assert(data)
		local isCurrentSessionRegistered = false
		for i, sessionData in ipairs(data.Sessions) do
			if sessionData.StartTimestamp == sessionStartTimestamp then
				isCurrentSessionRegistered = true
				break
			end
		end
		if not isCurrentSessionRegistered then
			table.insert(data.Sessions, {
				StartTimestamp = sessionStartTimestamp,
				ClaimAt = if #data.Sessions == 0 then data.ClaimTimestamp else nil,
				FinishTimestamp = nil,
			})
		end

		SessionData[player.UserId].TimerRewardList[level] = data

		return TableUtil.deepCopy(data)
	end
	return nil
end

function PlayerManager.onPlayerRemoving(player: Player)
	-- update session data in ranges
	for lvl, timerRewardData in ipairs(SessionData[player.UserId].TimerRewardList) do
		for i, sessionData in ipairs(timerRewardData.Sessions) do
			if SessionData[player.UserId].SessionStartTimestamp == sessionData.StartTimestamp then
				sessionData.FinishTimestamp = TimerRewardUtil.getTimestamp()
			end
		end
	end

	--save the Players data to the datastore
	saveData(player, SessionData[player.UserId])
	--when this player attempts to leave fire this event
	PlayerRemoving:Fire(player)
end

function PlayerManager.onClose()
	--debug to stop firing in studio
	if game:GetService("RunService"):IsStudio() then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		--save the Players data to the datastore when the server closes just in case it failed before
		coroutine.wrap(function()
			PlayerManager.onPlayerRemoving(player)
		end)()
	end
end

--function to check what gamepasses the player currently owns
function PlayerManager.registerGamepasses(player: Player)
	--loop through all the game passes
	for id, passFunction in pairs(Gamepass) do
		--if the player owns this gamepass
		local success, msg = pcall(function()
			if MarketplaceService:UserOwnsGamePassAsync(player.UserId, id) then
				passFunction(player)
			end
		end)
		if not success then
			warn(msg)
		end
	end
end

function PlayerManager.resetData(player: Player)
	local success1, message1 = pcall(function()
		PlayerData:RemoveAsync(getRebirthKey(player.UserId))
	end)
	if not success1 then
		warn("rebirth reset failed: " .. tostring(message1))
	end
	local success2, message2 = pcall(function()
		PlayerData:RemoveAsync(getDataKey(player.UserId))
	end)
	if not success2 then
		warn("data reset failed: " .. tostring(message2))
	end
	SessionData[player.UserId] = TableUtil.deepCopy(DATA_TEMPLATE)
end

NetworkUtil.onServerInvoke(GET_ONBOARDING_PROGRESS_KEY, function(player: Player): OnboardingData?
	local session = SessionData[player.UserId]
	if session then
		return session.Onboarding
	end
	return nil
end)

AFKRewardEvent.Event:Connect(function(player: Player, rewardValue: number)
	--get the current Players money and increase by whatever is the reward value
	local Money = PlayerManager.getMoney(player) + rewardValue

	--save the new value
	PlayerManager.setMoney(player, Money)

	--save the new value
	PlayerManager.setTotalMoney(player, PlayerManager.getTotalMoney(player) + rewardValue)
end)

--Bind the invoke to player manager.
GetHighestBreadRackValue.OnServerInvoke = PlayerManager.getHighestBreadRackValue
NetworkUtil.getRemoteEvent(ON_UPDATE_PLAYER_TIMER_REWARD_DATA_LIST)
NetworkUtil.onServerInvoke(GET_PLAYER_TIMER_REWARD_DATA_LIST, function(player: Player): { [number]: TimerRewardSaveData }
	return PlayerManager.getTimerRewardSaveDataList(player)
end)

return PlayerManager
