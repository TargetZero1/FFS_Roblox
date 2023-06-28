--!strict
-- this core functionality has been split from the original script to avoid recursive dependencies with StationModifierUtil
-- Services
-- Packages
-- Modules
local PetData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("PetData"))
-- Types
export type PetData = PetData.EntryData
export type PetMetal = "Normal" | "Silver" | "Gold" | "Diamond"
export type PetClass = "Cat" | "Dog" | "Mouse" | "Bird"
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

function Util.getData(balanceId: string): PetData
	local data = PetData[balanceId]
	assert(data, "bad data for " .. tostring(balanceId))
	return data
end

function Util.getModifier(balanceId: string): number
	local data = Util.getData(balanceId)
	local modifier = data.Modifier
	assert(modifier, "bad modifier for id " .. tostring(balanceId))
	return modifier
end

return Util
