--!strict
-- Services
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
-- Packages
local PetModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetModifierUtil"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
-- Modules
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
-- Types
type Maid = Maid.Maid
-- Constants
local GET_PET_DATA_LIST = "GetPetDataList"
local ON_UPDATE_PET_DATA_LIST = "OnUpdatePetDataList"
local GET_PET_SELECTION = "GetPetSelection"
local ON_UPDATE_PET_SELECTION = "OnUpdatePetSelection"
local ON_PROMPT_ACTIVATED = "OnPetAssignmentPrompt"
local OWNER_ONLY_TAG = "OwnerOnly"
local ASSIGN_PET_EVENT = "AssignPetToStation"
local DELETE_PET_EVENT = "DeletePet"
local MERGE_PETS_EVENT = "MergePets"
local ON_PET_ASSIGNMENT = "OnPetAssignment"
-- Variables
-- References
NetworkUtil.getRemoteEvent(ON_PET_ASSIGNMENT)
-- Private functions
function getPromptAnchor(station: Instance): BasePart?
	for i, inst in ipairs(station:GetDescendants()) do
		if inst:IsA("BasePart") and inst.Name == "PetPosition" then
			return inst
		end
	end
	return nil
end
function getPetData(player: Player, petId: string): PlayerManager.PetSaveData
	local petDataList: { [number]: PlayerManager.PetSaveData } = PlayerManager.getSavedPets(player)
	for i, data in ipairs(petDataList) do
		if data.Id == petId then
			return data
		end
	end
	error("bad pet data for " .. tostring(petId))
end

NetworkUtil.getRemoteEvent(ON_UPDATE_PET_DATA_LIST)
NetworkUtil.getRemoteEvent(ON_UPDATE_PET_SELECTION)
NetworkUtil.getRemoteEvent(ON_PROMPT_ACTIVATED)

function bootAnchor(anchor: BasePart?, station: Instance, owner: Player): Maid?
	if not anchor then
		return
	end
	assert(anchor, "bad anchor")

	local stationName: PlayerManager.ComponentName = station.Name :: any

	local maid = Maid.new()
	maid:GiveTask(anchor.Destroying:Connect(function()
		maid:Destroy()
	end))

	NetworkUtil.onServerInvoke(GET_PET_DATA_LIST, function(player: Player): { [number]: PlayerManager.PetSaveData }
		if player == owner then
			return PlayerManager.getSavedPets(player)
		end
		return {}
	end)

	NetworkUtil.onServerInvoke(GET_PET_SELECTION, function(player: Player, componentName: PlayerManager.ComponentName): PlayerManager.PetSaveData?
		if player == owner then
			return PlayerManager.getAssignedPet(player, componentName)
		end
		return nil
	end)

	local currentPetId: string? = nil
	local initialPet: PlayerManager.PetSaveData? = PlayerManager.getAssignedPet(owner, stationName)
	if initialPet then
		currentPetId = initialPet.Id
	end

	maid:GiveTask(PlayerManager.getPetDataChangedSignal(owner):Connect(function(petData: PlayerManager.PetSaveData?)
		if petData then
			if petData.Id == currentPetId and petData.Assignment ~= stationName then
				NetworkUtil.fireClient(ON_UPDATE_PET_SELECTION, owner, nil)
				currentPetId = nil
			end
			if petData.Assignment == stationName then
				currentPetId = petData.Id
				NetworkUtil.fireClient(ON_UPDATE_PET_SELECTION, owner, petData)
			end
		elseif currentPetId then
			local success = pcall(function()
				getPetData(owner, currentPetId)
			end)
			if not success then
				NetworkUtil.fireClient(ON_UPDATE_PET_SELECTION, owner, nil)
				currentPetId = nil
			end
		end

		NetworkUtil.fireClient(ON_UPDATE_PET_DATA_LIST, owner, PlayerManager.getSavedPets(owner))
	end))

	maid:GiveTask(NetworkUtil.onServerEvent(ASSIGN_PET_EVENT, function(player: Player, componentName: PlayerManager.ComponentName, petId: string)
		if player == owner and componentName == stationName then
			local petData = getPetData(player, petId)
			petData.Assignment = stationName
			PlayerManager.savePet(player, petData)
			NetworkUtil.fireClient(ON_PET_ASSIGNMENT, player)
		end
	end))
	maid:GiveTask(NetworkUtil.onServerEvent(DELETE_PET_EVENT, function(player: Player, componentName: PlayerManager.ComponentName, petId: string)
		if player == owner and componentName == stationName then
			PlayerManager.deletePet(player, petId)
		end
	end))
	maid:GiveTask(NetworkUtil.onServerEvent(MERGE_PETS_EVENT, function(player: Player, componentName: PlayerManager.ComponentName, petAId: string, petBId: string)
		if player == owner and componentName == stationName then
			local petAData = getPetData(player, petAId)
			local petBData = getPetData(player, petBId)
			local mergeOutcome = PetModifierUtil.getMergeOutcome(petAData.BalanceId, petBData.BalanceId)
			assert(mergeOutcome, "Pets can't be merged: " .. tostring(petAId) .. ", " .. tostring(petBId))
			PlayerManager.deletePet(player, petAId)
			PlayerManager.deletePet(player, petBId)
			PlayerManager.savePet(player, {
				Id = HttpService:GenerateGUID(false),
				BalanceId = mergeOutcome,
				Assignment = componentName,
			})
			print("merge success")
		end
	end))

	local prompt = maid:GiveTask(Instance.new("ProximityPrompt"))
	prompt.Name = "PetAssignment"
	prompt.ActionText = "Assign Pet"
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.Q
	CollectionService:AddTag(prompt, "ProximityPrompt")
	CollectionService:AddTag(prompt, OWNER_ONLY_TAG)
	maid:GiveTask(prompt.Triggered:Connect(function(player: Player)
		if player == owner then
			NetworkUtil.fireClient(ON_PROMPT_ACTIVATED, owner, stationName)
		end
	end))
	prompt.Parent = anchor

	return maid
end

-- Class
return function(station: Instance, owner: Player)
	station.DescendantAdded:Connect(function(inst: Instance)
		if inst.Name == "PetPosition" and inst:IsDescendantOf(station) and inst:IsA("BasePart") then
			bootAnchor(inst, station, owner)
		end
	end)
	return bootAnchor(getPromptAnchor(station), station, owner)
end
