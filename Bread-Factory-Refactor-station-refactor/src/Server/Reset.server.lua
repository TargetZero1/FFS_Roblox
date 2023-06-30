--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local CollectionService = game:GetService("CollectionService")
-- Services
-- Packages
-- Modules
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))

-- Types
-- Constants
-- local DO_NOT_SAVE_TAG = "DO_NOT_SAVE_PLAYER_DATA"
-- Variables
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ResetEvent = RemoteEvents:WaitForChild("RESET") :: RemoteEvent
-- Class

function resetPlayer(player: Player?)
	--check player that touched the button has not already spawned a tycoon
	if player ~= nil then
		--RESET everything

		-- --save the new value
		-- PlayerManager.setMoney(player, 0)
		-- PlayerManager.setTotalMoney(player, 0)
		-- PlayerManager.setRebirths(player, 0)
		-- PlayerManager.setMultiplier(player, 0)
		-- PlayerManager.clearUnlockIds(player)
		-- PlayerManager.resetModifierLevels(player)
		-- PlayerManager.setCareerCash(player, 0)
		-- PlayerManager.setHighestBreadRackValue(player, 100)
		-- --bread stats
		-- PlayerManager.setDoughCreatedAmount(player, 0)
		-- PlayerManager.setBreadShapedAmount(player, 0)
		-- PlayerManager.setBreadDeliveredAmount(player, 0)
		-- PlayerManager.setBreadCookedAmount(player, 0)

		-- --Rebirth stats
		-- PlayerManager.setRebirthCoinsAmount(player, 0)
		-- PlayerManager.setRebirthCoinsRemainingAmount(player, 0)
		-- PlayerManager.setRebirthCoinsSpentAmount(player, 0)

		-- PlayerManager.setPlayTime(player, 0)

		-- --reset multipliers
		-- PlayerManager.setMultiplierBonusAmount(player, 0)
		-- PlayerManager.setTimeRemainingAmount(player, 0)

		-- --Rebirth/Bread coins
		-- PlayerManager.setRebirthCoinsRemainingAmount(player, 0)
		-- PlayerManager.setRebirthCoinsSpentAmount(player, 0)
		-- PlayerManager.setRebirthCoinsAmount(player, 0)

		-- PlayerManager.setDonateAmount(player, 0)

		-- local resetBreadData: BreadManager.PlayerData = { --template table
		-- 	BreadType1 = { Name = "Sourdough", Amount = 0, Value = 0 },
		-- 	BreadType2 = { Name = "Tabatiere", Amount = 0, Value = 0 },
		-- 	BreadType3 = { Name = "Zopf", Amount = 0, Value = 0 },
		-- 	BreadType4 = { Name = "Pitta", Amount = 0, Value = 0 },
		-- 	BreadType5 = { Name = "Ciabatta", Amount = 0, Value = 0 },
		-- 	BreadType6 = { Name = "EpiDeBle", Amount = 0, Value = 0 },
		-- 	BreadType7 = { Name = "BaguetteFlute", Amount = 0, Value = 0 },
		-- 	BreadType8 = { Name = "BaguetteFicelle", Amount = 0, Value = 0 },
		-- 	BreadType9 = { Name = "BaguetteDeCampagne", Amount = 0, Value = 0 },
		-- 	BreadType10 = { Name = "PainComplet", Amount = 0, Value = 0 },
		-- 	BreadType11 = { Name = "PainDeMie", Amount = 0, Value = 0 },
		-- 	BreadType12 = { Name = "PainPolka", Amount = 0, Value = 0 },
		-- 	BreadType13 = { Name = "PainAuxCereales", Amount = 0, Value = 0 },
		-- 	BreadType14 = { Name = "PainAuLevain", Amount = 0, Value = 0 },
		-- 	BreadType15 = { Name = "PainDeSeigleNoir", Amount = 0, Value = 0 },
		-- 	BreadType16 = { Name = "PainDeCampagne", Amount = 0, Value = 0 },
		-- }

		-- BreadManager.setBreadTable(player, resetBreadData)

		-- local resetCosmeticData: CosmeticManager.PlayerData = { --template table
		-- 	--Modifier Levels
		-- 	Equipped = {
		-- 		["Background"] = "Default",
		-- 		["Logo"] = "Default",
		-- 		["Theme"] = "Default",
		-- 		["VFX"] = "Default",
		-- 	},
		-- 	Backgrounds = {
		-- 		["Background1"] = { Unlocked = false },
		-- 		["Background2"] = { Unlocked = false },
		-- 		["Background3"] = { Unlocked = false },
		-- 		["Background4"] = { Unlocked = false },
		-- 		["Background5"] = { Unlocked = false },
		-- 	},
		-- 	Logos = {
		-- 		["Logo1"] = { Unlocked = false },
		-- 		["Logo2"] = { Unlocked = false },
		-- 		["Logo3"] = { Unlocked = false },
		-- 		["Logo4"] = { Unlocked = false },
		-- 		["Logo5"] = { Unlocked = false },
		-- 	},
		-- 	Themes = {
		-- 		["Theme1"] = { Unlocked = false },
		-- 		["Theme2"] = { Unlocked = false },
		-- 		["Theme3"] = { Unlocked = false },
		-- 		["Theme4"] = { Unlocked = false },
		-- 		["Theme5"] = { Unlocked = false },
		-- 	},
		-- 	VFX = {
		-- 		["VFX1"] = { Unlocked = false },
		-- 		["VFX2"] = { Unlocked = false },
		-- 		["VFX3"] = { Unlocked = false },
		-- 		["VFX4"] = { Unlocked = false },
		-- 		["VFX5"] = { Unlocked = false },
		-- 	},
		-- }
		-- CosmeticManager.setCosmeticsTable(player, resetCosmeticData)

		-- --UI for Current multiplier values
		-- local UIParent = player.PlayerGui:WaitForChild("ScreenGui")
		-- local TimerUI = UIParent:WaitForChild("ObbyTimer")

		-- TimerUI:SetAttribute("TimeRemaining", 0)

		-- --set player attributes
		-- player:SetAttribute("FeedTheWorld", false)
		-- player:SetAttribute("Timer", 0)
		-- player:SetAttribute("EasyObby", false)
		-- player:SetAttribute("HardObby", false)
		-- player:SetAttribute("FriendMultiplier", 1)
		local donateValue = PlayerManager.getDonateAmount(player)
		PlayerManager.resetData(player)
		PlayerManager.setDonateAmount(player, donateValue)
		-- CollectionService:AddTag(player, DO_NOT_SAVE_TAG)
		player:Kick("RESET DATA")
	end
end

--hook up event for when player clicks the reset button
ResetEvent.OnServerEvent:Connect(function(player: Player)
	resetPlayer(player)
end)
