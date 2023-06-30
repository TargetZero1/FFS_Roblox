--!strict
-- Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- Modules
local PlayerManager =
	require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
local BreadManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BreadManager"))
local ReferenceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
local RewardData = require(game:GetService("ReplicatedStorage"):WaitForChild("Balancing"):WaitForChild("RewardData"))
local Pets = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Pets"))

-- Types
type Maid = Maid.Maid
type RewardData = RewardData.EntryData
-- Constants
local DEBUG_ENABLED = false
-- local DEV_HERE_MODE = false
local UPDATE_VERSION = 0.1
local SECONDS_IN_DAY = 60*60*24

-- Variables
local PlayerData = DataStoreService:GetDataStore("PlayerData_2.0")
local maid = Maid.new()
-- References
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AFKRewardEvent = BindableEvents:WaitForChild("AFKRewardEvent") :: BindableEvent
local ObbyResetEvent = RemoteEvents:WaitForChild("ObbyReset") :: RemoteEvent
-- local ClaimTycoonEvent = BindableEvents:WaitForChild("ClaimTycoon") :: BindableEvent
local AdminSettings = ReplicatedFirst:WaitForChild("AdminControls")
-- local TeleportToDevTycoonEvent = RemoteEvents:WaitForChild("TeleportToDevTycoonEvent") :: RemoteEvent
-- local TycoonSpawns = workspace:WaitForChild("TycoonSpawns")

-- Private function
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

--require playermanager to use player stats
PlayerManager.start()
BreadManager.start()

--get value from admin setting script
if AdminSettings then
	if AdminSettings:GetAttribute("DEBUG_ENABLED") ~= nil then
		DEBUG_ENABLED = AdminSettings:GetAttribute("DEBUG_ENABLED")
	end
end

--function to look through all spawn locations and assign one to the player
-- function findSpawn()
-- 	--WARNING the game does not check if more Players are here than spawns allow,
-- 	-- so make sure to create more spawns than needed

-- 	--loop through all spawn points available
-- 	for _, spawnPoint in ipairs(TycoonSpawns:GetChildren()) do
-- 		--check if spawn point is occupied
-- 		if not spawnPoint:GetAttribute("Claimed") then
-- 			--if this spawn is not being used then return this value
-- 			return spawnPoint
-- 		end
-- 	end
-- 	error("No spawn found")
-- end

--function to control Update Ui pop up
function displayUpdate(player: Player)
	local foundData = PlayerData:GetAsync(tostring(player.UserId) .. "UPDATE_VERSION")

	--boolean to control if we should display the update UI
	local display = false

	if foundData ~= nil then
		--get current update version
		if AdminSettings then
			UPDATE_VERSION = AdminSettings:GetAttribute("UPDATE_VERSION")
		end

		--check if found data is equal to the current version
		if foundData ~= UPDATE_VERSION then
			display = true
		end
	else
		display = true
	end

	local playerGui = assert(player:WaitForChild("PlayerGui", 20), "assertion failed") :: PlayerGui

	if display == true then
		--find the Players UI
		local mainGui = assert(playerGui:WaitForChild("MainGui", 20), "assertion failed") :: ScreenGui

		local updateUI = mainGui:WaitForChild("UpdatePop-up", 20) :: GuiObject?
		if updateUI then
			--display the update pop up
			updateUI.Visible = true
		end

		--save new version to prevent seeing UI again
		PlayerData:SetAsync(tostring(player.UserId) .. "UPDATE_VERSION", UPDATE_VERSION)
	end
end

function getOnlineKey(userId: number): string
	return `{userId}_LastVisitAward_V3`
end

function getLastVisitAward(userId: number): number
	local timestamp = PlayerData:GetAsync(getOnlineKey(userId))
	return timestamp or (DateTime.now().UnixTimestamp - SECONDS_IN_DAY - 1)
end

function setLastVisitAward(userId: number): ()
	PlayerData:SetAsync(getOnlineKey(userId), DateTime.now().UnixTimestamp)
end

--function to control when to display AFK window for Players
function displayAFK(player: Player): ()
	local lastAwardTimestamp = getLastVisitAward(player.UserId)

	local afkMoney = 0

	--total days away
	local days = math.floor((DateTime.now().UnixTimestamp - lastAwardTimestamp) / SECONDS_IN_DAY)
	print("DAYS", days)
	if days > 0 then
		local rewardData = RewardData[days] or RewardData[#RewardData]
		assert(rewardData, "'rewardData' assertion failed")

		afkMoney = rewardData.Amount
	end

	if afkMoney > 0 then
		print("adding afk UI")
		--find the Players UI
		local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui;
		local mainGui = assert(playerGui:WaitForChild("MainGui", 20), "assertion failed") :: ScreenGui;

		local afkUI = mainGui:WaitForChild("AFKPop-up", 60) :: GuiObject?;
		if afkUI then
			print("setting reward amount");
			(_getChild(_getChild(afkUI, "Moneybackground"), "MoneyLabel") :: TextLabel).Text = "$" .. afkMoney;
			--display the update pop up
			afkUI.Visible = true

			AFKRewardEvent:Fire(player, afkMoney)
			setLastVisitAward(player.UserId)
		end
	end
end

--function for tracking player obby rewards
function disableObbyReward(player: Player, Obby)
	player:SetAttribute(Obby, false)
end

ObbyResetEvent.OnServerEvent:Connect(disableObbyReward)

-- --function to check if player joining is a team member
-- function metADev(player: Player): boolean
-- 	local developersTable = {
-- 		"L3gendrasp",
-- 		"Pragma_Once",
-- 		"Bethanytheanimator",
-- 		"jpm3design",
-- 		"BWhite_NSG",
-- 		"Jimbulothy",
-- 		"Betelgeuse_87",
-- 		"4udioMonkey",
-- 		"FacelessMochi",
-- 		"Dark_Shinobi100",
-- 	}
-- 	local metDeveloper = false

-- 	for i, dev in pairs(developersTable) do
-- 		if player.Name == dev then
-- 			metDeveloper = true
-- 		end
-- 	end

-- 	return metDeveloper
-- end

--wait for player manager to finish setting up before triggering AFK check
PlayerManager.PlayerAdded:Connect(function(player: Player)
	--find the 1st unoccupied plot of land
	-- local plot = findSpawn()
	-- local plotNumber = 0

	-- --check the Developer Tycoon is Unoccupied
	-- local devHere = DEV_HERE_MODE --PrototypeTycoon:GetAttribute("Claimed")

	-- --check if the admin Controls script attribute is set to Developer Mode
	-- if AdminSettings:GetAttribute("DevMode") ~= nil then
	-- 	if AdminSettings:GetAttribute("DevMode") == true and metADev(player) == true and devHere == false then
	-- 		plotNumber = 0
	-- 	else
	-- 		plotNumber = plot:GetAttribute("PlotNumber")
	-- 	end
	-- else
	-- 	if plot:GetAttribute("PlotNumber") ~= nil then
	-- 		plotNumber = plot:GetAttribute("PlotNumber")
	-- 	else
	-- 		--loop until it is no longer nil
	-- 		while plot:GetAttribute("PlotNumber") == nil do
	-- 			wait(0.1)
	-- 			--find new plot
	-- 			plot = findSpawn()
	-- 		end
	-- 		--check attribute
	-- 		plotNumber = plot:GetAttribute("PlotNumber")
	-- 	end
	-- end

	-- fire an event to tell the plot their new owner
	-- ClaimTycoonEvent:Fire(plotNumber, player)

	--loop through all Players
	for i, p in pairs(Players:GetPlayers()) do
		--check if joining player is friends with anyone in the lobby
		if player:IsFriendsWith(p.UserId) then
			--grant a bonus to collector pay
			player:SetAttribute("FriendMultiplier", 1.2)
			p:SetAttribute("FriendMultiplier", 1.2)

			if DEBUG_ENABLED then
				print(player.Name .. " is friends with " .. p.Name)
			end
		end
	end

	--check for if the game should display the update UI
	displayUpdate(player)

	displayAFK(player)

	--if enabled on Admin controls
	if AdminSettings:GetAttribute("LoafValueReader") == true then
		--give player LoafValueReader bonus
		player:SetAttribute("LoafValueReader", true)
	end

	--sets collision group
	local function declareCollisionGroup(char: Model)
		if not char or not char.PrimaryPart then
			return
		end
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CollisionGroup = "Player"
			end
		end
	end
	declareCollisionGroup(player.Character or player.CharacterAdded:Wait())
	player.CharacterAdded:Connect(declareCollisionGroup)

	print("Attempt to Initializng pet")
end)

-- Players.PlayerRemoving:Connect(function(player: Player)
-- 	--save new version to prevent seeing UI again
-- 	setLastOnline(player.UserId)
-- 	-- PlayerData:SetAsync(tostring(player.UserId) .. "LastOnline", os.time())
-- end)

-- TeleportToDevTycoonEvent.OnServerEvent:Connect(function(player: Player)
-- 	--find the 1st unoccupied plot of land
-- 	local plot
-- 	local plotNumber = 0

-- 	--check the Developer Tycoon is Unoccupied
-- 	local devHere = DEV_HERE_MODE --PrototypeTycoon:GetAttribute("Claimed")

-- 	--check if the admin Controls script attribute is set to Developer Mode
-- 	if devHere == false then
-- 		plotNumber = 0
-- 	else
-- 		if plot:GetAttribute("PlotNumber") ~= nil then
-- 			plotNumber = plot:GetAttribute("PlotNumber")
-- 		else
-- 			--loop until it is no longer nil
-- 			while plot:GetAttribute("PlotNumber") == nil do
-- 				wait(0.1)
-- 				--find new plot
-- 				plot = findSpawn()
-- 				--check attribute
-- 				plotNumber = plot:GetAttribute("PlotNumber")
-- 			end
-- 		end
-- 	end

-- 	--fire an event to tell the plot their new owner
-- 	ClaimTycoonEvent:Fire(plotNumber, player)

-- 	--reference to the developer tycoon
-- 	local tycoon = assert(assert(workspace:WaitForChild("TycoonPrototype"), "assertion failed"):WaitForChild("PrototypeClaimTycoon", 20))

-- 	--teleport to the centre of the tycoon
-- 	local character = assert(player.Character, "'player.Character' assertion failed")
-- 	local hrp = assert(character:WaitForChild("HumanoidRootPart", 20), "assertion failed") :: Part
-- 	hrp.Position = (tycoon:WaitForChild("Template") :: Model):GetPivot().Position
-- end)

Pets.init(maid)
