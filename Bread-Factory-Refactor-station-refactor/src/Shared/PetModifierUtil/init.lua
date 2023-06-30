--!strict
-- Services
-- Packages
-- Modules
local BaseModifierUtil = require(script:WaitForChild("BaseModifierUtil"))
-- Types
export type PetClass = BaseModifierUtil.PetClass
export type PetMetal = BaseModifierUtil.PetMetal
-- Constants
-- Variables
-- References
-- Class
local Util = {}

-- Done to avoid recursive dependency with StationModifierUtil
Util.getData = BaseModifierUtil.getData
Util.getModifier = BaseModifierUtil.getModifier

function Util.getBalanceId(class: PetClass, metal: PetMetal, level: number): string
	return class .. "_" .. metal .. "_" .. tostring(level)
end

function Util.getClass(balanceId: string): PetClass
	local class: any = balanceId:split("_")[1]
	assert(class, "bad class for " .. tostring(balanceId))
	return class
end

function Util.getLevel(balanceId: string): number
	local levelText: string = balanceId:split("_")[3]
	local level: number? = tonumber(levelText)
	assert(level, "bad level for " .. tostring(balanceId))
	return level
end

function Util.getName(id: string): string
	local data = Util.getData(id)
	local name = data.Name
	assert(name, "bad name for id " .. tostring(id))
	return name
end

function Util.getCost(balanceId: string): number
	local data = Util.getData(balanceId)
	local cost = data.Cost
	assert(cost, "bad cost for id " .. tostring(balanceId))
	return cost
end

function Util.getHatchCost(petClass: PetClass): number
	local baseId = Util.getBalanceId(petClass, "Normal", 1)
	return Util.getCost(baseId)
end

function Util.getBallots(balanceId: string): number
	local data = Util.getData(balanceId)
	local ballots = data.Ballots
	assert(ballots, "bad ballots for id " .. tostring(balanceId))
	return ballots
end

function Util.getMetalTier(balanceId: string): PetMetal
	local metal: string = balanceId:split("_")[2]
	assert(metal, "no metal tier for " .. tostring(balanceId))
	return metal :: PetMetal
end

function Util.getMetalUpgrade(balanceId: string): string?
	local order: { [number]: PetMetal } = { "Normal", "Silver", "Gold", "Diamond" }

	local metalIndex = table.find(order, Util.getMetalTier(balanceId))
	if metalIndex then
		return order[metalIndex + 1]
	end
	return nil
end

function Util.getMergeOutcome(petABalancingId: string, petBBalancingId: string): string?
	local petAClass = Util.getClass(petABalancingId)
	local petBClass = Util.getClass(petBBalancingId)
	local petAMetal = Util.getMetalTier(petABalancingId)
	local petBMetal = Util.getMetalTier(petBBalancingId)
	local nextPetMetal = Util.getMetalUpgrade(petABalancingId)
	if nextPetMetal and petAMetal == petBMetal and petAClass == petBClass then
		return Util.getBalanceId(petAClass :: PetClass, nextPetMetal :: PetMetal, 1)
	else
		return nil
	end
end

function Util.getRarity(balanceId: string): number
	local data = Util.getData(balanceId)
	local chance = data.Chance
	assert(chance, "bad rarity for id " .. tostring(balanceId))
	return chance
end

function Util.getBreadPerMinute(balanceId: string): number
	local data = Util.getData(balanceId)
	local breadPerMinute = data.BreadPerMinute
	assert(breadPerMinute, "bad bread-per-minute for id " .. tostring(balanceId))
	return breadPerMinute
end

return Util
