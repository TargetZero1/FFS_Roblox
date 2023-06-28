--!strict
-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))

-- Modules
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local BreadDropUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BreadDropUtil"))
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))
local PetBuilder = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PetBuilder"))
local SkinUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("SkinUtil"))
local MidasStateTree = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MidasStateTree"))

-- Types
type Maid = Maid.Maid
type DropData = BreadDropUtil.DropData
export type Rack = {
	__index: Rack,
	Owner: Player,
	Instance: Model,
	_Maid: Maid,
	_IsAlive: boolean,
	_PetSpawnCFrame: CFrame,
	PetBalanceId: string?,
	PetEnabled: boolean,
	ModifierId: {
		Storage: string,
	},
	Queue: { [number]: DropData },
	SurfaceGui: SurfaceGui,
	UpgradeSubscription: RBXScriptConnection,
	EquipPet: (self: Rack, petBalanceId: string?, equipped: boolean?) -> (),
	new: (owner: Player, instance: Model, petSpawnCF: CFrame) -> Rack,
	OnTouched: (self: Rack, hit: BasePart) -> (),
	ResetBreadDisplayed: (self: Rack) -> (),
	ChangeBreadDisplayed: (self: Rack) -> (),
	Upgrade: (self: Rack, modifierId: string) -> (),
	Press: (self: Rack, player: Player) -> (),
	Destroy: (self: Rack) -> (),
}

-- Constants
local ON_TRAY_GRAB = "OnTrayGrab"

-- Variables
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local SoundEffectTriggerFolder = BindableEvents:WaitForChild("SoundEffectTriggers")
local BreadTool = ServerStorage:WaitForChild("BreadTray") :: Tool
local SoundEvent = RemoteEvents:WaitForChild("PlaySoundEvent") :: RemoteEvent
local ArrowEvent = RemoteEvents:FindFirstChild("ArrowEvent") :: RemoteEvent?
local SFXEvent = SoundEffectTriggerFolder:WaitForChild("PlayKneaderSound") :: BindableEvent
NetworkUtil.getRemoteEvent(ON_TRAY_GRAB)

-- private function
function getCollisionBox(inst: Model): Part
	local part = inst:WaitForChild("CollisionBox", 20) :: Part?
	assert(part, "'part' assertion failed")
	return part
end

-- Class
local Rack = {} :: Rack
Rack.__index = Rack

function Rack.new(owner: Player, instance: Model, petSpawnCF: CFrame): Rack
	print("RACK NEW")
	local self: Rack = setmetatable({}, Rack) :: any

	self.Owner = owner
	self.Instance = instance
	self.PetEnabled = false
	self._PetSpawnCFrame = petSpawnCF
	self._Maid = Maid.new()
	self._IsAlive = true
	self._Maid:GiveTask(function()
		self._IsAlive = false
	end)

	self._Maid:GiveTask(PlayerManager.getPetDataChangedSignal(self.Owner):Connect(function()
		for i, data in ipairs(PlayerManager.getSavedPets(self.Owner)) do
			if data.Assignment == self.Instance.Name then
				self:EquipPet(data.BalanceId, true)
				return
			end
		end
		self:EquipPet(nil, false)
	end))

	for i, data in ipairs(PlayerManager.getSavedPets(self.Owner)) do
		PlayerManager.getPetDataChangedSignal(self.Owner):Fire(data)
	end

-- print("INIT RACK")

	-- print("Spawning")
	self.ModifierId = {
		Storage = StationModifierUtil.getId("Rack", "Storage", PlayerManager.getModifierLevel(self.Owner, "Rack", "Storage")),
	}

	MidasStateTree.Tycoon.Rack.Level.Storage(owner, function(): number?
		local balanceId = self.ModifierId.Storage
		if balanceId then
			return StationModifierUtil.getLevel(balanceId)
		end
		return nil
	end)
		

	-- self.Instance:SetAttribute("StorageId", ModifierUtil.getLevel(self.ModifierId.Storage))
	-- self.Instance:GetAttributeChangedSignal("StorageId"):Connect(function()
	-- 	local lvl = assert(self.Instance:GetAttribute("StorageId"))
	-- 	-- print("Upgrading storage to", lvl)
	-- 	self.ModifierId.Storage = ModifierUtil.getId("Rack", "Storage", lvl)
	-- end)

	--ap.a = 1
	self._Maid:GiveTask(getCollisionBox(self.Instance).Touched:Connect(function(hit: BasePart)
		-- print("Collision Box Touched!")
		self:OnTouched(hit)
	end))

	local onPromptClick = BreadDropUtil.newDropPrompt(getCollisionBox(self.Instance) :: BasePart, "Tray", "Grab", function()
		return 0.5
	end)
	self._Maid:GiveTask(onPromptClick:Connect(function(player: Player)
		self:Press(player)
	end))
	--A table to keep track of the bread that has been collected.
	self.Queue = {}

	self:ChangeBreadDisplayed()

	local countPart = self.Instance:WaitForChild("CountPart", 20)
	assert(countPart, "'countPart' assertion failed")
	local surfaceGui = countPart:WaitForChild("SurfaceGui", 20) :: SurfaceGui?
	assert(surfaceGui, "'surfaceGui' assertion failed")
	self.SurfaceGui = surfaceGui
	if self.SurfaceGui then
		local textLabel = assert(self.SurfaceGui:WaitForChild("TextLabel", 20) :: TextLabel?, "assertion failed")
		textLabel.TextScaled = true
		textLabel.Text = tostring(#self.Queue)
	end

	SkinUtil.set(self.Instance, self.ModifierId.Storage, true)

	return self
end

function Rack:EquipPet(petBalanceId: string?, enabled: boolean?): ()
	if not self._IsAlive then return end
	print("new equip")
	if enabled ~= nil then
		self.PetEnabled = enabled
	end
	self.PetBalanceId = petBalanceId


	PetBuilder(self._Maid, self.Owner, petBalanceId, self._PetSpawnCFrame, self.Instance, enabled, function()
		return self.PetEnabled
	end, function()
		return #self.Queue
	end, function() end)
end

function Rack:Upgrade( modifierId: string)
	if not self._IsAlive then return end
	if self.Owner then
		self.ModifierId[StationModifierUtil.getPropertyName(modifierId)] = modifierId
		SkinUtil.set(self.Instance, self.ModifierId.Storage, false)
		BreadDropUtil.normalizeQueue(self.Queue)
	end
	--check if player has muted the SFX
	if self.Owner:GetAttribute("MuteSFX") ~= nil then
		if self.Owner:GetAttribute("MuteSFX") == false then
			--play the SFX
			--play sound effect
			SoundEvent:FireClient(self.Owner, "UpgradeSound")
		end
	end
end

function Rack:ResetBreadDisplayed()
	if not self._IsAlive then return end
	if self.Queue then
		local breadShelfMarkers = self.Instance:WaitForChild("BreadShelfMarkers", 20)
		assert(breadShelfMarkers, "'breadShelfMarkers' assertion failed")

		local regularBreads = breadShelfMarkers:WaitForChild("RegularBreads", 20)
		assert(regularBreads, "'regularBreads' assertion failed")

		local comicalBreads = breadShelfMarkers:WaitForChild("ComicalBread")
		assert(comicalBreads, "'comicalBreads' assertion failed")

		--If there is no more stored bread then just reset it entirely.
		if #self.Queue <= 0 then
			for i = 1, 15 do
				local inst = regularBreads:FindFirstChild("BreadMarker" .. tostring(i))
				assert(inst and inst:IsA("BasePart"), "assertion failed")
				inst.Transparency = 1

				local decal = inst:WaitForChild("Decal", 10)
				assert(decal and decal:IsA("Decal"), "assertion failed")
				decal.Transparency = 1
			end

			for i = 1, 3 do
				local inst = comicalBreads:WaitForChild("BreadPile" .. tostring(i), 20)
				assert(inst, "'inst' assertion failed")
				for _, child in ipairs(inst:GetChildren()) do
					assert(child:IsA("BasePart"), "assertion failed")
					child.Transparency = 1

					local decal = child:WaitForChild("Decal", 10)
					assert(decal and decal:IsA("Decal"), "assertion failed")
					decal.Transparency = 1
				end
			end
		end

		if #self.Queue > 0 then
			local value = math.floor(#self.Queue / 10)
			if value <= 15 then
				for i = 1, 15 do
					if i > value then
						local inst = regularBreads:FindFirstChild("BreadMarker" .. tostring(i))
						assert(inst and inst:IsA("BasePart"), "assertion failed")
						inst.Transparency = 1

						local decal = inst:WaitForChild("Decal", 10)
						assert(decal and decal:IsA("Decal"), "assertion failed")
						decal.Transparency = 1
					end
				end
			end

			local newValue = math.floor((#self.Queue - 150) / 25)
			for i = 1, 3 do
				if i > newValue then
					local inst = comicalBreads:WaitForChild("BreadPile" .. tostring(i), 20)
					assert(inst, "'inst' assertion failed")
					for _, child in ipairs(inst:GetChildren()) do
						assert(child:IsA("BasePart"), "assertion failed")
						child.Transparency = 1

						local decal = child:WaitForChild("Decal", 10)
						assert(decal and decal:IsA("Decal"), "assertion failed")
						decal.Transparency = 1
					end
				end
			end
		end
	end
end

function Rack:ChangeBreadDisplayed()
	if not self._IsAlive then return end
	if self.Queue then
		local breadShelfMarkers = self.Instance:WaitForChild("BreadShelfMarkers", 20)
		assert(breadShelfMarkers, "'breadShelfMarkers' assertion failed")

		local regularBreads = breadShelfMarkers:WaitForChild("RegularBreads", 20)
		assert(regularBreads, "'regularBreads' assertion failed")

		local comicalBreads = breadShelfMarkers:WaitForChild("ComicalBread")
		assert(comicalBreads, "'comicalBreads' assertion failed")

		if #self.Queue > 0 then
			local value = math.floor(#self.Queue / 10)
			--value = math.min(value, 15)
			if value <= 15 then
				for i = 1, 15 do
					if i <= value then
						local inst = regularBreads:FindFirstChild("BreadMarker" .. tostring(i))
						assert(inst and inst:IsA("BasePart"), "assertion failed")

						inst.Transparency = 0
						local decal = inst:WaitForChild("Decal", 10)
						assert(decal and decal:IsA("Decal"), "assertion failed")

						decal.Transparency = 0.4
					end
				end
			end

			if value > 15 then
				value = math.min(((#self.Queue - 150) / 25), 3)
				for i = 1, 3 do
					if i <= value then
						local inst = comicalBreads:WaitForChild("BreadPile" .. tostring(i), 20)
						assert(inst, "'inst' assertion failed")
						for _, child in ipairs(inst:GetChildren()) do
							assert(child:IsA("BasePart"), "assertion failed")
							child.Transparency = 0

							local decal = child:WaitForChild("Decal", 10)
							assert(decal and decal:IsA("Decal"), "assertion failed")
							decal.Transparency = 0.4
						end --End of child loop
					end --End of i < value
				end --End of loop 1 to 3
			end --End of if > 15
		end --End of number of stored bred
	end --End of null check
end

function Rack:OnTouched(hitPart: BasePart)
	if not self._IsAlive then return end
	-- print(Worth)
	--check worth is not nil, so whatever touched the collider must be a resource
	if
		BreadDropUtil.getIfDrop(hitPart) --[[and ModifierUtil.getValue(self.ModifierId.Storage) > #self.Queue]]
	then
		local dropData = BreadDropUtil.get(hitPart)
		hitPart:Destroy()

		table.insert(self.Queue, dropData)
		BreadDropUtil.normalizeQueue(self.Queue)

		self:ChangeBreadDisplayed()

		local doughCreatedTotal = PlayerManager.getDoughCreatedAmount(self.Owner) or 0

		if self.SurfaceGui then
			local textLabel = self.SurfaceGui:WaitForChild("TextLabel", 20) :: TextLabel?
			assert(textLabel, "'textLabel' assertion failed")
			textLabel.Text = tostring(#self.Queue)
		end

		--check for negatives
		if doughCreatedTotal < 0 then
			doughCreatedTotal = 1
		end
		PlayerManager.setDoughCreatedAmount(self.Owner, doughCreatedTotal - 1)
	end
end

function Rack:Press(player)
	if not self._IsAlive then return end
	if player == self.Owner then
		--Check the player is not already holding a tray.

		if not player:GetAttribute("HasTray") and #self.Queue > 0 then
			player:SetAttribute("HasTray", true)
			--self.Midas:Fire("Press", 5)
			NetworkUtil.fireClient(ON_TRAY_GRAB, self.Owner)
			--Create a new tool to represent the bread being picked up.
			local newTray = BreadTool:Clone()
			--Put it in the player's backpack.
			newTray.Parent = player.Backpack
			--The the humanoid of the player.
			local character = assert(player.Character, "'player.Character' assertion failed")
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				--check if player has muted the SFX
				if self.Owner:GetAttribute("MuteSFX") ~= nil then
					if self.Owner:GetAttribute("MuteSFX") == false then
						--play the SFX
						--trigger SFX event for the collector
						SFXEvent:Fire(self.Owner)
					end
				end

				--Equip the tool directly to the player so they see it instantly instead of just displaying on the toolbar.
				humanoid:EquipTool(newTray)
				--Give the tool an attribute to represent the value of the bread stored in the collector.
				--newTray:SetAttribute("BreadValue", self.StoredValue)

				--check if player has hidden the arrows or not
				if self.Owner:GetAttribute("ShowArrow") ~= nil then
					if self.Owner:GetAttribute("ShowArrow") == true then
						--Create a beam from the tray to the collection point.
						local instParent = assert(self.Instance.Parent, "'self.Instance.Parent' assertion failed")
						local truckParts = assert(instParent:WaitForChild("TruckParts", 10), "assertion failed")
						local collectionPoint = assert(truckParts:WaitForChild("CollectionPoint", 10), "assertion failed")

						assert(ArrowEvent, "'ArrowEvent' assertion failed")
						ArrowEvent:FireClient(player, collectionPoint, true)
					end
				end

				--Reset the stored value.
				--self.StoredValue = 0
				--Set the flag allow a player to only have one tray at a time.
				local trayQueue = {}
				local storageValue = StationModifierUtil.getValue(self.ModifierId.Storage, self.Owner, self.PetBalanceId)
				print("ID", self.ModifierId.Storage, "Storage", storageValue)
				for i = 1, storageValue do
					local data = self.Queue[1]
					if data then
						table.remove(self.Queue, 1)
						table.insert(trayQueue, data)
					end
				end

				newTray:SetAttribute("Queue", HttpService:JSONEncode(trayQueue))
				-- print("Q", trayQueue)
				self:ResetBreadDisplayed()
				self:ChangeBreadDisplayed()

				if self.SurfaceGui then
					local textLabel = self.SurfaceGui:WaitForChild("TextLabel")
					assert(textLabel:IsA("TextLabel"), "assertion failed")
					textLabel.Text = tostring(#self.Queue)
				end
				----Loop through all the table entries of stored bread and give the tray attributes with their relative names and values.
				--table.foreach(self.StoredBread, function(key, value)
				--	local storageLimit = PlayerManager.getTrayStorageLimit(player) or 10
				--	if value >= storageLimit then
				--		newTray:SetAttribute(key, storageLimit)
				--		value -= storageLimit
				--	else
				--		newTray:SetAttribute(key, value)
				--		value -= value
				--	end
				--end)
				--Empty the stored bread.
				--self.StoredBread = {}
			end
		else
			--self.Midas:Fire("PressFail", 5)
		end
	end
end

function Rack:Destroy()
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


return Rack
