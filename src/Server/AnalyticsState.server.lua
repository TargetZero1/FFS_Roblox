--!strict
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local TableUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("TableUtil"))
local HashUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("HashUtil"))
local Midas = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Midas"))

-- Modules
local MidasStateTree = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MidasStateTree"))
local GameplayState = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("GameplayState"))
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
local TimerRewardUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TimerRewardUtil"))

-- Types
type Maid = Maid.Maid
type OnboardingData = PlayerManager.OnboardingData
type TimerRewardSaveData = TimerRewardUtil.TimerRewardSaveData
type LevelStatus = "Available" | "Locked" | "Reloading"
-- Variables
-- References
local MapFolder = workspace:WaitForChild("Map")
local MapExtents = MapFolder:WaitForChild("Extents")
local MapStart = MapExtents:WaitForChild("Start") :: BasePart
local MapFinish = MapExtents:WaitForChild("Finish") :: BasePart

-- Constants
local MAP_START = MapStart.Position
local MAP_FINISH = MapFinish.Position
local GAMEPLAY_EVENT_PATH = "GameplayEvent"
local ONBOARDING_CATEGORY_ORDER = {
	"Knead",
	"Bake",
	"Wrap",
	"Collect",
	"Deposit",
	"Deliver",
	"Hatch",
	"Assign",
}

-- Private Functions
function getNormalizedPosition(position: Vector3): Vector2
	local x = (position.X - MAP_START.X)/(MAP_FINISH.X - MAP_START.X)
	local z = (position.Z - MAP_START.Z)/(MAP_FINISH.Z - MAP_START.Z)
	return Vector2.new(x,z)
end

function bootPlayer(player: Player)
	local maid = Maid.new()
	maid:GiveTask(player.Destroying:Connect(function()
		maid:Destroy()
	end))

	MidasStateTree.Rebirths.Count(player, function(): number
		return assert(PlayerManager.getRebirths(player))
	end)


	MidasStateTree.PositionPercent.X(player, function()
		local char = player.Character
		if char then
			local primPart = char.PrimaryPart
			if primPart then
				return getNormalizedPosition(primPart.Position).X
			end
		end
		return nil
	end)

	MidasStateTree.PositionPercent.Z(player, function()
		local char = player.Character
		if char then
			local primPart = char.PrimaryPart
			if primPart then
				return getNormalizedPosition(primPart.Position).Y
			end
		end
		return nil
	end)

	MidasStateTree.GameplayEvent.Explore(player, function()
		return GameplayState.getIfIsExplore(player)
	end)

	MidasStateTree.GameplayEvent.Obby.Easy(player, function()
		return GameplayState.getIfIsEasyObby(player)
	end)

	MidasStateTree.GameplayEvent.Obby.Hard(player, function()
		return GameplayState.getIfIsHardObby(player)
	end)

	MidasStateTree.GameplayEvent.PetHatch(player, function()
		return GameplayState.getIfIsPetHatch(player)
	end)

	MidasStateTree.GameplayEvent.PetManagement(player, function()
		return GameplayState.getIfIsPetManagement(player)
	end)

	MidasStateTree.GameplayEvent.UpgradingTycoon(player, function()
		return GameplayState.getIfIsUpgradingTycoon(player)
	end)

	MidasStateTree.GameplayEvent.RunningStation(player, function()
		return GameplayState.getIfIsRunningStation(player)
	end)

	MidasStateTree.Cash(player, function()
		return PlayerManager.getMoney(player)
	end)

	for i, chapter in ipairs(ONBOARDING_CATEGORY_ORDER) do

		MidasStateTree.Onboarding[chapter].Order(player, function(): number?
			return i
		end)
	
		MidasStateTree.Onboarding[chapter].Completed(player, function(): number?
			local data: OnboardingData? = PlayerManager.getOnboardingData(player)
			if data then
				local count = 0
				for k, v in pairs(data[chapter]) do
					if v then
						count += 1
					end
				end
				return count
			end
			return nil
		end)
	
		MidasStateTree.Onboarding[chapter].Total(player, function(): number?
			local data: OnboardingData? = PlayerManager.getOnboardingData(player)
			if data then
				return #TableUtil.keys(data[chapter])
			end
			return nil
		end)
	end

	for i=1, 12 do
		local function getSaveData(): TimerRewardSaveData
			return PlayerManager.getTimerRewardSaveDataList(player)[i]
		end
		
		MidasStateTree.Timer[`Level{i}`](player, function(): LevelStatus
			local saveData = getSaveData()
			local timeUntilClaim = TimerRewardUtil.getTimeUntilClaimable(saveData)
			local timeUntilReset = TimerRewardUtil.getTimeUntilReset(saveData)
			
			if timeUntilReset <= 0 then
				if timeUntilClaim > 0 then
					return "Locked"
				else
					return "Available"
				end
			else
				return "Reloading"
			end

		end)
	end

	local lastTick = tick()
	local lastHash = ""
	local function getStateHash(): string
		local out = {
			getIfIsExplore = GameplayState.getIfIsExplore(player),
			getIfIsEasyObby = GameplayState.getIfIsEasyObby(player),
			getIfIsHardObby = GameplayState.getIfIsHardObby(player),
			getIfIsPetHatch = GameplayState.getIfIsPetHatch(player),
			getIfIsPetManagement = GameplayState.getIfIsPetManagement(player),
			getIfIsUpgradingTycoon = GameplayState.getIfIsUpgradingTycoon(player),
			getIfIsRunningStation = GameplayState.getIfIsRunningStation(player),
		}
		local outText = HttpService:JSONEncode(out)
		return HashUtil.md5(outText)
	end

	print("reached end of boot for analytics")
	maid:GiveTask(RunService.Heartbeat:Connect(function()
		if tick() - lastTick > 15 then
			lastTick = tick()
			local currentHash = getStateHash()
			if lastHash ~= currentHash then
				print("Updating")
				lastHash = currentHash
				local tracker = Midas:GetTracker(player, GAMEPLAY_EVENT_PATH)
				tracker:Fire("Update")
			end
		end
	end))

end

-- Class
Players.PlayerAdded:Connect(bootPlayer)
for i, player in ipairs(Players:GetPlayers()) do
	bootPlayer(player)
end