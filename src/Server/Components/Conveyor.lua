--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

-- Modules

-- Types
type Maid = Maid.Maid
export type Conveyor = {
	__index: Conveyor,
	_Maid: Maid,
	_IsAlive: boolean,
	Speed: number,
	Owner: Player,
	Instance: Model,
	new: (owner: Player, instance: Model) -> Conveyor,
	Destroy: (self: Conveyor) -> (),
}

-- Constants
-- Variables
-- References
-- Class

local Conveyor = {} :: Conveyor
Conveyor.__index = Conveyor

--create new Conveyor module for this tycoon and what instance
function Conveyor.new(owner: Player, instance: Model): Conveyor
	local self: Conveyor = setmetatable({}, Conveyor) :: any
	self._Maid = Maid.new()
	self._IsAlive = true
	--declare owning tycoon and part for this acomponent
	self.Owner = owner
	self.Instance = instance

	--save the speed of the conveyor
	self.Speed = instance:GetAttribute("Speed") :: number
	assert(self.Speed, "bad assertion")

	self._Maid:GiveTask(self.Instance.Destroying:Connect(function()
		self._Maid:Destroy()
	end))

	--save reference to the belt
	local belt = assert(self.Instance:WaitForChild("Belt", 20) :: BasePart?)
	local rightVector = belt.CFrame.LookVector
	--set the velocity of the belt to whatever the speed is, allows conveyors to be placed at different orientations
	belt.AssemblyLinearVelocity = rightVector * (self.Instance:GetAttribute("Speed"))

	self._Maid:GiveTask(self.Instance.AttributeChanged:Connect(function(AttributeName)
		if AttributeName == "Speed" then
			if self.Instance:GetAttribute("Speed") >= 0 then
				--set the velocity of the belt to whatever the speed is, allows conveyors to be placed at different orientations
				belt.AssemblyLinearVelocity = rightVector * self.Instance:GetAttribute("Speed")
			end
			--upgrades the conveyor model
		end
	end))

	--give back a copy of the table
	return self
end

function Conveyor:Destroy()
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


return Conveyor
