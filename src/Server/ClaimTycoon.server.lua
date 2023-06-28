--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

-- Modules
local Tycoon = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Tycoon"))
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
local ReferenceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ReferenceUtil"))

-- Types
type Tycoon = Tycoon.Tycoon
type Maid = Maid.Maid

-- Constants
local OWNER_USER_ID_KEY = "OwnerUserId"
local CLAIM_KEY = "Claimed"
local IS_LOADING_KEY = "IsLoading"
local CENSUS_PERIOD = 5 --seconds
-- Variables
-- References
local TemplateModel = ServerStorage:WaitForChild("Template") :: Model
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerLoadedEvent = BindableEvents:WaitForChild("PlayerLoadedEvent") :: BindableEvent
local TeleportEvent = RemoteEvents:WaitForChild("TeleportPlayerEvent") :: RemoteEvent

-- Private functions
local _getChild = ReferenceUtil.getChild

function hideLoadingBlock(tycoonSpawn: BasePart)
	local loadingModel = _getChild(tycoonSpawn, "Loading") :: Model
	task.wait(1)
	for i, part in ipairs(loadingModel:GetChildren()) do
		assert(part:IsA("BasePart"))
		part.CanCollide = false
		part.Transparency = 1
		local gui = part:FindFirstChildOfClass("SurfaceGui")
		if gui then
			gui.Enabled = false
		end
	end
end

function showLoadingBlock(tycoonSpawn: BasePart): ()
	local loadingModel = _getChild(tycoonSpawn, "Loading") :: Model
	for i, part in ipairs(loadingModel:GetChildren()) do
		assert(part:IsA("BasePart"))
		part.CanCollide = true
		part.Transparency = 0
		local gui = part:FindFirstChildOfClass("SurfaceGui")
		if gui then
			gui.Enabled = true
		end
	end
end

function setOwnership(tycoonSpawn: BasePart, player: Player?)
	if player then
		tycoonSpawn:SetAttribute(OWNER_USER_ID_KEY, player.UserId)
		tycoonSpawn:SetAttribute(CLAIM_KEY, true)
	else
		tycoonSpawn:SetAttribute(OWNER_USER_ID_KEY, nil)
		tycoonSpawn:SetAttribute(CLAIM_KEY, false)
	end
end

function getIfAvailable(tycoonSpawn: BasePart): boolean
	return tycoonSpawn:GetAttribute(CLAIM_KEY) == false 
	and tycoonSpawn:GetAttribute(OWNER_USER_ID_KEY) == nil 
	and tycoonSpawn:GetAttribute(IS_LOADING_KEY) == false 
end

function getTycoonOwnerUserId(tycoonSpawn: BasePart): number?
	return tycoonSpawn:GetAttribute(OWNER_USER_ID_KEY)
end

function trackPlayTime(player: Player): ()
	--track time played
	PlayerManager.setPlayTime(player, PlayerManager.getPlayTime(player) + 1)
end

function updateSign(tycoonSpawn: BasePart, player: Player?): ()

	--reference to the billboard
	local plotOwnerSign = _getChild(tycoonSpawn, "PlotOwnerSign") :: Model
	local signBillboard = _getChild(plotOwnerSign, "SignBillboard") :: BasePart
	local signTextLabel = _getChild(_getChild(signBillboard, "SurfaceGui"), "OwnerNameLabel") :: TextLabel
	local signIconLabel = _getChild(_getChild(signBillboard, "SurfaceGui"), "Icon") :: ImageLabel

	--check if the player is leaving
	if player then

		--if they are not then change the sign to their name
		signTextLabel.Text = player.Name .. "'s Bakery"
		signIconLabel.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(player.UserId) .. "&w=150&h=150"
		signIconLabel.Visible = true

		plotOwnerSign:SetAttribute("Owner", player.Name)

		--also change parts collision properties
		tycoonSpawn.CanCollide = false
		tycoonSpawn.Transparency = 1
	else

		--if they are  then change the sign to display the area is available
		signTextLabel.Text = "Empty Bakery"
		signIconLabel.Image = ""
		signIconLabel.Visible = false

		--also change parts collision properties
		tycoonSpawn.CanCollide = true
		tycoonSpawn.Transparency = 0
	end
end

function cleanUpTycoon(tycoonSpawn: BasePart): ()
	print(`Cleaning up tycoon {tycoonSpawn.Name}`)
	setOwnership(tycoonSpawn)
	
	-- show the loading block
	print(`Showing loading block {tycoonSpawn.Name}`)
	showLoadingBlock(tycoonSpawn)

	-- updat the sign
	print(`Updating sign {tycoonSpawn.Name}`)
	updateSign(tycoonSpawn, nil)

	-- delete the old template
	print(`Deleting old template {tycoonSpawn.Name}`)
	local oldTemplate = tycoonSpawn:FindFirstChild("Template")
	if oldTemplate then
		oldTemplate:Destroy()
	end

	-- add a new template
	print(`New template {tycoonSpawn.Name}`)
	local newTemplate = TemplateModel:Clone() :: Model
	newTemplate:PivotTo(tycoonSpawn:GetPivot())
	newTemplate.Name = "Template"
	newTemplate.Parent = tycoonSpawn	

	--hide the loading block
	print(`Hide block {tycoonSpawn.Name}`)
	hideLoadingBlock(tycoonSpawn)
end

function loadTycoon(tycoonSpawn: BasePart, player: Player?, isRebirth: boolean?): ()
	print(`Loading tycoon {tycoonSpawn.Name} for {tostring(player)}`)
	assert(getIfAvailable(tycoonSpawn) or isRebirth)
	tycoonSpawn:SetAttribute(IS_LOADING_KEY, true)

	local success, msg = pcall(function()
		-- clean tycoon
		cleanUpTycoon(tycoonSpawn)

		print(`Setting ownership {tycoonSpawn.Name}`)
		setOwnership(tycoonSpawn, player)

		-- spawn the template model
		print(`Waiting for template {tycoonSpawn.Name}`)
		local currentTemplate = tycoonSpawn:WaitForChild("Template") :: Model

		-- create maid to handle memory leaks
		local maid = Maid.new()
		maid:GiveTask(currentTemplate.Destroying:Connect(function()
			print(`Destroying old template via maid {tycoonSpawn.Name}`)
			maid:Destroy()
		end))

		-- player
		if not player then
			print(`Completed nil-player loading {tycoonSpawn.Name}`)
			tycoonSpawn:SetAttribute(IS_LOADING_KEY, false)
		else

			maid:GiveTask(Players.PlayerRemoving:Connect(function(plr: Player)
				if plr.UserId == player.UserId then
					maid:Destroy()
				end
			end))
	
			--reference to owning Tycoon
			updateSign(tycoonSpawn, player)
	
			--set the player spawn to the correct location
			player.RespawnLocation = _getChild(tycoonSpawn, "SpawnLocation") :: SpawnLocation
	
			--increment the timer every second
			local lastUpdate = tick()
			maid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime: number)
				if tick() - lastUpdate >= 1 then
					lastUpdate = tick()
					trackPlayTime(player)
				end
			end))
	
			-- tycoon object
			local tycoon = maid:GiveTask(Tycoon.new(
				player, 
				_getChild(tycoonSpawn, "Spawn") :: BasePart,
				currentTemplate
			))
			maid:GiveTask(tycoon.OnRebirth:Connect(function()
				loadTycoon(tycoonSpawn, player, true)
			end))
	
			--trigger event in order to give player badge
			PlayerLoadedEvent:Fire(player)

			maid:GiveTask(TeleportEvent.OnServerEvent:Connect(function(plr: Player)
				if plr.UserId == player.UserId then
					local character = player.Character
					if character then
						character:PivotTo(tycoonSpawn:GetPivot() + Vector3.new(0,4,0))
					end
				end
			end))

			print(`Completed player loading {tycoonSpawn.Name}`)
		end
	end)
	if not success then
		warn(msg)
		cleanUpTycoon(tycoonSpawn)
	end
	
	tycoonSpawn:SetAttribute(IS_LOADING_KEY, false)
end

--function to run when a player leaves the game
Players.PlayerRemoving:Connect(function(player: Player)
	for i, tycoonSpawn in ipairs(workspace:WaitForChild("TycoonSpawns"):GetChildren()) do
		if tycoonSpawn:IsA("BasePart") and player.UserId == getTycoonOwnerUserId(tycoonSpawn) then
			cleanUpTycoon(tycoonSpawn)
			tycoonSpawn:SetAttribute(IS_LOADING_KEY, false)
		end
	end	
end)

function tycoonCensus()
	for i, tycoonSpawn in ipairs(workspace:WaitForChild("TycoonSpawns"):GetChildren()) do
		if tycoonSpawn:IsA("BasePart") then
			local userId = getTycoonOwnerUserId(tycoonSpawn)
			if userId then 
				if not Players:GetPlayerByUserId(userId) and not tycoonSpawn:SetAttribute(IS_LOADING_KEY) then
					cleanUpTycoon(tycoonSpawn)
				end
			end
		end
	end
end

-- add players to a tycoon
local function bootPlayer(player: Player)
	-- try to spawn a player
	local function attemptSpawn(): boolean
		for i, tycoonSpawn in ipairs(workspace:WaitForChild("TycoonSpawns"):GetChildren()) do
			if tycoonSpawn:IsA("BasePart") and getIfAvailable(tycoonSpawn) then
				loadTycoon(tycoonSpawn, player)
				return true
			end
		end
		return false
	end
	if attemptSpawn() then return end

	-- clean up any tycoons without active players
	repeat
		task.wait(CENSUS_PERIOD)
	until attemptSpawn()

	-- assert(attemptSpawn(), "something has gone very wrong with tycoon spawning")
end
Players.PlayerAdded:Connect(bootPlayer)
for i, player in ipairs(Players:GetPlayers()) do
	bootPlayer(player)
end

-- update tycoon
for i, tycoonSpawn in ipairs(workspace:WaitForChild("TycoonSpawns"):GetChildren()) do
	if tycoonSpawn:IsA("BasePart") and getIfAvailable(tycoonSpawn) then
		loadTycoon(tycoonSpawn)
	end
end

local lastCheck = tick()
RunService.Heartbeat:Connect(function()
	if tick() - lastCheck > CENSUS_PERIOD then
		lastCheck = tick()
		tycoonCensus()
	end
end)

--[[
local function debugTycoon(tycoonSpawn: BasePart)
	local OWNER_USER_ID_KEY = "OwnerUserId"
	local CLAIM_KEY = "Claimed"
	local IS_LOADING_KEY = "IsLoading"

	print("\n\n\n\n\n")
	print(`CURRENT {tycoonSpawn.Name} STATE!`)
	print(`CLAIMED?: {tycoonSpawn:GetAttribute(CLAIM_KEY)}`)
	print(`LOADING?: {tycoonSpawn:GetAttribute(IS_LOADING_KEY)}`)
	print(`PLOT_NUMBER?: {tycoonSpawn:GetAttribute("PlotNumber")}`)
	print(`OWNER_USER_ID?: {tycoonSpawn:GetAttribute(OWNER_USER_ID_KEY)}`)
end

debugTycoon(workspace:WaitForChild("TycoonSpawns"):WaitForChild("ClaimTycoon7") :: BasePart)
]]

--[[
local function fixTycoons()
	local CLAIM_KEY = "Claimed"
	local IS_LOADING_KEY = "IsLoading"
	for i, tycoonSpawn in ipairs(workspace:WaitForChild("TycoonSpawns"):GetChildren()) do
		if tycoonSpawn:IsA("BasePart") and not tycoonSpawn:GetAttribute(CLAIM_KEY) then
			tycoonSpawn:SetAttribute(IS_LOADING_KEY, false)
		end
	end
end
fixTycoons()
]]


--[[
local function updateTycoonPivot(tycoonSpawn: BasePart)
	local templateCF = (tycoonSpawn:WaitForChild("Template") :: Model):GetPivot()
	local cf = tycoonSpawn:GetPivot()
	local offset = cf:Inverse() * templateCF
	tycoonSpawn.PivotOffset *= offset
end
for i, tycoonSpawn in ipairs(workspace:WaitForChild("TycoonSpawns"):GetChildren()) do
	if tycoonSpawn:IsA("BasePart") then
		updateTycoonPivot(tycoonSpawn)
	end
end
]]
