--!strict
-- Services
local RunService = game:GetService("RunService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- local Draw = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Draw"))

-- Modules
-- Types
-- Constants
local UPDATE_DURATION = 0.5
-- Variables
-- References
local PointA = workspace:WaitForChild("PointA") :: BasePart
local PointB = workspace:WaitForChild("PointB") :: BasePart
-- Class
return function(frame: Frame)
	local maid = Maid.new()
	task.spawn(function()
		local Module = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Onboarding"):WaitForChild("ArrowUtil"))
		local lastUpdate = 0
		maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
			if tick() - lastUpdate > UPDATE_DURATION then
				lastUpdate = tick()
				local renderMaid = maid:GiveTask(Maid.new())
				local container = Module.getContainer(renderMaid)
				local isDone = false

				local points = Module.pathFind(PointA.Position, PointB.Position)
				Module.drawArrows(renderMaid, points, container)
				maid._render = function()
					if not isDone then
						pcall(function()
							container:Destroy()
						end)

						repeat
							task.wait()
						until isDone
					end
					renderMaid:Destroy()
				end
				isDone = true
			end
		end))
	end)
	return function()
		maid:Destroy()
	end
end
