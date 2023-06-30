--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

-- Modules
local ReferenceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ReferenceUtil"))

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal

export type RebirthButton = {
	__index: RebirthButton,
	_Maid: Maid,
	_IsAlive: boolean,
	_IsUnlocked: boolean,
	Owner: Player,
	Instance: BasePart,
	OnClick: Signal,
	new: (owner: Player, part: BasePart) -> RebirthButton,
	OnTouched: (self: RebirthButton, hit: BasePart) -> (),
	Press: (self: RebirthButton, player: Player) -> (),
	Unlock: (self: RebirthButton) -> (),
	Destroy: (self: RebirthButton) -> (),
}
-- Constants
-- Variables
-- References
-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute
-- Class
local RebirthButton = {} :: RebirthButton
RebirthButton.__index = RebirthButton

--create new unlockable module for this tycoon and what instance
function RebirthButton.new(owner: Player, part: BasePart): RebirthButton
	local self: RebirthButton = setmetatable({}, RebirthButton) :: any
	self._Maid = Maid.new()
	--declare owning tycoon and part for this component
	self._IsAlive = true
	self.Owner = owner
	self.Instance = part
	self._IsUnlocked = false
	self.OnClick = self._Maid:GiveTask(Signal.new())

	--create the billboard
	local prompt = _getChild(self.Instance, "Billboard") :: BillboardGui
	local textLabel = _getChild(prompt, "ActionText") :: TextLabel
	--set up default values
	textLabel.Text = self.Instance:GetAttribute("Display")

	--hook up collection event for when player touches the pad
	self._Maid:GiveTask(self.Instance.Touched:Connect(function(...)
		--fire collection event to pay player
		self:OnTouched(...)
	end))

	--give back a copy of the table
	return self
end

function RebirthButton:Unlock()
	if not self._IsUnlocked then

	end
	self._IsUnlocked = true
end

function RebirthButton:Press(player: Player)
	if not self._IsUnlocked then return end
	--save a reference to the buttons Id for what it unlocks
	--check if player who interacts with the button is the owner of this tycoon and they have the money necessary to buy it
	if player == self.Owner then
		--check if the truck is currently out for delivery
		if self.Owner:GetAttribute("TruckDelivering") ~= nil then
			--wait until it has returned before progressing
			if self.Owner:GetAttribute("TruckDelivering") == false then
				--ask tycoon to fire this event for this button
				--upon doing so all the parts that are linked to the id will unlock
				self.OnClick:Fire()
			end
		end

		--if somehow it is nil, then the player has just loaded back in
		if self.Owner:GetAttribute("TruckDelivering") == nil then
			--as they have just returned they wont have had to deliver any bread so let them rebirth unhindered
			--ask tycoon to fire this event for this button
			--upon doing so all the parts that are linked to the id will unlock
			self.OnClick:Fire()
		end
	end
end

function RebirthButton:OnTouched(hitPart: BasePart)
	--get whatever character touched the pad
	local Character = hitPart:FindFirstAncestorWhichIsA("Model")

	--check character exists
	if Character ~= nil then
		--get the player attached to the character
		local player = game:GetService("Players"):GetPlayerFromCharacter(Character)

		--check player that touched the bank is the owner of this tycoon
		if player and player == self.Owner then
			self:Press(player)
		end
	end
end

function RebirthButton:Destroy()
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


return RebirthButton
