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

export type BirdProperties = {} & Pet.PetProperties
export type BirdFunctions<Self> = {} & Pet.PetFunctions<Self>
export type BirdInfo<Self> = BirdProperties & BirdFunctions<Self>
export type Bird = BirdInfo<BirdInfo<any>>

-- constants
-- local ANIMATION_ID = {
-- 	Walk = 12693536525,
-- 	WalkObject = 12693565088,
-- 	Sit = 12693950494,
-- 	Bored = 12694890610,
-- 	Sleep = 12694745704,
-- }

--class
local Bird = {} :: Bird
Bird.__index = Bird
setmetatable(Bird, Pet)

function Bird.new(balanceId: string, player: Player, cframe: CFrame, ...): Bird
	local self: Bird = setmetatable(Pet.new(balanceId, player, cframe, ...), Bird) :: any
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

function Bird.init(maid: Maid)
	return nil
end

return Bird
