--!strict
-- Services
local TweenService = game:GetService("TweenService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))

-- Modules
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
local TextUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TextUtil"))
local BreadDropUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BreadDropUtil"))
local MultiplierUtil = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("MultiplierUtil"))
local BreadManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BreadManager"))
local MidasStateTree = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MidasStateTree"))

-- Types
type DropData = BreadDropUtil.DropData
type Maid = Maid.Maid
export type DeliveryTruck = {
	__index: DeliveryTruck,
	_Maid: Maid,
	_IsAlive: boolean,
	_DeliveryCount: number,
	Queue: { [number]: DropData },
	RespawnTime: number,
	TruckActive: boolean,
	InitialCFrame: CFrame,
	_TouchDebounce: boolean,
	Owner: Player,
	Instance: Model,
	TruckParts: Folder,
	Prompt: ProximityPrompt,
	GoalPoint: BasePart,
	StartPoint: BasePart,
	SurfaceGUI: SurfaceGui?,
	PreviousDeliveryTime: number,
	AutoLoadSubscription: RBXScriptConnection,
	Subscription: RBXScriptConnection,
	new: (owner: Player, instance: Model) -> DeliveryTruck,
	OnTouched: (self: DeliveryTruck, hit: BasePart) -> (),
	CreatePrompt: (self: DeliveryTruck) -> ProximityPrompt,
	Press: (self: DeliveryTruck, player: Player) -> (),
	UpdateGUI: (self: DeliveryTruck) -> (),
	Fire: (self: DeliveryTruck, id: "Rebirth"?) -> (),
	TweenTruck: (self: DeliveryTruck, player: Player) -> (),
	FinishDelivery: (self: DeliveryTruck, player: Player) -> (),
	GetMultiplier: (self: DeliveryTruck) -> number,
	Destroy: (self: DeliveryTruck) -> (),
}

-- Constants
local DEBUG_ENABLED = false
local ON_DEPOSIT = "OnTrayDeposit"
local ON_DELIVER = "OnTruckDeliver"

-- Variables
-- References
local RemoteEvents = assert(ReplicatedStorage:WaitForChild("RemoteEvents", 20))
local BindableEvents = assert(ReplicatedStorage:WaitForChild("BindableEvents", 20))
local SoundEffectTriggers = assert(BindableEvents:WaitForChild("SoundEffectTriggers", 20)) :: BindableEvent
local PopUpFolder = assert(RemoteEvents:WaitForChild("PopUp", 20)) :: RemoteEvent
local ArrowEvent = RemoteEvents:FindFirstChild("ArrowEvent") :: RemoteEvent?
local SFXEvent = SoundEffectTriggers:WaitForChild("PlayTruckSound") :: BindableEvent
local BakersDozen = assert(BindableEvents:WaitForChild("BakersDozen", 20)) :: BindableEvent
local SoundEvent = RemoteEvents:WaitForChild("PlaySoundEvent") :: RemoteEvent
local MoneyPopUpEvent = PopUpFolder:WaitForChild("DisplayMoneyPopUp") :: RemoteEvent
local AdminSettings = ReplicatedFirst:WaitForChild("AdminControls", 20)
NetworkUtil.getRemoteEvent(ON_DEPOSIT)
NetworkUtil.getRemoteEvent(ON_DELIVER)

-- Class
local DeliveryTruck = {} :: DeliveryTruck
DeliveryTruck.__index = DeliveryTruck

--get value from admin setting script
if AdminSettings ~= nil then
	if AdminSettings:GetAttribute("DEBUG_ENABLED") ~= nil then
		DEBUG_ENABLED = AdminSettings:GetAttribute("DEBUG_ENABLED")
	end
end

function getRevenue(queue: { [number]: DropData }, multiplier: number): number
	local revenue = 0
	for i, bread in ipairs(queue) do
		revenue += bread.Value * multiplier
	end

	return math.round(revenue * 100) / 100
end

function DeliveryTruck.new(owner: Player, instance: Model): DeliveryTruck
	local self: DeliveryTruck = setmetatable({}, DeliveryTruck) :: any
	self._Maid = Maid.new()
	self._IsAlive = true
	self.Owner = owner
	self.Instance = instance
	self._DeliveryCount = 0
	MidasStateTree.Tycoon.Truck.DeliveryCount(owner, function()
		return self._DeliveryCount
	end)
	self.RespawnTime = 2
	self.TruckActive = true
	self._TouchDebounce = true
	self._IsAlive = true
	self.Queue = {}
	self.InitialCFrame = assert(self.Instance.PrimaryPart).CFrame

	self.TruckParts = assert(assert(self.Instance.Parent, "assertion failed"):FindFirstChild("TruckParts") :: Folder?, "assertion failed")
	--Setup a touched event for the truck's collection point.
	self._Maid:GiveTask(assert(self.TruckParts:WaitForChild("CollectionPoint", 20) :: BasePart?).Touched:Connect(function(hit: BasePart)
		self:OnTouched(hit)
	end))
	--Create a prompt to show the player they can deliver bread.
	self.Prompt = self._Maid:GiveTask(self:CreatePrompt())
	--Connect the prompt triggered event to the press function.
	self._Maid:GiveTask(self.Prompt.Triggered:Connect(function(player: Player)
		self:Press(player)
	end))
	self.GoalPoint = assert(self.TruckParts:WaitForChild("GoalPoint", 20) :: BasePart?, "assertion failed")
	self.StartPoint = assert(self.TruckParts:WaitForChild("StartPoint", 20) :: BasePart?, "assertion failed")
	--A table that stores the types of bread in the truck.

	--Path to the SurfaceGUI parent.
	self.SurfaceGUI = assert(assert(self.TruckParts:WaitForChild("DisplayBoard", 10) :: BasePart?, "assertion failed"):WaitForChild("BreadCountSurfaceGUI", 10) :: SurfaceGui?, "assertion failed")
	--The amount loaded into the truck, loaded from the player's data or 0 if no data.
	self:UpdateGUI()
	--Tracks when the last truck was delivered
	self.PreviousDeliveryTime = os.time()
	--Subscribe to the heartbeat service to check for elapsed time.
	self._Maid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime: number)
		--Check if the Tycoon owner is a VIP
		if self.Owner:GetAttribute("VIP") ~= nil then
			--Check if the truck is active, no point counting if its out on delivery.
			if self.TruckActive then
				if os.difftime(os.time(), self.PreviousDeliveryTime) >= 15 then
					self:Press(self.Owner)
				end
			end
		end
		self:UpdateGUI()
	end))

	-- self.AutoLoadSubscription = self.Tycoon:SubscribeTopic("AutoLoader",function(...)
	-- 	--trigger this event
	-- 	self:AutoLoad(...)
	-- end)

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

			if self.TruckActive == true then
				--Update the Gui
				self:UpdateGUI()
			end

			--connect this topic to the named function
			--save the subscription and subscrive to the button topic
			--whenever a button is pressed it will fire the event
			-- self.Subscription = self._Maid:GiveTask(self.Tycoon:SubscribeTopic("Button", function(...)
			-- 	--trigger this event
			-- 	self:Fire(...)
			-- end))
		end
	end)

	return self
end


function DeliveryTruck:Destroy()
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

-- function DeliveryTruck:AutoLoad(player: Player, value: number)
-- 	if(player == self.Tycoon.Owner) then
-- 		if value ~= nil then
-- 			PlayerManager.setTruckMoney(self.Tycoon.Owner, getRevenue(self.Queue, self:GetMultiplier()))
-- 			PlayerManager.setTruckBreadCount(self.Tycoon.Owner, #self.Queue)
-- 			self:UpdateGUI()
-- 		end
-- 	end
-- end

function DeliveryTruck:TweenTruck(player)
	--self.SurfaceGUI.Enabled = false
	assert(self.SurfaceGUI, "assertion failed")
	assert(assert(self.SurfaceGUI:WaitForChild("ValueFrame", 10), "assertion failed"):WaitForChild("TruckValue", 10) :: TextLabel?, "assertion failed").Text = "Out For Delivery"
	--Setup the Tween to drive the truck away
	local cFrameValue = self._Maid:GiveTask(Instance.new("CFrameValue"))
	cFrameValue.Value = self.Instance:GetPivot()

	self._Maid:GiveTask(cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		self.Instance:PivotTo(cFrameValue.Value)
	end))

	local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local tween = TweenService:Create(cFrameValue, tweenInfo, {
		Value = CFrame.fromMatrix(self.GoalPoint.Position, cFrameValue.Value.XVector, cFrameValue.Value.YVector, cFrameValue.Value.ZVector),
	})
	tween:Play()

	task.spawn(function()
		tween.Completed:Wait()
		cFrameValue:Destroy()
		self:FinishDelivery(player)
	end)
end
--Update the relevant SurfaceGUI values.
function DeliveryTruck:UpdateGUI()
	--Check if SurfaceGUI is nil
	if self.SurfaceGUI ~= nil then
		local surfaceGui = self.SurfaceGUI
		assert(surfaceGui, "assertion failed")
		--Check if the SurfaceGUI has a child called ValueFrame to set value to.
		if self.SurfaceGUI:FindFirstChild("ValueFrame") then
			local textLabel = assert(assert(surfaceGui:WaitForChild("ValueFrame", 20), "assertion failed"), "assertion failed"):WaitForChild("TruckValue", 10) :: TextLabel

			local uiPadding = self._Maid:GiveTask(Instance.new("UIPadding"))
			uiPadding.PaddingBottom = UDim.new(0, 5)
			uiPadding.PaddingTop = UDim.new(0, 5)
			uiPadding.PaddingLeft = UDim.new(0, 10)
			uiPadding.PaddingRight = UDim.new(0, 10)
			uiPadding.Parent = textLabel

			local uiCorner = self._Maid:GiveTask(Instance.new("UICorner"))
			uiCorner.CornerRadius = UDim.new(0, 5)
			uiCorner.Parent = textLabel

			--textLabel.BackgroundTransparency = 0.1
			--textLabel.BackgroundColor3 = Color3.fromHSV(1,0,0.2)
			--textLabel.TextColor3 = Color3.fromHSV(1,0,0.8)

			--textLabel.AutomaticSize = Enum.AutomaticSize.XY
			--textLabel.Size = UDim2.fromScale(0,0)
			--textLabel.Position = UDim2.fromScale(0.5,0.5)
			--textLabel.AnchorPoint = Vector2.new(0.5,0.5)
			textLabel.Text = "$" .. TextUtil.applySuffix(getRevenue(self.Queue, 1)) .. "(x" .. self:GetMultiplier() .. ")"
		end

		if self.SurfaceGUI:FindFirstChild("BreadAmount") then
			local textLabel = assert(surfaceGui:WaitForChild("BreadAmount", 20), "assertion failed") :: TextLabel

			local uiPadding = self._Maid:GiveTask(Instance.new("UIPadding"))
			uiPadding.PaddingBottom = UDim.new(0, 5)
			uiPadding.PaddingTop = UDim.new(0, 5)
			uiPadding.PaddingLeft = UDim.new(0, 10)
			uiPadding.PaddingRight = UDim.new(0, 10)
			uiPadding.Parent = textLabel

			local uiCorner = self._Maid:GiveTask(Instance.new("UICorner"))
			uiCorner.CornerRadius = UDim.new(0, 5)
			uiCorner.Parent = textLabel

			--textLabel.BackgroundTransparency = 0.1
			--textLabel.BackgroundColor3 = Color3.fromHSV(1,0,0.2)
			--textLabel.TextColor3 = Color3.fromHSV(1,0,0.8)

			--textLabel.AutomaticSize = Enum.AutomaticSize.XY
			--textLabel.Size = UDim2.fromScale(0,0)
			--textLabel.Position = UDim2.fromScale(0.5,0.5)
			--textLabel.AnchorPoint = Vector2.new(0.5,0.5)
			textLabel.TextScaled = true
			textLabel.Text = tostring(#self.Queue)
		end
	end
end

function DeliveryTruck:GetMultiplier()
	--round numbers down
	local function roundValue(number: number, places: number): number
		return assert(tonumber(string.format("%." .. (places or 0) .. "f", number)), "assertion failed")
	end

	--round to 2 decimal places
	return roundValue(MultiplierUtil.get(self.Owner), 2)
end

function DeliveryTruck:OnTouched(hitPart)
	if not self.TruckActive then
		return
	end
	--Check if the parts parent is has a BreadTray, essentially checks if the thing touching it is a character equipped with the bread tool.
	local breadTray = assert(hitPart.Parent, "assertion failed"):FindFirstChild("BreadTray")
	--Checking for the BreadTray child should mean the parent is the character and not another part.
	if breadTray then
		if DEBUG_ENABLED then
			print("Holding Bread Tray")
		end
		--Attempt to get the character from the hit part.
		local character = hitPart.Parent
		if character then
			assert(character:IsA("Model"), "assertion failed")
			--Attempt to get the player from the character.
			local player = game:GetService("Players"):GetPlayerFromCharacter(character)
			if player and player == self.Owner then
				NetworkUtil.fireClient(ON_DEPOSIT, self.Owner)
				--If the player attribute for having a tray is false then the tray has been delivered but not yet destroyed
				--in the ResetTray script.
				if player:GetAttribute("HasTray") == false then
					return
				end
				local breadQueueStr = assert(breadTray:GetAttribute("Queue"), "assertion failed")

				local breadQueue: { [number]: DropData } = HttpService:JSONDecode(breadQueueStr) :: any
				assert(breadQueue, "assertion failed")
				--set value to the correct amount
				--check worth is not nil, so whatever touched the collider must be a resource
				if breadQueue and self._TouchDebounce then
					self._TouchDebounce = false

					for i, data in ipairs(breadQueue) do
						table.insert(self.Queue, data)
					end

					PlayerManager.setTruckMoney(self.Owner, getRevenue(self.Queue, self:GetMultiplier()))
					PlayerManager.setTruckBreadCount(self.Owner, #self.Queue)

					self:UpdateGUI()
					--breadTray:Destroy()

					--fire the event on the client with the destination
					assert(ArrowEvent, "assertion failed")
					ArrowEvent:FireClient(player, self.Instance, false)

					--Reset the HasTray attribute which will allow the player to pick up another tray.
					player:SetAttribute("HasTray", false)
					--Brief wait to allow other touch events to happen.
					wait(0.2)
					self._TouchDebounce = true
				end
			end
		end
	end
end

function DeliveryTruck:CreatePrompt()
	local prompt = self._Maid:GiveTask(Instance.new("ProximityPrompt"))

	prompt.HoldDuration = 0
	prompt.Parent = self.Instance.PrimaryPart
	prompt.ActionText = "Deliver"
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 20
	prompt.Style = Enum.ProximityPromptStyle.Custom
	CollectionService:AddTag(prompt, "ProximityPrompt")
	CollectionService:AddTag(prompt, "OwnerOnly")
	return prompt
end

function DeliveryTruck:FinishDelivery(player: Player)
	--Make the Truck and Glass window invisible.
	for _, basePart in pairs(self.Instance:GetDescendants()) do
		if basePart:IsA("BasePart") then
			basePart.Transparency = 1
		end
	end

	--Get the player's money.
	local playerMoney = PlayerManager.getMoney(player)

	--self.Midas:Fire("FinishDelivery")

	--round money to whole numbers for payment
	local paymentMoney = getRevenue(self.Queue, self:GetMultiplier())
	print("PAYMENT", math.round(100 * paymentMoney) / 100, "BREAD", #self.Queue, "MULTI", math.round(self:GetMultiplier() * 100) / 100) --, "Q", self.Queue)
	--Set the player's money to their current amount plus the value of the truck.
	PlayerManager.setMoney(player, playerMoney + paymentMoney)

	--increase the total amount of money this player has earned
	-- PlayerManager.setTotalMoney(player, PlayerManager.getTotalMoney(player) + paymentMoney)

	--increase the total amount of money the player has earned in this rebirth
	-- PlayerManager.setCareerCash(player, PlayerManager.getCareerCash(player) + paymentMoney)

	--check if player has muted the SFX
	if self.Owner:GetAttribute("MuteSFX") ~= nil then
		if self.Owner:GetAttribute("MuteSFX") == false then
			--play the SFX
			--play sound effect
			SoundEvent:FireClient(self.Owner, "MoneySound")
		end
	end

	--Fire Money Pop Up event
	MoneyPopUpEvent:FireClient(self.Owner, paymentMoney)

	--track how many peices of bread the player has delivered
	local BreadDeliveredTotal = PlayerManager.getBreadDeliveredAmount(self.Owner) or 0

	--fire event to give badge for player delivering 13 loafs
	if BreadDeliveredTotal >= 13 then
		BakersDozen:Fire(self.Owner)
	end

	--increase the counter by the amount of bread that was delivered
	PlayerManager.setBreadDeliveredAmount(self.Owner, BreadDeliveredTotal + #self.Queue)

	--Reset the SessionData truck money so the player cannot leave and come back with their previous amount in the truck.
	PlayerManager.setTruckMoney(player, getRevenue(self.Queue, self:GetMultiplier()))
	PlayerManager.setTruckBreadCount(player, #self.Queue)
	--Empty the types of stored bread in the truck.
	self.Queue = {}
	--Updated the SurfaceGUI to display the new amounts.
	self:UpdateGUI()

	--Wait for however long the respawn time is set to.
	wait(self.RespawnTime)
	--Mark the truck as active again allowing use.
	self.TruckActive = true
	--Make the Truck and Glass window visible again.
	for _, basePart in pairs(self.Instance:GetDescendants()) do
		if basePart:IsA("BasePart") then
			basePart.Transparency = 0
		end
	end
	--Reset the truck to its original location.
	self.Instance:PivotTo(CFrame.new(self.StartPoint.Position) * (self.InitialCFrame - self.InitialCFrame.Position))
	--Enable the SurfaceGUI again.
	assert(self.SurfaceGUI, "assertion failed")
	self.SurfaceGUI.Enabled = true
	--Enable the Deliver prompt again.
	self.Prompt.Enabled = true
	--Reset the auto send timer.
	self.PreviousDeliveryTime = os.time()

	--reset the attribute for the player to allow them to rebirth
	self.Owner:SetAttribute("TruckDelivering", false)
	--reset hastray
	player:SetAttribute("HasTray", nil)
end

function DeliveryTruck:Press(player)
	if self.TruckActive then
		if player == self.Owner and self.Owner:GetAttribute("TruckDelivering") == false then
			--Check if there is anything loaded into the truck
			if #self.Queue > 0 then
				NetworkUtil.fireClient(ON_DELIVER, self.Owner)

				local lastCount = #self.Queue
				local lastValue = 0
	
				for i, data: DropData in ipairs(self.Queue) do
					lastValue += data.Value
					local setKey = `setBreadType{data.TypeIndex}`
					if BreadManager[setKey] then
						BreadManager[setKey](player, 1, data.Value)
					end
				end

				MidasStateTree.Tycoon.Truck.LastDelivery.Count(self.Owner, function()
					return lastCount
				end)
				MidasStateTree.Tycoon.Truck.LastDelivery.Value(self.Owner, function()
					return lastValue
				end)
				self._DeliveryCount += 1

				--self.Midas:Fire("StartDelivery")
				--check if player has muted the SFX
				if self.Owner:GetAttribute("MuteSFX") ~= nil then
					if self.Owner:GetAttribute("MuteSFX") == false then
						--play the SFX
						--play sound effect
						SFXEvent:Fire(self.Owner)
					end
				end
				--set the attribute on the player to prevent them from rebirth
				self.Owner:SetAttribute("TruckDelivering", true)

				--Set the truck to no longer be active.
				self.TruckActive = false
				--Disabled the Deliver prompt.
				self.Prompt.Enabled = false
				--Start the truck on its movement.
				self:TweenTruck(player)
			end
		end
	end
end

function DeliveryTruck:Fire(id: "Rebirth"?)
	--check to see if button that was triggered is relevant to this object
	if id == "Rebirth" then
		--reset truck storage
		--Reset how much is loaded onto the truck.
		--Reset the SessionData truck money so the player cannot leave and come back with their previous amount in the truck.
		PlayerManager.setTruckMoney(self.Owner, getRevenue(self.Queue, self:GetMultiplier()))
		PlayerManager.setTruckBreadCount(self.Owner, #self.Queue)

		--delete self
		self:Destroy()
	end
end

return DeliveryTruck
