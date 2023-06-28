--!strict
-- Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

-- Modules
local Station = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("Station"))
local Kneader = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("Station"):WaitForChild("Kneader"))
local Oven = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("Station"):WaitForChild("Oven"))
local Windmill = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("Station"):WaitForChild("Windmill"))
local Wrapper = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("Station"):WaitForChild("Wrapper"))
local Conveyor = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("Conveyor"))
local DeliveryTruck = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("DeliveryTruck"))
local Modifier = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("Modifier"))
local Rack = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("Rack"))
local RebirthButton = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("RebirthButton"))
local RebirthProgressBoard = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("RebirthProgressBoard"))
local ReferenceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type Station = Station.Station
type Kneader = Kneader.Kneader
type Oven = Oven.Oven
type Windmill = Windmill.Windmill
type Wrapper = Wrapper.Wrapper
type Conveyor = Conveyor.Conveyor
type DeliveryTruck = DeliveryTruck.DeliveryTruck
type Modifier = Modifier.Modifier
type Rack = Rack.Rack
type RebirthButton = RebirthButton.RebirthButton
type RebirthProgressBoard = RebirthProgressBoard.RebirthProgressBoard

export type Tycoon = {
	__index: Tycoon,
	_Maid: Maid,
	_IsAlive: boolean,
	_IsRebirthing: boolean,
	_Spawn: BasePart,
	_TopicEvent: BindableEvent,
	Owner: Player,
	Instance: Model,
	OnRebirth: Signal,
	Components: {
		Kneader: Kneader,
		Oven: Oven,
		Windmill: Windmill,
		Wrapper: Wrapper,
		DeliveryTruck: DeliveryTruck,
		Rack: Rack,

		RebirthButton: RebirthButton,
		RebirthProgressBoard: RebirthProgressBoard,
		Modifiers: {[number]: Modifier},
		Conveyors: {[number]: Conveyor},
	},
	new: (player: Player, spawnPoint: BasePart, model: Model) -> Tycoon,
	Destroy: (self: Tycoon) -> (),
}

-- Constants
-- Variables
-- References
-- local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
-- local RebirthEvent = assert(BindableEvents:WaitForChild("Rebirth", 20) :: BindableEvent?)
local TeleportToDevTycoonEvent = assert(RemoteEvents:WaitForChild("TeleportToDevTycoonEvent", 20) :: RemoteEvent?)
-- local CosmeticChoiceEventFolder = RemoteEvents:WaitForChild("CosmeticChoiceEvent")
-- local CosmeticChangeEvent = assert(CosmeticChoiceEventFolder:WaitForChild("CosmeticChoice", 20) :: RemoteEvent?)

-- private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

-- Class
local Tycoon = {} :: Tycoon
Tycoon.__index = Tycoon

function Tycoon.new(player: Player, spawnPoint: BasePart, model: Model): Tycoon
	--create a new table with the metatable set to the tycoon
	local self: Tycoon = setmetatable({}, Tycoon) :: any
	self._Maid = Maid.new()
	self._IsAlive = true
	self._IsRebirthing = false

	self.Owner = player
	self._Spawn = spawnPoint
	self.Instance = model

	self.OnRebirth = self._Maid:GiveTask(Signal.new())

	local petSpawnCFrame = model:GetPivot()

	self.Components = {} :: any
	self.Components.Kneader = self._Maid:GiveTask(Kneader.new(player, _getChild(_getChild(model, "KneadingStation"), "Kneader") :: Model, petSpawnCFrame))
	self.Components.Oven = self._Maid:GiveTask(Oven.new(player, _getChild(_getChild(model, "BakingStation"), "Oven") :: Model, petSpawnCFrame))
	self.Components.Windmill = self._Maid:GiveTask(Windmill.new(player, _getChild(_getChild(model, "Windmill"), "Dropper") :: Model, petSpawnCFrame))
	self.Components.Wrapper = self._Maid:GiveTask(Wrapper.new(player, _getChild(_getChild(model, "WrappingStation"), "Wrapper") :: Model, petSpawnCFrame))
	self.Components.Rack = self._Maid:GiveTask(Rack.new(player, _getChild(model, "BreadRack") :: Model, petSpawnCFrame))
	self.Components.DeliveryTruck = self._Maid:GiveTask(DeliveryTruck.new(player, _getChild(model, "TruckModel") :: Model))
	self.Components.RebirthButton = self._Maid:GiveTask(RebirthButton.new(player, _getChild(_getChild(model, "Rebirth"), "Rebirth") :: BasePart))
	self.Components.RebirthProgressBoard = self._Maid:GiveTask(RebirthProgressBoard.new(player, _getChild(_getChild(model, "Rebirth"), "RebirthProgressBoard") :: BasePart))
	
	self.Components.Modifiers = {}
	for i, modifierPart in ipairs(CollectionService:GetTagged("UpdatedModifier")) do
		if modifierPart:IsDescendantOf(model) and modifierPart:IsA("BasePart") then
			local modifier = self._Maid:GiveTask(Modifier.new(player, modifierPart))
			self._Maid:GiveTask(modifier.OnUpgrade:Connect(function(modId: string)
				-- print("MOD", modId)
				local category = StationModifierUtil.getCategory(modId)
				if self.Components[category] then
					local station: Station = self.Components[category]
					-- print("STATION", category, station)
					station:Upgrade(modId)
				end
			end))

			table.insert(self.Components.Modifiers, modifier)
		end
	end

	self.Components.Conveyors = {}
	for i, conveyorModel in ipairs(CollectionService:GetTagged("Conveyor")) do
		if conveyorModel:IsDescendantOf(model) and conveyorModel:IsA("Model") then
			local conveyor = self._Maid:GiveTask(Conveyor.new(player, conveyorModel))
			table.insert(self.Components.Conveyors, conveyor)
		end
	end

	self._Maid:GiveTask(self.Components.RebirthButton.OnClick:Connect(function()
		if self._IsRebirthing then return end
		self._IsRebirthing = true
		PlayerManager.setRebirths(player, assert(PlayerManager.getRebirths(player))+1)
		PlayerManager.resetData(player)
		self.OnRebirth:Fire()
	end))

	self._Maid:GiveTask(self.Components.RebirthProgressBoard.OnRebirthUnlock:Connect(function()
		self.Components.RebirthButton:Unlock()
	end))

	self._Maid:GiveTask(TeleportToDevTycoonEvent.OnServerEvent:Connect(function(plr: Player)
		if player.UserId == plr.UserId then
			local character = player.Character
			if character then
				character:PivotTo(self.Instance:GetPivot() + Vector3.new(0,4,0))
			end
		end
	end))
	
	local lastUpdate = tick()
	self._Maid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime: number)
		if tick() - lastUpdate > 1 then
			self.Components.RebirthProgressBoard:CheckAvailable()
		end
	end))

	return self
end

function Tycoon:Destroy()
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

return Tycoon
