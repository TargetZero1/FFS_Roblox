--!strict
-- Services
local ServerStorage = game:GetService("ServerStorage")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local Template = ServerStorage:WaitForChild("Template") :: Model
local TycoonSpawns = workspace:WaitForChild("TycoonSpawns")

return function()
	task.spawn(function()
		for i, tycoonSpawn in ipairs(TycoonSpawns:GetChildren()) do
			assert(tycoonSpawn:IsA("BasePart"))
			local tycoonTemplate = tycoonSpawn:WaitForChild("Template") :: Model
			local tycoonCF = tycoonTemplate:GetPivot()
			tycoonTemplate:Destroy()
			tycoonTemplate = Template:Clone()
			tycoonTemplate:PivotTo(tycoonCF)
			tycoonTemplate.Parent = tycoonSpawn
		end
	end)

	return function() end
end
