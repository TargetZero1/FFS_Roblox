--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local TeleportEvent = RemoteEvents:WaitForChild("TeleportPlayerEvent") :: RemoteEvent
local TycoonFolder = workspace:WaitForChild("TycoonSpawns")
-- Class

TeleportEvent.OnServerEvent:Connect(function(player: Player)
	if player.Character then
		for i = 1, 8 do
			local tycoon = TycoonFolder:FindFirstChild("ClaimTycoon" .. tostring(i))
			if tycoon ~= nil then
				local plotOwnerSign = tycoon:FindFirstChild("PlotOwnerSign")
				if plotOwnerSign and plotOwnerSign:GetAttribute("Owner") == player.Name then
					local character = player.Character
					assert(character, "assertion failed")
					local hrp = character:FindFirstChild("HumanoidRootPart") :: Part?
					assert(hrp, "assertion failed")
					local template = tycoon:FindFirstChild("Template") :: Model?
					assert(template, "assertion failed")
					hrp.Position = template:GetPivot().Position
					break
				end
			end
		end
	end
end)
