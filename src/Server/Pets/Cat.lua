--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--classes
local Pet = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"):WaitForChild("Pet"))

--types
type Maid = Maid.Maid

type Pet = Pet.Pet

export type CatProperties = {} & Pet.PetProperties
export type CatFunctions<Self> = {} & Pet.PetFunctions<Self>
export type CatInfo<Self> = CatProperties & CatFunctions<Self>
export type Cat = CatInfo<CatInfo<any>>

-- constants
-- local ANIMATION_IDS = {
-- 	Walk = 12308318874,
-- 	WalkObject = 12319016926,
-- 	Sit = 12328546231,
-- 	Bored = 12400607053,
-- 	Sleep = 12339976330,
-- }

--class
local Cat = {} :: Cat
Cat.__index = Cat
setmetatable(Cat, Pet)

function Cat.new(balanceId: string, player: Player, cframe: CFrame, ...): Cat
	local self: Cat = setmetatable(Pet.new(balanceId, player, cframe, ...), Cat) :: any
	self.BalanceId = balanceId

	--adjusting velocity
	local primaryPart = self.PetModel.PrimaryPart
	assert(primaryPart, "assertion failed")
	local alignPosition = primaryPart:FindFirstChild("AlignPosition")
	assert(alignPosition and alignPosition:IsA("AlignPosition"), "assertion failed")
	alignPosition.MaxVelocity = 15

	self:Update()
	return self
end

function Cat.init(maid: Maid)
	return nil
end

return Cat
