--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
-- local PetKinds = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetKinds"))
--classes
local Pet = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"):WaitForChild("Pet"))

--types
type Maid = Maid.Maid
type Pet = Pet.Pet

export type MouseProperties = {} & Pet.PetProperties
export type MouseFunctions<Self> = {} & Pet.PetFunctions<Self>
export type MouseInfo<Self> = MouseProperties & MouseFunctions<Self>
export type Mouse = MouseInfo<MouseInfo<any>>

-- constants
-- local ANIMATION_IDS = {
-- 	Walk = 12316954325,
-- 	WalkObject = 12318817353,
-- 	Sit = 12704652912,
-- 	Bored = 12704672466,
-- 	Sleep = 12704684232,
-- }

--class
local Mouse = {} :: Mouse
Mouse.__index = Mouse
setmetatable(Mouse, Pet)

function Mouse.new(balanceId: string, player: Player, cframe: CFrame, ...): Mouse
	local self: Mouse = setmetatable(Pet.new(balanceId, player, cframe, ...), Mouse) :: any
	-- self.Energy = self:GetMaxEnergy()
	self.BalanceId = balanceId

	self:Update()
	return self
end

-- function Mouse:GetMaxEnergy()
-- 	assert(PetKinds.Mouse.LevelsStats[self.Level], "Level not found!")
-- 	return PetKinds.Mouse.LevelsStats[self.Level].MaximumEnergy
-- end

function Mouse.init(maid: Maid)
	return nil
end

return Mouse
