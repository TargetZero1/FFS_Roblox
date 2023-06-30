--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

-- Modules
local TycoonType = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Components"):WaitForChild("TycoonType"))
local ReferenceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))

-- Types
type Tycoon = TycoonType.Tycoon
type Maid = Maid.Maid
export type VIPButton = {
	__index: VIPButton,
	_Maid: Maid,
	Instance: BasePart,
	Tycoon: Tycoon,
	Money: number,
	Cost: number,
	new: (tycoon: Tycoon, part: BasePart) -> VIPButton,
	Init: (self: VIPButton) -> (),
	CreateBillboardPrompt: (self: VIPButton) -> (),
	CheckAvailable: (self: VIPButton) -> (),
	CreatePrompt: (self: VIPButton) -> ProximityPrompt,
	OnTouched: (self: VIPButton, hit: BasePart) -> (),
	Press: (self: VIPButton, player: Player) -> (),
}
-- Constants
-- Variables
-- References
-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

-- Class
local VIPButton = {} :: VIPButton
VIPButton.__index = VIPButton

--create new unlockable module for this tycoon and what instance
function VIPButton.new(tycoon: Tycoon, part: BasePart): VIPButton
	local self: VIPButton = setmetatable({}, VIPButton) :: any
	self._Maid = Maid.new()
	--declare owning tycoon and part for this component
	self.Tycoon = tycoon
	self.Instance = part
	self.Money = 0
	self.Cost = 0
	self._Maid:GiveTask(self.Instance.Destroying:Connect(function()
		self._Maid:Destroy()
	end))
	--give back a copy of the table
	return self
end

function VIPButton:Init()
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
function VIPButton:CreatePrompt()
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
function VIPButton:CreateBillboardPrompt()
	--set up billboard prompt
	local prompt = _getChild(self.Instance, "Billboard") :: BillboardGui;

	--set up default values
	(_getChild(prompt, "ActionText") :: TextLabel).Text = self.Instance:GetAttribute("Display");
	(_getChild(prompt, "ObjectText") :: TextLabel).Text = "$" .. self.Instance:GetAttribute("Cost")
end

--check player can afford this button
function VIPButton:CheckAvailable()
	--save the UI
	local UI = _getChild(self.Instance, "Billboard") :: BillboardGui

	local actionText = _getChild(UI, "ActionText") :: TextLabel
	local objectText = _getChild(UI, "ObjectText") :: TextLabel

	--check the player has enough money for this object
	if self.Money >= self.Cost then
		--set up default values
		actionText.TextColor3 = Color3.fromRGB(0, 255, 0)
		objectText.TextColor3 = Color3.fromRGB(0, 255, 0)
	else
		--set up default values
		actionText.TextColor3 = Color3.fromRGB(255, 0, 0)
		objectText.TextColor3 = Color3.fromRGB(255, 0, 0)
	end
end

function VIPButton:Press(player: Player)
	--save a reference to the buttons Id for what it unlocks
	local id = self.Instance:GetAttribute("Id")

	--save a reference to the cost to activate this button
	local cost = self.Instance:GetAttribute("Cost")

	--save a reference to the players current money
	local Money = PlayerManager.getMoney(player)

	--check if player who interacts with the button is the owner of this tycoon and they have the money necessary to buy it
	if player == self.Tycoon.Owner and Money >= cost then
		--subtract the cost from the players money
		PlayerManager.setMoney(player, Money - cost)

		--ask tycoon to fire this event for this button
		--upon doing so all the parts that are linked to the id will unlock
		self.Tycoon:PublishTopic("Button", id)
	end
end

function VIPButton:OnTouched(hitPart: BasePart)
	--get whatever character touched the pad
	local Character = hitPart:FindFirstAncestorWhichIsA("Model")

	--check character exists
	if Character ~= nil then
		--get the player attached to the character
		local player = game:GetService("Players"):GetPlayerFromCharacter(Character)

		--check player that touched the bank is the owner of this tycoon
		if player and player == self.Tycoon.Owner then
			if player:GetAttribute("VIP") ~= nil then
				if player:GetAttribute("VIP") == true then
					self:Press(player)
				end
			end
		end
	end
end

return VIPButton
