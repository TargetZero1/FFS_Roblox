--!strict
--script to control what Types bread the player has already delivered
-- Services
local Players = game:GetService("Players")
local DatastoreServiece = game:GetService("DataStoreService")
-- Packages
-- Modules
local Config = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Config"))
-- Types
export type BreadData = {
	Name: string,
	Amount: number?,
	Value: number?,
}
export type PlayerData = {
	BreadType1: BreadData,
	BreadType2: BreadData,
	BreadType3: BreadData,
	BreadType4: BreadData,
	BreadType5: BreadData,
	BreadType6: BreadData,
	BreadType7: BreadData,
	BreadType8: BreadData,
	BreadType9: BreadData,
	BreadType10: BreadData,
	BreadType11: BreadData,
	BreadType12: BreadData,
	BreadType13: BreadData,
	BreadType14: BreadData,
	BreadType15: BreadData,
	BreadType16: BreadData,
}
-- Constants
local DATASTORE_NAME = Config.Datastore

-- Variables
local SessionData: { [number]: PlayerData } = {}
local PlayerData = DatastoreServiece:GetDataStore(DATASTORE_NAME)

-- References
local PlayerAdded = Instance.new("BindableEvent")
local PlayerRemoving = Instance.new("BindableEvent")

--function to reconcile any discrepencies in the datastore
local function reconcile(source: PlayerData, template: PlayerData)
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

local function loadData(player: Player): (boolean, PlayerData)
	--wrap the load data into a pcall for safety
	local success, result = pcall(function()
		return PlayerData:GetAsync(player.UserId .. "BreadData")
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
		return PlayerData:SetAsync(player.UserId .. "BreadData", data)
	end)
	--if data retreival is not successful
	if not success then
		--display a warning in the log
		warn(result)
	end

	--return if it was successful
	return success
end

local function newBreadReader(index: number): (Player) -> BreadData
	return function(player: Player): BreadData
		--variable to return the value
		local breadData: BreadData = {
			Name = "Unknown",
			Amount = 0,
			Value = 0,
		}
		local breadKey = "BreadType" .. tostring(index)
		--check the player has data for this bread type
		if SessionData[player.UserId][breadKey] then
			--save the amount of bread for this type
			breadData = SessionData[player.UserId][breadKey] :: BreadData
		end

		-- print(SessionData[player.UserId], " = ", breadData)

		--return the bread amount
		return breadData
	end
end

local function newBreadWriter(index: number): (Player, number?, number) -> ()
	return function(player: Player, amount: number?, value: number?)
		--check the input value isn't zero
		if amount and value and (amount <= 0 and value <= 0) then
			--if value is zero, break out
			return
		end

		local breadKey = "BreadType" .. tostring(index)
		local breadData: BreadData = assert(SessionData[player.UserId][breadKey], "assertion failed")

		--check for nil
		if amount ~= nil then
			--check if we want to change the saved amount
			if amount > 0 then
				--check the player has data
				if breadData.Amount then
					--increase the total by the amount if so
					breadData.Amount += amount
				else
					--if data is nill then set to the input value that we know is real
					breadData.Amount = amount
				end
			end
		end

		--check for nil
		if value ~= nil then
			--check if we want to change the saved value
			if value > 0 then
				--check the player has data
				if breadData.Value then
					--increase the total by the amount if so
					breadData.Value += value
				else
					--if data is nill then set to the input value that we know is real
					breadData.Value = value
				end
			end
		end
	end
end

-- Class
local BreadManager = {}

BreadManager.PlayerAdded = PlayerAdded.Event
BreadManager.PlayerRemoving = PlayerRemoving.Event

--connect the defeault player added event to the new functionality below
function BreadManager.start()
	--just in case someone joins before the following event can run
	for _, player in ipairs(Players:GetPlayers()) do
		--run the On player added event on another thread for each player
		coroutine.wrap(BreadManager.onPlayerAdded)(player)
	end
	--connect the new events to trigger the correct functions when fired
	Players.PlayerAdded:Connect(BreadManager.onPlayerAdded)
	Players.PlayerRemoving:Connect(BreadManager.onPlayerRemoving)

	--when game is about to quit save all the Players data
	game:BindToClose(BreadManager.onClose)
end

function BreadManager.onPlayerAdded(player: Player)
	--retreive the data for this player from the roblox cloud server
	local success, data = loadData(player)
	repeat
		wait(0.1)

	until success == false or success == true

	--if data retreival worked and it's not nil
	if success and data ~= nil then

		--check if parts of the data are nill and fix if so
		if data.BreadType1 == nil then
			data.BreadType1 = { Name = "Sourdough", Amount = 0, Value = 0 }
		end
		if data.BreadType2 == nil then
			data.BreadType2 = { Name = "Tabatiere", Amount = 0, Value = 0 }
		end
		if data.BreadType3 == nil then
			data.BreadType3 = { Name = "Zopf", Amount = 0, Value = 0 }
		end
		if data.BreadType4 == nil then
			data.BreadType4 = { Name = "Pitta", Amount = 0, Value = 0 }
		end
		if data.BreadType5 == nil then
			data.BreadType5 = { Name = "Ciabatta", Amount = 0, Value = 0 }
		end
		if data.BreadType6 == nil then
			data.BreadType6 = { Name = "EpiDeBle", Amount = 0, Value = 0 }
		end
		if data.BreadType7 == nil then
			data.BreadType7 = { Name = "BaguetteFlute", Amount = 0, Value = 0 }
		end
		if data.BreadType8 == nil then
			data.BreadType8 = { Name = "BaguetteFicelle", Amount = 0, Value = 0 }
		end
		if data.BreadType9 == nil then
			data.BreadType9 = { Name = "BaguetteDeCampagne", Amount = 0, Value = 0 }
		end
		if data.BreadType10 == nil then
			data.BreadType10 = { Name = "PainComplet", Amount = 0, Value = 0 }
		end
		if data.BreadType11 == nil then
			data.BreadType11 = { Name = "PainDeMie", Amount = 0, Value = 0 }
		end
		if data.BreadType12 == nil then
			data.BreadType12 = { Name = "PainPolka", Amount = 0, Value = 0 }
		end
		if data.BreadType13 == nil then
			data.BreadType13 = { Name = "PainAuxCereales", Amount = 0, Value = 0 }
		end
		if data.BreadType14 == nil then
			data.BreadType14 = { Name = "PainAuLevain", Amount = 0, Value = 0 }
		end
		if data.BreadType15 == nil then
			data.BreadType15 = { Name = "PainDeSeigleNoir", Amount = 0, Value = 0 }
		end
		if data.BreadType16 == nil then
			data.BreadType16 = { Name = "PainDeCampagne", Amount = 0, Value = 0 }
		end
		--check if data is nill
	else
		if success and data == nil then
			warn("no data found, adding template data")
			data = { --template table
				BreadType1 = { Name = "Sourdough", Amount = 0, Value = 0 },
				BreadType2 = { Name = "Tabatiere", Amount = 0, Value = 0 },
				BreadType3 = { Name = "Zopf", Amount = 0, Value = 0 },
				BreadType4 = { Name = "Pitta", Amount = 0, Value = 0 },
				BreadType5 = { Name = "Ciabatta", Amount = 0, Value = 0 },
				BreadType6 = { Name = "EpiDeBle", Amount = 0, Value = 0 },
				BreadType7 = { Name = "BaguetteFlute", Amount = 0, Value = 0 },
				BreadType8 = { Name = "BaguetteFicelle", Amount = 0, Value = 0 },
				BreadType9 = { Name = "BaguetteDeCampagne", Amount = 0, Value = 0 },
				BreadType10 = { Name = "PainComplet", Amount = 0, Value = 0 },
				BreadType11 = { Name = "PainDeMie", Amount = 0, Value = 0 },
				BreadType12 = { Name = "PainPolka", Amount = 0, Value = 0 },
				BreadType13 = { Name = "PainAuxCereales", Amount = 0, Value = 0 },
				BreadType14 = { Name = "PainAuLevain", Amount = 0, Value = 0 },
				BreadType15 = { Name = "PainDeSeigleNoir", Amount = 0, Value = 0 },
				BreadType16 = { Name = "PainDeCampagne", Amount = 0, Value = 0 },
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
			BreadType1 = { Name = "Sourdough", Amount = 0, Value = 0 },
			BreadType2 = { Name = "Tabatiere", Amount = 0, Value = 0 },
			BreadType3 = { Name = "Zopf", Amount = 0, Value = 0 },
			BreadType4 = { Name = "Pitta", Amount = 0, Value = 0 },
			BreadType5 = { Name = "Ciabatta", Amount = 0, Value = 0 },
			BreadType6 = { Name = "EpiDeBle", Amount = 0, Value = 0 },
			BreadType7 = { Name = "BaguetteFlute", Amount = 0, Value = 0 },
			BreadType8 = { Name = "BaguetteFicelle", Amount = 0, Value = 0 },
			BreadType9 = { Name = "BaguetteDeCampagne", Amount = 0, Value = 0 },
			BreadType10 = { Name = "PainComplet", Amount = 0, Value = 0 },
			BreadType11 = { Name = "PainDeMie", Amount = 0, Value = 0 },
			BreadType12 = { Name = "PainPolka", Amount = 0, Value = 0 },
			BreadType13 = { Name = "PainAuxCereales", Amount = 0, Value = 0 },
			BreadType14 = { Name = "PainAuLevain", Amount = 0, Value = 0 },
			BreadType15 = { Name = "PainDeSeigleNoir", Amount = 0, Value = 0 },
			BreadType16 = { Name = "PainDeCampagne", Amount = 0, Value = 0 },
		}
	)

	SessionData[player.UserId] = data

	--fire the player added event that is created at the top of this script
	PlayerAdded:Fire(player)
end

--GETTERS

--Getter for the entire bread table for the player
function BreadManager.getBreadTable(player: Player): PlayerData
	return SessionData[player.UserId]
end

BreadManager.getBreadType1 = newBreadReader(1)
BreadManager.getBreadType2 = newBreadReader(2)
BreadManager.getBreadType3 = newBreadReader(3)
BreadManager.getBreadType4 = newBreadReader(4)
BreadManager.getBreadType5 = newBreadReader(5)
BreadManager.getBreadType6 = newBreadReader(6)
BreadManager.getBreadType7 = newBreadReader(7)
BreadManager.getBreadType8 = newBreadReader(8)
BreadManager.getBreadType9 = newBreadReader(9)
BreadManager.getBreadType10 = newBreadReader(10)
BreadManager.getBreadType11 = newBreadReader(11)
BreadManager.getBreadType12 = newBreadReader(12)
BreadManager.getBreadType13 = newBreadReader(13)
BreadManager.getBreadType14 = newBreadReader(14)
BreadManager.getBreadType15 = newBreadReader(15)
BreadManager.getBreadType16 = newBreadReader(16)

--SETTERS
--Setter for the entire bread table for the player
function BreadManager.setBreadTable(player: Player, dataTable: PlayerData)
	--variable to store if data is broken
	local BrokenData = false

	--loop through table and check data is not nill
	for i, v in ipairs(dataTable) do
		if v == nil then
			BrokenData = true
		end
	end

	--if data is not incorrect
	if BrokenData == false then
		--set the Players data to match the input table
		SessionData[player.UserId] = dataTable
	end
end

BreadManager.setBreadType1 = newBreadWriter(1)
BreadManager.setBreadType2 = newBreadWriter(2)
BreadManager.setBreadType3 = newBreadWriter(3)
BreadManager.setBreadType4 = newBreadWriter(4)
BreadManager.setBreadType5 = newBreadWriter(5)
BreadManager.setBreadType6 = newBreadWriter(6)
BreadManager.setBreadType7 = newBreadWriter(7)
BreadManager.setBreadType8 = newBreadWriter(8)
BreadManager.setBreadType9 = newBreadWriter(9)
BreadManager.setBreadType10 = newBreadWriter(10)
BreadManager.setBreadType11 = newBreadWriter(11)
BreadManager.setBreadType12 = newBreadWriter(12)
BreadManager.setBreadType13 = newBreadWriter(13)
BreadManager.setBreadType14 = newBreadWriter(14)
BreadManager.setBreadType15 = newBreadWriter(15)
BreadManager.setBreadType16 = newBreadWriter(16)

-- Function for when the player leaves
function BreadManager.onPlayerRemoving(player: Player)
	--save the Players data to the datastore
	saveData(player, SessionData[player.UserId])
	--when this player attempts to leave fire this event
	PlayerRemoving:Fire(player)
end

--function for when the player leaves in studio
function BreadManager.onClose()
	--debug to stop firing in studio
	if game:GetService("RunService"):IsStudio() then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		--save the Players data to the datastore when the server closes just in case it failed before
		coroutine.wrap(function()
			BreadManager.onPlayerRemoving(player)
		end)()
	end
end

return BreadManager
