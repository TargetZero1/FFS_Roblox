--!strict
-- Script handled by the server that has access to the Cosmtetics manager
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
-- Packages
-- Modules
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local CosmeticsManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("CosmeticsManager"))
-- Types
type PlayerData = CosmeticsManager.PlayerData
type CosmeticData = CosmeticsManager.CosmeticData
type BackgroundData = CosmeticsManager.BackgroundData
type EquipData = CosmeticsManager.EquipData
type LogoData = CosmeticsManager.LogoData
type ThemeData = CosmeticsManager.ThemeData
type VFXData = CosmeticsManager.VFXData

-- Constants
-- Variables
-- References
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ManagerEvents = RemoteEvents:WaitForChild("ManagerEvent")
local CosmeticEvent = RemoteFunctions:WaitForChild("CosmeticEvent", 20) :: RemoteFunction
local CosmeticPurchaseEvent = RemoteEvents:WaitForChild("CosmeticPurchaseEvent", 20) :: RemoteEvent
local GetCosmeticsData = ManagerEvents:WaitForChild("GetCosmeticsData") :: RemoteFunction

-- Class
CosmeticsManager.start()

--function to run when player fires event
CosmeticEvent.OnServerInvoke = function(player: Player, cosmeticType: string, cosmeticNumber: number): CosmeticData | BackgroundData | EquipData | LogoData | ThemeData | VFXData
	--if the player desires data about a background
	if cosmeticType:match("Background") then
		--if they want the entire table
		if cosmeticNumber == 0 then
			return CosmeticsManager.getBackgroundsTable(player)
		end
		--if they want an individual entry
		if cosmeticNumber == 1 then
			--get a copy of this players backgrounds table
			local CosmeticsTable = CosmeticsManager.getBackgroundsTable(player)
			--return the value for background1
			return CosmeticsTable.Background1
		end
		if cosmeticNumber == 2 then
			--get a copy of this players backgrounds table
			local CosmeticsTable = CosmeticsManager.getBackgroundsTable(player)
			--return the value for background2
			return CosmeticsTable.Background2
		end
		if cosmeticNumber == 3 then
			--get a copy of this players backgrounds table
			local CosmeticsTable = CosmeticsManager.getBackgroundsTable(player)
			--return the value for background3
			return CosmeticsTable.Background3
		end
		if cosmeticNumber == 4 then
			--get a copy of this players backgrounds table
			local CosmeticsTable = CosmeticsManager.getBackgroundsTable(player)
			--return the value for background4
			return CosmeticsTable.Background4
		end
		if cosmeticNumber == 5 then
			--get a copy of this players backgrounds table
			local CosmeticsTable = CosmeticsManager.getBackgroundsTable(player)
			--return the value for background5
			return CosmeticsTable.Background5
		end
	end
	--if the player desires data about a Logo
	if cosmeticType:match("Logo") then
		--if they want the entire table
		if cosmeticNumber == 0 then
			return CosmeticsManager.getLogosTable(player)
		end
		--if they want an individual entry
		if cosmeticNumber == 1 then
			--get a copy of this players logos table
			local CosmeticsTable = CosmeticsManager.getLogosTable(player)
			--return the value for logos1
			return CosmeticsTable.Logo1
		end
		if cosmeticNumber == 2 then
			--get a copy of this players logos table
			local CosmeticsTable = CosmeticsManager.getLogosTable(player)
			--return the value for logos2
			return CosmeticsTable.Logo2
		end
		if cosmeticNumber == 3 then
			--get a copy of this players logos table
			local CosmeticsTable = CosmeticsManager.getLogosTable(player)
			--return the value for logos3
			return CosmeticsTable.Logo3
		end
		if cosmeticNumber == 4 then
			--get a copy of this players logos table
			local CosmeticsTable = CosmeticsManager.getLogosTable(player)
			--return the value for logos4
			return CosmeticsTable.Logo4
		end
		if cosmeticNumber == 5 then
			--get a copy of this players logos table
			local CosmeticsTable = CosmeticsManager.getLogosTable(player)
			--return the value for logos5
			return CosmeticsTable.Logo5
		end
	end
	--if the player desires data about a Themes
	if cosmeticType:match("Theme") then
		--if they want the entire table
		if cosmeticNumber == 0 then
			return { Unlocked = true } -- default should always be unlocked
		end
		--if they want an individual entry
		if cosmeticNumber == 1 then
			--get a copy of this players Themes table
			local CosmeticsTable = CosmeticsManager.getThemesTable(player)
			--return the value for Themes1
			return CosmeticsTable.Theme1
		end
		if cosmeticNumber == 2 then
			--get a copy of this players Themes table
			local CosmeticsTable = CosmeticsManager.getThemesTable(player)
			--return the value for Themes2
			return CosmeticsTable.Theme2
		end
		if cosmeticNumber == 3 then
			--get a copy of this players Themes table
			local CosmeticsTable = CosmeticsManager.getThemesTable(player)
			--return the value for Themes3
			return CosmeticsTable.Theme3
		end
		if cosmeticNumber == 4 then
			--get a copy of this players Themes table
			local CosmeticsTable = CosmeticsManager.getThemesTable(player)
			--return the value for Themes4
			return CosmeticsTable.Theme4
		end
		if cosmeticNumber == 5 then
			--get a copy of this players Themes table
			local CosmeticsTable = CosmeticsManager.getThemesTable(player)
			--return the value for Themes5
			return CosmeticsTable.Theme5
		end
	end
	--if the player desires data about a VFX
	if cosmeticType:match("VFX") then
		--if they want the entire table
		if cosmeticNumber == 0 then
			return CosmeticsManager.getVFXTable(player)
		end
		--if they want an individual entry
		if cosmeticNumber == 1 then
			--get a copy of this players VFX table
			local CosmeticsTable = CosmeticsManager.getVFXTable(player)
			--return the value for VFX1
			return CosmeticsTable.VFX1
		end
		if cosmeticNumber == 2 then
			--get a copy of this players VFX table
			local CosmeticsTable = CosmeticsManager.getVFXTable(player)
			--return the value for VFX2
			return CosmeticsTable.VFX2
		end
		if cosmeticNumber == 3 then
			--get a copy of this players VFX table
			local CosmeticsTable = CosmeticsManager.getVFXTable(player)
			--return the value for VFX3
			return CosmeticsTable.VFX3
		end
		if cosmeticNumber == 4 then
			--get a copy of this players VFX table
			local CosmeticsTable = CosmeticsManager.getVFXTable(player)
			--return the value for VFX4
			return CosmeticsTable.VFX4
		end
		if cosmeticNumber == 5 then
			--get a copy of this players VFX table
			local CosmeticsTable = CosmeticsManager.getVFXTable(player)
			--return the value for VFX5
			return CosmeticsTable.VFX5
		end
	end
	error("Bad request: " .. tostring(player) .. "," .. tostring(cosmeticType) .. "," .. tostring(cosmeticNumber))
end

CosmeticPurchaseEvent.OnServerEvent:Connect(function(player: Player, cosmeticType: string, cosmeticNumber: number, cost: number)
	if (PlayerManager.getRebirths(player) == nil) or (PlayerManager.getRebirths(player) ~= nil and assert(PlayerManager.getRebirths(player)) < cost) then
		return
	end

	--if the player is saving data about a background
	if cosmeticType:match("Background") then
		--if they want the entire table
		local CosmeticsTable = CosmeticsManager.getBackgroundsTable(player)
		--if they want an individual entry
		if cosmeticNumber == 1 then
			--overwrite the saved entry for background1
			CosmeticsTable.Background1 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 2 then
			--overwrite the saved entry for background2
			CosmeticsTable.Background2 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 3 then
			--overwrite the saved entry for background3
			CosmeticsTable.Background3 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 4 then
			--overwrite the saved entry for background4
			CosmeticsTable.Background4 = { Unlocked = true }
		end --if they want an individual entry
		if cosmeticNumber == 5 then
			--overwrite the saved entry for background5
			CosmeticsTable.Background5 = { Unlocked = true }
		end

		--save the value for background
		CosmeticsManager.setBackgroundsTable(player, CosmeticsTable)
	end
	--if the player is saving data about a background
	if cosmeticType:match("Logo") then
		--if they want the entire table
		local CosmeticsTable = CosmeticsManager.getLogosTable(player)

		--if they want an individual entry
		if cosmeticNumber == 1 then
			--overwrite the saved entry for Logo1
			CosmeticsTable.Logo1 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 2 then
			--overwrite the saved entry for Logo2
			CosmeticsTable.Logo2 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 3 then
			--overwrite the saved entry for Logo3
			CosmeticsTable.Logo3 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 4 then
			--overwrite the saved entry for Logo4
			CosmeticsTable.Logo4 = { Unlocked = true }
		end --if they want an individual entry
		if cosmeticNumber == 5 then
			--overwrite the saved entry for Logo5
			CosmeticsTable.Logo5 = { Unlocked = true }
		end
		--save the value for Logo
		CosmeticsManager.setLogosTable(player, CosmeticsTable)
	end
	--if the player is saving data about a Theme
	if cosmeticType:match("Theme") then
		--if they want the entire table
		local CosmeticsTable = CosmeticsManager.getThemesTable(player)

		--if they want an individual entry
		if cosmeticNumber == 1 then
			--overwrite the saved entry for Theme1
			CosmeticsTable.Theme1 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 2 then
			--overwrite the saved entry for Theme2
			CosmeticsTable.Theme2 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 3 then
			--overwrite the saved entry for Theme3
			CosmeticsTable.Theme3 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 4 then
			--overwrite the saved entry for Theme4
			CosmeticsTable.Theme4 = { Unlocked = true }
		end --if they want an individual entry
		if cosmeticNumber == 5 then
			--overwrite the saved entry for Theme5
			CosmeticsTable.Theme5 = { Unlocked = true }
		end
		--save the value for Theme
		CosmeticsManager.setThemesTable(player, CosmeticsTable)
	end
	--if the player is saving data about a VFX
	if cosmeticType:match("VFX") then
		--if they want the entire table
		local CosmeticsTable = CosmeticsManager.getVFXTable(player)

		--if they want an individual entry
		if cosmeticNumber == 1 then
			--overwrite the saved entry for VFX1
			CosmeticsTable.VFX1 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 2 then
			--overwrite the saved entry for VFX2
			CosmeticsTable.VFX2 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 3 then
			--overwrite the saved entry for VFX3
			CosmeticsTable.VFX3 = { Unlocked = true }
		end
		--if they want an individual entry
		if cosmeticNumber == 4 then
			--overwrite the saved entry for VFX4
			CosmeticsTable.VFX4 = { Unlocked = true }
		end --if they want an individual entry
		if cosmeticNumber == 5 then
			--overwrite the saved entry for VFX5
			CosmeticsTable.VFX5 = { Unlocked = true }
		end

		--save the value for VFX
		CosmeticsManager.setVFX(player, CosmeticsTable)
	end

	--[[if(PlayerManager.getRebirthCoinsRemainingAmount(player) ~= nil) then
		--deduct bread coins from player
		PlayerManager.setRebirthCoinsRemainingAmount(player, PlayerManager.getRebirthCoinsRemainingAmount(player) - Cost)
	end
	
	if(PlayerManager.getRebirthCoinsSpentAmount(player) ~= nil) then
		--track how much has been spent
		PlayerManager.setRebirthCoinsSpentAmount(player, PlayerManager.getRebirthCoinsSpentAmount(player) + Cost)
	end]]

	--reducing rebirth cost
	PlayerManager.setRebirths(player, assert(PlayerManager.getRebirths(player)) - cost)
end)

--getter for client

GetCosmeticsData.OnServerInvoke = function(plr: Player)
	return CosmeticsManager.getThemesTable(plr)
end
