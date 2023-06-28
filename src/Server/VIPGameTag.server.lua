--!strict
-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")
-- Packages
-- Modules
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("PlayerManager"))
local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService")) :: any
-- Types
-- Constants

local GROUP_ID = 11827920 --your group id
local GAMEPASS_ID = 50319918 -- Gamepass ID

-- Variables
-- References
-- Private functions

-- Class
--function to check if player owns the VIP gamepass
function CheckVIP(player: Player)
	--check if player owns gamepass
	local success, msg = pcall(function()
		if MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_ID) then
			--create a tag for the owning player
			local tags = {
				{
					TagText = "Owner", -- Tag
					TagColor = Color3.fromRGB(255, 255, 0), -- VIP Color
				},
			}

			local speaker = nil
			while speaker == nil do
				speaker = ChatService:GetSpeaker(player.Name)
				if speaker ~= nil then
					break
				end
				wait(0.01)
			end
			speaker:SetExtraData("Tags", tags)
			speaker:SetExtraData("ChatColor", Color3.fromRGB(0, 170, 255)) -- Text Color
		end
	end)
	if success then
		warn(msg)
	end
end

--wait for player manager to finish loading data
PlayerManager.PlayerAdded:Connect(function(player: Player)
	--check what role the player has in the group
	local role: string?
	local success, message = pcall(function()
		role = player:GetRoleInGroup(GROUP_ID)
	end)
	if success then
		warn(message)
	end

	--if the player is a developer
	if role == "Developer" then
		--give the player the Developer tag
		local tags = {
			{
				TagText = "Developer", -- Tag
				TagColor = Color3.fromRGB(15, 255, 3), -- VIP Color
			},
		}
		local speaker = nil
		while speaker == nil do
			speaker = ChatService:GetSpeaker(player.Name)
			if speaker ~= nil then
				break
			end
			wait(0.01)
		end
		speaker:SetExtraData("Tags", tags)
		speaker:SetExtraData("ChatColor", Color3.fromRGB(0, 170, 255)) -- Text Color
	end

	--if the player is the owner
	if role == "Owner" then
		--give the player the CEO tag
		local tags = {
			{
				TagText = "Owner", -- Tag
				TagColor = Color3.fromRGB(1, 188, 255), -- VIP Color
			},
		}
		local speaker = nil
		while speaker == nil do
			speaker = ChatService:GetSpeaker(player.Name)
			if speaker ~= nil then
				break
			end
			wait(0.01)
		end
		speaker:SetExtraData("Tags", tags)
		speaker:SetExtraData("ChatColor", Color3.fromRGB(0, 170, 255)) -- Text Color
	end
	CheckVIP(player)
end)
