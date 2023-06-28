--!strict
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
-- Class
--script to keep track of obby bonuses
Players.LocalPlayer:SetAttribute("EasyObby", false)
Players.LocalPlayer:SetAttribute("HardObby", false)

--event to fire on the server to enable obby bonus again
local ObbyResetEvent = RemoteEvents:WaitForChild("ObbyReset", 20) :: RemoteEvent?
assert(ObbyResetEvent)

--reference to obby wall stored in replicated storage
local ObbyWall = ReplicatedStorage:WaitForChild("Wall", 20) :: Part?
assert(ObbyWall)

--spawn localised walls to block player movement until available again
local function SpawnCooldownWalls(position, Size, Rotation)
	--spawn basic part
	local part = ObbyWall:Clone()
	part.Parent = game.Workspace
	part.Size = Size
	part.Position = position
	part.Orientation = Rotation
	part.Anchored = true

	return part
end

--if player has easy obby  bonus reset after 90 seconds
Players.LocalPlayer:GetAttributeChangedSignal("EasyObby"):Connect(function()
	--reference to obby bonus timer UI
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
	local playerUI = playerGui:WaitForChild("ScreenGui", 20) :: ScreenGui?
	assert(playerUI)
	local timerUI = playerUI:WaitForChild("ObbyTimer", 20)
	assert(timerUI)

	if Players.LocalPlayer:GetAttribute("EasyObby") == true then
		--spawn part at location
		local EasyCooldownWall = SpawnCooldownWalls(Vector3.new(74.472, 11.9, 385.333), Vector3.new(47.365, 28.438, 196.599), Vector3.new(0, 0, 0))

		--set timer for UI display
		timerUI:SetAttribute("TimeRemaining", timerUI:GetAttribute("TimeRemaining") + 90)
		task.wait(90)
		--update values to allow player to claim multiple times
		--	game.Players.LocalPlayer:SetAttribute("EasyObby", false)

		--check if player has another ongoing obby bonus
		if Players.LocalPlayer:GetAttribute("HardObby") == false then
			ObbyResetEvent:FireServer("EasyObby")
		end

		--wait before destroying
		task.wait(15)
		EasyCooldownWall:Destroy()
	end
end)

--if player has easy obby  bonus reset after 180 seconds
Players.LocalPlayer:GetAttributeChangedSignal("HardObby"):Connect(function()
	--reference to obby bonus timer UI
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
	local playerUI = playerGui:WaitForChild("ScreenGui", 20) :: ScreenGui?
	assert(playerUI)
	local timerUI = playerUI:WaitForChild("ObbyTimer", 20)
	assert(timerUI)

	if Players.LocalPlayer:GetAttribute("HardObby") == true then
		--spawn part at location
		local HardCooldownWall = SpawnCooldownWalls(Vector3.new(84.625, 11.9, -180.372), Vector3.new(62.508, 52.958, 188.956), Vector3.new(0, 0, 0))

		--set timer for UI display
		timerUI:SetAttribute("TimeRemaining", timerUI:GetAttribute("TimeRemaining") + 180)
		task.wait(180)
		--update values to allow player to claim multiple times
		--	game.Players.LocalPlayer:SetAttribute("HardObby", false)

		--check if player has another ongoing obby bonus
		if Players.LocalPlayer:GetAttribute("EasyObby") == false then
			ObbyResetEvent:FireServer("HardObby")
		end

		--wait before destroying
		task.wait(15)
		HardCooldownWall:Destroy()
	end
end)
