--!strict
-- Services
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

-- Packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))

-- Modules
local TycoonType = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Components"):WaitForChild("TycoonType"))
local ReferenceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
local BreadTypes = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("BreadTypes"))
local BreadDropUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BreadDropUtil"))
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
local Pets = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"))
local PetBuilder = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PetBuilder"))
local PetAssignmentPrompt = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PetAssignmentPrompt"))
local SkinUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("SkinUtil"))

-- Types
type Maid = Maid.Maid

type ModifiedPet = (Pets.Pet & {
	BreadPerMinute: number,
	isWrapping: boolean,
})

type DropData = BreadDropUtil.DropData
type Tycoon = TycoonType.Tycoon
export type Wrapper = {
	__index: Wrapper,
	_Maid: Maid,
	_IsAlive: boolean,
	_WrapDebounce: boolean,
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
	SurfaceGui: SurfaceGui,
	UpgradeSubscription: RBXScriptConnection,
	new: (tycoon: Tycoon, inst: Model) -> Wrapper,
	wrap: (drop: DropData?, multiplierId: string, petBalanceId: string?, dropSpawn: Attachment, instance: Model, player: Player, owner: Player) -> (),
	Init: (self: Wrapper) -> (),
	Press: (self: Wrapper, player: Player, isAutomated: boolean) -> (),
	OnTouch: (self: Wrapper, hit: BasePart) -> (),
	OnUpgraded: (self: Wrapper, player: Player, upgradeType: string, upgradeValue: number) -> (),
	EquipPet: (self: Wrapper, petBalanceId: string?, equipped: boolean?) -> (),
}
-- Constants
local DEBUG_ENABLED = false
local ON_WRAP_PRESS = "OnWrapPress"

-- Variables

-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local SoundEffectTriggers = BindableEvents:WaitForChild("SoundEffectTriggers")
local AdminSettings = ReplicatedFirst:WaitForChild("AdminControls")
local SoundEvent = RemoteEvents:WaitForChild("PlaySoundEvent") :: RemoteEvent
local SFXEvent = SoundEffectTriggers:WaitForChild("PlayWrappingSound") :: BindableEvent
NetworkUtil.getRemoteEvent(ON_WRAP_PRESS)

-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

--get value from admin setting script
if AdminSettings then
	if AdminSettings:GetAttribute("DEBUG_ENABLED") ~= nil then
		-- DEBUG_ENABLED = AdminSettings:GetAttribute("DEBUG_ENABLED")
	end
end

-- Class
local Wrapper = {} :: Wrapper
Wrapper.__index = Wrapper

-- create new Wrapper module for this tycoon and what instance
function Wrapper.new(tycoon: Tycoon, instance: Model): Wrapper
	local self: Wrapper = setmetatable({}, Wrapper) :: any
	self._Maid = Maid.new()
	self._IsAlive = true
	self._Maid:GiveTask(function()
		self._IsAlive = false
	end)
	--declare owning tycoon and part for this component
	self.Tycoon = tycoon
	self.Instance = instance
	self.PetEnabled = false
	self.Queue = {}
	self._WrapDebounce = true
	--define drop attachment/spawn area
	self.DropSpawn = _getChild(_getChild(instance, "Detector"), "Spawn") :: Attachment

	--test pet
	-- if
	-- 	self.Tycoon.Owner.Name == "aryoseno11"
	-- 	or self.Tycoon.Owner.Name == "BWhite_NSG"
	-- 	or self.Tycoon.Owner.Name == "CJ_Oyer"
	-- then
	-- 	self:EquipPet(ModifierUtil.getPetBalanceId("Cat", "Normal", 2), true)
	-- end

	PetAssignmentPrompt(self.Instance, self.Tycoon.Owner)
	local function updatePet()
		-- print("\nUPDATING!", self.Instance.Name)
		for i, data in ipairs(PlayerManager.getSavedPets(self.Tycoon.Owner)) do
			-- print(self.Instance.Name, ": ", i, " -> ", data.Assignment)
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
	--give back a copy of the table
	return self
end

function Wrapper:Init()
	if not self._IsAlive then return end
	local modifierName = self.Instance:GetAttribute("ModifierName")

	self.ModifierId = {
		Multiplier = StationModifierUtil.getId("Wrapper", "Multiplier", PlayerManager.getModifierLevel(self.Tycoon.Owner, "Wrapper", "Multiplier")),
		Recharge = StationModifierUtil.getId("Wrapper", "Recharge", PlayerManager.getModifierLevel(self.Tycoon.Owner, "Wrapper", "Recharge")),
	}

	-- local inst: any = self.Instance

	-- inst:SetAttribute("MultiplierId", ModifierUtil.getLevel(self.ModifierId.Multiplier))
	-- inst:SetAttribute("RechargeId", ModifierUtil.getLevel(self.ModifierId.Recharge))
	-- inst:GetAttributeChangedSignal("MultiplierId"):Connect(function()
	-- 	local lvl = assert(self.Instance:GetAttribute("MultiplierId"))
	-- 	self.ModifierId.Multiplier = ModifierUtil.getId("Wrapper", "Multiplier", lvl)
	-- end)

	-- inst:GetAttributeChangedSignal("RechargeId"):Connect(function()
	-- 	local lvl = assert(self.Instance:GetAttribute("RechargeId"))
	-- 	self.ModifierId.Recharge = ModifierUtil.getId("Wrapper", "Recharge", lvl)
	-- end)

	local onPromptClick: any = BreadDropUtil.newDropPrompt(_getChild(_getChild(_getParent(self.Instance), "Wrapper"), "PromptAnchor") :: BasePart, "Dough", function()
		return assert(self.Instance:GetAttribute("Display") or "Wrap") :: string
	end, function()
		return StationModifierUtil.getValue(self.ModifierId.Recharge, self.Tycoon.Owner, self.PetBalanceId)
	end)
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

	----wait for player to buy gamepass from shop for ultimate wrapper
	--self.Tycoon.Owner:GetAttributeChangedSignal("UltimateWrapper"):Connect(function()
	--	if(self.Tycoon.Owner:GetAttribute("UltimateWrapper") == true) then
	--		--set values to maximum
	--		self.Instance:SetAttribute("Speed",0.5)
	--	end
	--end)

	self._Maid:GiveTask(self.Instance:GetAttributeChangedSignal("Speed"):Connect(function(...)
		if DEBUG_ENABLED then
			print("Wrapping Speed Changed")
		end
	end))

	self._Maid:GiveTask(self.Instance:GetAttributeChangedSignal("Automation"):Connect(function()
		if DEBUG_ENABLED then
			print("Wrapping Automation Changed")
		end
	end))

	self._Maid:GiveTask(self.Instance:GetAttributeChangedSignal("Multiplier"):Connect(function()
		if DEBUG_ENABLED then
			print("Wrapping Multiplier Changed")
		end
	end))

	self.SurfaceGui = _getChild(_getChild(self.Instance, "CountPart"), "SurfaceGui") :: SurfaceGui
	if self.SurfaceGui then
		if self.SurfaceGui:FindFirstChild("TextLabel") then
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
			textLabel.TextScaled = true
			textLabel.Position = UDim2.fromScale(0.5, 0.5)
			textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			textLabel.Text = tostring(#self.Queue)
		end
	end

	SkinUtil.set(self.Instance, self.ModifierId.Multiplier, true)
end

function Wrapper:EquipPet(petBalanceId: string?, enabled: boolean?): ()
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

function Wrapper:OnUpgraded(player: Player, modifierId: string): ()
	if not self._IsAlive then return end
	if player == self.Tycoon.Owner then
		self.ModifierId[StationModifierUtil.getPropertyName(modifierId)] = modifierId
		SkinUtil.set(self.Instance, self.ModifierId.Multiplier, false)
		BreadDropUtil.normalizeQueue(self.Queue)
	end
end

function Wrapper:OnTouch(hit: BasePart)
	if not self._IsAlive then return end
	--if the object has a value
	if BreadDropUtil.getIfDrop(hit) then
		local data = BreadDropUtil.get(hit)
		--delete resource as it has done its job
		hit:Destroy()

		if #self.Queue >= 100 then
			table.remove(self.Queue, 1)
		end

		table.insert(self.Queue, data)
		BreadDropUtil.normalizeQueue(self.Queue)

		if self.SurfaceGui then
			if self.SurfaceGui:FindFirstChild("TextLabel") then
				(_getChild(self.SurfaceGui, "TextLabel") :: TextLabel).Text = tostring(#self.Queue)
			end
		end
	end
end

function Wrapper:Press(player: Player, isAutomated: boolean)
	if not self._IsAlive then return end
	if not self._WrapDebounce and not isAutomated then
		return
	end
	local data = self.Queue[1]
	if data then
		if not isAutomated then
			self._WrapDebounce = false
		end
		if not isAutomated then
			NetworkUtil.fireClient(ON_WRAP_PRESS, self.Tycoon.Owner)
		end
		task.spawn(function()
			Wrapper.wrap(data, self.ModifierId.Multiplier, self.PetBalanceId, self.DropSpawn, self.Instance, player, self.Tycoon.Owner)
			table.remove(self.Queue, 1)
			if self.SurfaceGui:FindFirstChild("TextLabel") then
				(_getChild(self.SurfaceGui, "TextLabel") :: TextLabel).Text = tostring(#self.Queue)
			end
			if self.Tycoon.Owner:GetAttribute("MuteSFX") ~= nil then
				if self.Tycoon.Owner:GetAttribute("MuteSFX") == false then
					--play the SFX
					--play sound effect
					SFXEvent:Fire(self.Tycoon.Owner)
				end
			end
		end)
		task.wait(StationModifierUtil.getValue(self.ModifierId.Recharge, self.Tycoon.Owner))
		if not isAutomated then
			self._WrapDebounce = true
		end
	end
end

function Wrapper.wrap(dropData: DropData?, multiplierId: string, petBalanceId: string?, dropSpawn: Attachment, instance: Model, player: Player, owner: Player)
	if not dropData then
		return
	end
	assert(dropData, "assertion failed")

	local typeName = BreadTypes.Order[dropData.TypeIndex]
	local wrappedBread = BreadTypes.Types[typeName].Wrapped:Clone()
	wrappedBread.Position = dropSpawn.WorldPosition
	wrappedBread.Orientation = Vector3.new(0, dropSpawn.WorldOrientation.Y, 0)
	wrappedBread.Parent = instance
	wrappedBread.BrickColor = BrickColor.new("Burnt Sienna")

	dropData.Value *= StationModifierUtil.getValue(multiplierId, owner, petBalanceId)
	BreadDropUtil.set(wrappedBread, dropData)

	wrappedBread:SetAttribute("Wrapped", true)

	--Add bread decal to the wrapped bread.
	local breadDecal = BreadTypes.BreadDecal:Clone()
	breadDecal.Parent = wrappedBread

	--the debris service sets the lifetime for this item before deletion, default is 10 seconds
	Debris:AddItem(wrappedBread, 20)

	--check if player has option enabled
	if owner:GetAttribute("LoafValueReader") ~= nil then
		if owner:GetAttribute("LoafValueReader") == true then
			--display the value of this object
			local valueBillboardGui = _getChild(wrappedBread, "ValueBillboardGUI") :: BillboardGui
			local textLabel = _getChild(valueBillboardGui, "TextLabel") :: TextLabel
			textLabel.Text = "$" .. math.round(dropData.Value * 100) / 100
			valueBillboardGui.Enabled = true
		end
	end
end

return Wrapper
