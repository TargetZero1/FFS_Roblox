--!strict
-- Services
local Debris = game:GetService("Debris")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))

-- Modules
local TycoonType = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Components"):WaitForChild("TycoonType"))
local ReferenceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local BreadTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("BreadTypes"))
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))
local BreadDropUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BreadDropUtil"))
local Pets = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"))
local PetBuilder = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PetBuilder"))
local PetAssignmentPrompt = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PetAssignmentPrompt"))
local SkinUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("SkinUtil"))

-- Types
type Maid = Maid.Maid

type ModifiedPet = (Pets.Pet & {
	BreadPerMinute: number,
	isCooking: boolean,
})

type DropData = BreadDropUtil.DropData
type Tycoon = TycoonType.Tycoon
export type Oven = {
	__index: Oven,
	_Maid: Maid,
	_IsAlive: boolean,
	_Debounce: boolean,
	Tycoon: Tycoon,
	Instance: Model,
	PetBalanceId: string?,
	PetEnabled: boolean,
	DropSpawn: Attachment,
	SurfaceGui: SurfaceGui,
	ModifierId: {
		Value: string,
		Recharge: string,
	},
	Queue: { [number]: DropData },
	OnTouch: (self: Oven, hit: BasePart) -> (),
	UpgradeSubscription: RBXScriptConnection,
	OnUpgraded: (self: Oven, player: Player, upgradeType: string, upgradeValue: number) -> (),
	new: (tycoon: Tycoon, inst: Model) -> Oven,
	Press: (self: Oven, player: Player, isAutomated: boolean) -> (),
	cook: (data: DropData?, valueId: string, rechargeId: string, petBalanceId: string?, dropSpawn: Attachment, instance: Model, player: Player, owner: Player) -> (),
	EquipPet: (self: Oven, petBalanceId: string?, equipped: boolean?) -> (),
	Init: (self: Oven) -> (),
}
-- Constants
local _DEBUG_ENABLED = false
local ON_OVEN_PRESS = "OnOvenPress"
-- Variables
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local SoundEffectTriggers = BindableEvents:WaitForChild("SoundEffectTriggers")
local SoundEvent = RemoteEvents:WaitForChild("PlaySoundEvent") :: RemoteEvent
local SFXEvent = SoundEffectTriggers:WaitForChild("PlayOvenSound") :: BindableEvent
NetworkUtil.getRemoteEvent(ON_OVEN_PRESS)
-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

-- Class
local Oven = {} :: Oven
Oven.__index = Oven

------ ADMIN SETTINGS -----
--reference to the admin controls script that sets key data
local AdminSettings = ReplicatedFirst:WaitForChild("AdminControls")
if AdminSettings then
	if AdminSettings:GetAttribute("DEBUG_ENABLED") ~= nil then
		_DEBUG_ENABLED = AdminSettings:GetAttribute("DEBUG_ENABLED")
	end
end

--create new Oven module for this tycoon and what instance
function Oven.new(tycoon, instance)
	local self: Oven = setmetatable({}, Oven) :: any
	self._Maid = Maid.new()
	self._IsAlive = true
	self._Maid:GiveTask(function()
		self._IsAlive = false
	end)

	self._Debounce = true
	--declare owning tycoon and part for this component
	self.Tycoon = tycoon
	self.Instance = instance
	self.PetEnabled = false
	self.Queue = {}

	--define drop attachment/spawn area
	self.DropSpawn = _getChild(_getChild(instance, "Detector"), "Spawn") :: Attachment

	--give back a copy of the table
	PetAssignmentPrompt(self.Instance, self.Tycoon.Owner)
	local function updatePet()
		for i, data in ipairs(PlayerManager.getSavedPets(self.Tycoon.Owner)) do
			if data.Assignment == self.Instance.Name then
				self:EquipPet(data.BalanceId, true)
				return
			end
		end
		self:EquipPet(nil, false)
	end
	self._Maid:GiveTask(PlayerManager.getPetDataChangedSignal(self.Tycoon.Owner):Connect(updatePet))
	task.spawn(updatePet)

	self._Maid:GiveTask(self.Instance.Destroying:Connect(function()
		self._Maid:Destroy()
	end))
	for i, data in ipairs(PlayerManager.getSavedPets(self.Tycoon.Owner)) do
		PlayerManager.getPetDataChangedSignal(self.Tycoon.Owner):Fire(data)
	end

	return self
end

function Oven:EquipPet(petBalanceId: string?, enabled: boolean?): ()
	if not self._IsAlive then return end
	print("new equip")
	if enabled ~= nil then
		self.PetEnabled = enabled
	end
	self.PetBalanceId = petBalanceId

	local primaryPart = self.Tycoon.Model.PrimaryPart
	assert(primaryPart, "primaryPart missing from tycoon model")

	PetBuilder(self._Maid, self.Tycoon.Owner, petBalanceId, primaryPart.CFrame, self.Instance, enabled, function()
		return self.PetEnabled
	end, function()
		return #self.Queue
	end, function()
		self:Press(self.Tycoon.Owner, true)
	end)
end

function Oven:Init()
	if not self._IsAlive then return end
	local modifierName = self.Instance:GetAttribute("ModifierName")
	self.ModifierId = {
		Value = StationModifierUtil.getId("Oven", "Value", PlayerManager.getModifierLevel(self.Tycoon.Owner, "Oven", "Value")),
		Recharge = StationModifierUtil.getId("Oven", "Recharge", PlayerManager.getModifierLevel(self.Tycoon.Owner, "Oven", "Recharge")),
	}
	-- self.Instance:SetAttribute("ValueId", ModifierUtil.getLevel(self.ModifierId.Value))
	-- self.Instance:SetAttribute("RechargeId", ModifierUtil.getLevel(self.ModifierId.Recharge))
	-- self.Instance:GetAttributeChangedSignal("ValueId"):Connect(function()
	-- 	local lvl = assert(self.Instance:GetAttribute("ValueId"))
	-- 	self.ModifierId.Value = ModifierUtil.getId("Oven", "Value", lvl)
	-- end)
	-- self.Instance:GetAttributeChangedSignal("RechargeId"):Connect(function()
	-- 	local lvl = assert(self.Instance:GetAttribute("RechargeId"))
	-- 	self.ModifierId.Recharge = ModifierUtil.getId("Oven", "Recharge", lvl)
	-- end)

	local onPromptClick = BreadDropUtil.newDropPrompt(_getChild(_getChild(_getParent(self.Instance), "Oven"), "PromptAnchor") :: BasePart, "Dough", "Cook", function()
		return StationModifierUtil.getValue(self.ModifierId.Recharge, self.Tycoon.Owner, self.PetBalanceId)
	end) :: any
	self._Maid:GiveTask(onPromptClick:Connect(function(player: Player)
		self:Press(player, false)
	end))

	--trigger touched event if something touches the detector
	self._Maid:GiveTask((_getChild(self.Instance, "Detector") :: BasePart).Touched:Connect(function(...)
		self:OnTouch(...)
	end))

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

	----wait for player to buy gamepass from shop for ultimate Oven
	--self.Tycoon.Owner:GetAttributeChangedSignal("UltimateOven"):Connect(function()
	--	if(self.Tycoon.Owner:GetAttribute("UltimateOven") == true) then
	--		--set values to maximum
	--		self.Instance:SetAttribute("Speed",0.5)
	--	end
	--end)

	self.SurfaceGui = _getChild(_getChild(self.Instance, "CountPart"), "SurfaceGui") :: SurfaceGui

	if self.SurfaceGui then
		local textLabel = assert(self.SurfaceGui:WaitForChild("TextLabel", 20)) :: TextLabel

		local uiPadding = self._Maid:GiveTask(Instance.new("UIPadding"))
		uiPadding.PaddingBottom = UDim.new(0, 5)
		uiPadding.PaddingTop = UDim.new(0, 5)
		uiPadding.PaddingLeft = UDim.new(0, 10)
		uiPadding.PaddingRight = UDim.new(0, 10)
		uiPadding.Parent = textLabel

		local uiCorner = self._Maid:GiveTask(Instance.new("UICorner"))
		uiCorner.CornerRadius = UDim.new(0, 5)
		uiCorner.Parent = textLabel

		textLabel.BackgroundTransparency = 0.1
		textLabel.BackgroundColor3 = Color3.fromHSV(1, 0, 0.2)
		textLabel.TextColor3 = Color3.fromHSV(1, 0, 0.8)

		textLabel.AutomaticSize = Enum.AutomaticSize.XY
		textLabel.TextScaled = true
		textLabel.Size = UDim2.fromScale(0, 0)
		textLabel.Position = UDim2.fromScale(0.5, 0.5)
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.Text = tostring(#self.Queue)
	end

	--Connect to a TycoonRebirthEvent_Critical function to clean up this component
	self._Maid:GiveTask(self.Tycoon:SubscribeTopic("TycoonRebirthEvent_Critical", function(player: Player)
		table.clear(self)
		self.UpgradeSubscription:Disconnect()
	end))

	SkinUtil.set(self.Instance, self.ModifierId.Value, true)
end

function Oven:OnUpgraded(player: Player, modifierId: string): ()
	if not self._IsAlive then return end
	if player == self.Tycoon.Owner then
		self.ModifierId[StationModifierUtil.getPropertyName(modifierId)] = modifierId
		SkinUtil.set(self.Instance, self.ModifierId.Value, false)
		BreadDropUtil.normalizeQueue(self.Queue)
	end
end

function Oven:OnTouch(hit: BasePart)
	if not self._IsAlive then return end
	--if the object has a value
	if BreadDropUtil.getIfDrop(hit) then
		local data = BreadDropUtil.get(hit)
		--delete resource as it has done its job
		hit:Destroy()

		--Check if the list is too large and remove the first entry.
		if #self.Queue >= 100 then
			table.remove(self.Queue, 1)
		end

		table.insert(self.Queue, data)
		BreadDropUtil.normalizeQueue(self.Queue)

		if self.SurfaceGui then
			-- print("COUNT"..tostring(#self.Queue));
			(_getChild(self.SurfaceGui, "TextLabel") :: TextLabel).Text = tostring(#self.Queue)
		end
	end
end

function Oven:Press(player: Player, isAutomated: boolean)
	if not self._IsAlive then return end
	local data = self.Queue[1]
	if data and (self._Debounce or isAutomated) then
		if not isAutomated then
			self._Debounce = false
		end
		if not isAutomated then
			NetworkUtil.fireClient(ON_OVEN_PRESS, self.Tycoon.Owner)
		end

		table.remove(self.Queue, 1)
		Oven.cook(data, self.ModifierId.Value, self.ModifierId.Recharge, self.PetBalanceId, self.DropSpawn, self.Instance, player, self.Tycoon.Owner)

		if self.Tycoon.Owner:GetAttribute("MuteSFX") ~= nil then
			if self.Tycoon.Owner:GetAttribute("MuteSFX") == false then
				--play the SFX
				--play sound effect
				SFXEvent:Fire(self.Tycoon.Owner)
			end
		end

		if self.SurfaceGui then
			(_getChild(self.SurfaceGui, "TextLabel") :: TextLabel).Text = tostring(#self.Queue)
		end

		task.wait(StationModifierUtil.getValue(self.ModifierId.Recharge, self.Tycoon.Owner, self.PetBalanceId))

		if not isAutomated then
			self._Debounce = true
		end
	end
end

function Oven.cook(data: DropData?, valueId: string, rechargeId: string, petBalanceId: string?, dropSpawn: Attachment, instance: Model, player: Player, owner: Player)
	if not data then
		return
	end
	assert(data, "assertion failed")

	-- local breadValue =  ModifierUtil.getValue(valueId)
	local drop = BreadTypes.Order[data.TypeIndex]
	local breadData = BreadTypes.Types[drop]
	assert(breadData, "no breadData for " .. tostring(drop))
	--clone the drop from server storage
	local cookedBread = breadData.Cooked:Clone()

	--reposition to correct place
	cookedBread.Position = dropSpawn.WorldPosition
	cookedBread.Orientation = Vector3.new(0, dropSpawn.WorldOrientation.Y, 0)
	--reparent the drop to this dropper
	cookedBread.Parent = instance
	cookedBread.BrickColor = BrickColor.new("Burnt Sienna")
	data.Value += StationModifierUtil.getValue(valueId, owner)
	BreadDropUtil.set(cookedBread, data)

	--the debris service sets the lifetime for this item before deletion, default is 10 seconds
	Debris:AddItem(cookedBread, 20)

	local BreadCookedTotal = PlayerManager.getBreadCookedAmount(player) or 0

	PlayerManager.setBreadCookedAmount(player, BreadCookedTotal + 1)
end

return Oven
