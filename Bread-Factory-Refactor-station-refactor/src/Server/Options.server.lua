--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local MuteSFX = RemoteEvents:WaitForChild("MuteSFX") :: RemoteEvent
local HideArrow = RemoteEvents:WaitForChild("HideArrow") :: RemoteEvent

-- Class
Players.PlayerAdded:Connect(function(player: Player)
	player:SetAttribute("MuteSFX", false)
	player:SetAttribute("ShowArrow", true)
end)

MuteSFX.OnServerEvent:Connect(function(player: Player)
	if player:GetAttribute("MuteSFX") ~= nil then
		if player:GetAttribute("MuteSFX") == true then
			player:SetAttribute("MuteSFX", false)
		else
			player:SetAttribute("MuteSFX", true)
		end
	end
end)

HideArrow.OnServerEvent:Connect(function(player: Player)
	if player:GetAttribute("ShowArrow") ~= nil then
		if player:GetAttribute("ShowArrow") == true then
			player:SetAttribute("ShowArrow", false)
		else
			player:SetAttribute("ShowArrow", true)
		end
	end
end)
