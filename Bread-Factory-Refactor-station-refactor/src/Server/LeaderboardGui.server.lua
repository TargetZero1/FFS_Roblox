--!strict
-- Services
-- local DatastoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
-- Packages
-- Modules
-- Types
type SaveData = {
	key: string,
	value: number,
}
-- Constants
-- local REFRESH_RATE = 10

-- Variables
local RebirthTable: { [number]: SaveData }

-- References
-- local PlayerData = DatastoreService:GetDataStore("PlayerData")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local GlobalLeaderboard = BindableEvents:WaitForChild("GlobalLeaderboard")
local BreadLeaderboard = BindableEvents:WaitForChild("BreadLeaderboard")

local LeaderboardFolder = workspace:WaitForChild("Leaderboards")
local LeaderboardModels = LeaderboardFolder:WaitForChild("Models")

local ShowRebirthBoardEvent = GlobalLeaderboard:WaitForChild("ShowRebirthBoard") :: BindableEvent
local ShowDonationBoardEvent = GlobalLeaderboard:WaitForChild("ShowDonationBoard") :: BindableEvent
local ShowMoneyBoardEvent = GlobalLeaderboard:WaitForChild("ShowMoneyBoard") :: BindableEvent
local ShowPlayTimeBoardEvent = GlobalLeaderboard:WaitForChild("ShowPlayTimeBoard") :: BindableEvent
local ShowSourdoughBoardEvent = BreadLeaderboard:WaitForChild("ShowBread1Board") :: BindableEvent

local BreadValueBoard = LeaderboardModels:WaitForChild("BreadValueBoard") :: BasePart
local DonationBoard = LeaderboardModels:WaitForChild("DonationBoard") :: BasePart
local PlayTimeBoard = LeaderboardModels:WaitForChild("PlayTimeBoard") :: BasePart
local RebirthBoard = LeaderboardModels:WaitForChild("RebirthBoard") :: BasePart
local SourdoughValueBoard = LeaderboardModels:WaitForChild("SourdoughValueBoard") :: BasePart

-- local AdminSettings = ReplicatedFirst:WaitForChild("AdminControls", 20)
-- if(AdminSettings ~= nil) then
-- 	if(AdminSettings:GetAttribute("LeaderboardRefreshTimer") ~= nil) then
-- 		if(AdminSettings:GetAttribute("LeaderboardRefreshTimer") >= 10) then
-- 			REFRESH_RATE = AdminSettings:GetAttribute("LeaderboardRefreshTimer")
-- 		end
-- 	end
-- end
-- Private Functions

function bootLeadboard(leaderboardPart: BasePart, updateEvent: BindableEvent, formatText: (value: number) -> string)
	local surfaceGui = leaderboardPart:WaitForChild("SurfaceGui") :: SurfaceGui
	local scrollingFrame = surfaceGui:WaitForChild("ScrollingFrame") :: ScrollingFrame
	local topFrame = surfaceGui:WaitForChild("Frame") :: Frame
	local playerName = topFrame:WaitForChild("PlayerName") :: TextLabel
	local playerFace = topFrame:WaitForChild("PlayerFace") :: ImageLabel
	local sampleTemplate = scrollingFrame:WaitForChild("Sample") :: Frame

	local function updateFirstPosition(savedData: SaveData)
		local thumbType = Enum.ThumbnailType.HeadShot
		local thumbSize = Enum.ThumbnailSize.Size48x48

		--loop through cash page SavedData is the cash value on this player
		local userId = tonumber(savedData.key)
		if userId and userId > 0 then
			--get the players username
			local username = Players:GetNameFromUserIdAsync(userId)
			--variable for cash value
			local value = savedData.value

			--check if cash exists
			if value then
				--Setup the top of the leaderboard
				playerName.Text = username

				local content, _isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
				playerFace.Image = content

				topFrame.Visible = true
			end
		end
	end

	--function used to update leaderboard
	local function refreshLeaderboard()
		--avoid errors breaking game
		pcall(function()
			local thumbType = Enum.ThumbnailType.HeadShot
			local thumbSize = Enum.ThumbnailSize.Size48x48

			--loop through cash page SavedData is the cash value on this player
			for rank, savedData in ipairs(RebirthTable) do
				local userId = tonumber(savedData.key)
				if userId and userId > 0 then
					if rank == 1 then
						updateFirstPosition(savedData)
					end

					--get the players username
					local username = Players:GetNameFromUserIdAsync(userId)
					--variable for cash value
					local value = savedData.value

					--check if cash exists
					if value then
						--clone example GUI
						local sample = sampleTemplate:Clone()
						sample.Position = sample.Position + UDim2.new(0, 0, 0.2 * (rank - 1), 0)
						--set leadderboard entry to visible
						sample.Visible = true
						--set parent to frame
						sample.Parent = scrollingFrame
						--rename it so user can tell who is who
						sample.Name = username

						--Set up UI infolocal content, isReady = Players:GetUserThumbnailAsync(p.UserId, thumbType, thumbSize)
						local content, _isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
						local profileIcon = sample:WaitForChild("ProfileIcon") :: ImageLabel
						local rankLabel = sample:WaitForChild("RankLabel") :: TextLabel
						local nameLabel = sample:WaitForChild("NameLabel") :: TextLabel
						local cashLabel = sample:WaitForChild("CashLabel") :: TextLabel

						profileIcon.Image = content
						profileIcon.Visible = true
						rankLabel.Text = "#" .. tostring(rank)
						nameLabel.Text = username
						cashLabel.Text = formatText(value)
					end
				end
			end
		end)
	end

	updateEvent.Event:Connect(function(params: { [number]: SaveData })
		RebirthTable = params

		--hide the top of the board
		topFrame.Visible = false

		-- gets all children of the surface gui
		for i, frame in pairs(scrollingFrame:GetChildren()) do
			--checks if frame isn't the default
			if frame.Name ~= "Sample" and frame:IsA("Frame") then
				--delete everything
				frame:Destroy()
			end
		end
		refreshLeaderboard()
	end)
end

-- Class
bootLeadboard(RebirthBoard, ShowRebirthBoardEvent, function(value: number): string
	return if value ~= 0 and value ~= 1 then tostring(value) .. " Rebirths" else tostring(value) .. " Rebirth"
end)
bootLeadboard(DonationBoard, ShowDonationBoardEvent, function(value: number): string
	return "R$" .. tostring(value)
end)
bootLeadboard(BreadValueBoard, ShowMoneyBoardEvent, function(value: number): string
	return tostring(value) --"$"..tostring(value)
end)
bootLeadboard(PlayTimeBoard, ShowPlayTimeBoardEvent, function(seconds: number): string
	local function fmt(int: number): string
		return string.format("%02i", int)
	end

	local minutes = math.floor(seconds / 60)
	local hours = math.floor(minutes / 60)
	minutes = minutes - hours * 60
	local days = math.floor(hours / 24)
	hours = hours - days * 24

	--calculate seconds remaining after determining amount of time spent elsewhere(hours,minutes, etc.)
	local secs = seconds - (minutes * 60) - (hours * 3600) - (days * 86400)

	--return the correct string
	return fmt(days) .. ":" .. fmt(hours) .. ":" .. fmt(minutes) .. ":" .. fmt(secs) .. "s"
end)
bootLeadboard(SourdoughValueBoard, ShowSourdoughBoardEvent, function(value: number): string
	return tostring(value) --"$"..tostring(value)
end)
