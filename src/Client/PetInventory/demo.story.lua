--!strict

--services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))

--modules
local PetInventory = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("PetInventory"))
local PetModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetModifierUtil"))

--types
type Maid = Maid.Maid
type Fuse = ColdFusion.Fuse
type CanBeState<a> = ColdFusion.CanBeState<a>
type State<a> = ColdFusion.State<a>
type ValueState<a> = ColdFusion.ValueState<a>
type PetSaveData = PetInventory.PetSaveData

--constants
local CLASSES = { "Mouse", "Cat", "Bird", "Dog" }

--local functions
local function getRandomModifiedPetData()
	local rand = math.random(1, 4)
	local petClass = CLASSES[rand]
	local petId = PetModifierUtil.getBalanceId(petClass :: any, "Normal", math.random(1, 5))

	local petData: PetSaveData = {
		Id = HttpService:GenerateGUID(false),
		BalanceId = petId,
		Assignment = if math.random() < 0.1 then "Wrapper" else nil,
	}

	return petData
end

return function(target: Instance?): () -> ()
	local maid = Maid.new()

	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Computed = _fuse.Computed
	local _Value = _fuse.Value

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	local petsData = _Value({
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
		getRandomModifiedPetData(),
	})
	local PetSelection = _Value(nil :: any)

	local MergeTarget = _Value(nil :: any)

	local OnEquip = maid:GiveTask(Signal.new())
	local OnMerge = maid:GiveTask(Signal.new())
	local OnDelete = maid:GiveTask(Signal.new())
	local OnSelect = maid:GiveTask(Signal.new())

	local petInventory = maid:GiveTask(PetInventory(maid, petsData, PetSelection, MergeTarget, OnEquip, OnMerge, OnDelete, OnSelect))
	petInventory.Parent = target

	maid:GiveTask(OnSelect:Connect(function(selectData: PetSaveData?)
		print("select click")
		PetSelection:Set(selectData)
	end))

	maid:GiveTask(OnEquip:Connect(function(modifiedPetData: PetSaveData)
		print("equip click")
	end))

	maid:GiveTask(OnMerge:Connect(function(modifiedPetData: PetSaveData)
		print("merge click")
		if MergeTarget:Get() == modifiedPetData then
			MergeTarget:Set(nil)
		else
			MergeTarget:Set(modifiedPetData)
		end
	end))

	maid:GiveTask(OnDelete:Connect(function(modifiedPetData: PetSaveData)
		print("delete click")
	end))

	return function()
		maid:Destroy()
	end
end
