--!strict
-- Services
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

-- Modules
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
-- local TextUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TextUtil"))
local BreadDropUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BreadDropUtil"))
local ReferenceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
local PetBuilder = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PetBuilder"))
local BreadTypes = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("BreadTypes"))

-- local MultiplierUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("MultiplierUtil"))
-- local BreadManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BreadManager"))
local PetAssignmentPrompt = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PetAssignmentPrompt"))
local SkinUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("SkinUtil"))
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))

-- Types
type DropData = BreadDropUtil.DropData
type Maid = Maid.Maid
type Signal = Signal.Signal
export type StationType = "Kneader" | "Oven" | "Windmill" | "Wrapper" | "Base"
export type StationProperties = {
	_Maid: Maid,
	_IsAlive: boolean,
	_IsPlayerLocked: boolean,
	_PetBalanceId: string?,
	_DropAttachment: Attachment,
	_SurfaceGui: SurfaceGui?,
	_IsPlayerTriggerable: boolean,
	_DropTemplate: BasePart,
	_PetSpawnCFrame: CFrame,
	Type: StationType,
	Instance: Model,
	Owner: Player,
	OnFire: Signal,
	ModifierId: {
		Recharge: string,
		Multiplier: string?,
		Value: string?,
	},
	Queue: { [number]: DropData },
}
export type StationFunctions<Self> = {
	__index: Self,
	_OnTouch: (self: Self, hit: BasePart) -> (),
	_PlayDropSoundEffect: (self: Self, soundEffectTrigger: BindableEvent) -> (),
	_TrackModifier: (self: Self, propertyName: string) -> (),
	_BuildPrompt: (self: Self, objectText: string, actionText: string) -> (),
	Fire: (self: Self, player: Player?) -> (),
	Upgrade: (self: Self, modId: string) -> (),
	EquipPet: (self: Self, petBalanceId: string?, equipped: boolean?) -> (),
	Destroy: (self: Self) -> (),
	_new: (owner: Player, instance: Model, stationType: StationType, petSpawnCF: CFrame) -> Self,
}
type BaseStation<Self> = StationProperties & StationFunctions<Self>
export type Station = BaseStation<BaseStation<any>>

-- Constants
local BREAD_TYPE_INDEX = 1
local BREAD_TYPE = "Sourdough"
-- Variables
-- References
local DropsFolder = game:GetService("ServerStorage"):WaitForChild("Drops")
local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
local SoundEvent = RemoteEvents:WaitForChild("PlaySoundEvent") :: RemoteEvent

-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

-- Class
local Station = {} :: Station
Station.__index = Station

function Station._new(owner: Player, instance: Model, stationType: StationType, petSpawnCF: CFrame): Station

	local self: Station = setmetatable({}, Station) :: any
	self._Maid = Maid.new()
	self._IsAlive = true
	self._IsPlayerLocked = false
	self._PetSpawnCFrame = petSpawnCF

	self.Queue = {}
	self.Owner = owner
	self.Instance = self._Maid:GiveTask(instance)
	self.Type = stationType
	self.OnFire = self._Maid:GiveTask(Signal.new())
	self._DropAttachment = assert(assert(self.Instance:WaitForChild("Detector", 10)):WaitForChild("Spawn", 5)) :: Attachment
	if self.Type == "Windmill" then
		self._DropTemplate = self._Maid:GiveTask(assert(DropsFolder:WaitForChild(self.Instance:GetAttribute("Drop"), 20) :: BasePart):Clone())
	elseif self.Type == "Wrapper" then
		local wrappedBread = self._Maid:GiveTask(BreadTypes.Types[BREAD_TYPE].Wrapped:Clone())
		wrappedBread.Position = self._DropAttachment.WorldPosition
		wrappedBread.Orientation = Vector3.new(0, self._DropAttachment.WorldOrientation.Y, 0)
		wrappedBread.BrickColor = BrickColor.new("Burnt Sienna")

		self._DropTemplate = wrappedBread

	elseif self.Type == "Oven" then
		local cookedBread = self._Maid:GiveTask(BreadTypes.Types[BREAD_TYPE].Cooked:Clone())
		cookedBread.BrickColor = BrickColor.new("Burnt Sienna")
		self._DropTemplate = cookedBread
	elseif self.Type == "Kneader" then
		local dough = self._Maid:GiveTask(BreadTypes.Types[BREAD_TYPE].Dough:Clone())
		dough.BrickColor = BrickColor.new("Burnt Sienna")
		self._DropTemplate = dough
	end
	assert(self._DropTemplate, `missing drop template for station of type {self.Type}`)



	self.ModifierId = {
		Recharge = "",
	}


	--trigger touched event if something touches the detector

	if self.Type ~= "Windmill" then

		self._Maid:GiveTask(assert(self.Instance:WaitForChild("Detector", 20) :: BasePart).Touched:Connect(function(hit: BasePart)
			self:_OnTouch(hit)
		end))
	
		-- print(self.Type)
		local surfaceGui = assert(assert(self.Instance:FindFirstChild("CountPart")):WaitForChild("SurfaceGui", 20) :: SurfaceGui?)
		local textLabel = assert(surfaceGui:WaitForChild("TextLabel", 20)) :: TextLabel

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

		self._IsPlayerTriggerable = true
		self._SurfaceGui = surfaceGui
	else
		self._IsPlayerTriggerable = false
	end

	if self.ModifierId.Multiplier then
		SkinUtil.set(self.Instance, self.ModifierId.Multiplier, true)
	elseif self.ModifierId.Value then
		SkinUtil.set(self.Instance, self.ModifierId.Value, true)
	end

	if not self._IsPlayerTriggerable then
		local lastFire = tick()
		self._Maid:GiveTask(RunService.Heartbeat:Connect(function()
			local recharge = StationModifierUtil.getValue(self.ModifierId.Recharge, self.Owner, self._PetBalanceId)
			if tick() - lastFire > recharge then
				lastFire = tick()
				self:Fire()
			end
		end))
	else
			
		local assignmentMaid = PetAssignmentPrompt(self.Instance, self.Owner)
		if assignmentMaid then
			self._Maid:GiveTask(assignmentMaid)
		end

		local function updatePet()
			for i, data in ipairs(PlayerManager.getSavedPets(self.Owner)) do
				if data.Assignment == self.Instance.Name then
					self:EquipPet(data.BalanceId, true)
					return
				end
			end
			self:EquipPet(nil, false)
		end
		self._Maid:GiveTask(PlayerManager.getPetDataChangedSignal(self.Owner):Connect(updatePet))
		task.spawn(updatePet)

		for i, data in ipairs(PlayerManager.getSavedPets(self.Owner)) do
			PlayerManager.getPetDataChangedSignal(self.Owner):Fire(data)
		end
	end

	return self
end

function Station:_BuildPrompt(objectText: string, actionText: string)

	local function getCooldown()
		return StationModifierUtil.getValue(self.ModifierId.Recharge, self.Owner, self._PetBalanceId)
	end

	local function getActionText()
		return self.Instance:GetAttribute("Display") or actionText --assert(self.Instance:GetAttribute("Display")) :: string
	end

	local onPromptClick = BreadDropUtil.newDropPrompt(
		_getChild(_getChild(_getParent(self.Instance), self.Type), "PromptAnchor") :: BasePart, 
		objectText, 
		getActionText, 
		getCooldown
	)

	self._Maid:GiveTask(onPromptClick:Connect(function(player: Player)
		self:Fire(player)
	end))
end

function Station:_TrackModifier(propertyName: string)
	self.ModifierId[propertyName] = StationModifierUtil.getId(
		self.Type, 
		propertyName,
		 PlayerManager.getModifierLevel(self.Owner, self.Type, propertyName)
	)
end

function Station:Upgrade(modId: string): ()
	if not self._IsAlive then return end
	local modifierName = StationModifierUtil.getPropertyName(modId)
	self.ModifierId[modifierName] = modId
	local success, msg = pcall(function()
		if modifierName == "Value" or modifierName == "Multiplier" then
			SkinUtil.set(self.Instance, self.ModifierId[modifierName], false)
		end
	end)
	if not success then
		warn(msg)
	end
	if self.Owner:GetAttribute("MuteSFX") ~= nil then
		if self.Owner:GetAttribute("MuteSFX") == false then
			--play the SFX
			--play sound effect
			SoundEvent:FireClient(self.Owner, "UpgradeSound")
		end
	end
	BreadDropUtil.normalizeQueue(self.Queue)
end

function Station:_OnTouch(hit: BasePart)
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

		if self._SurfaceGui then
			assert(self._SurfaceGui:WaitForChild("TextLabel", 20) :: TextLabel?).Text = tostring(#self.Queue)
		end

		local breadShapedTotal = PlayerManager.getBreadShapedAmount(self.Owner) or 0
		PlayerManager.setBreadShapedAmount(self.Owner, breadShapedTotal + 1)

		--keep track that a wheat drop has been deleted
		if PlayerManager.getWheatCreatedAmount(self.Owner) ~= nil then
			PlayerManager.setWheatCreatedAmount(self.Owner, PlayerManager.getWheatCreatedAmount(self.Owner) - 1)
		end

		task.wait(StationModifierUtil.getValue(self.ModifierId.Recharge, self.Owner, self._PetBalanceId))
	end
end

function Station:_PlayDropSoundEffect(soundEffectTrigger: BindableEvent)
	--check if player has muted the SFX
	if self.Owner:GetAttribute("MuteSFX") ~= nil then
		if self.Owner:GetAttribute("MuteSFX") == false then
			--play the SFX
			--play sound effect
			soundEffectTrigger:Fire(self.Owner)
		end
	end
end

function Station:Fire(player: Player?)
	if not self._IsAlive then return end
	player = player or self.Owner
	assert(player)
	local doughCreatedTotal = PlayerManager.getDoughCreatedAmount(self.Owner) or 0

	local isAutomated = self._PetBalanceId ~= nil or (not self._IsPlayerTriggerable)

	--check if player who interacts with the button is the owner of this tycoon
	if player == self.Owner then
		--self.Midas:Fire("Press", 5)

		--check if there is bread to cook
		if (#self.Queue > 0 or self.Type == "Windmill") and ((self._IsPlayerLocked == false) or isAutomated) then
			if not isAutomated then
				self._IsPlayerLocked = true
			end

			--spawn the bread
			if not self._IsAlive then return end

			self.OnFire:Fire()

			local dropData: DropData
			if self.Type == "Windmill" then
				dropData = BreadDropUtil.new(BREAD_TYPE_INDEX, self.Owner)
				
			else
				dropData = self.Queue[1]
				table.remove(self.Queue, 1)
			end

			
			if self.ModifierId.Value then
				dropData.Value += StationModifierUtil.getValue(self.ModifierId.Value, self.Owner, self._PetBalanceId)
			elseif self.ModifierId.Multiplier then
				dropData.Value *= StationModifierUtil.getValue(self.ModifierId.Multiplier, self.Owner, self._PetBalanceId)
			end


			--clone the drop from server storage
			local drop = self._DropTemplate:Clone()
			BreadDropUtil.set(drop, dropData)
			drop.CollisionGroup = "Bread"
			drop.Position = self._DropAttachment.WorldPosition
			drop.Orientation = Vector3.new(0, self._DropAttachment.WorldOrientation.Y, 0)
			drop.Anchored = false
			drop.Parent = workspace

			--the debris service sets the lifetime for this item before deletion, default is 20 seconds
			Debris:AddItem(drop, 20)

			PlayerManager.setDoughCreatedAmount(self.Owner, doughCreatedTotal + 1)

			--remove from table


			if self._SurfaceGui then
				(_getChild(self._SurfaceGui, "TextLabel") :: TextLabel).Text = tostring(#self.Queue)
			end
			task.wait(StationModifierUtil.getValue(
				self.ModifierId.Recharge, 
				self.Owner, 
				self._PetBalanceId
			))

			if not isAutomated then
				self._IsPlayerLocked = false
			end
		end
	end
end

function Station:EquipPet(petBalanceId: string?, enabled: boolean?): ()
	if not self._IsAlive then return end
	self._PetBalanceId = petBalanceId

	local function getIfEnabled()
		return self._PetBalanceId == petBalanceId
	end

	local function getQueueLength(): number
		if not self._IsAlive then return 0 end
		return #self.Queue
	end

	local function fireStation()
		self:Fire(self.Owner)
	end

	local petMaid = Maid.new()
	self._Maid._pet = petMaid

	PetBuilder(petMaid, 
		self.Owner, 
		petBalanceId, 
		self._PetSpawnCFrame, 
		self.Instance, 
		enabled, 
		getIfEnabled, 
		getQueueLength, 
		fireStation
	)

end

function Station:Destroy()
	if not self._IsAlive then
		return
	end
	self._IsAlive = false
	self._Maid:Destroy()
	local t: any = self
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(t, nil)
end
return Station