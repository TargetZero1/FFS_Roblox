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
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local BreadTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("BreadTypes"))
local TycoonType = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Components"):WaitForChild("TycoonType"))
local ReferenceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
local BreadDropUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BreadDropUtil"))
local Pets = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"))
local PetBuilder = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PetBuilder"))
local PetAssignmentPrompt = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PetAssignmentPrompt"))
local SkinUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("SkinUtil"))
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))

-- Types
type Maid = Maid.Maid

type ModifiedPet = (Pets.Pet & {
	BreadPerMinute: number,
	isKneading: boolean,
})

type DropData = BreadDropUtil.DropData
type Tycoon = TycoonType.Tycoon
export type KneadedUpdated = {
	__index: KneadedUpdated,
	_Maid: Maid,
	_IsAlive: boolean, 
	Tycoon: Tycoon,
	Instance: Model,
	PetBalanceId: string?,
	PetEnabled: boolean,
	DropSpawn: Attachment,
	ModifierId: {
		Multiplier: string,
		Recharge: string,
	},
	Queue: { [number]: DropData },
	Locked: boolean,
	SurfaceGui: SurfaceGui,
	UpgradeSubscription: RBXScriptConnection,
	new: (tycoon: Tycoon, inst: Model) -> KneadedUpdated,
	Init: (self: KneadedUpdated) -> (),
	Press: (self: KneadedUpdated, player: Player, isAutomated: boolean) -> (),
	OnTouch: (self: KneadedUpdated, hit: BasePart) -> (),
	OnUpgraded: (self: KneadedUpdated, player: Player, upgradeType: string, upgradeValue: number) -> (),

	EquipPet: (self: KneadedUpdated, petBalanceId: string?, equipped: boolean?) -> (),
	knead: (dropData: DropData?, multiplierId: string, petBalanceId: string?, dropSpawn: Attachment, instance: Model, player: Player, owner: Player) -> (),
}
-- Constants
local _DEBUG_ENABLED = false
local ON_KNEADER_PRESS = "OnKneaderPress"
-- Variables
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local SoundEffectTriggers = BindableEvents:WaitForChild("SoundEffectTriggers")
local SoundEvent = RemoteEvents:WaitForChild("PlaySoundEvent") :: RemoteEvent
local SFXEvent = SoundEffectTriggers:WaitForChild("PlayKneaderSound") :: BindableEvent
NetworkUtil.getRemoteEvent(ON_KNEADER_PRESS)

-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

-- Class
local Kneader = {} :: KneadedUpdated
Kneader.__index = Kneader

------ ADMIN SETTINGS -----
--reference to the admin controls script that sets key data
local AdminSettings = ReplicatedFirst:FindFirstChild("AdminControls")

--get value from admin setting script
if AdminSettings then
	if AdminSettings:GetAttribute("DEBUG_ENABLED") ~= nil then
		_DEBUG_ENABLED = AdminSettings:GetAttribute("DEBUG_ENABLED")
	end
end

--create new Kneader module for this tycoon and what instance
function Kneader.new(tycoon: Tycoon, instance: Model): KneadedUpdated
	print("Kneader created")
	local self: KneadedUpdated = setmetatable({}, Kneader) :: any
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
	self.DropSpawn = assert(instance:WaitForChild("Detector", 20)):WaitForChild("Spawn", 20) :: Attachment

	self.Queue = {}

	--boolean to lock if player can spawn bread or not
	self.Locked = false

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
	--give back a copy of the table
	return self
end

function Kneader:Init()
	if not self._IsAlive then return end
	local modifierName = self.Instance:GetAttribute("ModifierName")

	self.ModifierId = {
		Multiplier = StationModifierUtil.getId(modifierName, "Multiplier", PlayerManager.getModifierLevel(self.Tycoon.Owner, modifierName, "Multiplier")),
		Recharge = StationModifierUtil.getId(modifierName, "Recharge", PlayerManager.getModifierLevel(self.Tycoon.Owner, modifierName, "Recharge")),
	}
	-- self.Instance:SetAttribute("MultiplierId", ModifierUtil.getLevel(self.ModifierId.Multiplier))
	-- self.Instance:SetAttribute("RechargeId", ModifierUtil.getLevel(self.ModifierId.Recharge))
	-- self.Instance:GetAttributeChangedSignal("MultiplierId"):Connect(function()
	-- 	local lvl = assert(self.Instance:GetAttribute("MultiplierId"))
	-- 	self.ModifierId.Multiplier = ModifierUtil.getId(modifierName, "Multiplier", lvl)
	-- end)
	-- self.Instance:GetAttributeChangedSignal("RechargeId"):Connect(function()
	-- 	local lvl = assert(self.Instance:GetAttribute("RechargeId"))
	-- 	self.ModifierId.Recharge = ModifierUtil.getId(modifierName, "Recharge", lvl)
	-- end)

	local onPromptClick = BreadDropUtil.newDropPrompt(_getChild(_getChild(_getParent(self.Instance), modifierName), "PromptAnchor") :: BasePart, "Dough", function()
		return assert(self.Instance:GetAttribute("Display")) :: string
	end, function()
		return StationModifierUtil.getValue(self.ModifierId.Recharge, self.Tycoon.Owner, self.PetBalanceId)
	end)
	self._Maid:GiveTask(onPromptClick:Connect(function(player: Player)
		self:Press(player, false)
	end))

	--trigger touched event if something touches the detector
	self._Maid:GiveTask(assert(self.Instance:WaitForChild("Detector", 20) :: BasePart).Touched:Connect(function(hit: BasePart)
		self:OnTouch(hit)
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

	self.SurfaceGui = assert(assert(self.Instance:WaitForChild("CountPart", 20)):WaitForChild("SurfaceGui", 20) :: SurfaceGui?)
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
		textLabel.Size = UDim2.fromScale(0, 0)
		textLabel.Position = UDim2.fromScale(0.5, 0.5)
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.TextScaled = true
		textLabel.Text = tostring(#self.Queue)
	end

	--Connect to a TycoonRebirthEvent_Critical function to clean up this component
	self._Maid:GiveTask(self.Tycoon:SubscribeTopic("TycoonRebirthEvent_Critical", function(player)
		if player == self.Tycoon.Owner then
			table.clear(self)
			self = nil :: any
		end
	end))

	SkinUtil.set(self.Instance, self.ModifierId.Multiplier, true)
end

function Kneader:OnUpgraded(player: Player, modifierId: string): ()
	if not self._IsAlive then return end
	if player == self.Tycoon.Owner then
		self.ModifierId[StationModifierUtil.getPropertyName(modifierId)] = modifierId
		SkinUtil.set(self.Instance, self.ModifierId.Multiplier, false)
		BreadDropUtil.normalizeQueue(self.Queue)
	end
end

function Kneader:OnTouch(hit: BasePart)
	if not self._IsAlive then return end
	--if the object has a value
	if BreadDropUtil.getIfDrop(hit) then
		local dropData = BreadDropUtil.get(hit)
		--delete resource as it has done its job
		hit:Destroy()

		--Check if the list is too large and remove the first entry.
		if #self.Queue >= 100 then
			table.remove(self.Queue, 1)
		end
		--Insert the bread name into the drop list.
		table.insert(self.Queue, dropData)
		BreadDropUtil.normalizeQueue(self.Queue)

		if self.SurfaceGui then
			assert(self.SurfaceGui:WaitForChild("TextLabel", 20) :: TextLabel?).Text = tostring(#self.Queue)
		end
		local breadShapedTotal = PlayerManager.getBreadShapedAmount(self.Tycoon.Owner) or 0

		PlayerManager.setBreadShapedAmount(self.Tycoon.Owner, breadShapedTotal + 1)

		--keep track that a wheat drop has been deleted
		if PlayerManager.getWheatCreatedAmount(self.Tycoon.Owner) ~= nil then
			PlayerManager.setWheatCreatedAmount(self.Tycoon.Owner, PlayerManager.getWheatCreatedAmount(self.Tycoon.Owner) - 1)
		end

		task.wait(StationModifierUtil.getValue(self.ModifierId.Recharge, self.Tycoon.Owner, self.PetBalanceId))
	end
end

function Kneader:Press(player: Player, isAutomated: boolean)
	if not self._IsAlive then return end
	local doughCreatedTotal = PlayerManager.getDoughCreatedAmount(self.Tycoon.Owner) or 0

	--check if player who interacts with the button is the owner of this tycoon
	if player == self.Tycoon.Owner then
		--self.Midas:Fire("Press", 5)

		--check if there is bread to cook
		if #self.Queue > 0 and ((self.Locked == false) or isAutomated) then
			if not isAutomated then
				self.Locked = true
			end
			if not isAutomated then
				NetworkUtil.fireClient(ON_KNEADER_PRESS, self.Tycoon.Owner)
			end
			task.spawn(function()
				--spawn the bread
				self.knead(self.Queue[1], self.ModifierId.Multiplier, self.PetBalanceId, self.DropSpawn, self.Instance, player, self.Tycoon.Owner)

				PlayerManager.setDoughCreatedAmount(self.Tycoon.Owner, doughCreatedTotal + 1)

				--check if player has muted the SFX
				if self.Tycoon.Owner:GetAttribute("MuteSFX") ~= nil then
					if self.Tycoon.Owner:GetAttribute("MuteSFX") == false then
						--play the SFX
						--play sound effect
						SFXEvent:Fire(self.Tycoon.Owner)
					end
				end

				--remove from table
				table.remove(self.Queue, 1)

				if self.SurfaceGui then
					(_getChild(self.SurfaceGui, "TextLabel") :: TextLabel).Text = tostring(#self.Queue)
				end
			end)

			task.wait(StationModifierUtil.getValue(self.ModifierId.Recharge, self.Tycoon.Owner, self.PetBalanceId))

			--unlock the kneader to allow players to use it again
			if not isAutomated then
				self.Locked = false
			end
		end
	end
end

function Kneader:EquipPet(petBalanceId: string?, enabled: boolean?): ()
	if not self._IsAlive then return end
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

function Kneader.knead(dropData: DropData?, multiplierId: string, petBalanceId: string?, dropSpawn: Attachment, instance: Model, player: Player, owner: Player)
	--Don't spawn bread if value is nil
	if not dropData then
		return
	end
	assert(dropData, "assertion failed")
	--clone the drop from server storage
	local dropTypeName = BreadTypes.Order[dropData.TypeIndex]
	local kneadedBread = assert(BreadTypes.Types[dropTypeName] :: BreadTypes.BreadType?, "assertion failed").Dough:Clone()

	--reposition to correct place
	kneadedBread.Position = dropSpawn.WorldPosition
	kneadedBread.Orientation = Vector3.new(0, dropSpawn.WorldOrientation.Y, 0)
	--reparent the drop to this dropper
	kneadedBread.Parent = instance
	kneadedBread.BrickColor = BrickColor.new("Burnt Sienna")
	dropData.Value *= StationModifierUtil.getValue(multiplierId, owner, petBalanceId)
	-- print("MOD", ModifierUtil.getValue(multiplierId, petBalanceId))
	BreadDropUtil.set(kneadedBread, dropData)

	--the debris service sets the lifetime for this item before deletion, default is 10 seconds
	Debris:AddItem(kneadedBread, 30)

	local BreadCookedTotal = PlayerManager.getBreadCookedAmount(player) or 0

	PlayerManager.setBreadCookedAmount(player, BreadCookedTotal + 1)
end

return Kneader
