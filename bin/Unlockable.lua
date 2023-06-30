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
export type Unlockable = {
	__index: Unlockable,
	_Maid: Maid,
	Tycoon: Tycoon,
	Instance: Instance,
	Subscription: RBXScriptConnection,
	new: (tycoon: Tycoon, inst: Instance) -> Unlockable,
	Init: (self: Unlockable) -> (),
	OnButtonPressed: (self: Unlockable, id: number) -> (),
}
-- Constants
-- Variables
-- References
-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

-- Class
local Unlockable = {} :: Unlockable
Unlockable.__index = Unlockable

--create new unlockable module for this tycoon and what instance
function Unlockable.new(tycoon: Tycoon, inst: Instance): Unlockable
	local self: Unlockable = setmetatable({}, Unlockable) :: any
	self._Maid = Maid.new()
	--declare owning tycoon and instance for this component
	self.Tycoon = tycoon
	self.Instance = inst
	self._Maid:GiveTask(self.Instance.Destroying:Connect(function()
		self._Maid:Destroy()
	end))
	--give back a copy of the table
	return self
end

--hook this unlockable up to a topic
function Unlockable:Init()
	--connect this topic to the named function
	--save the subscription and subscrive to the button topic
	--whenever a button is pressed it will fire the event
	self.Subscription = self._Maid:GiveTask(self.Tycoon:SubscribeTopic("Button", function(...)
		--trigger this event
		self:OnButtonPressed(...)
	end))
end

function Unlockable:OnButtonPressed(id: number)
	--check to see if button that was triggered is relevant to this object
	if id == self.Instance:GetAttribute("UnlockId") then
		--call the unlock event on this tycoon
		(self.Tycoon :: any):Unlock(self.Instance, id); --I don't know why, but this typecheck fails and I can't fix it

		--enable the billboard GUi for the button
		(_getChild(self.Instance, "Billboard") :: BillboardGui).Enabled = true

		--once object is unlocked there is no need to still be subscribed
		self.Subscription:Disconnect()
	end
end

return Unlockable
