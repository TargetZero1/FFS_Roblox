--!strict
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

-- Modules
local ReferenceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
export type RebirthProgressBoard = {
	__index: RebirthProgressBoard,
	_Maid: Maid,
	_IsAlive: boolean,
	Owner: Player,
	Instance: BasePart,
	RebirthSpawned: boolean,
	OnRebirthUnlock: Signal,
	new: (owner: Player, part: BasePart) -> RebirthProgressBoard,
	CheckAvailable: (self: RebirthProgressBoard) -> (),
	Destroy: (self: RebirthProgressBoard) -> (),
}
-- Constants
-- Variables
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PopUpFolder = RemoteEvents:WaitForChild("PopUp")
local RebirthPopUpEvent = PopUpFolder:WaitForChild("DisplayRebirthPopUp") :: RemoteEvent

-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

-- Class
local RebirthProgressBoard = {} :: RebirthProgressBoard
RebirthProgressBoard.__index = RebirthProgressBoard

--create new unlockable module for this tycoon and what instance
function RebirthProgressBoard.new(owner: Player, part: BasePart): RebirthProgressBoard
	local self: RebirthProgressBoard = setmetatable({}, RebirthProgressBoard) :: any
	self._Maid = Maid.new()
	self._IsAlive = true
	--declare owning tycoon and part for this component
	self.Owner = owner
	self.Instance = part
	self.OnRebirthUnlock = self._Maid:GiveTask(Signal.new())

	self.RebirthSpawned = false

	task.spawn(function()
		while wait(1) do
			local PlayerFound = false

			--loop through all players
			for i, player in pairs(Players:GetPlayers()) do
				if player == self.Owner then
					PlayerFound = true
				end
			end

			if PlayerFound == false then
				break
			end

			if self.RebirthSpawned == false then
				--check if the player can afford this object
				self:CheckAvailable()
			else
				break
			end
		end
	end)

	return self
end

--check player can afford this button
function RebirthProgressBoard:CheckAvailable()
	--save the players current money
	local money = PlayerManager.getCareerCash(self.Owner)

	local cost = 200000
	--200k,500k,900k
	if PlayerManager.getRebirths(self.Owner) ~= nil then
		local PreviousValue = (200000 * assert(PlayerManager.getRebirths(self.Owner)))

		--cost this rebirth = previous rebith + a value for the increase
		cost = PreviousValue + 200000
	end

	--the loading bar for the loading screen
	local backgroundInst = _getChild(_getChild(self.Instance, "SurfaceGui"), "Background")
	local totalMoneyEarned = _getChild(backgroundInst, "TotalMoneyEarned") :: TextLabel
	local totalMoneyNeeded = _getChild(backgroundInst, "TotalMoneyNeeded") :: TextLabel
	local barFrame = _getChild(backgroundInst, "Bar") :: GuiObject

	totalMoneyEarned.Text = "Total Earned: " .. FormatUtil.money(money)

	--convert text to display $CostK
	--round numbers down
	local function valueRound(num: number, places: number): number
		return assert(tonumber(string.format("%." .. (places or 0) .. "f", num)))
	end

	-- local costDisplay = ""
	-- --is the cost in the millions?
	-- if cost >= 1000000 then
	-- 	--round to 2 decimal places
	-- 	costDisplay = valueRound(cost / 1000000, 2) .. "M"
	-- else
	-- 	--how many thousands
	-- 	costDisplay = valueRound(cost / 1000, 2) .. "K"
	-- end

	totalMoneyNeeded.Text = "Rebirth requires " .. FormatUtil.money(cost)

	--the filler bar for inside the loading bar
	local filler = _getChild(barFrame, "Filler") :: GuiObject

	--the text box to display the current percent loaded
	local percentageText = _getChild(barFrame, "Percent") :: TextLabel

	--calculate the total percentage of bar to fill
	local formula = (money / cost) * 100

	--prevent overflow
	if formula > 100 then
		formula = 100
	end

	--Add to the base value the modifier level times the modifier variations and round it to two decimal places.
	formula = valueRound(formula, 2)

	--update text value for percenage loaded
	percentageText.Text = formula .. "%"

	--resize bar to match current percentage loaded
	--resize bar gradually over time to match the current "forumla"(% of 100), Enums are to control smoothing properties
	filler:TweenSize(UDim2.new(formula / 100, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, true)

	--check the player has enough money for this object
	if money >= cost and self.RebirthSpawned == false then
		--reveal the rebirth button
		--ask tycoon to fire this event for this button
		--upon doing so all the parts that are linked to the id will unlock

		-- self.Tycoon:PublishTopic("Button", "UnlockRebirth")
		self.OnRebirthUnlock:Fire()

		--fire pop up event for the player to see the notification
		RebirthPopUpEvent:FireClient(self.Owner)

		self.RebirthSpawned = true
	end
end

function RebirthProgressBoard:Destroy()
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

return RebirthProgressBoard
