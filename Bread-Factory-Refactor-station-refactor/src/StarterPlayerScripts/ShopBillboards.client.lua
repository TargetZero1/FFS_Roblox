--!strict
-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
-- Modules
local TextUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TextUtil")) --reference to local player
local GamePassDescriptions = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("GamePassDescription"))
local CurrencyDescriptions = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("CurrencyDescription"))
-- local CosmeticDescriptions = require(
-- 	game:GetService("ReplicatedStorage")
-- 		:WaitForChild("Shared")
-- 		:WaitForChild("Data")
-- 		:WaitForChild("Cosmetic")
-- 		:WaitForChild("CosmeticThemesDescription")
-- )
local ReferenceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
-- Types
-- Constants
-- Variables
local DynamicCashActivated = false
local DynamicCashButtons = {}
local NormalCashButtons = {}

-- References
local Player = Players.LocalPlayer
-- local MainGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui")
-- local PurchaseCosmeticsPopUp = ReferenceUtil.getChild(MainGui, "PurchaseCosmeticsPopUp") :: Frame
-- local ConfirmButton = ReferenceUtil.getChild(PurchaseCosmeticsPopUp, "PurchaseConfirmButton") :: TextButton
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
-- local SetupEvent = RemoteEvents:WaitForChild("SetupShopSurfaces") :: RemoteEvent
local HighestBreadRackNotifier = RemoteEvents:WaitForChild("HighestBreadRackNotify") :: RemoteEvent
-- local CosmeticPurchaseEvent = RemoteEvents:WaitForChild("CosmeticPurchaseEvent") :: RemoteEvent
-- local CosmeticChoiceEventFolder = RemoteEvents:WaitForChild("CosmeticChoiceEvent")
-- local CosmeticChangeEvent = CosmeticChoiceEventFolder:WaitForChild("CosmeticChoice") :: RemoteEvent
local GetHighestBreadRackValue = RemoteFunctions:WaitForChild("GetHighestBreadRackValue") :: RemoteFunction
-- local CosmeticEvent = RemoteFunctions:WaitForChild("CosmeticEvent") :: RemoteFunction

local _getChild = ReferenceUtil.getChild
--function for prompting the player to buy a gamepass
function buyGamepass(id: number)
	--check if player already has gamepass
	local hasPass = false
	pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, id)
	end)

	--if they do not then prompt purchase
	if not hasPass then
		--pcall(function()
		--pcall(function()
		--local productInfo = MarketplaceService:GetProductInfo(Id, Enum.InfoType.GamePass)
		--midas:SetState("Gamepass/Name", function()
		--return productInfo.Name
		--end)
		--midas:SetState("Gamepass/Cost", function()
		--return productInfo.PriceInRobux
		--end)
		--midas:SetState("Gamepass/Id", function()
		--return Id
		--end)
		--end)
		--end)
		--midas:Fire("Gamepass/Prompt")
		MarketplaceService:PromptGamePassPurchase(Player, id)
	end
end

--function for prompting the player to buy a developer product
function buyDeveloperItem(id: number)
	--prompt the player to buy the developer product
	--pcall(function()
	--pcall(function()
	--local productInfo = MarketplaceService:GetProductInfo(Id, Enum.InfoType.Product)
	--midas:SetState("Product/Name", function()
	--return productInfo.Name
	--end)
	--midas:SetState("Product/Cost", function()
	--return productInfo.PriceInRobux
	--end)
	--midas:SetState("Product/Id", function()
	--return Id
	--end)
	--end)
	--midas:Fire("Product/Prompt")
	--end)

	MarketplaceService:PromptProductPurchase(Player, id)
end
--Update the CashGUI based on the new amount sent.
function updateCashGUI(newAmount: number)
	if not DynamicCashActivated then
		if newAmount >= 100 then
			--Make all dynamic buttons visible
			for i = 1, #DynamicCashButtons do
				DynamicCashButtons[i].Visible = true
			end
			--Make all normal buttons invisible
			for i = 1, #NormalCashButtons do
				NormalCashButtons[i].Visible = false
			end
			DynamicCashActivated = true
		end
	elseif DynamicCashActivated then
		if newAmount < 100 then
			--Make all normal buttons visible
			for i = 1, #NormalCashButtons do
				NormalCashButtons[i].Visible = true
			end
			--Make all dynamic buttons invisible
			for i = 1, #DynamicCashButtons do
				DynamicCashButtons[i].Visible = false
			end
			DynamicCashActivated = false
		end
	end

	if DynamicCashActivated then
		for i = 1, #DynamicCashButtons do
			local value: number? = tonumber(string.match(DynamicCashButtons[i].name, "%d+") or "not a number lol")
			if value then
				DynamicCashButtons[i].CurrencyNameLabel.Text = TextUtils.applySuffix((newAmount * value))
			end
		end
	end
end

--Setup cash GUI
function setupCashGUI(parentPart: BasePart)
	--Create SurfaceGUI to attach to script parent.
	local surfaceGUI = Instance.new("SurfaceGui")
	surfaceGUI.Name = "GamePassSurfaceGUI"
	surfaceGUI.Parent = parentPart
	surfaceGUI.ResetOnSpawn = false
	surfaceGUI.Face = Enum.NormalId.Front

	local cashFrame = Instance.new("Frame")
	cashFrame.Parent = surfaceGUI
	cashFrame.Position = UDim2.fromScale(0, -0.1)
	cashFrame.Size = UDim2.fromScale(1, 1)
	cashFrame.BackgroundTransparency = 1

	local UIGridLayout = Instance.new("UIGridLayout")
	UIGridLayout.Parent = cashFrame
	UIGridLayout.CellSize = UDim2.fromScale(0.3, 0.47)
	UIGridLayout.CellPadding = UDim2.fromScale(0.05, 0.02)
	UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

	for gamepass, details: CurrencyDescriptions.CurrentUpgradeType in pairs(CurrencyDescriptions) do
		if gamepass then
			local currencyButton = Instance.new("ImageButton")
			currencyButton.Image = ""
			currencyButton.Name = details["Name"] .. "Button"
			currencyButton.Parent = cashFrame
			currencyButton.BackgroundTransparency = 1
			currencyButton.LayoutOrder = details["LayoutOrder"]

			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Parent = currencyButton
			imageLabel.Size = UDim2.fromScale(1, 1)
			imageLabel.Image = details["Thumbnail"]
			imageLabel.Name = "CashImage"
			imageLabel.BackgroundTransparency = 1

			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.fromScale(1, 0.2)
			textLabel.Position = UDim2.fromScale(0, 0.7)
			textLabel.Parent = currencyButton
			textLabel.Name = "CurrencyNameLabel"
			textLabel.BackgroundTransparency = 1
			textLabel.TextScaled = true
			textLabel.Font = Enum.Font.FredokaOne
			textLabel.TextStrokeTransparency = 0
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

			textLabel.Text = details["Name"]

			currencyButton.Activated:Connect(function()
				buyDeveloperItem(details["ID"])
			end)

			if string.find(details["Name"], "Dynamic") then
				currencyButton.Visible = false
				table.insert(DynamicCashButtons, currencyButton)
			else
				table.insert(NormalCashButtons, currencyButton)
			end
		end
	end
end

--Setup the GUI for gamepasses.
function setupGamepassGUI(parentPart: BasePart)
	--Create SurfaceGUI to attach to script parent.
	local surfaceGUI = Instance.new("SurfaceGui")
	surfaceGUI.Name = "GamePassSurfaceGUI"
	surfaceGUI.Parent = parentPart
	surfaceGUI.ResetOnSpawn = false
	surfaceGUI.Face = Enum.NormalId.Front

	local gamepassFrame = Instance.new("Frame")
	gamepassFrame.Parent = surfaceGUI
	gamepassFrame.Position = UDim2.fromScale(0, -0.2)
	gamepassFrame.Size = UDim2.fromScale(1, 1)
	gamepassFrame.BackgroundTransparency = 1

	local UIGridLayout = Instance.new("UIGridLayout")
	UIGridLayout.Parent = gamepassFrame
	UIGridLayout.CellSize = UDim2.fromScale(0.3, 0.47)
	UIGridLayout.CellPadding = UDim2.fromScale(0.05, 0.02)
	UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

	for gamepass, details: GamePassDescriptions.GamepassDescription in pairs(GamePassDescriptions) do
		if gamepass then
			local gamepassButton = Instance.new("ImageButton")
			gamepassButton.HoverImage = details["HoverThumbnail"]
			gamepassButton.Image = details["Thumbnail"]
			gamepassButton.Name = details["Name"] .. "Button"
			gamepassButton.Parent = gamepassFrame
			gamepassButton.BackgroundTransparency = 1
			gamepassButton.LayoutOrder = details["LayoutOrder"]

			gamepassButton.Activated:Connect(function()
				buyGamepass(details["ID"])
			end)
		end
	end
end

--Setup the GUI for Cosmetics
-- function setupCosmeticsGUI(parentPart: BasePart)
-- 	local surfaceGUI = Instance.new("SurfaceGui")
-- 	surfaceGUI.Name = "GamePassSurfaceGUI"
-- 	surfaceGUI.Parent = parentPart
-- 	surfaceGUI.ResetOnSpawn = false
-- 	surfaceGUI.Face = Enum.NormalId.Front

-- 	local gamepassFrame = Instance.new("Frame")
-- 	gamepassFrame.Parent = surfaceGUI
-- 	gamepassFrame.Position = UDim2.fromScale(0, -0.2)
-- 	gamepassFrame.Size = UDim2.fromScale(1, 1)
-- 	gamepassFrame.BackgroundTransparency = 1

-- 	local UIGridLayout = Instance.new("UIGridLayout")
-- 	UIGridLayout.Parent = gamepassFrame
-- 	UIGridLayout.CellSize = UDim2.fromScale(0.3, 0.47)
-- 	UIGridLayout.CellPadding = UDim2.fromScale(0.05, 0.02)
-- 	UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
-- 	UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
-- 	UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 	for gamepass, details: CosmeticDescriptions.CosmeticData in pairs(CosmeticDescriptions) do
-- 		if gamepass then
-- 			local gamepassButton = Instance.new("ImageButton")
-- 			gamepassButton.HoverImage = details["HoverThumbnail"]
-- 			gamepassButton.Image = details["Thumbnail"]
-- 			gamepassButton.Name = details["Name"] .. "Button"
-- 			gamepassButton.Parent = gamepassFrame
-- 			gamepassButton.BackgroundTransparency = 1
-- 			gamepassButton.LayoutOrder = details["LayoutOrder"]

-- 			gamepassButton.Activated:Connect(function()
-- 				--purchase from rebirth

-- 				--checking if the cosmetic is unlocked or not yet
-- 				local CosmeticUnlock = CosmeticEvent:InvokeServer(details["Name"], details["LayoutOrder"])

-- 				print(CosmeticUnlock)
-- 				if CosmeticUnlock and CosmeticUnlock.Unlocked == false then -- if it's locked
-- 					(_getChild(PurchaseCosmeticsPopUp, "Cost") :: TextLabel).Text = "Rebirths Required: "
-- 						.. tostring(details["Cost"] or "N/A");
-- 					(_getChild(PurchaseCosmeticsPopUp, "Description") :: TextLabel).Text = details["Description"]
-- 					ConfirmButton:SetAttribute("ChosenTheme", details["Name"])
-- 					PurchaseCosmeticsPopUp.Visible = true
-- 				else
-- 					CosmeticChangeEvent:FireServer(
-- 						"Theme",
-- 						"9@PmmbLY9spRdz5NXrH",
-- 						"Theme" .. tostring(details["LayoutOrder"] or 0)
-- 					)
-- 				end
-- 				--buyGamepass(details["ID"])
-- 			end)
-- 		end
-- 	end
-- end

HighestBreadRackNotifier.OnClientEvent:Connect(function(newAmount)
	updateCashGUI(newAmount)
end)

--Setting up cosmeticsPopUp ConfirmButton

-- ConfirmButton.MouseButton1Down:Connect(function()
-- 	--variables
-- 	local chosenTheme = ConfirmButton:GetAttribute("ChosenTheme")
-- 	local details = CosmeticDescriptions[chosenTheme]

-- 	--initialize
-- 	assert(chosenTheme, "Theme not detected!")

-- 	--manage the data to unlock the theme
-- 	CosmeticPurchaseEvent:FireServer("Theme", details["LayoutOrder"], details["Cost"])

-- 	--check if it succeeded or failed to unlock
-- 	local cosmeticUnlock = CosmeticEvent:InvokeServer(details["Name"], details["LayoutOrder"])

-- 	if cosmeticUnlock and cosmeticUnlock.Unlocked == true then -- if it succeeded then change the theme
-- 		PurchaseCosmeticsPopUp.Visible = false
-- 		CosmeticChangeEvent:FireServer("Theme", "9@PmmbLY9spRdz5NXrH", "Theme" .. tostring(details["LayoutOrder"] or 0))
-- 	end
-- end)

function bootTemplate(tycoonSpawn: Part)
	local tycoonTemplate = _getChild(tycoonSpawn, "Template") :: Model
	local gamepassPart = _getChild(tycoonTemplate, "ShopGamepassGUIPart") :: BasePart
	local cashPart = _getChild(tycoonTemplate, "ShopCashGUIPart") :: BasePart
	-- local cosmeticPart = _getChild(tycoonSpawn, "CosmeticsGUIPart") :: BasePart
	print("SET UP THE GUI!")
	setupGamepassGUI(gamepassPart)
	setupCashGUI(cashPart)

	tycoonSpawn.DescendantAdded:Connect(function(inst: Instance)
		if inst:IsA("BasePart") then
			if inst.Name == "ShopGamepassGUIPart" then
				setupGamepassGUI(inst)
			elseif inst.Name == "ShopCashGUIPart" then
				setupCashGUI(inst)
			end
		end
	end)
	-- setupCosmeticsGUI(cosmeticPart)

	task.spawn(function()
		if GetHighestBreadRackValue:InvokeServer() >= 100 then
			updateCashGUI(GetHighestBreadRackValue:InvokeServer())
		end
	end)
end

for i, claimPart in ipairs(workspace:WaitForChild("TycoonSpawns"):GetChildren()) do
	if claimPart:IsA("Part") then
		bootTemplate(claimPart)
	end
end
