--!strict
-- Services
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
-- Modules
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))
local BreadTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("BreadTypes"))
local TycoonType = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Components"):WaitForChild("TycoonType"))
local BreadDropUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BreadDropUtil"))
local ReferenceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
-- local Pets = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"))
-- local PetBuilder = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PetBuilder"))
-- local PetAssignmentPrompt = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PetAssignmentPrompt"))
local SkinUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("SkinUtil"))

-- Types
type Maid = Maid.Maid

type DropData = BreadDropUtil.DropData
type Tycoon = TycoonType.Tycoon

export type Windmill = {
	__index: Windmill,
	_Maid: Maid,
	_IsAlive: boolean,
	ModifierId: {
		Value: string,
		Recharge: string,
	},
	Tycoon: Tycoon,
	PetBalanceId: string?,
	PetEnabled: boolean,
	Instance: Model,
	Spawned: boolean,
	DropSpawn: Attachment,
	DropTemplate: BasePart,
	BreadType: string,
	-- EquipPet: (self: Windmill, petBalanceId: string?, equipped: boolean?) -> (),
	UpgradeSubscription: RBXScriptConnection,
	SelectBreadConnection: RBXScriptConnection,
	new: (tycoon: Tycoon, instance: Model) -> Windmill,
	Init: (self: Windmill) -> (),
	Drop: (self: Windmill) -> (),
	OnUpgraded: (self: Windmill, player: Player, ModifierId: string) -> (),
	Press: (self: Windmill, player: Player) -> (),
	Destroy: (self: Windmill) -> (),
}
-- Constants
local _DEBUG_ENABLED = false

-- Variables
-- References
local DropsFolder = ServerStorage:WaitForChild("Drops")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SoundEffectTriggers = BindableEvents:WaitForChild("SoundEffectTriggers")
local BreadChoiceEventFolder = RemoteEvents:WaitForChild("BreadChoiceEvent")

local requestModifiers = BindableEvents:WaitForChild("RequestModifiers") :: BindableEvent
local SoundEvent = RemoteEvents:WaitForChild("PlaySoundEvent") :: RemoteEvent
local SFXEvent = SoundEffectTriggers:WaitForChild("PlayDropperSound") :: BindableEvent
local SelectBreadEvent = BreadChoiceEventFolder:WaitForChild("SelectBreadType") :: RemoteEvent
local DisplayChoiceEvent = BreadChoiceEventFolder:WaitForChild("DisplayChoiceUI") :: RemoteEvent
local AdminSettings = ReplicatedFirst:WaitForChild("AdminControls", 10)

--get value from admin setting script
if AdminSettings ~= nil then
	if AdminSettings:GetAttribute("DEBUG_ENABLED") ~= nil then
		_DEBUG_ENABLED = AdminSettings:GetAttribute("DEBUG_ENABLED")
	end
end

-- Private function
local _getChild = ReferenceUtil.getChild

-- Class
local Windmill = {} :: Windmill
Windmill.__index = Windmill

--create new Windmill module for this tycoon and what instance
function Windmill.new(tycoon: Tycoon, instance: Model)
	local self: Windmill = setmetatable({}, Windmill) :: any
	self._Maid = Maid.new()
	self._IsAlive = true
	self._Maid:GiveTask(function()
		self._IsAlive = false
	end)
	
	--declare owning tycoon and part for this component
	self.Tycoon = tycoon
	self.Instance = instance
	self.PetEnabled = false

	--define drop attachment/spawn area
	self.DropSpawn = assert(assert(instance:WaitForChild("Spout", 10)):WaitForChild("Spawn", 10) :: Attachment?, "assertion failed")
	self.Spawned = false
	--Bread type that is being produced.
	self.BreadType = "Sourdough"

	-- PetAssignmentPrompt(self.Instance, self.Tycoon.Owner)
	-- self._Maid:GiveTask(PlayerManager.getPetDataChangedSignal(self.Tycoon.Owner):Connect(function()
	-- 	for i, data in ipairs(PlayerManager.getSavedPets(self.Tycoon.Owner)) do
	-- 		if data.Assignment == self.Instance.Name then
	-- 			self:EquipPet(data.BalanceId, true)
	-- 			return
	-- 		end
	-- 	end
	-- 	self:EquipPet(nil, false)
	-- end))
	self._Maid:GiveTask(self.Instance.Destroying:Connect(function()
		self._Maid:Destroy()
	end))
	return self
end

function Windmill:Init()
	if not self._IsAlive then return end
	local modifierName = self.Instance:GetAttribute("ModifierName")

	self.ModifierId = {
		Value = StationModifierUtil.getId(modifierName, "Value", PlayerManager.getModifierLevel(self.Tycoon.Owner, modifierName, "Value")),
		Recharge = StationModifierUtil.getId(modifierName, "Recharge", PlayerManager.getModifierLevel(self.Tycoon.Owner, modifierName, "Recharge")),
	}
	-- self.Instance:SetAttribute("ValueId", ModifierUtil.getLevel(self.ModifierId.Value))
	-- self.Instance:SetAttribute("RechargeId", ModifierUtil.getLevel(self.ModifierId.Recharge))

	-- self.Instance:GetAttributeChangedSignal("ValueId"):Connect(function()
	-- 	local lvl = assert(self.Instance:GetAttribute("ValueId"))
	-- 	self.ModifierId.Value = ModifierUtil.getId(modifierName, "Value", lvl)
	-- end)
	-- self.Instance:GetAttributeChangedSignal("RechargeId"):Connect(function()
	-- 	local lvl = assert(self.Instance:GetAttribute("RechargeId"))
	-- 	self.ModifierId.Recharge = ModifierUtil.getId(modifierName, "Recharge", lvl)
	-- end)

	-- local onPromptClick = BreadDropUtil.newDropPrompt(
	-- 	_getChild(self.Instance, "PromptAnchor") :: BasePart,
	-- 	function()
	-- 		return self.BreadType
	-- 	end,
	-- 	"Drop",
	-- 	function()
	-- 		return ModifierUtil.getValue(self.ModifierId.Recharge, self.PetBalanceId)
	-- 	end
	-- )
	-- onPromptClick:Connect(function(player: Player)
	-- 	self:Drop(false)
	-- end)

	self.UpgradeSubscription = self._Maid:GiveTask(self.Tycoon:SubscribeTopic(modifierName, function(...)
		--trigger this event
		self:OnUpgraded(...)

		--check if player has muted the SFX
		if self.Tycoon.Owner:GetAttribute("MuteSFX") ~= nil then
			if self.Tycoon.Owner:GetAttribute("MuteSFX") == false then
				--play the SFX
				--play sound effect
				SoundEvent:FireClient(self.Tycoon.Owner, "UpgradeSound")
			end
		end
	end))

	requestModifiers:Fire(self.Tycoon.Owner, modifierName)

	--Connect to the SelectBread remote event
	self.SelectBreadConnection = self._Maid:GiveTask(SelectBreadEvent.OnServerEvent:Connect(function(player: Player, breadType: string, code: string)
		--Check the codes match up to avoid players exploiting to the final bread.
		if code == "9@PmmbLY9spRdz5NXrH" then
			--Check if this dropper belongs to the player's tycoon.
			if player == self.Tycoon.Owner then
				self.BreadType = breadType
			end
		end
	end))

	--Connect to a TycoonRebirthEvent_Critical function to clean up this component
	self._Maid:GiveTask(self.Tycoon:SubscribeTopic("TycoonRebirthEvent_Critical", function(player: Player)
		if player == self.Tycoon.Owner then
			self.SelectBreadConnection:Disconnect()
			self.UpgradeSubscription:Disconnect()
			table.clear(self)
			self = nil :: any
		end
	end))

	local lastDropTick = 0
	self._Maid:GiveTask(RunService.Heartbeat:Connect(function(dT: number)
		local rechargeDuration = StationModifierUtil.getValue(self.ModifierId.Recharge, self.Tycoon.Owner)
		if tick() - lastDropTick > rechargeDuration then
			lastDropTick = tick()
			self:Drop()
		end
	end))

	SkinUtil.set(self.Instance, self.ModifierId.Value, true)
end

function Windmill:OnUpgraded(player: Player, modifierId: string)
	if not self._IsAlive then return end
	if player == self.Tycoon.Owner then
		self.ModifierId[StationModifierUtil.getPropertyName(modifierId)] = modifierId
		SkinUtil.set(self.Instance, self.ModifierId.Value, false)
	end
end

function Windmill:Drop()
	if not self._IsAlive then return end
	--check folder exists
	task.spawn(function()
		self.DropTemplate = assert(DropsFolder:WaitForChild(self.Instance:GetAttribute("Drop"), 20) :: BasePart?)

		local breadTypeIndex = table.find(BreadTypes.Order, self.BreadType)
		assert(breadTypeIndex, "bad bread type: " .. tostring(self.BreadType))
		local dropData = BreadDropUtil.new(breadTypeIndex, self.Tycoon.Owner)
		dropData.Value += StationModifierUtil.getValue(self.ModifierId.Value, self.Tycoon.Owner, self.PetBalanceId)
		-- print("VAL", ModifierUtil.getValue(self.ModifierId.Value, self.PetBalanceId), dropData.Value )
		--clone the drop from server storage
		local drop = self.DropTemplate:Clone()
		drop.CollisionGroup = "Bread"
		BreadDropUtil.set(drop, dropData)

		--reposition to correct place
		drop.Position = self.DropSpawn.WorldPosition

		--reparent the drop to this dropper
		drop.Parent = self.Instance

		--the debris service sets the lifetime for this item before deletion, default is 20 seconds
		Debris:AddItem(drop, 20)

		--check if player has muted the SFX
		if self.Tycoon.Owner:GetAttribute("MuteSFX") ~= nil then
			if self.Tycoon.Owner:GetAttribute("MuteSFX") == false then
				--play the SFX
				--play sound effect
				SFXEvent:Fire(self.Tycoon.Owner)
			end
		end
	end)

	task.wait(StationModifierUtil.getValue(self.ModifierId.Recharge, self.Tycoon.Owner, self.PetBalanceId))
end

function Windmill:Press(player: Player)
	if not self._IsAlive then return end
	if player == self.Tycoon.Owner then
		DisplayChoiceEvent:FireClient(player)
	end
end

-- function Windmill:EquipPet(petBalanceId: string?, enabled: boolean?): ()
-- 	if enabled ~= nil then
-- 		self.PetEnabled = enabled
-- 	end
-- 	self.PetBalanceId = petBalanceId

-- 	local primaryPart = self.Tycoon.Model.PrimaryPart
-- 	assert(primaryPart, "primaryPart missing from tycoon model")

-- 	PetBuilder(self._Maid, self.Tycoon.Owner, petBalanceId, primaryPart.CFrame, self.Instance, enabled, function()
-- 		return self.PetEnabled
-- 	end, function()
-- 		return 1
-- 	end, function()
-- 		self:Drop()
-- 	end)
-- end

return Windmill
