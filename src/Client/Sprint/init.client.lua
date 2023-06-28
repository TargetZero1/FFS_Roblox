--!strict
-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Packages
-- Modules
-- Types
-- Constants
local SPRINT_SPEED = 50
local WALK_SPEED = 16

-- Variables
-- References
local player = Players.LocalPlayer

-- Class
UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			local character = player.Character
			assert(character, "bad assertion")
			local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid
			assert(humanoid, "bad assertion")
			humanoid.WalkSpeed = SPRINT_SPEED
		end
	end
end)

UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			local character = player.Character
			assert(character, "bad assertion")
			local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid
			assert(humanoid, "bad assertion")
			humanoid.WalkSpeed = WALK_SPEED
		end
	end
end)
