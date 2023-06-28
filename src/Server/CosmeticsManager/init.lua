--!strict
-- Services
local Players = game:GetService("Players")
local DatastoreServiece = game:GetService("DataStoreService")

-- Packages
-- Modules
local Config = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Config"))
-- Types
export type CosmeticData = {
	Unlocked: boolean,
}

export type EquipData = {
	Background: string,
	Logo: string,
	Theme: string,
	VFX: string,
}
export type BackgroundData = {
	Background1: CosmeticData,
	Background2: CosmeticData,
	Background3: CosmeticData,
	Background4: CosmeticData,
	Background5: CosmeticData,
}
export type LogoData = {
	Logo1: CosmeticData,
	Logo2: CosmeticData,
	Logo3: CosmeticData,
	Logo4: CosmeticData,
	Logo5: CosmeticData,
}
export type ThemeData = {
	Theme1: CosmeticData,
	Theme2: CosmeticData,
	Theme3: CosmeticData,
	Theme4: CosmeticData,
	Theme5: CosmeticData,
}
export type VFXData = {
	VFX1: CosmeticData,
	VFX2: CosmeticData,
	VFX3: CosmeticData,
	VFX4: CosmeticData,
	VFX5: CosmeticData,
}
export type PlayerData = {
	Equipped: EquipData,
	Backgrounds: BackgroundData,
	Logos: LogoData,
	Themes: ThemeData,
	VFX: VFXData,
}
-- Constants
local DATASTORE_NAME = Config.Datastore

-- Variables

local PlayerData = DatastoreServiece:GetDataStore(DATASTORE_NAME)
local SessionData: { [number]: PlayerData } = {}
-- References
local PlayerAdded = Instance.new("BindableEvent")
local PlayerRemoving = Instance.new("BindableEvent")

-- private functions

--function to reconcile any discrepencies in the datastore
local function reconcile(source: PlayerData, template: PlayerData): PlayerData
	--loop through the template table and put all the values from this into the source table if they don't exists
	for k, v in pairs(template) do
		--if this entry does not exist in source table
		if not source[k] then
			--insert it
			source[k] = v
		end
	end
	--send the new source table back
	return source
end

local function loadData(player: Player): (boolean, PlayerData?)
	--wrap the load data into a pcall for safety
	local success, result = pcall(function()
		return PlayerData:GetAsync(tostring(player.UserId) .. "CosmeticsData")
	end)
	--if data retreival is not successful
	if not success then
		--display a warning in the log
		warn(result)
	end

	--return the retreived data if it was successful
	return success, result
end

local function saveData(player: Player, data: PlayerData): boolean
	--wrap the save data into a pcall for safety
	local success, result = pcall(function()
		--overwrite previous data
		return PlayerData:SetAsync(tostring(player.UserId) .. "CosmeticsData", data)
	end)
	--if data retreival is not successful
	if not success then
		--display a warning in the log
		warn(result)
	end

	--return if it was successful
	return success
end

-- Class
local CosmeticsManager = {}

--connect the player added event to the player manager to allow other scripts to access it
CosmeticsManager.PlayerAdded = PlayerAdded.Event
CosmeticsManager.PlayerRemoving = PlayerRemoving.Event

--connect the defeault player added event to the new functionality below
function CosmeticsManager.start()
	--just in case someone joins before the following event can run
	for _, player in ipairs(Players:GetPlayers()) do
		--run the On player added event on another thread for each player
		coroutine.wrap(CosmeticsManager.onPlayerAdded)(player)
	end
	--connect the new events to trigger the correct functions when fired
	Players.PlayerAdded:Connect(CosmeticsManager.onPlayerAdded)
	Players.PlayerRemoving:Connect(CosmeticsManager.onPlayerRemoving)

	--when game is about to quit save all the Players data
	game:BindToClose(CosmeticsManager.onClose)
end

function CosmeticsManager.onPlayerAdded(player: Player)
	--retreive the data for this player from the roblox cloud server
	local success = false
	local data: PlayerData?
	repeat
		wait(0.1)
		success, data = loadData(player)
	until success == false or success == true

	--if data retreival worked and it's not nil
	if success and data then
		--check if parts of the data are nill and fix if so
		if data.Equipped == nil then
			data.Equipped = {
				["Background"] = "Default",
				["Logo"] = "Default",
				["Theme"] = "Default",
				["VFX"] = "Default",
			}
		else --check if parts of the data is nill and replace if so
			if data.Equipped.Background == nil then
				data.Equipped.Background = "Default"
			end
			if data.Equipped.Logo == nil then
				data.Equipped.Logo = "Default"
			end
			if data.Equipped.Theme == nil then
				data.Equipped.Theme = "Default"
			end
			if data.Equipped.VFX == nil then
				data.Equipped.VFX = "Default"
			end
		end
		if type(data.Backgrounds) ~= "table" then
			data.Backgrounds = {
				["Background1"] = { Unlocked = false } :: CosmeticData,
				["Background2"] = { Unlocked = false } :: CosmeticData,
				["Background3"] = { Unlocked = false } :: CosmeticData,
				["Background4"] = { Unlocked = false } :: CosmeticData,
				["Background5"] = { Unlocked = false } :: CosmeticData,
			}
		else --check if parts of the data is nill and replace if so
			if data.Backgrounds.Background1 == nil then
				data.Backgrounds.Background1 = { Unlocked = false } :: CosmeticData
			end
			if data.Backgrounds.Background2 == nil then
				data.Backgrounds.Background2 = { Unlocked = false } :: CosmeticData
			end
			if data.Backgrounds.Background3 == nil then
				data.Backgrounds.Background3 = { Unlocked = false } :: CosmeticData
			end
			if data.Backgrounds.Background4 == nil then
				data.Backgrounds.Background4 = { Unlocked = false } :: CosmeticData
			end
			if data.Backgrounds.Background5 == nil then
				data.Backgrounds.Background5 = { Unlocked = false } :: CosmeticData
			end
		end
		if type(data.Logos) ~= "table" then
			data.Logos = {
				["Logo1"] = { Unlocked = false } :: CosmeticData,
				["Logo2"] = { Unlocked = false } :: CosmeticData,
				["Logo3"] = { Unlocked = false } :: CosmeticData,
				["Logo4"] = { Unlocked = false } :: CosmeticData,
				["Logo5"] = { Unlocked = false } :: CosmeticData,
			}
		else --check if parts of the data is nill and replace if so
			if data.Logos.Logo1 == nil then
				data.Logos.Logo1 = { Unlocked = false } :: CosmeticData
			end
			if data.Logos.Logo2 == nil then
				data.Logos.Logo2 = { Unlocked = false } :: CosmeticData
			end
			if data.Logos.Logo3 == nil then
				data.Logos.Logo3 = { Unlocked = false } :: CosmeticData
			end
			if data.Logos.Logo4 == nil then
				data.Logos.Logo4 = { Unlocked = false } :: CosmeticData
			end
			if data.Logos.Logo5 == nil then
				data.Logos.Logo5 = { Unlocked = false } :: CosmeticData
			end
		end
		if type(data.Themes) ~= "table" then
			data.Themes = {
				["Theme1"] = { Unlocked = false } :: CosmeticData,
				["Theme2"] = { Unlocked = false } :: CosmeticData,
				["Theme3"] = { Unlocked = false } :: CosmeticData,
				["Theme4"] = { Unlocked = false } :: CosmeticData,
				["Theme5"] = { Unlocked = false } :: CosmeticData,
			}
		else --check if parts of the data is nill and replace if so
			if data.Themes.Theme1 == nil then
				data.Themes.Theme1 = { Unlocked = false } :: CosmeticData
			end
			if data.Themes.Theme2 == nil then
				data.Themes.Theme2 = { Unlocked = false } :: CosmeticData
			end
			if data.Themes.Theme3 == nil then
				data.Themes.Theme3 = { Unlocked = false } :: CosmeticData
			end
			if data.Themes.Theme4 == nil then
				data.Themes.Theme4 = { Unlocked = false } :: CosmeticData
			end
			if data.Themes.Theme5 == nil then
				data.Themes.Theme5 = { Unlocked = false } :: CosmeticData
			end
		end
		if type(data.VFX) ~= "table" then
			data.VFX = {
				["VFX1"] = { Unlocked = false } :: CosmeticData,
				["VFX2"] = { Unlocked = false } :: CosmeticData,
				["VFX3"] = { Unlocked = false } :: CosmeticData,
				["VFX4"] = { Unlocked = false } :: CosmeticData,
				["VFX5"] = { Unlocked = false } :: CosmeticData,
			}
		else --check if parts of the data is nill and replace if so
			if data.VFX.VFX1 == nil then
				data.VFX.VFX1 = { Unlocked = false } :: CosmeticData
			end
			if data.VFX.VFX2 == nil then
				data.VFX.VFX2 = { Unlocked = false } :: CosmeticData
			end
			if data.VFX.VFX3 == nil then
				data.VFX.VFX3 = { Unlocked = false } :: CosmeticData
			end
			if data.VFX.VFX4 == nil then
				data.VFX.VFX4 = { Unlocked = false } :: CosmeticData
			end
			if data.VFX.VFX5 == nil then
				data.VFX.VFX5 = { Unlocked = false } :: CosmeticData
			end
		end

		--check if data is nill
	else
		if success and data == nil then
			data = { --template table
				--Modifier Levels
				Equipped = {
					["Background"] = "Default",
					["Logo"] = "Default",
					["Theme"] = "Default",
					["VFX"] = "Default",
				},
				Backgrounds = {
					["Background1"] = { Unlocked = false } :: CosmeticData,
					["Background2"] = { Unlocked = false } :: CosmeticData,
					["Background3"] = { Unlocked = false } :: CosmeticData,
					["Background4"] = { Unlocked = false } :: CosmeticData,
					["Background5"] = { Unlocked = false } :: CosmeticData,
				},
				Logos = {
					["Logo1"] = { Unlocked = false } :: CosmeticData,
					["Logo2"] = { Unlocked = false } :: CosmeticData,
					["Logo3"] = { Unlocked = false } :: CosmeticData,
					["Logo4"] = { Unlocked = false } :: CosmeticData,
					["Logo5"] = { Unlocked = false } :: CosmeticData,
				},
				Themes = {
					["Theme1"] = { Unlocked = false } :: CosmeticData,
					["Theme2"] = { Unlocked = false } :: CosmeticData,
					["Theme3"] = { Unlocked = false } :: CosmeticData,
					["Theme4"] = { Unlocked = false } :: CosmeticData,
					["Theme5"] = { Unlocked = false } :: CosmeticData,
				},
				VFX = {
					["VFX1"] = { Unlocked = false } :: CosmeticData,
					["VFX2"] = { Unlocked = false } :: CosmeticData,
					["VFX3"] = { Unlocked = false } :: CosmeticData,
					["VFX4"] = { Unlocked = false } :: CosmeticData,
					["VFX5"] = { Unlocked = false } :: CosmeticData,
				},
			}
		end
	end

	--create session data from existsing data or brand new default values
	SessionData[player.UserId] = reconcile(
		--if data retreival was successful
		if success
			then data
			else
				--use a blank table
				{} :: any,
		{ --template table
			--Modifier Levels
			Equipped = {
				["Background"] = "Default",
				["Logo"] = "Default",
				["Theme"] = "Default",
				["VFX"] = "Default",
			},
			Backgrounds = {
				["Background1"] = { Unlocked = false } :: CosmeticData,
				["Background2"] = { Unlocked = false } :: CosmeticData,
				["Background3"] = { Unlocked = false } :: CosmeticData,
				["Background4"] = { Unlocked = false } :: CosmeticData,
				["Background5"] = { Unlocked = false } :: CosmeticData,
			},
			Logos = {
				["Logo1"] = { Unlocked = false } :: CosmeticData,
				["Logo2"] = { Unlocked = false } :: CosmeticData,
				["Logo3"] = { Unlocked = false } :: CosmeticData,
				["Logo4"] = { Unlocked = false } :: CosmeticData,
				["Logo5"] = { Unlocked = false } :: CosmeticData,
			},
			Themes = {
				["Theme1"] = { Unlocked = false } :: CosmeticData,
				["Theme2"] = { Unlocked = false } :: CosmeticData,
				["Theme3"] = { Unlocked = false } :: CosmeticData,
				["Theme4"] = { Unlocked = false } :: CosmeticData,
				["Theme5"] = { Unlocked = false } :: CosmeticData,
			},
			VFX = {
				["VFX1"] = { Unlocked = false } :: CosmeticData,
				["VFX2"] = { Unlocked = false } :: CosmeticData,
				["VFX3"] = { Unlocked = false } :: CosmeticData,
				["VFX4"] = { Unlocked = false } :: CosmeticData,
				["VFX5"] = { Unlocked = false } :: CosmeticData,
			},
		}
	)

	SessionData[player.UserId] = assert(data, "assertion failed")

	--fire the player added event that is created at the top of this script
	PlayerAdded:Fire(player)
end

--GETTERS

--Getter for the entire cosmetics table for the player
function CosmeticsManager.getCosmeticsTable(player: Player): PlayerData
	return SessionData[player.UserId]
end

--Getter for the entire cosmetics table for the player
function CosmeticsManager.getEquippedTable(player: Player): EquipData
	return SessionData[player.UserId].Equipped
end

--Getter for the entire cosmetics table for the player
function CosmeticsManager.getBackgroundsTable(player: Player): BackgroundData
	return SessionData[player.UserId].Backgrounds
end

--Getter for the entire cosmetics table for the player
function CosmeticsManager.getLogosTable(player: Player): LogoData
	return SessionData[player.UserId].Logos
end

--Getter for the entire cosmetics table for the player
function CosmeticsManager.getThemesTable(player: Player): ThemeData
	return SessionData[player.UserId].Themes
end

--Getter for the entire cosmetics table for the player
function CosmeticsManager.getVFXTable(player: Player): VFXData
	return SessionData[player.UserId].VFX
end

--SETTERS
--Setter for the entire cosmetics table for the player
function CosmeticsManager.setCosmeticsTable(player: Player, dataTable: PlayerData)
	SessionData[player.UserId] = dataTable
end
function CosmeticsManager.setEquippedTable(player: Player, dataTable: EquipData)
	SessionData[player.UserId].Equipped = dataTable
end
--Setter for the a table of backgrounds for the player
function CosmeticsManager.setBackgroundsTable(player: Player, dataTable: BackgroundData)
	SessionData[player.UserId].Backgrounds = dataTable
end
--Setter for the a table of Logos for the player
function CosmeticsManager.setLogosTable(player: Player, dataTable: LogoData)
	SessionData[player.UserId].Logos = dataTable
end
--Setter for the a table of Themes for the player
function CosmeticsManager.setThemesTable(player: Player, dataTable: ThemeData)
	SessionData[player.UserId].Themes = dataTable
end
--Setter for the a table of VFX for the player
function CosmeticsManager.setVFX(player: Player, dataTable: VFXData)
	SessionData[player.UserId].VFX = dataTable
end

-- Function for when the player leaves
function CosmeticsManager.onPlayerRemoving(player: Player)
	--save the Players data to the datastore
	saveData(player, SessionData[player.UserId])
	--when this player attempts to leave fire this event
	PlayerRemoving:Fire(player)
end

--function for when the player leaves in studio
function CosmeticsManager.onClose()
	--debug to stop firing in studio
	if game:GetService("RunService"):IsStudio() then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		--save the Players data to the datastore when the server closes just in case it failed before
		coroutine.wrap(function()
			CosmeticsManager.onPlayerRemoving(player)
		end)()
	end
end

return CosmeticsManager
