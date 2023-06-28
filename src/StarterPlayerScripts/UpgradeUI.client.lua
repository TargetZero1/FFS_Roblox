--!strict
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))

-- Modules
local ReferenceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))
local GamepassUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("GamepassUtil"))

-- Types
type Maid = Maid.Maid
type GuiConfig = {
	Part: BasePart,
	Id: string,
}
type UpgradeGui = {
	_Maid: Maid,
	MainGui: BillboardGui,
	UpgradeButton: TextButton,
	UpgradeName: TextLabel,
	UpgradeAmount: TextLabel,
	ModifierIcon: ImageLabel,
	Description: TextLabel,
	BuyConnection: RBXScriptConnection?,
	BalanceId: string,
}

-- Constants
local GET_IF_UPGRADING = "GetIfUpgrading"
-- Variables
local CurrentConfigs: { [string]: GuiConfig } = {}
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SetupModifierUI = RemoteEvents:WaitForChild("SetupModifierUI") :: RemoteEvent
local BuyModifier = RemoteEvents:WaitForChild("BuyModifier") :: RemoteEvent
local UpdateModifier = RemoteEvents:WaitForChild("UpdateModifier") :: RemoteEvent

-- Private functions
local _getChild = ReferenceUtil.getChild

function getKey(id: string)
	local modifierCategory = StationModifierUtil.getCategory(id)
	local modifierProperty = StationModifierUtil.getPropertyName(id)
	return modifierCategory .. "_" .. modifierProperty
end

-- function incrementId(id: string)
-- 	local modifierCategory = ModifierUtil.getCategory(id)
-- 	local modifierProperty = ModifierUtil.getPropertyName(id)
-- 	local modifierLevel = ModifierUtil.getLevel(id)
-- 	return ModifierUtil.getId(modifierCategory, modifierProperty, modifierLevel+1)
-- end

function boot(playerGui: PlayerGui, maid: Maid)
	local GUIs: { [string]: UpgradeGui } = {}

	local modifierFolder: Folder = maid:GiveTask(Instance.new("Folder"))
	modifierFolder.Name = "Modifiers"
	modifierFolder.Parent = playerGui

	local function createUI(parentPart: BasePart, modId: string): (BillboardGui, TextButton, TextLabel, TextLabel, ImageLabel, TextLabel)
		--print(parentPart, displayName, modifierCategory, modifierType, modifierCost, modifierAmount, modifierIcon, ultimateUpgradeAmount)
		local modifierCategory = StationModifierUtil.getCategory(modId)

		local gui_key = getKey(modId)

		--Create BillboardGUI to show over part that can be upgrade.
		local billboardGui = maid:GiveTask(Instance.new("BillboardGui"))
		assert(billboardGui, "'billboardGui' assertion failed")
		billboardGui.Size = UDim2.fromScale(25, 5)
		billboardGui.Name = gui_key
		billboardGui.Active = true
		billboardGui.AlwaysOnTop = true
		billboardGui.ResetOnSpawn = false
		billboardGui.MaxDistance = 50
		--billboardGui.ExtentsOffsetWorldSpace = Vector3.new(0, 0, -2.5)
		billboardGui.Parent = modifierFolder

		local gridLayout = Instance.new("UIGridLayout")
		gridLayout.Name = "ModifierLayout"
		gridLayout.Parent = billboardGui
		gridLayout.CellSize = UDim2.new(0.3, 0., 1, 0)
		gridLayout.CellPadding = UDim2.new(0.05, 0, 0, 0)
		gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		if modifierCategory == "Baking" then
			billboardGui.Size = UDim2.fromScale(35, 5)
			gridLayout.CellSize = UDim2.new(0.21, 0, 1, 0)
		end

		assert(billboardGui, "'billboardGui' assertion failed")
		billboardGui.Adornee = parentPart

		local connection
		--An ancestry check is required for mainly when the second windmill is purchased because it doesn't seem to appear without being disbaled then enabled.
		connection = parentPart.AncestryChanged:Connect(function(child, parent)
			billboardGui.Adornee = parentPart
			if connection then
				connection:Disconnect()
			end
		end)

		--Create parent frame for all other UI components.
		local upgradeFrame: Frame = Instance.new("Frame")
		upgradeFrame.Size = UDim2.fromScale(1, 1)
		upgradeFrame.Name = "UpgradeFrame"
		upgradeFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		upgradeFrame.BackgroundTransparency = 1
		upgradeFrame.Parent = billboardGui

		local backgroundImage: ImageLabel = Instance.new("ImageLabel")
		backgroundImage.Size = UDim2.fromScale(1, 1)
		backgroundImage.Image = "rbxassetid://10760299087"
		backgroundImage.BackgroundTransparency = 1
		backgroundImage.Parent = upgradeFrame
		--Create a UICorner object to give the frame corners.
		local uiCorner: UICorner = Instance.new("UICorner")
		uiCorner.Name = "FrameCorner"
		uiCorner.CornerRadius = UDim.new(0.2, 1)
		uiCorner.Parent = upgradeFrame
		--Create modifier cost TextButton.
		local upgradeButton: TextButton = Instance.new("TextButton")
		upgradeButton.Name = "UpgradeButton"
		upgradeButton.Size = UDim2.new(0.8, 0, 0.2, 0)
		upgradeButton.Position = UDim2.new(0.1, 0, 0.7, 0)
		upgradeButton.BackgroundColor3 = Color3.fromRGB(21, 244, 255)
		upgradeButton.BackgroundTransparency = 1
		upgradeButton.TextScaled = true
		upgradeButton.TextStrokeTransparency = 0
		upgradeButton.AutoButtonColor = true
		upgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		if StationModifierUtil.getCategory(modId) == "Rack" and StationModifierUtil.getPropertyName(modId) == "Storage" and GamepassUtil.getIfInfiniteTrayOwned(Players.LocalPlayer.UserId) then
			upgradeButton.Visible = false
		end
		if StationModifierUtil.getIfModifierExists(modId) then
			upgradeButton.Text = FormatUtil.money(StationModifierUtil.getCost(modId))
		else
			upgradeButton.Text = "?"
		end
		upgradeButton.ZIndex = 5
		upgradeButton.Parent = upgradeFrame
		--Clone the UICorner to use on the button as well.
		local uiCornerTwo = uiCorner:Clone()
		uiCornerTwo.Parent = upgradeButton
		--Create an image label to replace the button icon.
		local buttonBackgroundImage: ImageLabel = Instance.new("ImageLabel")
		buttonBackgroundImage.Name = "ButtonBackgroundImage"
		buttonBackgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonBackgroundImage.Position = UDim2.fromScale(0.5, 0.45)
		buttonBackgroundImage.Size = UDim2.fromScale(1, 1.2)
		buttonBackgroundImage.BackgroundTransparency = 1
		buttonBackgroundImage.Image = "rbxassetid://10283013700"
		buttonBackgroundImage.Parent = upgradeButton
		--Create TextLabel to show the upgrade id.
		local upgradeName: TextLabel = Instance.new("TextLabel")
		upgradeName.Size = UDim2.new(0.9, 0, 0.2, 0)
		upgradeName.Position = UDim2.new(0.05, 0, 0.1, 0)
		upgradeName.Text = StationModifierUtil.getPropertyName(modId):gsub("Recharge", "Cooldown Timer"):gsub("Storage", "Carrying Capacity") --.." "..tostring(ModifierUtil.getLevel(modId))
		upgradeName.BackgroundTransparency = 1
		upgradeName.TextScaled = true
		upgradeName.Font = Enum.Font.FredokaOne
		upgradeName.TextColor3 = Color3.fromRGB(214, 214, 214)
		upgradeName.TextStrokeTransparency = 0
		upgradeName.Parent = upgradeFrame
		--Create TextLabel to show the amount the modifier is.
		local upgradeAmount: TextLabel = Instance.new("TextLabel")
		upgradeAmount.Size = UDim2.new(0.9, 0, 0.2, 0)
		upgradeAmount.Position = UDim2.new(0.05, 0, 0.35, 0)
		if StationModifierUtil.getIfModifierExists(modId) then
			upgradeAmount.Text = FormatUtil.formatNumber(StationModifierUtil.getValue(modId, Players.LocalPlayer))
		else
			upgradeAmount.Text = "?"
		end
		upgradeAmount.BackgroundTransparency = 1
		upgradeAmount.TextScaled = true
		upgradeAmount.TextColor3 = Color3.fromRGB(214, 214, 214)
		upgradeAmount.Font = Enum.Font.FredokaOne
		upgradeAmount.TextStrokeTransparency = 0
		upgradeAmount.Parent = upgradeFrame

		--Create an icon to display the type of upgrade
		local modifierImage: ImageLabel = Instance.new("ImageLabel")
		modifierImage.Name = "ModifierIcon"
		modifierImage.Size = UDim2.fromScale(0.3, 0.3)
		modifierImage.AnchorPoint = Vector2.new(0.5, 0.5)
		modifierImage.Position = UDim2.fromScale(0.99, 0.05)
		modifierImage.BackgroundTransparency = 1
		if StationModifierUtil.getIfModifierExists(modId) then
			modifierImage.Image = StationModifierUtil.getIcon(modId)
		else
			modifierImage.Image = ""
		end
		modifierImage.Parent = upgradeFrame

		--Create TextLabel to show the upgrade id.
		local descriptionBox: TextLabel = Instance.new("TextLabel")
		descriptionBox.Name = "Description"
		descriptionBox.Size = UDim2.new(0.9, 0, 0.9, 0)
		descriptionBox.Position = UDim2.new(0.05, 0, 0.1, 0)
		-- print("MOD DESC", ModifierDescription, "CAT", modifierCategory)
		descriptionBox.Text = StationModifierUtil.getDescription(modId)
		descriptionBox.BackgroundTransparency = 0
		descriptionBox.BackgroundColor3 = Color3.fromRGB(124, 81, 66)
		descriptionBox.BorderColor3 = Color3.fromRGB(71, 55, 51)
		descriptionBox.TextScaled = true
		descriptionBox.Font = Enum.Font.FredokaOne
		descriptionBox.TextColor3 = Color3.fromRGB(214, 214, 214)
		descriptionBox.TextStrokeTransparency = 0
		descriptionBox.ZIndex = 5
		descriptionBox.Visible = false
		descriptionBox.Parent = upgradeFrame

		maid:GiveTask(modifierImage.MouseEnter:Connect(function(x, y)
			descriptionBox.Visible = true
		end))

		maid:GiveTask(modifierImage.MouseLeave:Connect(function(x, y)
			descriptionBox.Visible = false
		end))

		return billboardGui, upgradeButton, upgradeName, upgradeAmount, modifierImage, descriptionBox
	end

	local lastUpdate = 0

	NetworkUtil.onClientInvoke(GET_IF_UPGRADING, function()
		return tick() - lastUpdate > 15
	end)

	local function updateUI(paramId: string?)
		-- id = incrementId(id)

		local function updateKey(gui_key: string)
			if GUIs[gui_key] ~= nil then
				lastUpdate = tick()
				local buyConnect = GUIs[gui_key].BuyConnection
				if buyConnect then
					buyConnect:Disconnect()
				end

				local id = GUIs[gui_key].BalanceId
				local nextId = StationModifierUtil.getId(StationModifierUtil.getCategory(id), StationModifierUtil.getPropertyName(id), StationModifierUtil.getLevel(id) + 1)
				if StationModifierUtil.getIfModifierExists(nextId) then
					--Update the relevant modifier information
					GUIs[gui_key].MainGui.Enabled = true

					GUIs[gui_key].UpgradeButton.Text = FormatUtil.money(StationModifierUtil.getCost(nextId))
					GUIs[gui_key].ModifierIcon.Image = StationModifierUtil.getIcon(id)
					GUIs[gui_key].Description.Text = StationModifierUtil.getDescription(nextId)
					GUIs[gui_key].UpgradeAmount.Text = FormatUtil.formatNumber(StationModifierUtil.getValue(id, Players.LocalPlayer))

					if StationModifierUtil.getCategory(id) == "Rack" and StationModifierUtil.getPropertyName(id) == "Storage" and GamepassUtil.getIfInfiniteTrayOwned(Players.LocalPlayer.UserId) then
						GUIs[gui_key].UpgradeButton.Visible = false
					end

					-- print("Booting ", id)
					GUIs[gui_key].BuyConnection = maid:GiveTask(GUIs[gui_key].UpgradeButton.Activated:Connect(function()
						print("buying id: ", id)
						BuyModifier:FireServer(id)
						GUIs[gui_key].BalanceId = nextId
					end))
				else
					GUIs[gui_key].MainGui.Enabled = false
				end
			end
		end
		if paramId then
			updateKey(getKey(paramId))
		else
			for k, _ in pairs(GUIs) do
				updateKey(k)
			end
		end
	end

	local function setupUI(config: GuiConfig)
		local setupMaid = maid:GiveTask(Maid.new())
		local gui_key = getKey(config.Id)
		CurrentConfigs[gui_key] = config

		local id = config.Id
		local parentPart = config.Part
		-- id = incrementId(id)
		assert(parentPart, "'parentPart' assertion failed")

		-- print(" S E T U P", gui_key)
		if GUIs[gui_key] ~= nil then
			GUIs[gui_key]._Maid:Destroy()
			GUIs[gui_key] = nil
		end

		--Create the UI and get get the objects returned.
		local billboardGUI, upgradeButton, upgradeName, upgradeAmount, icon, desc = createUI(parentPart, id)

		GUIs[gui_key] = {
			_Maid = setupMaid,
			MainGui = setupMaid:GiveTask(billboardGUI),
			UpgradeButton = setupMaid:GiveTask(upgradeButton),
			UpgradeName = setupMaid:GiveTask(upgradeName),
			UpgradeAmount = setupMaid:GiveTask(upgradeAmount),
			ModifierIcon = setupMaid:GiveTask(icon),
			Description = setupMaid:GiveTask(desc),
			--Connect an activation event to the TextButton that fires the needed serverside code.(See UpdatedModifier ModuleScript)
			BuyConnection = nil,
			BalanceId = id,
		}
		updateUI(id)
	end

	maid:GiveTask(SetupModifierUI.OnClientEvent:Connect(function(parentPart: BasePart, id: string)
		setupUI({
			Part = parentPart,
			Id = id,
		})
	end))
	for key, config in pairs(CurrentConfigs) do
		-- print("build prior: ", key)
		setupUI(config)
	end
	maid:GiveTask(UpdateModifier.OnClientEvent:Connect(updateUI))
	maid:GiveTask(MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr: Player, gamepassId: number, wasPurchased: boolean)
		if plr.UserId == Players.LocalPlayer.UserId and wasPurchased then
			updateUI()
		end
	end))
	maid:GiveTask(modifierFolder.Destroying:Connect(function()
		-- print("rebooting")
		maid:DoCleaning()
		task.wait(1)
		boot(playerGui, maid)
	end))
end

boot(Players.LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui, Maid.new())
