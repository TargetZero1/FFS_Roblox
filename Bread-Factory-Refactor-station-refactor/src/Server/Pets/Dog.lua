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

export type DogProperties = {} & Pet.PetProperties
export type DogFunctions<Self> = {} & Pet.PetFunctions<Self>
export type DogInfo<Self> = DogProperties & DogFunctions<Self>
export type Dog = DogInfo<DogInfo<any>>

-- constants
-- local ANIMATION_IDS = {
-- 	Walk = 12693536525,
-- 	WalkObject = 12693565088,
-- 	Sit = 12693950494,
-- 	Bored = 12694890610,
-- 	Sleep = 12694745704,
-- }

--class
local Dog = {} :: Dog
Dog.__index = Dog
setmetatable(Dog, Pet)

function Dog.new(balanceId: string, player: Player, cframe: CFrame, ...): Dog
	local self: Dog = setmetatable(Pet.new(balanceId, player, cframe, ...), Dog) :: any
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

function Dog.init(maid: Maid)
	return nil
end

return Dog
