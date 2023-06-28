--!strict
-- Services
-- local PathfindingService = game:GetService("PathfindingService")

-- Packages
-- local GeometryUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("GeometryUtil"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- local Draw = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Draw"))

-- Modules
-- Types
type Maid = Maid.Maid
type PathfindingConfig = {
	AgentRadius: number,
	AgentHeight: number,
	AgentCanJump: boolean,
	AgentCanClimb: boolean,
	WaypointSpacing: number,
	Costs: {[string]: number},
}
-- Constants
-- local CONSTANT_HEIGHT = 0
local BEAM_OFFSET = 3
local BEAM_COLOR = Color3.fromHSV(0.125,1,1)
-- Variables
-- References
-- local Path = PathfindingService:CreatePath({
-- 	AgentRadius = 8,
-- 	AgentHeight = 7,
-- 	AgentCanJump = true,
-- 	AgentCanClimb = false,
-- 	WaypointSpacing = 2,
-- 	Costs = {
-- 		Plastic = 1,
-- 		Slate = 1,
-- 		Mud = 1,
-- 		Grass = 100,
-- 		Foil = 1000,
-- 	},
-- })
-- Private Functions
-- function fromBuildCFrame(cf: CFrame): CFrame
-- 	return cf * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(0, 0, math.rad(-90))
-- end

function toBuildCFrame(cf: CFrame): CFrame
	return cf * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(0, math.rad(90), 0)
end
-- Class
local ArrowUtil = {}

function ArrowUtil.pathFind(origin: Vector3, goal: Vector3): {[number]: Vector3}
	-- -- origin *= Vector3.new(1,0,1)
	-- -- origin += Vector3.new(0,CONSTANT_HEIGHT,0)

	-- -- goal *= Vector3.new(1,0,1)
	-- -- goal += Vector3.new(0,CONSTANT_HEIGHT,0)

	-- local function smoothPath(points: {[number]: Vector3}): {[number]: Vector3}
	-- 	for i, point in ipairs(points) do
	-- 		local targetPoint = points[i+1]
	-- 		local referencePoint = points[i+2]
	-- 		if targetPoint and referencePoint then
	-- 			local targetNormal = (targetPoint - point).Unit
	-- 			local referenceNormal = (referencePoint - targetPoint).Unit
	-- 			local angle = GeometryUtil.getAngleBetweenTwoLines(
	-- 				{
	-- 					point*Vector3.new(1,0,1), 
	-- 					point*Vector3.new(1,0,1) + targetNormal*Vector3.new(1,0,1)
	-- 				}, 
	-- 				{
	-- 					point*Vector3.new(1,0,1), 
	-- 					point*Vector3.new(1,0,1) + referenceNormal*Vector3.new(1,0,1)
	-- 				}
	-- 			)
	-- 			if angle <= math.rad(1) then
	-- 				local copy = table.clone(points)
	-- 				table.remove(copy, i+1)
	-- 				return smoothPath(copy)
	-- 			end
	-- 		end
	-- 	end
	-- 	return points
	-- end
	-- local success, errorMessage = pcall(function()
	-- 	Path:ComputeAsync(origin, goal)
	-- end)
	-- if success and Path.Status == Enum.PathStatus.Success then
	-- 	-- Get the path waypoints
	-- 	local waypoints = Path:GetWaypoints()
	-- 	local points = {}
	-- 	for i, waypoint in ipairs(waypoints) do
	-- 		table.insert(points, waypoint.Position)
	-- 	end
	-- 	return smoothPath(points)
	-- else
	-- 	warn(tostring(errorMessage))
	-- end

	return {origin, origin:Lerp(goal, 0.5), goal}
	
end

function ArrowUtil.getContainer(maid: Maid): Part
	local container = maid:GiveTask(Instance.new("Part"))
	container.Anchored = true
	container.Transparency = 1
	container.CanCollide = false
	container.CanTouch = false
	container.CanQuery = false
	container.Name = "BeamContainer"
	return container
end

function ArrowUtil.drawArrows(maid: Maid, points: {[number]: Vector3}, container: Part): ()


	local directions = {}
	for i, point in ipairs(points) do
		local nxtPoint = points[i+1]
		local prevPoint = points[i-1]
		if prevPoint and nxtPoint then
			directions[i] = (nxtPoint - prevPoint).Unit
		elseif nxtPoint then
			directions[i] = (nxtPoint - point).Unit
		elseif prevPoint then
			directions[i] = (point - prevPoint).Unit
		end
	end
	for i, point in ipairs(points) do
		-- if i > 1 then
		local direction = directions[i]
		local nxtDirection = directions[i+1]
		local nxtPoint = points[i+1]
		if nxtPoint and direction and nxtDirection then
			nxtPoint += Vector3.new(0,BEAM_OFFSET,0)
			point += Vector3.new(0,BEAM_OFFSET,0)
			-- local controlPoint = GeometryUtil.getClosestPointToLineOnLine({nxtPoint, -nxtDirection}, {point, direction})
			-- if controlPoint then
			local nxtCF = CFrame.new(nxtPoint, nxtPoint - nxtDirection)
			local cf = CFrame.new(point, point - direction)
			local dist = (cf.Position - nxtCF.Position).Magnitude

			local attachment0 = maid:GiveTask(Instance.new("Attachment"))
			attachment0.Name = `{i}_0`
			attachment0.Parent = container
			attachment0.WorldCFrame = toBuildCFrame(nxtCF)
			
			local attachment1 = maid:GiveTask(Instance.new("Attachment"))
			attachment1.Name = `{i}_1`
			attachment1.Parent = container
			attachment1.WorldCFrame = toBuildCFrame(cf)

			local beam = maid:GiveTask(Instance.new("Beam"))
			beam.Name = `Beam{i}`
			beam.Attachment0 = attachment0
			beam.Attachment1 = attachment1
			beam.Texture = "http://www.roblox.com/asset/?id=9006027964"
			beam.LightEmission = 1
			beam.LightInfluence = 0.5
			beam.Color = ColorSequence.new(BEAM_COLOR)
			beam.ZOffset = 2
			beam.Segments = 20
			beam.FaceCamera = false
			beam.TextureMode = Enum.TextureMode.Wrap
			beam.TextureLength = 5
			beam.TextureSpeed = -2
			beam.Width0 = 4
			beam.Width1 = beam.Width0
			beam.CurveSize0 = dist * 0.3
			beam.CurveSize1 = dist * 0.3
			beam.Parent = container
			-- end
		end
		-- end
		
	end

	container.Parent = workspace
end

return ArrowUtil