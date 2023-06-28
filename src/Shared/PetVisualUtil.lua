--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
--modules
local ChanceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ChanceUtil"))
local PetModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetModifierUtil"))
--types
type RarityName = ChanceUtil.ChanceName
type Rarity<a> = ChanceUtil.Chance<a>
--constants
--variables
--references
local Assets = ReplicatedStorage:WaitForChild("Assets")
--class
local PetVisualUtil = {}

function PetVisualUtil.getPetModelNameByInfo(balanceId: string)
	local PetModels = Assets:WaitForChild("PetModels")
	assert(PetModels, "assertion failed")
	local petName: string
	local petClass = PetModifierUtil.getClass(balanceId)
	local level = PetModifierUtil.getLevel(balanceId)
	local nameStart = petClass .. tostring(level)
	for _, petModel: Model in pairs(PetModels:GetChildren() :: any) do
		if petModel.Name:find(nameStart) then
			petName = petModel.Name
			break
		end
	end
	assert(petName, "bad pet name for " .. tostring(balanceId))
	return petName
end

function PetVisualUtil.displayPet(balanceId: string): Model
	local PetModels = Assets:WaitForChild("PetModels")
	assert(PetModels, "assertion failed")
	local petDisplay: Instance? = PetModels:FindFirstChild(PetVisualUtil.getPetModelNameByInfo(balanceId))
	assert(petDisplay, "Unable to find the pet model")
	assert(petDisplay:IsA("Model"), "petDisplay is not a model")
	return petDisplay:Clone()
end

return PetVisualUtil
