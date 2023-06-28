--!strict
-- Services
local Players = game:GetService("Players")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
-- Modules
local PetInventory = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("PetInventory"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local PetModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetModifierUtil"))
local ExitButton = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ExitButton"))
-- Types
type Maid = Maid.Maid
type PetSaveData = PetInventory.PetSaveData
type Fuse = ColdFusion.Fuse
type CanBeState<a> = ColdFusion.CanBeState<a>
type State<a> = ColdFusion.State<a>
type ValueState<a> = ColdFusion.ValueState<a>
type Signal = Signal.Signal

-- Constants
local GET_PET_DATA_LIST = "GetPetDataList"
local ON_UPDATE_PET_DATA_LIST = "OnUpdatePetDataList"
local GET_PET_SELECTION = "GetPetSelection"
local ON_UPDATE_PET_SELECTION = "OnUpdatePetSelection"
local ON_PROMPT_ACTIVATED = "OnPetAssignmentPrompt"
local ASSIGN_PET_EVENT = "AssignPetToStation"
local DELETE_PET_EVENT = "DeletePet"
local MERGE_PETS_EVENT = "MergePets"
local ON_ANIM_PLAY = "OnAnimPlay"
local GET_IF_MANAGING = "GetIfManaging"
-- Variables
-- References
-- Class
function getUpdatedState<T>(maid: Maid, componentName: string?, getKey: string, updateKey: string, alt: T, manualUpdateSignal: Signal?): State<T>
	local _fuse = ColdFusion.fuse(maid)

	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local StateSource: ValueState<T?> = _Value(NetworkUtil.invokeServer(getKey, componentName))

	maid:GiveTask(NetworkUtil.onClientEvent(updateKey, function(v: T, compName: string?)
		if componentName == compName then
			StateSource:Set(v)
		end
	end))

	if manualUpdateSignal then
		maid:GiveTask(manualUpdateSignal:Connect(function(val: T)
			StateSource:Set(val)
		end))
	end

	return _Computed(function(source: T?): T
		if source ~= nil then
			return source
		else
			return alt
		end
	end, StateSource)
end

local isPetInventoryOpen = false

function boot(maid: Maid, componentName: string)
	local _fuse = ColdFusion.fuse(maid)

	local _new = _fuse.new
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local updatePetSelection = maid:GiveTask(Signal.new())

	local PetsData: State<{ [number]: PetSaveData }> = getUpdatedState(maid, nil, GET_PET_DATA_LIST, ON_UPDATE_PET_DATA_LIST, {})
	local PetSelection: State<PetSaveData?> = getUpdatedState(maid, componentName, GET_PET_SELECTION, ON_UPDATE_PET_SELECTION, nil :: any, updatePetSelection)
	local MergeTarget: ValueState<PetSaveData?> = _Value(nil :: PetSaveData?)
	local OnEquip = maid:GiveTask(Signal.new())
	local OnMerge = maid:GiveTask(Signal.new())
	local OnDelete = maid:GiveTask(Signal.new())
	local OnSelect = maid:GiveTask(Signal.new())

	local screenGui = Instance.new("ScreenGui")
	screenGui.DisplayOrder = 30
	screenGui.Name = "PetInventory"

	local petInventory = maid:GiveTask(PetInventory(maid, PetsData, PetSelection, MergeTarget, OnEquip, OnMerge, OnDelete, OnSelect)) :: Frame
	petInventory.Parent = screenGui

	isPetInventoryOpen = true
	ExitButton(petInventory, function()
		isPetInventoryOpen = false
		maid:Destroy()
	end, _Value(true))

	maid:GiveTask(OnSelect:Connect(function(petData: PetSaveData?)
		if not petData then
			return
		end
		assert(petData)
		-- if mergeBase then

		-- else
		updatePetSelection:Fire(petData)
		-- end
	end))

	local character = Players.LocalPlayer.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local startTick = tick()
			maid:GiveTask(humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
				if tick() - startTick > 2 then
					maid:Destroy()
				end
			end))
		end
	end

	maid:GiveTask(OnEquip:Connect(function(modifiedPetData: PetSaveData?)
		print("equip click")
		if not modifiedPetData then
			return
		end
		assert(modifiedPetData)
		NetworkUtil.fireServer(ASSIGN_PET_EVENT, componentName, modifiedPetData.Id)
		maid:Destroy()
	end))

	maid:GiveTask(OnMerge:Connect(function(modifiedPetData: PetSaveData?)
		print("merge click")
		if not modifiedPetData then
			return
		end
		assert(modifiedPetData)

		local prevMerge = MergeTarget:Get()
		if prevMerge and prevMerge.Id == modifiedPetData.Id then
			MergeTarget:Set(nil)
		elseif prevMerge then
			if PetModifierUtil.getMergeOutcome(prevMerge.BalanceId, modifiedPetData.BalanceId) then
				NetworkUtil.fireServer(MERGE_PETS_EVENT, componentName, prevMerge.Id, modifiedPetData.Id)
				MergeTarget:Set(nil)
			else
				print("bad merge outcome match")
			end
		elseif modifiedPetData then
			MergeTarget:Set(modifiedPetData)
		end

		-- if mergeBase and mergeBase.Id == modifiedPetData.Id then
		-- 	mergeBase = nil
		-- 	updatePetSelection:Fire(nil)
		-- else
		-- 	mergeBase = modifiedPetData
		-- 	updatePetSelection:Fire(mergeBase)
		-- end
	end))

	maid:GiveTask(OnDelete:Connect(function(modifiedPetData: PetSaveData?)
		print("delete click")
		if not modifiedPetData then
			return
		end
		assert(modifiedPetData)
		NetworkUtil.fireServer(DELETE_PET_EVENT, componentName, modifiedPetData.Id)
		-- maid:Destroy()
	end))

	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local bootMaid = Maid.new()
bootMaid:GiveTask(script.Destroying:Connect(function()
	bootMaid:Destroy()
end))

bootMaid:GiveTask(NetworkUtil.onClientEvent(ON_PROMPT_ACTIVATED, function(componentName: string)
	local maid = Maid.new()
	bootMaid._currentMenu = maid
	boot(maid, componentName)
end))

NetworkUtil.onClientInvoke(ON_ANIM_PLAY, function(_Animator: Animator, animationId: string)
	local animation: Animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local animTrack = _Animator:LoadAnimation(animation)

	animTrack.Looped = true
	animTrack:Play()

	local _maid = Maid.new()
	_maid:GiveTask(_Animator.Destroying:Connect(function()
		animTrack:Stop()
		_maid:Destroy()
	end))
	return nil
end)

NetworkUtil.onClientInvoke(GET_IF_MANAGING, function()
	return isPetInventoryOpen
end)