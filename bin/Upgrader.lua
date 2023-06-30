--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

-- Modules
local TycoonType = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Components"):WaitForChild("TycoonType"))
local ReferenceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ReferenceUtil"))

-- Types
type Tycoon = TycoonType.Tycoon
type Maid = Maid.Maid
export type Upgrader = {
	__index: Upgrader,
	_Maid: Maid,
	Instance: Model,
	new: (tycoon: Tycoon, inst: Model) -> Upgrader,
	Init: (self: Upgrader) -> (),
	OnTouch: (self: Upgrader, hit: BasePart) -> (),
}
-- Constants
-- Variables
-- References
-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

-- Class
local Upgrader = {} :: Upgrader
Upgrader.__index = Upgrader

--create new Upgrader module for this tycoon and what instance
function Upgrader.new(tycoon: Tycoon, instance: Model): Upgrader
	local self: Upgrader = setmetatable({}, Upgrader) :: any
	self._Maid = Maid.new()
	--declare owning tycoon and instance for this component
	self.Instance = instance
	self._Maid:GiveTask(self.Instance.Destroying:Connect(function()
		self._Maid:Destroy()
	end))
	--give back a copy of the table
	return self
end

function Upgrader:Init()
	--trigger touched event if something touches the detector
	self._Maid:GiveTask((_getChild(self.Instance, "Detector") :: BasePart).Touched:Connect(function(...)
		self:OnTouch(...)
	end))
end

function Upgrader:OnTouch(hit)
	--check whatever touched this has a worth value
	local worth = hit:GetAttribute("Worth")

	--if the object has a value
	if worth ~= nil then
		--set the objects value to its default X the multiplier
		hit:SetAttribute("Worth", hit:GetAttribute("Worth") * self.Instance:GetAttribute("Multiplier"))
	end
end

return Upgrader
