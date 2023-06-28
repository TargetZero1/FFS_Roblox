--!strict
-- Services
-- Packages
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
-- Modules
-- Types
-- Constants
local OWNER_USER_ID_KEY = "OwnerUserId"
local GET_IF_UPGRADING = "GetIfUpgrading"
local GET_IF_MANAGING = "GetIfManaging"
local GET_IF_RUNNING = "GetIfRunning"

-- Variables
-- References
local MapFolder = workspace:WaitForChild("Map")
local ZoneFolder = MapFolder:WaitForChild("Zones")
local TycoonZoneFolder = ZoneFolder:WaitForChild("Tycoon")
local TycoonSpawns = workspace:WaitForChild("TycoonSpawns")

NetworkUtil.getRemoteFunction(GET_IF_UPGRADING)
NetworkUtil.getRemoteFunction(GET_IF_MANAGING)
NetworkUtil.getRemoteFunction(GET_IF_RUNNING)

-- Private Functions
function getIfInsidePart(player: Player, part: Part): boolean
	local char = player.Character
	if char then
		local primPart = char.PrimaryPart
		if primPart then
			local params = OverlapParams.new()
			params.FilterDescendantsInstances = {primPart}
			params.FilterType = Enum.RaycastFilterType.Include
			params.RespectCanCollide = false
			local overlaps = workspace:GetPartBoundsInBox(
				part.CFrame,
				part.Size,
				params
			)
			return #overlaps == 1
		end
	end
	return false
end

function getTycoonSpawnPart(player: Player): Part?
	for i, spawnPart in ipairs(TycoonSpawns:GetChildren()) do
		if spawnPart:IsA("Part") then
			if spawnPart:GetAttribute(OWNER_USER_ID_KEY) == player.UserId then
				return spawnPart
			end
		end
	end
	return nil
end

function getTycoonZonePart(player: Player): Part?
	local spawnPart = getTycoonSpawnPart(player)
	
	if spawnPart then
		local plotNumber = assert(spawnPart:GetAttribute("PlotNumber"))
		local part = TycoonZoneFolder:FindFirstChild(tostring(plotNumber))
		assert(part)
		assert(part:IsA("Part"))
		return part
	end

	return nil
end

function getIfInAnyTycoons(player: Player): boolean
	for i, zonePart in ipairs(TycoonZoneFolder:GetChildren()) do
		if zonePart:IsA("Part") then
			if getIfInsidePart(player, zonePart) then
				return true
			end
		end
	end
	return false
end

function getIfInTycoon(player: Player)
	local tycoonZone = getTycoonZonePart(player)
	if tycoonZone then
		return getIfInsidePart(player, tycoonZone)
	else
		return false
	end
end

-- Class
local GameplayState = {}

GameplayState.getIfIsEasyObby = function(player: Player): boolean
	return getIfInsidePart(
		player,
		ZoneFolder:WaitForChild("EasyObby") :: Part
	)
end

GameplayState.getIfIsHardObby = function(player: Player): boolean
	return getIfInsidePart(
		player,
		ZoneFolder:WaitForChild("HardObby") :: Part
	)
end

GameplayState.getIfIsPetHatch = function(player: Player): boolean
	return getIfInsidePart(
		player,
		ZoneFolder:WaitForChild("PetHatch") :: Part
	)
end


GameplayState.getIfIsVisitTycoon = function(player: Player): boolean
	if getIfInAnyTycoons(player) then
		return not getIfInTycoon(player)
	else
		return false
	end
end

GameplayState.getIfIsUpgradingTycoon = function(player: Player): boolean
	if getIfInTycoon(player) then
		local spawnPart = getTycoonSpawnPart(player)
		if spawnPart then
			local val = NetworkUtil.invokeClient(GET_IF_UPGRADING, player)
			if val ~= nil then
				return val
			end
		end
	end
	return false
end

GameplayState.getIfIsPetManagement = function(player: Player): boolean
	if getIfInTycoon(player) then
		local spawnPart = getTycoonSpawnPart(player)
		if spawnPart then
			local val = NetworkUtil.invokeClient(GET_IF_MANAGING, player)
			if val ~= nil then
				return val
			end
		end
	end
	return false
end

GameplayState.getIfIsRunningStation = function(player: Player): boolean
	if getIfInTycoon(player) then
		local spawnPart = getTycoonSpawnPart(player)
		if spawnPart then
			local val = NetworkUtil.invokeClient(GET_IF_RUNNING, player)
			if val ~= nil then
				return val
			end
		end
	end
	return false
end

GameplayState.getIfIsIdleTycoon = function(player: Player): boolean
	if getIfInTycoon(player) then
		if 
			(not GameplayState.getIfIsRunningStation(player))
			and (not GameplayState.getIfIsPetManagement(player))
			and (not GameplayState.getIfIsUpgradingTycoon(player))
		then
			return true
		end
	end
	return false
end

GameplayState.getIfIsExplore = function(player: Player): boolean
	return not (
		GameplayState.getIfIsIdleTycoon(player)
		or GameplayState.getIfIsVisitTycoon(player)
		or GameplayState.getIfIsEasyObby(player)
		or GameplayState.getIfIsHardObby(player)
		or GameplayState.getIfIsPetHatch(player)
	)
end


return GameplayState