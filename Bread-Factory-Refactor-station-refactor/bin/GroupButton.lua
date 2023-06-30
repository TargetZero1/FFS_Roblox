--!strict
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

-- Modules
local TycoonType = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Components"):WaitForChild("TycoonType"))
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))

-- Types
type Tycoon = TycoonType.Tycoon
type Maid = Maid.Maid
export type GroupButton = {
	__index: GroupButton,
	_Maid: Maid,
	Speed: number,
	Cost: number,
	Money: number,
	Tycoon: Tycoon,
	Instance: BasePart,
	new: (tycoon: Tycoon, part: BasePart) -> GroupButton,
	Init: (self: GroupButton) -> (),
	OnTouched: (self: GroupButton, hit: BasePart) -> (),
	CheckAvailable: (self: GroupButton) -> (),
	CreatePrompt: (self: GroupButton) -> ProximityPrompt,
	CreateBillboardPrompt: (self: GroupButton) -> (),
	Press: (self: GroupButton, player: Player) -> (),
}

-- Variables

-- Class
local GroupButton = {} :: GroupButton
GroupButton.__index = GroupButton

--create new unlockable module for this tycoon and what instance
function GroupButton.new(tycoon: Tycoon, part: BasePart): GroupButton
	local self: GroupButton = setmetatable({}, GroupButton) :: any
	self._Maid = Maid.new()
	--declare owning tycoon and part for this component
	self.Tycoon = tycoon
	self.Instance = part
	self.Cost = 0
	self.Money = 0

	--give back a copy of the table
	self._Maid:GiveTask(self.Instance.Destroying:Connect(function()
		self._Maid:Destroy()
	end))
	return self
end

function GroupButton:Init()
	----create and save a reference to this proximity prompt
	--self.Prompt = self:CreatePrompt()

	----react to when the button is pressed
	--self.Prompt.triggered:Connect(function(...)
	--	self:Press(...)
	--end)

	--create the billboard
	self:CreateBillboardPrompt()

	--hook up collection event for when player touches the pad
	self._Maid:GiveTask(self.Instance.Touched:Connect(function(hit: BasePart)
		--fire collection event to pay player
		self:OnTouched(hit)
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
function GroupButton:CreatePrompt()
	--set up proximity prompt
	local prompt = self._Maid:GiveTask(Instance.new("ProximityPrompt"))

	--set up default values
	prompt.HoldDuration = 0.5
	prompt.Parent = self.Instance
	prompt.ActionText = self.Instance:GetAttribute("Display")
	prompt.ObjectText = "$" .. self.Instance:GetAttribute("Cost")
	CollectionService:AddTag(prompt, "ProximityPrompt")

	return prompt
end

--for using a proximity prompt system to interact
function GroupButton:CreateBillboardPrompt()
	--set up billboard prompt
	local billboard = assert(self.Instance:WaitForChild("Billboard", 10) :: BillboardGui?)

	--set up default values
	assert(billboard:WaitForChild("ActionText", 20) :: TextLabel?, "bad assertion").Text = self.Instance:GetAttribute("Display")
	assert(billboard:WaitForChild("ObjectText", 20) :: TextLabel?, "bad assertion").Text = "$" .. self.Instance:GetAttribute("Cost")
end

--check player can afford this button
function GroupButton:CheckAvailable()
	--save the UI
	local billboard: BillboardGui = assert(self.Instance:WaitForChild("Billboard", 60) :: BillboardGui?)

	--check the player has enough money for this object
	if self.Money >= self.Cost then
		--set up default values
		assert(billboard:WaitForChild("ActionText", 20) :: TextLabel?, "bad assertion").TextColor3 = Color3.fromRGB(0, 255, 0)
		assert(billboard:WaitForChild("ObjectText", 20) :: TextLabel?, "bad assertion").TextColor3 = Color3.fromRGB(0, 255, 0)
	else
		--set up default values
		assert(billboard:WaitForChild("ActionText", 20) :: TextLabel?, "bad assertion").TextColor3 = Color3.fromRGB(255, 0, 0)
		assert(billboard:WaitForChild("ObjectText", 20) :: TextLabel?, "bad assertion").TextColor3 = Color3.fromRGB(255, 0, 0)
	end
end

function GroupButton:Press(player)
	--save a reference to the buttons Id for what it unlocks
	local id = self.Instance:GetAttribute("Id")

	--save a reference to the cost to activate this button
	self.Cost = self.Instance:GetAttribute("Cost")

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

function GroupButton:OnTouched(hitPart)
	--get whatever character touched the pad
	local Character = hitPart:FindFirstAncestorWhichIsA("Model")

	--check character exists
	if Character ~= nil then
		--get the player attached to the character
		local player = game:GetService("Players"):GetPlayerFromCharacter(Character)

		--check player that touched the bank is the owner of this tycoon
		if player and player == self.Tycoon.Owner then
			if self.Tycoon.Owner:GetAttribute("InGroup") ~= nil then
				if self.Tycoon.Owner:GetAttribute("InGroup") == true then
					self:Press(player)
				end
			end
		end
	end
end

return GroupButton
