--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
-- Packages
-- Modules
local ReferenceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
-- Types
-- Constants
local OBBY_RESET_PART_NAME = "ObbyResetPart"
local BONUS_PART_NAME = "Bonus"
local SPAWN_PART_NAME = "Spawn"
local MOVING_PART_NAME = "sm_bread_pain_au_levain"
-- Variables
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local SoundEvent = RemoteEvents:WaitForChild("PlaySoundEvent") :: RemoteEvent
local ObbiesFolder = workspace:WaitForChild("ObbiesFolder")
local EasyObbyFolder = ObbiesFolder:WaitForChild("EasyObby") :: Folder
local HardObbyFolder = ObbiesFolder:WaitForChild("HardObby") :: Folder
-- local PauseSong = BindableEvents:WaitForChild("PauseSong") :: BindableEvent
local TycoonSpawns = workspace:WaitForChild("TycoonSpawns")
local OnCompleteObby = BindableEvents:WaitForChild("ObbyComplete") :: BindableEvent

-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
function initResetPart(resetPart: BasePart)
	assert(resetPart.Name == OBBY_RESET_PART_NAME, "assertion failed")
	--reference to the ObbyReswpanPart
	local parent = _getParent(resetPart)
	local respawnPosition = _getChild(parent, SPAWN_PART_NAME) :: BasePart

	resetPart.Touched:Connect(function(hit: BasePart)
		--get whatever character touched the pad
		local char = hit:FindFirstAncestorWhichIsA("Model")

		--check character exists
		if char ~= nil then
			--get the player attached to the character
			local player = game:GetService("Players"):GetPlayerFromCharacter(char)

			--check if the touched part has a humanoid part
			local hrp = char.PrimaryPart

			if hrp and player then
				--teleport the player when they touch the part
				hrp.Position = respawnPosition.Position

				--play sound effect
				SoundEvent:FireClient(player, "ResetSound")
			end
		end
	end)
end

function initBonusPart(bonusPart: BasePart, obbyName: string)
	-- print("init part 1", bonusPart)
	assert(bonusPart.Name == BONUS_PART_NAME, "assertion failed")
	-- print("init part 2", bonusPart)
	bonusPart.Transparency = 0 --1
	bonusPart.CanCollide = false
	bonusPart.CanQuery = true
	bonusPart.CanTouch = true
	--define the player manager
	-- print("init part 3", bonusPart)
	local parent = _getParent(bonusPart)
	local respawnPosition = _getChild(parent, SPAWN_PART_NAME) :: BasePart
	-- print("init part 4", bonusPart)
	local lastTouched: Player?

	--event to fire to tell sound manager to pause the song
	--hook up collection event for when player touches the pad
	bonusPart.Touched:Connect(function(hit: BasePart)
		local character = hit:FindFirstAncestorWhichIsA("Model")
		-- print("A")
		if character then
			local player = game:GetService("Players"):GetPlayerFromCharacter(character)
			-- print("B")
			--check character exists
			if player and lastTouched ~= player then
				-- print("C")
				--get the player attached to the character
				lastTouched = player

				--check if the touched part has a humanoid part
				local hrp = character.PrimaryPart

				if hrp then
					-- print("D")
					--check player that touched the bank is the owner of this tycoon
					player:SetAttribute(obbyName, true)
					local spawnFound = false
					for i = 1, 8 do
						local tycoon = TycoonSpawns:FindFirstChild("ClaimTycoon" .. tostring(i))
						if tycoon then
							local plotOwnerSign = _getChild(tycoon, "PlotOwnerSign")
							if plotOwnerSign:GetAttribute("Owner") == player.Name then
								local templateModel = _getChild(tycoon, "Template") :: Model
								if templateModel then
									-- print("D2")
									hrp.Position = templateModel:GetPivot().Position
									spawnFound = true
								end
								break
							end
						end
					end
					--If the player doesn't own a tycoon they will not have been reset.
					if not spawnFound then
						-- print("E")
						--teleport the player when they touch the part
						hrp.Position = respawnPosition.Position
					end
				end

				OnCompleteObby:Fire(player, obbyName)

				-- PauseSong:Fire()

				--choose a random SFX
				local chosenSFX = math.random(1, 2)

				if chosenSFX == 1 then
					--play sound effect
					SoundEvent:FireClient(player, "RewardSound")
				else
					--play sound effect
					SoundEvent:FireClient(player, "RewardSound2")
				end
			end
		end
	end)
	-- print("init part 6", bonusPart)
end

function initMover(movingPart: BasePart)
	assert(movingPart.Name == MOVING_PART_NAME, "assertion failed")

	local TweenService = game:GetService("TweenService")

	local tweenInfo = TweenInfo.new(
		2.5, --Time
		Enum.EasingStyle.Linear, --EasingStyle
		Enum.EasingDirection.In, --EasingDirection
		-1, --Repeat Count
		true, --Reverse
		0.5 --Delay Time
	)

	local tween = TweenService:Create(movingPart, tweenInfo, {
		Position = Vector3.new(movingPart.Position.X, 15, movingPart.Position.Z),
	})
	tween:Play()

	local lastPosition = movingPart.Position
	RunService.Heartbeat:Connect(function(deltaTime)
		local currentPosition = movingPart.Position
		local deltaPosition = currentPosition - lastPosition

		local velocity = deltaPosition / deltaTime

		movingPart.AssemblyLinearVelocity = velocity

		lastPosition = currentPosition
	end)
end

function initObby(obbyFolder: Folder)
	local obbyParts = obbyFolder:WaitForChild("ObbyParts")
	for i, part in ipairs(obbyParts:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Name == OBBY_RESET_PART_NAME then
				initResetPart(part)
			elseif part.Name == BONUS_PART_NAME then
				initBonusPart(part, obbyFolder.Name)
			elseif part.Name == MOVING_PART_NAME then
				initMover(part)
			end
		end
	end
end

initObby(EasyObbyFolder)
initObby(HardObbyFolder)
