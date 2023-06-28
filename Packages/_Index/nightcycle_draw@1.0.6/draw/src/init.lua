local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Terrain = Workspace.Terrain

local ORIGINAL_DEFAULT_COLOR = Color3.new(1, 0, 0)

function getDefaultParent(): Instance
	if not RunService:IsRunning() then
		return Workspace.CurrentCamera
	end

	if RunService:IsServer() then
		return Workspace
	else
		return Workspace.CurrentCamera
	end
end

function point(position: Vector3, color: Color3?, parent: Instance?, diameter: number?): Part
	if typeof(position) == "CFrame" then
		position = position.p
	end

	assert(typeof(position) == "Vector3", "Bad position")

	color = color or ORIGINAL_DEFAULT_COLOR
	parent = parent or getDefaultParent()
	diameter = diameter or 1
	assert(color ~= nil and parent ~= nil and diameter ~= nil)

	local part = Instance.new("Part")
	part.Material = Enum.Material.ForceField
	part.Anchored = true
	part.Archivable = false
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(position)
	part.Color = color
	part.Name = "DebugPoint"
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(diameter, diameter, diameter)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.Transparency = 0.5

	local sphereHandle = Instance.new("SphereHandleAdornment")
	sphereHandle.Archivable = false
	sphereHandle.Radius = diameter/4
	sphereHandle.Color3 = color
	sphereHandle.AlwaysOnTop = true
	sphereHandle.Adornee = part
	sphereHandle.ZIndex = 2
	sphereHandle.Parent = part

	part.Parent = parent

	return part
end

function _ray(ray: Ray, color: Color3?, parent: Instance?, meshDiameter: number?, diameter: number?): Part
	assert(typeof(ray) == "Ray", "Bad typeof(ray) for Ray")

	color = color or ORIGINAL_DEFAULT_COLOR
	parent = parent or getDefaultParent()
	meshDiameter = meshDiameter or 0.2
	diameter = diameter or 0.2
	assert(meshDiameter ~= nil and diameter ~= nil and parent ~= nil and color ~= nil)

	local rayCenter = ray.Origin + ray.Direction/2

	local part = Instance.new("Part")
	part.Material = Enum.Material.ForceField
	part.Anchored = true
	part.Archivable = false
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(rayCenter, ray.Origin + ray.Direction) * CFrame.Angles(math.pi/2, 0, 0)
	part.Color = color
	part.Name = "DebugRay"
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(diameter, ray.Direction.Magnitude, diameter)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.Transparency = 0.5

	local rotatedPart = Instance.new("Part")
	rotatedPart.Name = "RotatedPart"
	rotatedPart.Anchored = true
	rotatedPart.Archivable = false
	rotatedPart.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	rotatedPart.CastShadow = false
	rotatedPart.CFrame = CFrame.new(ray.Origin, ray.Origin + ray.Direction)
	rotatedPart.Transparency = 1
	rotatedPart.Size = Vector3.new(1, 1, 1)
	rotatedPart.Parent = part

	local lineHandleAdornment = Instance.new("LineHandleAdornment")
	lineHandleAdornment.Name = "DrawRayLineHandleAdornment"
	lineHandleAdornment.Length = ray.Direction.Magnitude
	lineHandleAdornment.Thickness = 5*diameter
	lineHandleAdornment.ZIndex = 3
	lineHandleAdornment.Color3 = color
	lineHandleAdornment.AlwaysOnTop = true
	lineHandleAdornment.Transparency = 0
	lineHandleAdornment.Adornee = rotatedPart
	lineHandleAdornment.Parent = rotatedPart

	local mesh = Instance.new("SpecialMesh")
	mesh.Name = "DrawRayMesh"
	mesh.Scale = Vector3.new(0, 1, 0) + Vector3.new(meshDiameter, 0, meshDiameter) / diameter
	mesh.Parent = part

	part.Parent = parent

	return part
end

function cframe(cf: CFrame): Model
	local model = Instance.new("Model")
	model.Name = "DebugCFrame"

	local position: Vector3 = cf.Position
	local _pointPart = point(position, nil, model, 0.1)

	local xRay = _ray(
		Ray.new(
		position,
		cf.XVector
	), Color3.new(0.75, 0.25, 0.25), model, 0.1)
	xRay.Name = "XVector"
	
	local yRay = _ray(Ray.new(
		position,
		cf.YVector
	), Color3.new(0.25, 0.75, 0.25), model, 0.1)
	yRay.Name = "YVector"

	local zRay = _ray(Ray.new(
		position,
		cf.ZVector
	), Color3.new(0.25, 0.25, 0.75), model, 0.1)
	zRay.Name = "ZVector"

	model.Parent = getDefaultParent()

	return model
end

local Draw = {
	_defaultColor = ORIGINAL_DEFAULT_COLOR,
	cframe = cframe,
	getDefaultParent = getDefaultParent,
	ray = _ray,
	point = point,
}

function Draw.updateRay(part: BasePart, ray: Ray, color: Color3?): nil
	color = color or part.Color
	assert(color ~= nil)

	local diameter = part.Size.X
	local rayCenter = ray.Origin + ray.Direction/2

	part.CFrame = CFrame.new(rayCenter, ray.Origin + ray.Direction) * CFrame.Angles(math.pi/2, 0, 0)
	part.Size = Vector3.new(diameter, ray.Direction.Magnitude, diameter)
	part.Color = color

	local rotatedPart = part:FindFirstChild("RotatedPart")
	if rotatedPart then
		rotatedPart.CFrame = CFrame.new(ray.Origin, ray.Origin + ray.Direction)
	end

	local lineHandleAdornment = rotatedPart and rotatedPart:FindFirstChild("DrawRayLineHandleAdornment")
	if lineHandleAdornment then
		lineHandleAdornment.Length = ray.Direction.Magnitude
		lineHandleAdornment.Thickness = 5*diameter
		lineHandleAdornment.Color3 = color
	end
	return nil
end

function Draw.text(adornee: (Instance | Vector3), text: string, color: Color3?): Attachment | BillboardGui
	color = color or ORIGINAL_DEFAULT_COLOR
	assert(color ~= nil)
	if typeof(adornee) == "Vector3" then
		local attachment = Instance.new("Attachment")
		attachment.WorldPosition = adornee
		attachment.Parent = Terrain
		attachment.Name = "DebugTextAttachment"

		Draw._textOnAdornee(attachment, text, color)

		return attachment
	elseif typeof(adornee) == "Instance" then
		return Draw._textOnAdornee(adornee, text, color)
	else
		error("Bad adornee")
	end
end

function Draw._textOnAdornee(adornee: Instance, text: string, color: Color3?): BillboardGui
	color = color or ORIGINAL_DEFAULT_COLOR
	assert(color ~= nil)

	local TEXT_HEIGHT_STUDS = 2
	local PADDING_PERCENT_OF_LINE_HEIGHT = 0.5

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "DebugBillboardGui"
	billboardGui.SizeOffset =  Vector2.new(0, 0.5)
	billboardGui.ExtentsOffset = Vector3.new(0, 1, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Adornee = adornee
	billboardGui.StudsOffset = Vector3.new(0, 0, 0.01)

	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.new(1, 0, 1, 0)
	background.Position = UDim2.new(0.5, 0, 1, 0)
	background.AnchorPoint = Vector2.new(0.5, 1)
	background.BackgroundTransparency = 0.3
	background.BorderSizePixel = 0
	background.BackgroundColor3 = color or ORIGINAL_DEFAULT_COLOR
	background.Parent = billboardGui

	local textLabel = Instance.new("TextLabel")
	textLabel.Text = tostring(text)
	textLabel.TextScaled = true
	textLabel.TextSize = 32
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Parent = background

	if tonumber(text) then
		textLabel.Font = Enum.Font.Code
	else
		textLabel.Font = Enum.Font.GothamMedium
	end

	local textSize = TextService:GetTextSize(
		textLabel.Text,
		textLabel.TextSize,
		textLabel.Font,
		Vector2.new(1024, 1e6))

	local lines = textSize.y/textLabel.TextSize

	local paddingOffset = textLabel.TextSize*PADDING_PERCENT_OF_LINE_HEIGHT
	local paddedHeight = textSize.y + 2*paddingOffset
	local paddedWidth = textSize.x + 2*paddingOffset
	local aspectRatio = paddedWidth/paddedHeight

	local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
	uiAspectRatio.AspectRatio = aspectRatio
	uiAspectRatio.Parent = background

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingBottom = UDim.new(paddingOffset/paddedHeight, 0)
	uiPadding.PaddingTop = UDim.new(paddingOffset/paddedHeight, 0)
	uiPadding.PaddingLeft = UDim.new(paddingOffset/paddedWidth, 0)
	uiPadding.PaddingRight = UDim.new(paddingOffset/paddedWidth, 0)
	uiPadding.Parent = background

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(paddingOffset/paddedHeight/2, 0)
	uiCorner.Parent = background

	local height = lines*TEXT_HEIGHT_STUDS * TEXT_HEIGHT_STUDS*PADDING_PERCENT_OF_LINE_HEIGHT

	billboardGui.Size = UDim2.new(height*aspectRatio, 0, height, 0)
	billboardGui.Parent = adornee

	return billboardGui
end

function Draw.sphere(position: Vector3, radius: number, color: Color3?, parent: Instance?): Part
	return Draw.point(position, color, parent, radius*2)
end

function Draw.labelledPoint(position: (Vector3 | CFrame), label: string, color: Color3?, parent: Instance?): Part
	if typeof(position) == "CFrame" then
		position = position.Position
	end
	assert(typeof(position) == "Vector3")
	color = color or ORIGINAL_DEFAULT_COLOR
	local part = Draw.point(position, color, parent)

	Draw.text(part, label, color)

	return part
end

function Draw.box(cf: (CFrame | Vector3), size: Vector3, color: Color3?): Part

	color = color or ORIGINAL_DEFAULT_COLOR

	cf = typeof(cf) == "Vector3" and CFrame.new(cf) or cf
	assert(typeof(cf) == "CFrame" and color ~= nil)

	local part = Instance.new("Part")
	part.Color = color
	part.Material = Enum.Material.ForceField
	part.Name = "DebugPart"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Archivable = false
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.TopSurface = Enum.SurfaceType.Smooth
	part.Transparency = 0.75
	part.Size = size
	part.CFrame = cf

	local boxHandleAdornment = Instance.new("BoxHandleAdornment")
	boxHandleAdornment.Adornee = part
	boxHandleAdornment.Size = size
	boxHandleAdornment.Color3 = color
	boxHandleAdornment.AlwaysOnTop = true
	boxHandleAdornment.Transparency = 0.75
	boxHandleAdornment.ZIndex = 1
	boxHandleAdornment.Parent = part

	part.Parent = Draw.getDefaultParent()

	return part
end

function Draw.region3(region3: Region3, color: Color3?): Part
	return Draw.box(region3.CFrame, region3.Size, color)
end

function Draw.terrainCell(position: Vector3, color: Color3?): Part
	local size = Vector3.new(4, 4, 4)

	color = color or ORIGINAL_DEFAULT_COLOR
	assert(color ~= nil)

	local solidCell = Terrain:WorldToCell(position)
	local terrainPosition = Terrain:CellCenterToWorld(solidCell.x, solidCell.y, solidCell.z)

	local part = Draw.box(CFrame.new(terrainPosition), size, color)
	part.Name = "DebugTerrainCell"

	return part
end

function Draw.vector(position: Vector3, direction: Vector3, color: Color3?, parent: Instance?, meshDiameter: number?): Part
	return Draw.ray(Ray.new(position, direction), color, parent, meshDiameter, nil)
end

-- export type Draw = typeof(Draw)
-- 
-- local drawUtil: Draw = Draw

return Draw