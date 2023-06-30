--!strict
-- Services
local CollectionService = game:GetService("CollectionService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

-- Modules
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
local TycoonType = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("TycoonType"))

-- Types
type Tycoon = TycoonType.Tycoon
type Maid = Maid.Maid
export type Button = {
	__index: Button,
	_Maid: Maid,
	Instance: Part,
	Tycoon: Tycoon,
	Cost: number,
	Money: number,
	new: (tycoon: Tycoon, part: Part) -> Button,
	Init: (self: Button) -> (),
	CreateBillboardPrompt: (self: Button) -> (),
	OnTouched: (self: Button, hit: BasePart) -> (),
	CreatePrompt: (self: Button) -> (),
	CheckAvailable: (self: Button) -> (),
	Press: (self: Button, player: Player) -> (),
}
-- Constants
-- Variables
-- References
-- Class
local Button = {} :: Button
Button.__index = Button

--create new unlockable module for this tycoon and what instance
function Button.new(tycoon: Tycoon, part: Part)
	local self: Button = setmetatable({}, Button) :: any
	self._Maid = Maid.new()
	--declare owning tycoon and part for this component
	self.Tycoon = tycoon
	self.Instance = part
	self.Cost = 0
	self.Money = 0

	self._Maid:GiveTask(self.Instance.Destroying:Connect(function()
		self._Maid:Destroy()
	end))
	--give back a copy of the table
	return self
end

function Button:Init()
	----create and save a reference to this proximity prompt
	--self.Prompt = self:CreatePrompt()

	----react to when the button is pressed
	--self.Prompt.triggered:Connect(function(...)
	--	self:Press(...)
	--end)

	--create the billboard
	self:CreateBillboardPrompt()

	--hook up collection event for when player touches the pad
	self._Maid:GiveTask(self.Instance.Touched:Connect(function(...)
		--fire collection event to pay player
		self:OnTouched(...)
	end))

	--spawn in another thread to avoid
	spawn(function()
		coroutine.wrap(function()
			while wait(1) do
				--save the current cost of the button
				self.Cost = self.Instance:GetAttribute("Cost")
				--save the players current money
				self.Money = PlayerManager.getMoney(self.Tycoon.Owner)
				--check if the player can afford this object
				self:CheckAvailable()
			end
		end)()
	end)
end

--for using a proximity prompt system to interact
function Button:CreatePrompt(): ProximityPrompt
	--set up proximity prompt
	local prompt = self._Maid:GiveTask(Instance.new("ProximityPrompt"))

	local displayText = self.Instance:GetAttribute("Display") :: string?
	assert(displayText, "'displayText' assertion failed")

	local costText = self.Instance:GetAttribute("Cost") :: string?
	assert(costText, "'costText' assertion failed")

	--set up default values
	prompt.HoldDuration = 0.5
	prompt.Parent = self.Instance
	prompt.ActionText = displayText
	prompt.ObjectText = "$" .. costText
	CollectionService:AddTag(prompt, "ProximityPrompt")
	return prompt
end

--for using a proximity prompt system to interact
function Button:CreateBillboardPrompt()
	--set up billboard prompt
	local billboard = self.Instance:WaitForChild("Billboard") :: BillboardGui

	local displayText: string = self.Instance:GetAttribute("Display")
	local costText: string = self.Instance:GetAttribute("Cost")

	--set up default values
	local actionTextLabel = billboard:WaitForChild("ActionText", 20) :: TextLabel?
	assert(actionTextLabel, "'actionTextLabel' assertion failed")
	local objectTextLabel = billboard:WaitForChild("ObjectText", 20) :: TextLabel?
	assert(objectTextLabel, "'objectTextLabel' assertion failed")

	actionTextLabel.Text = displayText
	objectTextLabel.Text = "$" .. costText
end

--check player can afford this button
function Button:CheckAvailable()
	--save the UI
	local billboard = self.Instance:WaitForChild("Billboard", 30) :: BillboardGui

	--set up default values
	local actionTextLabel = billboard:WaitForChild("ActionText", 20) :: TextLabel?
	assert(actionTextLabel, "'actionTextLabel' assertion failed")
	local objectTextLabel = billboard:WaitForChild("ObjectText", 20) :: TextLabel?
	assert(objectTextLabel, "'objectTextLabel' assertion failed")

	--check the player has enough money for this object
	if self.Money >= self.Cost then
		--set up default values
		actionTextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		objectTextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	else
		--set up default values
		actionTextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		objectTextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	end
end

function Button:Press(player: Player)
	--save a reference to the buttons Id for what it unlocks
	local id = self.Instance:GetAttribute("Id") :: number?
	assert(id, "'id' assertion failed")

	--save a reference to the cost to activate this button
	self.Cost = assert(self.Instance:GetAttribute("Cost") :: number?, "'cost' assertion failed")

	--save a reference to the players current money
	self.Money = PlayerManager.getMoney(player)

	--check if player who interacts with the button is the owner of this tycoon and they have the money necessary to buy it
	if player == self.Tycoon.Owner and self.Money >= self.Cost then
		--subtract the cost from the players money
		PlayerManager.setMoney(player, self.Money - self.Cost)

		--ask tycoon to fire this event for this button
		--upon doing so all the parts that are linked to the id will unlock
		self.Tycoon:PublishTopic("Button", id)
	end
end

function Button:OnTouched(hitPart: BasePart)
	--get whatever character touched the pad
	local character = hitPart:FindFirstAncestorWhichIsA("Model")

	--check character exists
	if character ~= nil then
		--get the player attached to the character
		local player = game:GetService("Players"):GetPlayerFromCharacter(character)
		assert(player, "'player' assertion failed")

		--check player that touched the bank is the owner of this tycoon
		if player and player == self.Tycoon.Owner then
			self:Press(player)
		end
	end
end

return Button
