--!strict
-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Packages
-- Modules
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
-- Types
-- Constants
-- Variables
-- References
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local PlayerDonated = BindableEvents:WaitForChild("PlayerDonated") :: BindableEvent
local FeedTheWorld = BindableEvents:WaitForChild("FeedTheWorld") :: BindableEvent

-- Class
local PRODUCTS

PRODUCTS = {
	[1280938671] = function(player: Player): boolean
		if PlayerManager.getMoney(player) ~= nil then
			PlayerManager.setMoney(player, PlayerManager.getMoney(player) + 1000)
		else
			PlayerManager.setMoney(player, 1000)
		end

		-- --increase the total amount of money this player has earned
		-- if PlayerManager.getTotalMoney(player) ~= nil then
		-- 	PlayerManager.setTotalMoney(player, PlayerManager.getTotalMoney(player) + 1000)
		-- else
		-- 	PlayerManager.setTotalMoney(player, 1000)
		-- end

		--return the purchase was successful
		return true
	end,
	--Donation dev products
	--5 robux
	[1296962478] = function(player: Player): boolean
		if PlayerManager.getDonateAmount(player) ~= nil then
			PlayerManager.setDonateAmount(player, PlayerManager.getDonateAmount(player) + 5)
		else
			PlayerManager.setDonateAmount(player, 5)
		end

		PlayerDonated:Fire(player)
		--return the purchase was successful
		return true
	end,
	--25 robux
	[1296962640] = function(player: Player): boolean
		if PlayerManager.getDonateAmount(player) ~= nil then
			PlayerManager.setDonateAmount(player, PlayerManager.getDonateAmount(player) + 25)
		else
			PlayerManager.setDonateAmount(player, 25)
		end
		PlayerDonated:Fire(player)
		--return the purchase was successful
		return true
	end,
	--50 robux
	[1296962698] = function(player: Player): boolean
		if PlayerManager.getDonateAmount(player) ~= nil then
			PlayerManager.setDonateAmount(player, PlayerManager.getDonateAmount(player) + 50)
		else
			PlayerManager.setDonateAmount(player, 50)
		end

		PlayerDonated:Fire(player)
		--return the purchase was successful
		return true
	end,
	--100 robux
	[1296962751] = function(player: Player): boolean
		if PlayerManager.getDonateAmount(player) ~= nil then
			PlayerManager.setDonateAmount(player, PlayerManager.getDonateAmount(player) + 100)
		else
			PlayerManager.setDonateAmount(player, 100)
		end
		PlayerDonated:Fire(player)
		--return the purchase was successful
		return true
	end,
	--200 robux
	[1296962786] = function(player: Player): boolean
		if PlayerManager.getDonateAmount(player) ~= nil then
			PlayerManager.setDonateAmount(player, PlayerManager.getDonateAmount(player) + 200)
		else
			PlayerManager.setDonateAmount(player, 200)
		end
		PlayerDonated:Fire(player)
		--return the purchase was successful
		return true
	end,
	--500 robux
	[1296962602] = function(player: Player): boolean
		if PlayerManager.getDonateAmount(player) ~= nil then
			PlayerManager.setDonateAmount(player, PlayerManager.getDonateAmount(player) + 500)
		else
			PlayerManager.setDonateAmount(player, 500)
		end
		PlayerDonated:Fire(player)
		--return the purchase was successful
		return true
	end,

	-- Timed Reward products
	--2 minute bonus
	[1296963344] = function(player: Player): boolean
		--give the player who bought it a 2 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 120)
		else
			PlayerManager.setTimeRemainingAmount(player, 120)
		end

		PlayerManager.setMultiplierBonusAmount(player, 2)

		--return the purchase was successful
		return true
	end,
	--5 minute bonus
	[1296963390] = function(player: Player): boolean
		--give the player who bought it a 5 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 300)
		else
			PlayerManager.setTimeRemainingAmount(player, 300)
		end

		PlayerManager.setMultiplierBonusAmount(player, 2)

		--return the purchase was successful
		return true
	end,

	--10 minute bonus
	[1296963438] = function(player: Player): boolean
		--give the player who bought it a 10 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 600)
		else
			PlayerManager.setTimeRemainingAmount(player, 600)
		end
		PlayerManager.setMultiplierBonusAmount(player, 2)

		--return the purchase was successful
		return true
	end,

	--15 minute bonus
	[1296963478] = function(player: Player): boolean
		--give the player who bought it a 15 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 900)
		else
			PlayerManager.setTimeRemainingAmount(player, 900)
		end
		PlayerManager.setMultiplierBonusAmount(player, 2)

		--return the purchase was successful
		return true
	end,

	--30 minute bonus
	[1296963521] = function(player: Player): boolean
		--give the player who bought it a 30 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 1800)
		else
			PlayerManager.setTimeRemainingAmount(player, 1800)
		end
		PlayerManager.setMultiplierBonusAmount(player, 2)

		--return the purchase was successful
		return true
	end,

	--60 minute bonus
	[1296963574] = function(player: Player): boolean
		--give the player who bought it a 60 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 3600)
		else
			PlayerManager.setTimeRemainingAmount(player, 3600)
		end
		PlayerManager.setMultiplierBonusAmount(player, 2)

		--return the purchase was successful
		return true
	end,

	--Feed the server
	--2 minute bonus
	[1296964143] = function(player: Player): boolean
		--Get all current players in game
		for i, player in pairs(Players:GetPlayers()) do
			player:SetAttribute("FeedTheWorld", true)
			if player:GetAttribute("Timer") ~= nil then
				player:SetAttribute("Timer", player:GetAttribute("Timer") + 120)
			else
				player:SetAttribute("Timer", 120)
			end
		end
		FeedTheWorld:Fire(player)
		--give the player who bought it a 2 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 120)
		else
			PlayerManager.setTimeRemainingAmount(player, 120)
		end
		PlayerManager.setMultiplierBonusAmount(player, 2)
		--return the purchase was successful
		return true
	end,
	--5 minute bonus
	[1296964228] = function(player: Player): boolean
		--Get all current players in game
		for i, player in pairs(Players:GetPlayers()) do
			player:SetAttribute("FeedTheWorld", true)
			if player:GetAttribute("Timer") ~= nil then
				player:SetAttribute("Timer", player:GetAttribute("Timer") + 300)
			else
				player:SetAttribute("Timer", 300)
			end
		end
		FeedTheWorld:Fire(player)
		--give the player who bought it a 5 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 300)
		else
			PlayerManager.setTimeRemainingAmount(player, 300)
		end
		PlayerManager.setMultiplierBonusAmount(player, 2)
		--return the purchase was successful
		return true
	end,
	--10 minute bonus
	[1296964267] = function(player: Player): boolean
		--Get all current players in game
		for i, player in pairs(Players:GetPlayers()) do
			player:SetAttribute("FeedTheWorld", true)
			if player:GetAttribute("Timer") ~= nil then
				player:SetAttribute("Timer", player:GetAttribute("Timer") + 600)
			else
				player:SetAttribute("Timer", 600)
			end
		end
		FeedTheWorld:Fire(player)
		--give the player who bought it a 10 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 600)
		else
			PlayerManager.setTimeRemainingAmount(player, 600)
		end
		PlayerManager.setMultiplierBonusAmount(player, 2)

		--return the purchase was successful
		return true
	end,
	--15 minute bonus
	[1296964306] = function(player: Player): boolean
		--Get all current players in game
		for i, player in pairs(Players:GetPlayers()) do
			player:SetAttribute("FeedTheWorld", true)
			if player:GetAttribute("Timer") ~= nil then
				player:SetAttribute("Timer", player:GetAttribute("Timer") + 900)
			else
				player:SetAttribute("Timer", 900)
			end
		end
		FeedTheWorld:Fire(player)
		--give the player who bought it a 15 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 900)
		else
			PlayerManager.setTimeRemainingAmount(player, 900)
		end
		PlayerManager.setMultiplierBonusAmount(player, 2)
		--return the purchase was successful
		return true
	end,
	--30 minute bonus
	[1296964351] = function(player: Player): boolean
		--Get all current players in game
		for i, player in pairs(Players:GetPlayers()) do
			player:SetAttribute("FeedTheWorld", true)
			if player:GetAttribute("Timer") ~= nil then
				player:SetAttribute("Timer", player:GetAttribute("Timer") + 1800)
			else
				player:SetAttribute("Timer", 1800)
			end
		end
		FeedTheWorld:Fire(player)
		--give the player who bought it a 30 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 1800)
		else
			PlayerManager.setTimeRemainingAmount(player, 1800)
		end
		PlayerManager.setMultiplierBonusAmount(player, 2)
		--return the purchase was successful
		return true
	end,
	--60 minute bonus
	[1296964418] = function(player: Player): boolean
		--Get all current players in game
		for i, player in pairs(Players:GetPlayers()) do
			player:SetAttribute("FeedTheWorld", true)
			if player:GetAttribute("Timer") ~= nil then
				player:SetAttribute("Timer", player:GetAttribute("Timer") + 3600)
			else
				player:SetAttribute("Timer", 3600)
			end
		end
		FeedTheWorld:Fire(player)
		--give the player who bought it a 60 minute bonus
		if PlayerManager.getTimeRemainingAmount(player) ~= nil then
			PlayerManager.setTimeRemainingAmount(player, assert(PlayerManager.getTimeRemainingAmount(player)) + 3600)
		else
			PlayerManager.setTimeRemainingAmount(player, 3600)
		end
		PlayerManager.setMultiplierBonusAmount(player, 2)
		--return the purchase was successful
		return true
	end,

	-- --Coin Dev products
	-- --10,000 coins
	-- [1296964815] = function(player: Player): boolean
	-- 	if PlayerManager.getMoney(player) ~= nil then
	-- 		PlayerManager.setMoney(player, PlayerManager.getMoney(player) + 10000)
	-- 	else
	-- 		PlayerManager.setMoney(player, 10000)
	-- 	end

	-- 	--increase the total amount of money this player has earned
	-- 	if PlayerManager.getTotalMoney(player) ~= nil then
	-- 		PlayerManager.setTotalMoney(player, PlayerManager.getTotalMoney(player) + 10000)
	-- 	else
	-- 		PlayerManager.setTotalMoney(player, 10000)
	-- 	end

	-- 	--return the purchase was successful
	-- 	return true
	-- end,
	-- --50,000 coins
	-- [1296964856] = function(player: Player): boolean
	-- 	if PlayerManager.getMoney(player) ~= nil then
	-- 		PlayerManager.setMoney(player, PlayerManager.getMoney(player) + 50000)
	-- 	else
	-- 		PlayerManager.setMoney(player, 50000)
	-- 	end

	-- 	--increase the total amount of money this player has earned
	-- 	if PlayerManager.getTotalMoney(player) ~= nil then
	-- 		PlayerManager.setTotalMoney(player, PlayerManager.getTotalMoney(player) + 50000)
	-- 	else
	-- 		PlayerManager.setTotalMoney(player, 50000)
	-- 	end
	-- 	--return the purchase was successful
	-- 	return true
	-- end,
	-- --100,000 coins
	-- [1296964903] = function(player: Player): boolean
	-- 	if PlayerManager.getMoney(player) ~= nil then
	-- 		PlayerManager.setMoney(player, PlayerManager.getMoney(player) + 100000)
	-- 	else
	-- 		PlayerManager.setMoney(player, 100000)
	-- 	end

	-- 	--increase the total amount of money this player has earned
	-- 	if PlayerManager.getTotalMoney(player) ~= nil then
	-- 		PlayerManager.setTotalMoney(player, PlayerManager.getTotalMoney(player) + 100000)
	-- 	else
	-- 		PlayerManager.setTotalMoney(player, 100000)
	-- 	end

	-- 	--return the purchase was successful
	-- 	return true
	-- end,
	-- --5,000 coins
	-- [1296964955] = function(player: Player): boolean
	-- 	if PlayerManager.getMoney(player) ~= nil then
	-- 		PlayerManager.setMoney(player, PlayerManager.getMoney(player) + 5000)
	-- 	else
	-- 		PlayerManager.setMoney(player, 5000)
	-- 	end

	-- 	--increase the total amount of money this player has earned
	-- 	if PlayerManager.getTotalMoney(player) ~= nil then
	-- 		PlayerManager.setTotalMoney(player, PlayerManager.getTotalMoney(player) + 5000)
	-- 	else
	-- 		PlayerManager.setTotalMoney(player, 5000)
	-- 	end

	-- 	--return the purchase was successful
	-- 	return true
	-- end,
	-- --250,000 coins
	-- [1296965017] = function(player: Player): boolean
	-- 	if PlayerManager.getMoney(player) ~= nil then
	-- 		PlayerManager.setMoney(player, PlayerManager.getMoney(player) + 250000)
	-- 	else
	-- 		PlayerManager.setMoney(player, 250000)
	-- 	end

	-- 	--increase the total amount of money this player has earned
	-- 	if PlayerManager.getTotalMoney(player) ~= nil then
	-- 		PlayerManager.setTotalMoney(player, PlayerManager.getTotalMoney(player) + 250000)
	-- 	else
	-- 		PlayerManager.setTotalMoney(player, 250000)
	-- 	end

	-- 	--return the purchase was successful
	-- 	return true
	-- end,
	-- --500,000 coins
	-- [1296965074] = function(player: Player): boolean
	-- 	if PlayerManager.getMoney(player) ~= nil then
	-- 		PlayerManager.setMoney(player, PlayerManager.getMoney(player) + 500000)
	-- 	else
	-- 		PlayerManager.setMoney(player, 500000)
	-- 	end

	-- 	--increase the total amount of money this player has earned
	-- 	if PlayerManager.getTotalMoney(player) ~= nil then
	-- 		PlayerManager.setTotalMoney(player, PlayerManager.getTotalMoney(player) + 500000)
	-- 	else
	-- 		PlayerManager.setTotalMoney(player, 500000)
	-- 	end

	-- 	--return the purchase was successful
	-- 	return true
	-- end,

	--Dynamic Cash PRODUCTS
	--50 Dynamic
	[1316662852] = function(player: Player): boolean
		local playerHighest = PlayerManager.getHighestBreadRackValue(player)
		--If somehow the code has reached here but the player has less than 100 highest then fail the transaction.
		if playerHighest < 100 then
			warn("Player's HighestBreadRackValue Is Below 100.")
			return false
		end

		if PlayerManager.getMoney(player) ~= nil then
			PlayerManager.setMoney(player, PlayerManager.getMoney(player) + (50 * playerHighest))
		else
			PlayerManager.setMoney(player, (50 * playerHighest))
		end

		return true
	end,
	--100 Dynamic
	[1316663047] = function(player: Player): boolean
		local playerHighest = PlayerManager.getHighestBreadRackValue(player)
		--If somehow the code has reached here but the player has less than 100 highest then fail the transaction.
		if playerHighest < 100 then
			warn("Player's HighestBreadRackValue Is Below 100.")
			return false
		end

		if PlayerManager.getMoney(player) ~= nil then
			PlayerManager.setMoney(player, PlayerManager.getMoney(player) + (100 * playerHighest))
		else
			PlayerManager.setMoney(player, (100 * playerHighest))
		end

		return true
	end,
	--500 Dynamic
	[1316663368] = function(player: Player): boolean
		local playerHighest = PlayerManager.getHighestBreadRackValue(player)
		--If somehow the code has reached here but the player has less than 100 highest then fail the transaction.
		if playerHighest < 100 then
			warn("Player's HighestBreadRackValue Is Below 100.")
			return false
		end

		if PlayerManager.getMoney(player) ~= nil then
			PlayerManager.setMoney(player, PlayerManager.getMoney(player) + (500 * playerHighest))
		else
			PlayerManager.setMoney(player, (500 * playerHighest))
		end

		return true
	end,
	--1000 Dynamic
	[1316663558] = function(player: Player): boolean
		local playerHighest = PlayerManager.getHighestBreadRackValue(player)
		--If somehow the code has reached here but the player has less than 100 highest then fail the transaction.
		if playerHighest < 100 then
			warn("Player's HighestBreadRackValue Is Below 100.")
			return false
		end

		if PlayerManager.getMoney(player) ~= nil then
			PlayerManager.setMoney(player, PlayerManager.getMoney(player) + (1000 * playerHighest))
		else
			PlayerManager.setMoney(player, (1000 * playerHighest))
		end

		return true
	end,
	--2500 Dynamic
	[1316663723] = function(player: Player): boolean
		local playerHighest = PlayerManager.getHighestBreadRackValue(player)
		--If somehow the code has reached here but the player has less than 100 highest then fail the transaction.
		if playerHighest < 100 then
			warn("Player's HighestBreadRackValue Is Below 100.")
			return false
		end

		if PlayerManager.getMoney(player) ~= nil then
			PlayerManager.setMoney(player, PlayerManager.getMoney(player) + (2500 * playerHighest))
		else
			PlayerManager.setMoney(player, (2500 * playerHighest))
		end

		return true
	end,
	--5000 Dynamic
	[1316663884] = function(player: Player): boolean
		local playerHighest = PlayerManager.getHighestBreadRackValue(player)
		--If somehow the code has reached here but the player has less than 100 highest then fail the transaction.
		if playerHighest < 100 then
			warn("Player's HighestBreadRackValue Is Below 100.")
			return false
		end

		if PlayerManager.getMoney(player) ~= nil then
			PlayerManager.setMoney(player, PlayerManager.getMoney(player) + (5000 * playerHighest))
		else
			PlayerManager.setMoney(player, (5000 * playerHighest))
		end

		return true
	end,
	--Rebirth Dev PRODUCTS
	--1 rebirth
	[1296965439] = function(player: Player): boolean
		if PlayerManager.getRebirthCoinsRemainingAmount(player) ~= nil then
			PlayerManager.setRebirthCoinsRemainingAmount(player, PlayerManager.getRebirthCoinsRemainingAmount(player) + 1)
		else
			PlayerManager.setRebirthCoinsRemainingAmount(player, 1)
		end

		if PlayerManager.getRebirthCoinsAmount(player) ~= nil then
			PlayerManager.setRebirthCoinsAmount(player, PlayerManager.getRebirthCoinsAmount(player) + 1)
		else
			PlayerManager.setRebirthCoinsAmount(player, 1)
		end

		--return the purchase was successful
		return true
	end,
	--10 rebirth
	[1296965489] = function(player: Player): boolean
		if PlayerManager.getRebirthCoinsRemainingAmount(player) ~= nil then
			PlayerManager.setRebirthCoinsRemainingAmount(player, PlayerManager.getRebirthCoinsRemainingAmount(player) + 10)
		else
			PlayerManager.setRebirthCoinsRemainingAmount(player, 10)
		end

		if PlayerManager.getRebirthCoinsAmount(player) ~= nil then
			PlayerManager.setRebirthCoinsAmount(player, PlayerManager.getRebirthCoinsAmount(player) + 10)
		else
			PlayerManager.setRebirthCoinsAmount(player, 10)
		end
		--return the purchase was successful
		return true
	end,
	--25 rebirth
	[1296965536] = function(player: Player): boolean
		if PlayerManager.getRebirthCoinsRemainingAmount(player) ~= nil then
			PlayerManager.setRebirthCoinsRemainingAmount(player, PlayerManager.getRebirthCoinsRemainingAmount(player) + 25)
		else
			PlayerManager.setRebirthCoinsRemainingAmount(player, 25)
		end

		if PlayerManager.getRebirthCoinsAmount(player) ~= nil then
			PlayerManager.setRebirthCoinsAmount(player, PlayerManager.getRebirthCoinsAmount(player) + 25)
		else
			PlayerManager.setRebirthCoinsAmount(player, 25)
		end

		--return the purchase was successful
		return true
	end,
	--1 bread coin
	[1345945340] = function(player: Player): boolean
		return PRODUCTS[1296965439](player)
	end,

	[1345949535] = function(player: Player): boolean
		return PRODUCTS[1296965489](player)
	end,

	[1345949711] = function(player: Player): boolean
		return PRODUCTS[1296965536](player)
	end,
}
--define a list of gamepass products
local GAMEPASS_PRODUCTS = {
	--Double Bread value
	[72142319] = function(player: Player): boolean
		player:SetAttribute("DoubleBread", 2)
		--return the purchase was successful
		return true
	end,
	--Loaf value reader
	[72142124] = function(player: Player): boolean
		player:SetAttribute("LoafValueReader", true)
		--return the purchase was successful
		return true
	end,
	--VIP
	[72141916] = function(player: Player): boolean
		player:SetAttribute("VIP", true)
		--return the purchase was successful
		return true
	end,
	--ULTIMATE MACHINES

	-- Ultimate Windmill
	[1] = function(player: Player): boolean
		--Event to fire for the player that bought the ultimate windmill
		--PlayerManager.setModifierLevel(player, "Windmill1Modifiers", "Speed",0.5)
		--set attribute on player to trigger machine updates
		player:SetAttribute("UltimateWindmill", true)
		--return the purchase was successful
		return true
	end,
	-- Ultimate Kneader
	[84834686] = function(player: Player): boolean
		--Event to fire for the player that bought the ultimate Kneader
		--PlayerManager.setModifierLevel(player, "KneadingModifiers", "Speed",0.5)
		--PlayerManager.setModifierLevel(player, "KneadingModifiers", "Automation",0.5)
		--set attribute on player to trigger machine updates
		player:SetAttribute("UltimateKneader", true)
		--return the purchase was successful
		return true
	end,
	-- Ultimate Oven
	[84834761] = function(player: Player): boolean
		--Event to fire for the player that bought the ultimate Oven
		--PlayerManager.setModifierLevel(player, "BakingModifiers", "Speed",0.5)
		--set attribute on player to trigger machine updates
		player:SetAttribute("UltimateOven", true)
		--return the purchase was successful
		return true
	end,
	-- Ultimate Wrapper
	[84834822] = function(player: Player): boolean
		--Event to fire for the player that bought the ultimate Wrapper
		--PlayerManager.setModifierLevel(player, "WrappingModifiers", "Speed",0.5)
		--set attribute on player to trigger machine updates
		player:SetAttribute("UltimateWrapper", true)
		--return the purchase was successful
		return true
	end,
}

--function on marketplace service that expects a call back containing key info
--this is called whenever the player buys something
type ReceiptInfo = {
	PurchaseId: string,
	PlayerId: number,
	ProductId: number,
	CurrencySpent: number,
	CurrencyType: Enum.CurrencyType,
	PlaceIdWherePurchased: number,
}

MarketplaceService.ProcessReceipt = function(info: ReceiptInfo): Enum.ProductPurchaseDecision
	--get the player who bought an item
	local player = Players:GetPlayerByUserId(info.PlayerId)
	--local midas = Analytics:GetMidas(player, "Monetization/Receipt")

	--pcall(function()
	--local productInfo = MarketplaceService:GetProductInfo(info.ProductId, Enum.InfoType.Product)
	--midas:SetState("Product/Cost", function()
	--return info.CurrencySpent
	--end)
	--midas:SetState("Product/Name", function()
	--return productInfo.Name
	--end)
	--midas:SetState("Product/Id", function()
	--return info.ProductId
	--end)
	--end)

	--if player has left or game crashed, unsure if player is there or not
	if not player then
		--notify the buyer of the product/Roblox that the transaction has not completed yet
		-- and do not charge the player
		--so it'll run this function again till it is successful/gives up
		--midas:Fire("Product/Outcome/Fail")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--run the pcall function to ensure that errors don't break the system
	assert(player)
	local success, result = pcall(PRODUCTS[info.ProductId], player)

	--if something went wrong
	if not success then
		if result then
			warn("ERROR for product " .. tostring(result))
		end
		--midas:Fire("Product/Outcome/Error")
		--something went wrong so don't charge the player
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--if everything went according to plan
	--midas:Fire("Product/Outcome/success")
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, productId: number, wasPurchased: boolean)
	--if player has left or game crashed, unsure if player is there or not
	if not player then
		--notify the buyer of the product/Roblox that the transaction has not completed yet
		-- and do not charge the player
		--so it'll run this function again till it is successful/gives up
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if player and wasPurchased then
		--run the pcall function to ensure that errors don't break the system
		local success, result = pcall(GAMEPASS_PRODUCTS[productId], player)

		--if something went wrong
		if not success then
			if result then
				warn("ERROR for product " .. tostring(result))
			end
			--something went wrong so don't charge the player
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end

	--if everything went according to plan
	return Enum.ProductPurchaseDecision.PurchaseGranted
end)
