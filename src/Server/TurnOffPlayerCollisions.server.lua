--!strict
-- Services
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Class
PhysicsService:RegisterCollisionGroup("Player")
PhysicsService:RegisterCollisionGroup("Bread")
PhysicsService:CollisionGroupSetCollidable("Player", "Player", false)
PhysicsService:CollisionGroupSetCollidable("Player", "Bread", false)
PhysicsService:CollisionGroupSetCollidable("Bread", "Bread", false)

function noCollide(model: Model)
	for k, v in pairs(model:GetChildren()) do
		if v:IsA("BasePart") then
			v.CollisionGroup = "Player"
		end
	end
end

Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(char)
		char:WaitForChild("HumanoidRootPart")
		char:WaitForChild("Head")
		char:WaitForChild("Humanoid")
		task.wait(0.1)
		noCollide(char)

		if player.Character then
			noCollide(player.Character)
		end
	end)
end)
