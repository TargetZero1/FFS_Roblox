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
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local PlayerDonated = BindableEvents:WaitForChild("PlayerDonated") :: BindableEvent
local BakersDozen = BindableEvents:WaitForChild("BakersDozen") :: BindableEvent
local RebirthEvent = BindableEvents:WaitForChild("Rebirth") :: BindableEvent
local FeedTheWorld = BindableEvents:WaitForChild("FeedTheWorld") :: BindableEvent

--badge for joining the game initally
local function joinGame(player: Player)
	--badge for starting the game
	local BadgeID = 2127676687
	if game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, BadgeID) == false then
		game:GetService("BadgeService"):AwardBadge(player.UserId, BadgeID)
	end
end

--badge for meeting a member of the team
local function metADev(player: Player)
	local developersTable = {
		"Bethanytheanimator",
		"jpm3design",
		"BWhite_NSG",
		"Jimbulothy",
		"Betelgeuse_87",
		"4udioMonkey",
		"FacelessMochi",
	}
	local metDeveloper = false

	--badge for meeting a member of the team
	local badgeID = 2127676832

	for i, Dev in pairs(developersTable) do
		if player.Name == Dev then
			metDeveloper = true
		end
	end

	if metDeveloper == true then
		for i, player in pairs(Players:GetPlayers()) do
			if game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, badgeID) == false then
				game:GetService("BadgeService"):AwardBadge(player.UserId, badgeID)
			end
		end
	end
end

local function metTheCEO(player: Player)
	--badge for meeting the CEO
	local badgeID = 2127676840

	if player.Name == "BWhite_NSG" then
		--Get all current Players in game
		for i, player in pairs(Players:GetPlayers()) do
			if game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, badgeID) == false then
				game:GetService("BadgeService"):AwardBadge(player.UserId, badgeID)
			end
		end
	end
end

--Events to trigger badge rewards
PlayerDonated.Event:Connect(function(player: Player)
	--badge for donating to the team
	local BadgeID = 2127676821

	--check if player has not already got the badge
	if game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, BadgeID) == false then
		--give them the badge
		game:GetService("BadgeService"):AwardBadge(player.UserId, BadgeID)
	end
end)

BakersDozen.Event:Connect(function(player: Player)
	--badge for delivering 13 loafs of bread
	local BadgeID = 2127676714

	--check if player has not already got the badge
	if game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, BadgeID) == false then
		--give them the badge
		game:GetService("BadgeService"):AwardBadge(player.UserId, BadgeID)
	end
end)

RebirthEvent.Event:Connect(function(player: Player)
	--badge for rebirthing in the game
	local BadgeID = 2127676735

	--check if player has not already got the badge
	if game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, BadgeID) == false then
		--give them the badge
		game:GetService("BadgeService"):AwardBadge(player.UserId, BadgeID)
	end
end)

FeedTheWorld.Event:Connect(function(player: Player)
	--badge for feeding everyone in the game
	local BadgeID = 2127678716

	--check if player has not already got the badge
	if game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, BadgeID) == false then
		--give them the badge
		game:GetService("BadgeService"):AwardBadge(player.UserId, BadgeID)
	end
end)
--check for badges when player joins
Players.PlayerAdded:Connect(function(player)
	joinGame(player)
	metADev(player)
	metTheCEO(player)
end)
