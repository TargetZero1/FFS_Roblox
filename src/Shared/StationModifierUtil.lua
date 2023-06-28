--!strict
-- Services
-- Packages
-- Modules
local KneaderMultiplierData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("KneaderMultiplierData"))
local KneaderRechargeData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("KneaderRechargeData"))
local OvenRechargeData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("OvenRechargeData"))
local OvenValueData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("OvenValueData"))
local RackStorageData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("RackStorageData"))
local WindmillRechargeData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("WindmillRechargeData"))
local WindmillValueData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("WindmillValueData"))
local WrapperMultiplierData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("WrapperMultiplierData"))
local WrapperRechargeData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("WrapperRechargeData"))
local PetBaseModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetModifierUtil"):WaitForChild("BaseModifierUtil"))
local GamepassUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("GamepassUtil"))

-- Types
export type ModifierData = {
	ModifierId: string,
	Category: string,
	Property: string,
	Icon: string,
	Description: string,
	Level: number,
	Cost: number,
	BaseValue: number,
	OptimalValue: number,
}
export type PetMetal = "Normal" | "Silver" | "Gold" | "Diamond"
export type PetClass = "Cat" | "Dog" | "Mouse" | "Bird"
-- Constants
local TREE = {
	Kneader = {
		Multiplier = KneaderMultiplierData,
		Recharge = KneaderRechargeData,
	},
	Oven = {
		Value = OvenValueData,
		Recharge = OvenRechargeData,
	},
	Rack = {
		Storage = RackStorageData,
	},
	Windmill = {
		Recharge = WindmillRechargeData,
		Value = WindmillValueData,
	},
	Wrapper = {
		Multiplier = WrapperMultiplierData,
		Recharge = WrapperRechargeData,
	},
}
-- Variables
-- References
-- Class
local Util = {}

function Util.getCategory(id: string): string
	local category = id:split("_")[1]
	assert(category, "assertion failed")
	return category
end

function Util.getPropertyName(id: string): string
	local propName = id:split("_")[2]
	assert(propName, "assertion failed")
	return propName
end

function Util.getIfModifierExists(id: string): boolean
	local cat = Util.getCategory(id)
	local propName = Util.getPropertyName(id)
	local lvl = Util.getLevel(id)
	local catData = TREE[cat]
	if not catData then
		return false
	end
	assert(catData, "no category for " .. tostring(id))

	local propData = catData[propName]
	if not propData then
		return false
	end
	assert(propData, "no property for " .. tostring(id))

	local data = propData[lvl]
	if not data then
		return false
	end
	assert(data, "no data for " .. tostring(id))

	return true
end

function Util.getLevel(id: string): number
	local levelStr = id:split("_")[3]
	assert(levelStr, "assertion failed")
	local levelNum = tonumber(levelStr)
	assert(levelNum, "assertion failed")
	return levelNum
end

function Util.getData(id: string): ModifierData
	local cat = Util.getCategory(id)
	local propName = Util.getPropertyName(id)
	local lvl = Util.getLevel(id)
	local catData = TREE[cat]
	assert(catData, "no category for " .. tostring(id))
	local propData = catData[propName]
	assert(propData, "no property for " .. tostring(id))
	local data = propData[lvl]
	assert(data, "no data for " .. tostring(id))
	return data
end

function Util.getPropertyMaxLevel(id: string): number
	local cat = Util.getCategory(id)
	local propName = Util.getPropertyName(id)
	local catData = TREE[cat]
	assert(catData, "no category for " .. tostring(id))
	return #catData[propName]
end

function Util.getId(category: string, property: string, level: number): string
	return category .. "_" .. property .. "_" .. tostring(level)
end

function Util.getCost(id: string): number
	local data = Util.getData(id)
	assert(data.Cost ~= nil)
	return data.Cost
end

function Util.getIcon(id: string): string
	local data = Util.getData(id)
	return assert(data.Icon, "failed for " .. tostring(id))
end
function Util.getDescription(id: string): string
	local data = Util.getData(id)
	return assert(data.Description, "failed for " .. tostring(id))
end

function Util.getValue(id: string, player: Player, petBalanceId: string?): number
	local category = Util.getCategory(id)
	local propertyName = Util.getPropertyName(id)

	if
		(category == "Kneader" and GamepassUtil.getIfSuperKneaderOwned(player.UserId))
		or (category == "Oven" and GamepassUtil.getIfSuperOvenOwned(player.UserId))
		or (category == "Wrapper" and GamepassUtil.getIfSuperWrapperOwned(player.UserId))
	then
		local level = Util.getLevel(id)
		id = Util.getId(category, propertyName, math.min(level + 5, Util.getPropertyMaxLevel(id)))
	end

	if category == "Rack" and propertyName == "Storage" and GamepassUtil.getIfInfiniteTrayOwned(player.UserId) then
		return 999
	end

	local data = Util.getData(id)
	local baseValue = data.BaseValue
	local optimalValue = data.OptimalValue
	assert(baseValue, "base value not found for " .. tostring(id))
	assert(optimalValue, "optimal value not found for " .. tostring(id))

	if petBalanceId then
		local petModifier = PetBaseModifierUtil.getModifier(petBalanceId)

		if
			(category == "Kneader" and GamepassUtil.getIfSuperKneaderOwned(player.UserId))
			or (category == "Oven" and GamepassUtil.getIfSuperOvenOwned(player.UserId))
			or (category == "Wrapper" and GamepassUtil.getIfSuperWrapperOwned(player.UserId))
		then
			petModifier = 1 - ((1 - petModifier) * 0.5)
		end

		return math.round(100 * (baseValue + (optimalValue - baseValue) * petModifier)) / 100
	else
		return baseValue
	end
end

return Util
