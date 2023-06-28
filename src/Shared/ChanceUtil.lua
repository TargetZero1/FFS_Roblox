--!strict

--types
export type ChanceName = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"

export type Chance<Name> = {
	ChancePoint: number,
	Name: Name,
}

local ChanceUtil = {}

ChanceUtil.RarityNameList = { "Common", "Uncommon", "Rare", "Epic", "Legendary" }

function ChanceUtil.new(chancePoint: number, name: ChanceName)
	return {
		ChancePoint = chancePoint,
		Name = name,
	} :: Chance<ChanceName>
end

function ChanceUtil.collapse(rarityTable: { [number]: Chance<ChanceName> })
	local totalPoints = 0
	for _, chance in pairs(rarityTable) do
		totalPoints += chance.ChancePoint
	end

	local rand = math.random(0, totalPoints)
	local collapsedChance
	local ptChance = 0
	for i, chance in pairs(rarityTable) do
		ptChance += chance.ChancePoint
		if ptChance >= rand then
			collapsedChance = chance
			break
		end
	end
	return collapsedChance
end

return ChanceUtil
