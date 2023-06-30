--!strict
-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
-- Modules
local TextUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TextUtil"))
local ShopDescriptionTable = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("CurrencyDescription")) --contains all coin item descriptions
local DonateDescriptionTable = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("DonationDescription")) --contains all donation item descriptions
local GamepassDescriptionTable = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("GamePassDescription")) --contains all gamepass item descriptions
-- local BreadDescriptionTable = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("BreadUpgradesDescription")) --contains all bread upgrades item descriptions

-- Types
type CosmeticData = DonateDescriptionTable.DonationUpgradeType
-- Constants
-- Variables
-- References
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui") :: PlayerGui
local Shop = PlayerGui:WaitForChild("MainGui") :: ScreenGui
local MainShopFrame = Shop:WaitForChild("MainShopFrame") :: Frame
local CurrencyFrame = MainShopFrame:WaitForChild("CurrencyFrame") :: Frame
local ShopPageScroll = MainShopFrame:WaitForChild("ShopPageScroll") :: Frame
local UIElements = ReplicatedStorage:WaitForChild("UIElements") :: Frame

local BreadShop = Shop:WaitForChild("BreadCoinsShop") :: Frame
local PopUp = MainShopFrame:WaitForChild("PurhchaseConfirmPopUp") :: Frame
local ShopPageLayout = ShopPageScroll:WaitForChild("UIPageLayout") :: UIPageLayout
local BreadCoinsButton = MainShopFrame:WaitForChild("Tab0") :: ImageButton
local DonateButton = MainShopFrame:WaitForChild("Tab1") :: ImageButton
local GamepassButton = MainShopFrame:WaitForChild("Tab2") :: ImageButton
local CoinsButton = MainShopFrame:WaitForChild("Tab3") :: ImageButton
local RebirthButton = MainShopFrame:WaitForChild("Tab4") :: ImageButton
-- local BreadButton = MainShopFrame:WaitForChild("Tab5") :: ImageButton
-- local GiftingButton = MainShopFrame:WaitForChild("Tab6") :: ImageButton
local XButton = MainShopFrame:WaitForChild("XButton") :: ImageButton
local MoreCoinsButton = CurrencyFrame:WaitForChild("MoreCoinsButton") :: ImageButton
local PlayerUI = PlayerGui:WaitForChild("ScreenGui") :: ScreenGui
local CurrencyUI = PlayerUI:WaitForChild("CurrencyUI") :: Frame
local MoreCoinsUIButton = CurrencyUI:WaitForChild("CurrencyButton") :: ImageButton
local CurrencyTemplateButton = UIElements:WaitForChild("CurrencyButtonTemplate") :: ImageButton
local DonateTemplateButton = UIElements:WaitForChild("DonateButtonTemplate") :: ImageButton

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local NeedMoneyEvent = RemoteEvents:WaitForChild("NeedMoney") :: RemoteEvent
local GetHighestBreadRackValue = RemoteFunctions:WaitForChild("GetHighestBreadRackValue") :: RemoteFunction

local ShopPageScrollCoins = ShopPageScroll:WaitForChild("Coins"):WaitForChild("Frame") :: Frame
local ShopPageScrollDonatePage = ShopPageScroll:WaitForChild("DonatePage"):WaitForChild("Frame") :: Frame
-- local ShopPageScrollRebirthUpgrades = ShopPageScroll:WaitForChild("RebirthUpgrades"):WaitForChild("Frame") :: Frame
local ShopPageScrollGamepassPage = ShopPageScroll:WaitForChild("GamepassPage"):WaitForChild("Frame") :: Frame
-- local ShopPageScrollBreadUpgrades = ShopPageScroll:WaitForChild("BreadUpgrades"):WaitForChild("Frame") :: Frame
-- local ShopPageScrollGiftingPage = ShopPageScroll:WaitForChild("GiftingPage"):WaitForChild("Frame") :: Frame

function playSound(soundName: string)
	local audio = game:GetService("SoundService"):FindFirstChild(soundName) :: Sound?
	if audio then
		if not audio.IsLoaded then
			audio.Loaded:Wait()
		end

		audio:Play()
	end
end

--function for greying out all inactive tab buttons
function greyButtons()
	BreadCoinsButton.ImageColor3 = Color3.new(122 / 255, 122 / 255, 122 / 255)
	DonateButton.ImageColor3 = Color3.new(122 / 255, 122 / 255, 122 / 255)
	GamepassButton.ImageColor3 = Color3.new(122 / 255, 122 / 255, 122 / 255)
	CoinsButton.ImageColor3 = Color3.new(122 / 255, 122 / 255, 122 / 255)
	RebirthButton.ImageColor3 = Color3.new(122 / 255, 122 / 255, 122 / 255)
	-- BreadButton.ImageColor3 = Color3.new(122/255, 122/255, 122/255)
	-- GiftingButton.ImageColor3 = Color3.new(122/255, 122/255, 122/255)
end

--function for prompting the player to buy a gamepass
function buyGamepass(id: number)
	--check if player already has gamepass
	local hasPass = false
	local _success, _message = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, id)
	end)

	--if they do not then prompt purchase
	if not hasPass then
		--pcall(function()
		--	pcall(function()
		--		local productInfo = MarketplaceService:GetProductInfo(Id, Enum.InfoType.GamePass)
		--		--midas:SetState("Gamepass/Name", function()
		--			--return productInfo.Name
		--		--end)
		--		--midas:SetState("Gamepass/Cost", function()
		--			--return productInfo.PriceInRobux
		--		--end)
		--		--midas:SetState("Gamepass/Id", function()
		--			--return Id
		--		--end)
		--	end)
		--end)
		--midas:Fire("Gamepass/Prompt")

		MarketplaceService:PromptGamePassPurchase(Player, id)
	end
end

--function for prompting the player to buy a developer product
function buyDeveloperItem(id: number)
	--prompt the player to buy the developer product
	--pcall(function()
	--	local productInfo = MarketplaceService:GetProductInfo(Id, Enum.InfoType.Product)
	--	--midas:SetState("Product/Name", function()
	--		--return productInfo.Name
	--	--end)
	--	--midas:SetState("Product/Cost", function()
	--		--return productInfo.PriceInRobux
	--	--end)
	--	--midas:SetState("Product/Id", function()
	--		--return Id
	--	--end)
	--end)
	--midas:Fire("Product/Prompt")

	MarketplaceService:PromptProductPurchase(Player, id)
end

--function for showing the pop up frame and setting the data
function displayPopUp(details: CosmeticData, typeIndex: number?)
	--display correct buying option based on product

	if typeIndex == 0 then
		buyGamepass(details["ID"])
	else
		buyDeveloperItem(details["ID"])
	end
	--Just commenting this out in case they change their mind on which description to go with.
	--if string.find(details["Name"], "Dynamic") then
	--	--Set the description to actual value.
	--	local highestValue = GetHighestBreadRackValue:InvokeServer()
	--	local value = string.match(details["Name"], "%d+")
	--	value = tonumber(value)
	--	local finalValue = highestValue * value
	--	PopUp.Description.Text = "Get "..finalValue.. "("..value.." x Bread Value) Cash."
	--else
	--change text to match item description
	--PopUp.Description.Text = details["Description"]
	--end

	----change text to match item description
	--PopUp.Description.Text = details["Description"]

	----change image to match item image
	--PopUp.Image.Image = details["Thumbnail"]

	----make pop up visible
	--PopUp.Visible = true

	----wait for player to click confirm button
	--PopUp.PurchaseConfirmButton.Activated:Connect(function()
	--	--trigger the sound effect
	--	PlaySound("MoneySound")

	--end)
end

--function for showing the pop up frame and setting the data
-- function displayGiftPopUp(details: CosmeticData)
-- 	--display correct buying option based on product
-- 	buyDeveloperItem(details["ServerID"] or details["ID"])
-- end

--function for creating all the items in this tab of the shop
--To create more pages of content simply duplicate this function and change the Parent
function createCoinButtons(descriptionTable: { [string]: CosmeticData })
	--loop through all items in the table and create a new button for them
	for name, details in pairs(descriptionTable) do
		--set the new button layout to match a saved template
		local newButton = CurrencyTemplateButton:Clone()
		--give the button an appropriate name
		newButton.Name = name .. " Button"
		--reparent the button to the correct page
		newButton.Parent = ShopPageScrollCoins

		--assign the correct data for this button, with data from the module script
		newButton.LayoutOrder = details["LayoutOrder"];
		(newButton:WaitForChild("CurrencyThumbnail") :: ImageLabel).Image = details["Thumbnail"];
		(newButton:WaitForChild("CurrencyNameLabel") :: TextLabel).Text = details["Name"]

		--wait for player to click the new button
		newButton.Activated:Connect(function()
			--have the pop up appear with the correct data for this item
			displayPopUp(details, 1)
		end)

		if string.find(name, "Dynamic") then
			newButton.Visible = false
		end
	end
end

--function for creating all the items in this tab of the shop
function createDonationButtons(descriptionTable: { [string]: CosmeticData })
	--loop through all items in the table and create a new button for them
	for name, details in pairs(descriptionTable) do
		--set the new button layout to match a saved template
		local newButton = DonateTemplateButton:Clone()
		--give the button an appropriate name
		newButton.Name = name .. " Button"
		--reparent the button to the correct page
		newButton.Parent = ShopPageScrollDonatePage

		--assign the correct data for this button, with data from the module script
		newButton.LayoutOrder = details["LayoutOrder"]
		newButton.Image = details["Thumbnail"]
		newButton.HoverImage = details["Thumbnail"] or ""
		newButton.PressedImage = details["Thumbnail"];
		(newButton:WaitForChild("DonateNameLabel") :: TextLabel).Text = details["Name"]

		--wait for player to click the new button
		newButton.Activated:Connect(function()
			--have the pop up appear with the correct data for this item
			displayPopUp(details, 1)
		end)
	end
end

--function for creating all the items in this tab of the shop
-- function createRebirthButtons(descriptionTable: {[string]: CosmeticData})
-- 	--loop through all items in the table and create a new button for them
-- 	for name, details in pairs(descriptionTable) do
-- 		--set the new button layout to match a saved template
-- 		local newButton = DonateTemplateButton:Clone()
-- 		--give the button an appropriate name
-- 		newButton.Name =  name.." Button"
-- 		--reparent the button to the correct page
-- 		newButton.Parent = ShopPageScrollRebirthUpgrades

-- 		--assign the correct data for this button, with data from the module script
-- 		newButton.LayoutOrder = details["LayoutOrder"]
-- 		newButton.Image = details["Thumbnail"]
-- 		newButton.HoverImage = details["Thumbnail"] or ""
-- 		newButton.PressedImage = details["Thumbnail"];
-- 		(newButton:WaitForChild("DonateNameLabel") :: TextLabel).Text = details["Name"]

-- 		--wait for player to click the new button
-- 		newButton.Activated:Connect(function()
-- 			--have the pop up appear with the correct data for this item
-- 			displayPopUp(details,1)
-- 		end)
-- 	end
-- end

--function for creating all the items in this tab of the shop
function createGamepassButtons(descriptionTable: { [string]: CosmeticData })
	--loop through all cosmetics and create buttons for them
	for name, details in pairs(descriptionTable) do
		--set the new button layout to match a saved template
		local newButton = DonateTemplateButton:Clone()
		--give the button an appropriate name
		newButton.Name = name .. " Button"
		--reparent the button to the correct page
		newButton.Parent = ShopPageScrollGamepassPage

		--assign the correct data for this button, with data from the module script
		newButton.LayoutOrder = details["LayoutOrder"]
		newButton.Image = details["Thumbnail"]
		newButton.HoverImage = details["Thumbnail"] or ""
		newButton.PressedImage = details["Thumbnail"];
		(newButton:WaitForChild("DonateNameLabel") :: TextLabel).Text = details["Name"]
		--wait for player to click the new button
		newButton.Activated:Connect(function()
			--have the pop up appear with the correct data for this item
			displayPopUp(details, 0)
		end)
	end
end

-- --function for creating all the items in this tab of the shop
-- function createBreadUpgradeButtons(descriptionTable: {[string]: CosmeticData})
-- 	--loop through all cosmetics and create buttons for them
-- 	for name, details in pairs(descriptionTable) do
-- 		--set the new button layout to match a saved template
-- 		local newButton = DonateTemplateButton:Clone()
-- 		--give the button an appropriate name
-- 		newButton.Name =  name.." Button"
-- 		--reparent the button to the correct page
-- 		newButton.Parent = ShopPageScrollBreadUpgrades

-- 		--assign the correct data for this button, with data from the module script
-- 		newButton.LayoutOrder = details["LayoutOrder"]
-- 		newButton.Image = details["Thumbnail"]
-- 		newButton.HoverImage = details["Thumbnail"] or ""
-- 		newButton.PressedImage = details["Thumbnail"];
-- 		(newButton:WaitForChild("DonateNameLabel") :: TextLabel).Text = details["Name"]
-- 		--wait for player to click the new button
-- 		newButton.Activated:Connect(function()
-- 			--have the pop up appear with the correct data for this item
-- 			displayPopUp(details)
-- 		end)
-- 	end
-- end

-- --function for creating all the items in this tab of the shop
-- function createBreadGiftButtons(descriptionTable: {[string]: CosmeticData})
-- 	--loop through all cosmetics and create buttons for them
-- 	for name, details in pairs(descriptionTable) do
-- 		--set the new button layout to match a saved template
-- 		local newButton = DonateTemplateButton:Clone()
-- 		--give the button an appropriate name
-- 		newButton.Name =  name.." Button"
-- 		--reparent the button to the correct page
-- 		newButton.Parent = ShopPageScrollGiftingPage

-- 		--assign the correct data for this button, with data from the module script
-- 		newButton.LayoutOrder = details["LayoutOrder"]
-- 		newButton.Image = details["Thumbnail"]
-- 		newButton.HoverImage = details["Thumbnail"] or ""
-- 		newButton.PressedImage = details["Thumbnail"];
-- 		(newButton:WaitForChild("DonateNameLabel") :: TextLabel).Text = details["Name"]

-- 		--wait for player to click the new button
-- 		newButton.Activated:Connect(function()
-- 			--have the pop up appear with the correct data for this item
-- 			displayGiftPopUp(details)
-- 		end)
-- 	end
-- end

--in order to create the buttons in the shop you must call the respective function and give it the table from the module script
--To create more pages just duplicate the call below and pass a new module script with data
createCoinButtons(ShopDescriptionTable :: any)
createDonationButtons(DonateDescriptionTable)
createGamepassButtons(GamepassDescriptionTable)
-- createBreadUpgradeButtons(BreadDescriptionTable :: any)
-- createGamepassButtons(BreadDescriptionTable :: any)
--Button Prompts

--function to run when player clicks the X button
XButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	--hide the pop up window
	PopUp.Visible = false
	ShopPageLayout:JumpToIndex(4) --changes page back to Donate
	greyButtons()
	DonateButton.ImageColor3 = Color3.new(255, 255, 255)
end)

--display bread coins shop when clicked
BreadCoinsButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")
	BreadShop.Visible = true
	MainShopFrame.Visible = false
	--hide the pop up window
	PopUp.Visible = false
	ShopPageLayout:JumpToIndex(4) --changes page back to Donate
	greyButtons()
	DonateButton.ImageColor3 = Color3.new(255, 255, 255)
end)

--function to run when player clicks the Donate button
DonateButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	greyButtons()
	DonateButton.ImageColor3 = Color3.new(255, 255, 255)
	ShopPageLayout:JumpToIndex(5) --changes page to Donate
end)

--function to run when player clicks the Gamepass button
GamepassButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	greyButtons()
	GamepassButton.ImageColor3 = Color3.new(255, 255, 255)
	ShopPageLayout:JumpToIndex(2) --changes page to Gamepass
end)

--function to run when player clicks the Coins button
CoinsButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	greyButtons()
	CoinsButton.ImageColor3 = Color3.new(255, 255, 255)
	local highestValue = GetHighestBreadRackValue:InvokeServer()
	if highestValue >= 100 then
		for _, child in ipairs(ShopPageScrollCoins:GetChildren()) do
			if child:IsA("ImageButton") then
				if string.find(child.Name, "Dynamic") then
					child.Visible = true
					local value = string.match(child.Name, "%d+")
					local numValue = assert(tonumber(value));
					(child:WaitForChild("CurrencyNameLabel") :: TextLabel).Text = TextUtils.applySuffix((highestValue * numValue))
				else
					child.Visible = false
				end
			end
		end
	end
	ShopPageLayout:JumpToIndex(1) --changes page to Coins
end)

--function to run when player clicks the Coins button
MoreCoinsButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	greyButtons()
	CoinsButton.ImageColor3 = Color3.new(255, 255, 255)
	ShopPageLayout:JumpToIndex(1) --changes page to Coins
end)

--function to run when player clicks the Coins button
MoreCoinsUIButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	MainShopFrame.Visible = true
	greyButtons()
	CoinsButton.ImageColor3 = Color3.new(255, 255, 255)
	ShopPageLayout:JumpToIndex(1) --changes page to Coins
end)

--function to run when player clicks the Rebirth button
RebirthButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	greyButtons()
	RebirthButton.ImageColor3 = Color3.new(255, 255, 255)
	ShopPageLayout:JumpToIndex(2) --changes page to rebirths
end)

--function to run when player clicks the bread upgrade button
-- BreadButton.Activated:Connect(function()
-- 	--trigger the sound effect
-- 	playSound("DropperSound")

-- 	greyButtons()
-- 	BreadButton.ImageColor3 = Color3.new(255, 255, 255)
-- 	ShopPageLayout:JumpToIndex(4) --changes page to bread upgrades
-- end)

-- --Function to run when player click the gifting button
-- GiftingButton.Activated:Connect(function()
-- 	playSound("DropperSound")
-- 	greyButtons()
-- 	GiftingButton.ImageColor3 = Color3.new(255, 255, 255)
-- 	ShopPageLayout:JumpToIndex(3)

-- end)

NeedMoneyEvent.OnClientEvent:Connect(function()
	--trigger the sound effect
	playSound("MoneySound")

	MainShopFrame.Visible = true
	greyButtons()
	CoinsButton.ImageColor3 = Color3.new(255, 255, 255)
	ShopPageLayout:JumpToIndex(1) --changes page to Coins
end)
