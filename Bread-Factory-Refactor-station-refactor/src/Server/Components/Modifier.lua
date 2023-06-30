--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

-- Modules
local ReferenceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))

-- Types
type StationModifierData = StationModifierUtil.ModifierData
type Maid = Maid.Maid
type Signal = Signal.Signal
export type Modifier = {
	__index: Modifier,
	_Maid: Maid,
	_IsAlive: boolean,
	Owner: Player,
	Instance: BasePart,
	Property: string,
	Level: number,
	Category: string,
	OnUpgrade: Signal,
	new: (owner: Player, part: BasePart) -> Modifier,
	GetId: (self: Modifier, offset: number?) -> string,
	PromptMoneyPurchase: (self: Modifier, player: Player, requiredCash: number) -> (),
	_OnPress: (self: Modifier, player: Player, id: string) -> (),
	Destroy: (self: Modifier) -> (),
}

-- Constants
-- Variables

-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local UpdateModifier = RemoteEvents:WaitForChild("UpdateModifier") :: RemoteEvent
local SetupModifierUI = RemoteEvents:WaitForChild("SetupModifierUI") :: RemoteEvent
local BuyModifier = RemoteEvents:WaitForChild("BuyModifier") :: RemoteEvent

-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

-- Class
local Modifier = {} :: Modifier
Modifier.__index = Modifier

function Modifier.new(owner: Player, inst: BasePart): Modifier
	-- print("MOD", inst:GetFullName())
	local self: Modifier = setmetatable({}, Modifier) :: any
	self._Maid = Maid.new()
	self._IsAlive = true
	assert(inst:IsDescendantOf(workspace), "part needs to be descendent of workspace. Current path is: " .. inst:GetFullName())
	self.Owner = owner
	self.Instance = inst

	self.Property = self.Instance:GetAttribute("Property")
	self.Category = self.Instance:GetAttribute("Category")

	assert(self.Property, "bad mod property")
	assert(self.Category, "bad mod category")

	local modId = StationModifierUtil.getId(self.Category, self.Property, 1)
	self.Level = PlayerManager.getModifierLevel(self.Owner, StationModifierUtil.getCategory(modId), StationModifierUtil.getPropertyName(modId)) or 1

	self.OnUpgrade = self._Maid:GiveTask(Signal.new())
	self._Maid:GiveTask(BuyModifier.OnServerEvent:Connect(function(player: Player, modId: string): ()
		if StationModifierUtil.getCategory(modId) == self.Category and StationModifierUtil.getPropertyName(modId) == self.Property then
			local level = StationModifierUtil.getLevel(modId)
			self.Level = level
			self.OnUpgrade:Fire(self:GetId())
			self:_OnPress(player, modId)
		end
	end))

	assert(self.Instance, "inst missing?")
	--Set the modifier level for this category and type to the new level.
	PlayerManager.setModifierLevel(self.Owner, self:GetId())
	SetupModifierUI:FireClient(owner, inst, self:GetId())

	return self
end

function Modifier:GetId(offset: number?)
	local level = self.Level
	if offset then
		level += offset
	end
	return StationModifierUtil.getId(self.Category, self.Property, level)
end

--function to run when a player needs more money to purchase an upgrade
function Modifier:PromptMoneyPurchase(player: Player, requiredCash: number): ()
	local function handlePrompt(id: number)
		return MarketplaceService:PromptProductPurchase(player, id)
	end

	if requiredCash <= 5000 then
		handlePrompt(1316662852)
		return
	else
		if requiredCash <= 10000 then
			handlePrompt(1316663047)
			return
		else
			if requiredCash <= 50000 then
				handlePrompt(1316663368)
				return
			else
				if requiredCash <= 100000 then
					handlePrompt(1316663558)
					return
				else
					if requiredCash <= 250000 then
						handlePrompt(1316663723)
						return
					else
						-- if requiredCash <= 500000 then
						handlePrompt(1316663884)
						return
						-- end
					end
				end
			end
		end
	end
end

function Modifier:_OnPress(player: Player, id: string): ()
	if not self.Category or not self.Property then
		warn("UpdatedModifier: [Pressed] Category or Property Invalid on " .. self.Instance.Name)
		return
	end

	local category = StationModifierUtil.getCategory(id)
	local propertyName = StationModifierUtil.getPropertyName(id)

	if player == self.Owner then
		if category == self.Category and self.Property == propertyName then
			print("Pressing", self.Category, self.Property, self.Level)
			local playerMoney = PlayerManager.getMoney(player)
			local nextId = self:GetId(1)
			local cost = StationModifierUtil.getCost(nextId)
			if playerMoney < cost then
				print("prompting money purchase")
				self:PromptMoneyPurchase(player, cost - playerMoney)
			end

			playerMoney = PlayerManager.getMoney(player)
			if playerMoney >= cost then
				local _playerRebirths = PlayerManager.getRebirths(player)

				-- Increase the modifier level.
				self.Level += 1
				print("Purchasing", self:GetId())
				--Take off the player's money.
				PlayerManager.setMoney(player, playerMoney - cost)

				PlayerManager.setModifierLevel(self.Owner, self:GetId())
				UpdateModifier:FireClient(self.Owner, self:GetId())

			end
		end
	end
end


function Modifier:Destroy()
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


return Modifier
