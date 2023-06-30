--!strict
-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
-- Modules
local BackgroundsDescriptionTable = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Cosmetic"):WaitForChild("CosmeticBackgroundDescription")) --contains all backgrounds item descriptions
local LogosDescriptionTable = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Cosmetic"):WaitForChild("CosmeticLogosDescription")) --contains all backgrounds item descriptions
local ThemesDescriptionTable = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Cosmetic"):WaitForChild("CosmeticThemesDescription")) --contains all backgrounds item descriptions
local VFXsDescriptionTable = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Cosmetic"):WaitForChild("CosmeticVFXsDescription")) --contains all backgrounds item descriptions
local BreadCoinsDescriptionTable = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Cosmetic"):WaitForChild("BreadCoinsDescription")) --contains all backgrounds item descriptions

-- Types
type CosmeticData = LogosDescriptionTable.CosmeticData
-- Constants
-- Variables
local TimeOfLastPurchase = os.time()
-- References
local Player = Players.LocalPlayer
local Shop = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
local BreadCoinsShop = Shop:WaitForChild("BreadCoinsShop")
local MainShop = Shop:WaitForChild("MainShopFrame") :: Frame
local RebirthStats = Player:WaitForChild("RebirthStats")
local PopUp = Shop:WaitForChild("BreadCoinsShop"):WaitForChild("PurhchaseConfirmPopUp") :: Frame
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local CosmeticEvent = RemoteFunctions:WaitForChild("CosmeticEvent") :: RemoteFunction
local CosmeticPurchaseEvent = RemoteEvents:WaitForChild("CosmeticPurchaseEvent") :: RemoteEvent
local UIElements = ReplicatedStorage:WaitForChild("UIElements")
local TemplateButton = UIElements:WaitForChild("DonateButtonTemplate") :: ImageButton
-- local TemplateBreadCoinsButton = UIElements:WaitForChild("DonateButtonTemplate")
local ShopPageScroll = BreadCoinsShop:WaitForChild("ShopPageScroll") :: ScrollingFrame
local ShopPageScrollVFX = ShopPageScroll:WaitForChild("VFX"):WaitForChild("Frame") :: Frame
local ShopPageScrollBackgrounds = ShopPageScroll:WaitForChild("Backgrounds"):WaitForChild("Frame") :: Frame
local ShopPageScrollBreadCoins = ShopPageScroll:WaitForChild("BreadCoins"):WaitForChild("Frame") :: Frame
local ShopPageScrollLogos = ShopPageScroll:WaitForChild("Logos"):WaitForChild("Frame") :: Frame
local ShopPageScrollThemes = ShopPageScroll:WaitForChild("Themes"):WaitForChild("Frame") :: Frame
local ShopPageLayout = ShopPageScroll:WaitForChild("UIPageLayout") :: UIPageLayout
local BackgroundsButton = BreadCoinsShop:WaitForChild("Tab1") :: ImageButton
local LogosButton = BreadCoinsShop:WaitForChild("Tab2") :: ImageButton
local ThemesButton = BreadCoinsShop:WaitForChild("Tab3") :: ImageButton
local VFXsButton = BreadCoinsShop:WaitForChild("Tab4") :: ImageButton
local BreadCoinsButton = BreadCoinsShop:WaitForChild("Tab5") :: ImageButton
local XButton = BreadCoinsShop:WaitForChild("XButton") :: ImageButton
local RebirthCoinsRemaining = RebirthStats:WaitForChild("RebirthCoinsRemaining") :: NumberValue
-- local RebirthCoinsSpent = RebirthStats:WaitForChild("RebirthCoinsSpent") :: NumberValue
local PopUpDescription = PopUp:WaitForChild("Description") :: TextLabel
local PopUpCost = PopUp:WaitForChild("Cost") :: TextLabel
local PopUpImage = PopUp:WaitForChild("Image") :: ImageLabel
local PopUpPurchaseConfirmButton = PopUp:WaitForChild("PurchaseConfirmButton") :: ImageButton
-- Class
function playSound(soundName)
	local audio = game:GetService("SoundService"):FindFirstChild(soundName) :: Sound?
	if audio then
		if not audio.IsLoaded then
			audio.Loaded:Wait()
		end

		audio:Play()
	end
end

--function for greying out all inactive tab buttons
function setGreyButtons()
	BackgroundsButton.ImageColor3 = Color3.new(122 / 255, 122 / 255, 122 / 255)
	LogosButton.ImageColor3 = Color3.new(122 / 255, 122 / 255, 122 / 255)
	ThemesButton.ImageColor3 = Color3.new(122 / 255, 122 / 255, 122 / 255)
	VFXsButton.ImageColor3 = Color3.new(122 / 255, 122 / 255, 122 / 255)
	BreadCoinsButton.ImageColor3 = Color3.new(122 / 255, 122 / 255, 122 / 255)
end

--function for prompting the player to buy a developer product
function buyDeveloperItem(id: number)
	--prompt the player to buy the developer product
	MarketplaceService:PromptProductPurchase(Player, id)
end

--function for showing the pop up frame and setting the data
function displayPopUp(details: CosmeticData)
	--variable to prevent multi-click event fires
	local firstClick = true
	--get the players current bread coins
	--check RebirthStats not invalid

	--change text to match item description
	PopUpDescription.Text = details["Description"]
	PopUpCost.Text = "Cost: " .. details["Cost"]

	--change image to match item image
	PopUpImage.Image = details["Thumbnail"]

	--make pop up visible
	PopUp.Visible = true

	--ping server to check if cosmetic is already purchased
	local CosmeticUnlock = CosmeticEvent:InvokeServer(details["Name"], details["LayoutOrder"])

	--check for nil
	if CosmeticUnlock ~= nil then
		--check if player does NOT already own cosmetic
		if CosmeticUnlock.Unlocked == false then
			--let them buy it
			PopUpPurchaseConfirmButton.Visible = true

			--wait for player to click confirm button
			PopUpPurchaseConfirmButton.Activated:Connect(function()
				if firstClick == true then
					firstClick = false

					if (RebirthCoinsRemaining.Value < assert(tonumber(details["Cost"]))) and not game:GetService("RunService"):IsStudio() then
						--prompt for purchase of more bread coins
						--make pop up invisible
						PopUp.Visible = false

						--have the pop up appear with the correct data for this item
						buyDeveloperItem(1296965536)
						firstClick = true
						return
					else
						--check if player can afford the cosmetic and they have not just bought another item
						if os.difftime(os.time(), TimeOfLastPurchase) >= 0.5 then
							--save the last time a player purchased something
							TimeOfLastPurchase = os.time()
							--track what has been bought
							if CosmeticEvent:InvokeServer(details["Name"], details["LayoutOrder"]).Unlocked == false then
								CosmeticPurchaseEvent:FireServer(details["Name"], details["LayoutOrder"], details["Cost"])

								--trigger the sound effect
								playSound("MoneySound")
							end

							--make pop up invisible
							PopUp.Visible = false
							firstClick = true
							return
						end
					end
				end
			end)
		else
			--hide buy button if so
			PopUpPurchaseConfirmButton.Visible = false
		end
	end
end

--function for creating all the items in this tab of the shop
--To create more pages of content simply duplicate this function and change the Parent

--function for creating all the items in this tab of the shop
function createCosmeticsButtons(descriptionTable: { [string]: CosmeticData }, parent: Instance)
	--loop through all items in the table and create a new button for them
	for name, details in pairs(descriptionTable) do
		--set the new button layout to match a saved template
		local newButton = TemplateButton:Clone()
		--give the button an appropriate name
		newButton.Name = name .. " Button"
		--reparent the button to the correct page
		newButton.Parent = parent

		--assign the correct data for this button, with data from the module script
		newButton.LayoutOrder = details["LayoutOrder"]
		newButton.Image = details["Thumbnail"]
		newButton.HoverImage = details["HoverThumbnail"]
		newButton.PressedImage = details["HoverThumbnail"];
		(newButton:WaitForChild("DonateNameLabel") :: TextLabel).Text = details["Name"]

		--wait for player to click the new button
		newButton.Activated:Connect(function()
			--have the pop up appear with the correct data for this item
			displayPopUp(details)
		end)
	end
end

--function for creating all the items in this tab of the shop
function createBreadCoinsButtons(descriptionTable: { [string]: CosmeticData }, parent: Instance)
	--loop through all items in the table and create a new button for them
	for name, details in pairs(descriptionTable) do
		--set the new button layout to match a saved template
		local newButton = TemplateButton:Clone()
		--give the button an appropriate name
		newButton.Name = name .. " Button"
		--reparent the button to the correct page
		newButton.Parent = parent

		--assign the correct data for this button, with data from the module script
		newButton.LayoutOrder = details["LayoutOrder"]
		newButton.Image = details["Thumbnail"]
		newButton.HoverImage = details["HoverThumbnail"]
		newButton.PressedImage = details["HoverThumbnail"];
		(newButton:WaitForChild("DonateNameLabel") :: TextLabel).Text = details["Name"]

		--wait for player to click the new button
		newButton.Activated:Connect(function()
			--have the pop up appear with the correct data for this item
			buyDeveloperItem(assert(details["ID"]))
		end)
	end
end

--in order to create the buttons in the shop you must call the respective function and give it the table from the module script
--To create more pages just duplicate the call below and pass a new module script with data
createCosmeticsButtons(BackgroundsDescriptionTable, ShopPageScrollBackgrounds)
createCosmeticsButtons(LogosDescriptionTable, ShopPageScrollLogos)
createCosmeticsButtons(ThemesDescriptionTable, ShopPageScrollThemes)
createCosmeticsButtons(VFXsDescriptionTable, ShopPageScrollVFX)
createBreadCoinsButtons(BreadCoinsDescriptionTable, ShopPageScrollBreadCoins)

--Button Prompts

--function to run when player clicks the X button
ThemesButton.ImageColor3 = Color3.new(255, 255, 255)
XButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	--show default shop
	MainShop.Visible = true

	--hide the pop up window
	PopUp.Visible = false
	ShopPageLayout:JumpToIndex(0) --changes page back to Donate
	setGreyButtons()
	ThemesButton.ImageColor3 = Color3.new(255, 255, 255)
end)

--function to run when player clicks the Donate button
BackgroundsButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	setGreyButtons()
	BackgroundsButton.ImageColor3 = Color3.new(255, 255, 255)
	ShopPageLayout:JumpToIndex(4) --changes page to Donate
end)

--function to run when player clicks the Gamepass button
LogosButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	setGreyButtons()
	LogosButton.ImageColor3 = Color3.new(255, 255, 255)
	ShopPageLayout:JumpToIndex(2) --changes page to Gamepass
end)

--function to run when player clicks the Coins button
ThemesButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	setGreyButtons()
	ThemesButton.ImageColor3 = Color3.new(255, 255, 255)
	ShopPageLayout:JumpToIndex(0) --changes page to Coins
end)

--function to run when player clicks the Rebirth button
VFXsButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")
	setGreyButtons()
	VFXsButton.ImageColor3 = Color3.new(255, 255, 255)
	ShopPageLayout:JumpToIndex(3) --changes page to rebirths
end)

--function to run when player clicks the bread upgrade button
BreadCoinsButton.Activated:Connect(function()
	--trigger the sound effect
	playSound("DropperSound")

	setGreyButtons()
	BreadCoinsButton.ImageColor3 = Color3.new(255, 255, 255)
	ShopPageLayout:JumpToIndex(1) --changes page to bread upgrades
end)
