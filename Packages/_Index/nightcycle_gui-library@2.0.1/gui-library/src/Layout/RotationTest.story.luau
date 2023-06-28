--!strict
local RunService = game:GetService("RunService")

-- Packages
local LayoutModule = script.Parent
assert(LayoutModule)
local Package = LayoutModule.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))
type State<T> = ColdFusion.State<T>
type Maid = Maid.Maid


function getSolvedAbsoluteSizeState(frame: Frame, maid: Maid): State<UDim2>
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _clone = _fuse.clone
	local _import = _fuse.import
	
	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local AbsoluteSize = _Value(UDim2.fromOffset(frame.AbsoluteSize.X,frame.AbsoluteSize.Y))

	local guiChildren: {[GuiObject]: Maid} = {}
	local function rotateVector2(origin: Vector2, offset: Vector2, angle: number): Vector2
		local sinAngle = math.sin(math.rad(angle))
		local cosAngle = math.cos(math.rad(angle))
		local point = origin + offset
	
		local pointRelativeToOrigin = point - origin
	
		local rotatedX = pointRelativeToOrigin.X * cosAngle - pointRelativeToOrigin.Y * sinAngle
		local rotatedY = pointRelativeToOrigin.X * sinAngle + pointRelativeToOrigin.Y * cosAngle
	
		return Vector2.new(rotatedX, rotatedY) + origin
	end
	local function getGuiBounds(guiObject: GuiObject): (Vector2, Vector2)
		local frameOrigin = frame.AbsolutePosition + 0.5 * frame.AbsoluteSize
		guiObject:SetAttribute("frameOrigin", frameOrigin)
		local rotatedCorner = rotateVector2(
			frameOrigin,
			-frame.AbsoluteSize*0.5,
			frame.AbsoluteRotation
		)
		guiObject:SetAttribute("rotatedCorner", rotatedCorner)
		local globalOffset = guiObject.AbsolutePosition - rotatedCorner
		guiObject:SetAttribute("globalOffset", globalOffset)

		local guiAbsPivot = guiObject.AbsolutePosition + guiObject.AbsoluteSize * 0.5
		local guiCorner = rotateVector2(
			guiAbsPivot, 
			-guiObject.AbsoluteSize/2,
			frame.AbsoluteRotation
		)
		guiObject:SetAttribute("guiCorner", guiCorner)

		local upperLeftCornerUnrotatedRelativePosition = rotateVector2(
			rotatedCorner,
			guiCorner-rotatedCorner,
			-frame.AbsoluteRotation
		) - rotatedCorner
		guiObject:SetAttribute("upperLeftCornerUnrotatedRelativePosition", upperLeftCornerUnrotatedRelativePosition)

		local relativeGuiPivot = upperLeftCornerUnrotatedRelativePosition + guiObject.AbsoluteSize * 0.5
		local rotatedRelativeGuiCorner = rotateVector2(
			relativeGuiPivot,
			-guiObject.AbsoluteSize * 0.5,
			guiObject.Rotation
		)

		local upperLeftCorner = rotatedRelativeGuiCorner
		local lowerRightCorner = rotateVector2(
			rotatedRelativeGuiCorner,
			guiObject.AbsoluteSize,
			guiObject.Rotation
		)
		local lowerLeftCorner = rotateVector2(
			rotatedRelativeGuiCorner,
			guiObject.AbsoluteSize*Vector2.new(0,1),
			guiObject.Rotation
		)
		local upperRightCorner = rotateVector2(
			rotatedRelativeGuiCorner,
			guiObject.AbsoluteSize*Vector2.new(1,0),
			guiObject.Rotation
		)
		local relMinV2 = Vector2.new(
			math.round(math.max(math.min(upperLeftCorner.X, lowerRightCorner.X, upperRightCorner.X, lowerLeftCorner.X), 0)),
			math.round(math.max(math.min(upperLeftCorner.Y, lowerRightCorner.Y, upperRightCorner.Y, lowerLeftCorner.Y), 0))
		)
		local relMaxV2 = Vector2.new(
			math.round(math.max(upperLeftCorner.X, lowerRightCorner.X, upperRightCorner.X, lowerLeftCorner.X, 0)),
			math.round(math.max(upperLeftCorner.Y, lowerRightCorner.Y, upperRightCorner.Y, lowerLeftCorner.Y, 0))
		)
		guiObject:SetAttribute("relMinV2", relMinV2)
		guiObject:SetAttribute("relMaxV2", relMaxV2)
		return relMinV2, relMaxV2
	end

	local function solveSize()
		local minX: number?
		local minY: number?
		local maxX: number?
		local maxY: number?


		for child in pairs(guiChildren) do
			if child:IsA("GuiObject") then

				-- set min / max limits
				local minV2, maxV2 = getGuiBounds(child)
				
				if minX then
					minX = math.min(minX, minV2.X)
				else
					minX = minV2.X
				end
				if minY then
					minY = math.min(minY, minV2.Y)
				else
					minY = minV2.Y
				end
				if maxX then
					maxX = math.max(maxX, maxV2.X)
				else
					maxX = maxV2.X
				end
				if maxY then
					maxY = math.max(maxY, maxV2.Y)
				else
					maxY = maxV2.Y
				end

			end
		end

		if minX and minY and maxX and maxY then
			local absSize = Vector2.new(maxX-minX,maxY-minY)
			
			if frame:FindFirstChildOfClass("UIPadding") then
				local uiPadding = frame:FindFirstChildOfClass("UIPadding")
				assert(uiPadding)
				absSize += Vector2.new(
					(uiPadding.PaddingLeft.Offset + uiPadding.PaddingLeft.Scale * absSize.X)
					+ (uiPadding.PaddingRight.Offset + uiPadding.PaddingRight.Scale * absSize.X),
					(uiPadding.PaddingTop.Offset + uiPadding.PaddingTop.Scale * absSize.Y)
					+ (uiPadding.PaddingBottom.Offset + uiPadding.PaddingBottom.Scale * absSize.Y)
				)
			end
			return UDim2.fromOffset(absSize.X, absSize.Y)
		else
			return UDim2.fromOffset(0,0)
		end
	end

	local solveNeeded = true
	local function addChild(child: Instance)
		if child:IsA("UIPadding") then
			solveNeeded = true
		end
 		if not child:IsA("GuiObject") then return end
		assert(child:IsA("GuiObject"))
		if guiChildren[child] then
			guiChildren[child]:Destroy()
		end
		local prevAbsSize = Vector2.new(
			math.round(child.AbsoluteSize.X), 
			math.round(child.AbsoluteSize.Y)
		)

		local function getRelativeVector2(parent: Frame, size: UDim2): Vector2
			return Vector2.new(
				parent.AbsoluteSize.X * size.X.Scale + size.X.Offset,
				parent.AbsoluteSize.Y * size.Y.Scale + size.Y.Offset
			)
		end
		
		local prevPos = getRelativeVector2(frame, child.Position)
		local prevRot = math.round(child.Rotation)

		guiChildren[child] = maid:GiveTask(Maid.new())
		guiChildren[child]:GiveTask(RunService.RenderStepped:Connect(function()
			local curAbsSize = Vector2.new(
				math.round(child.AbsoluteSize.X), 
				math.round(child.AbsoluteSize.Y)
			)
			local curPos = getRelativeVector2(frame, child.Position)
			local curRot = math.round(child.Rotation)

			if curAbsSize.X ~= prevAbsSize.X or curAbsSize.Y ~= prevAbsSize.Y then
				solveNeeded = true
			elseif curPos.X ~= prevPos.X or curPos.Y ~= prevPos.Y then
				solveNeeded = true
			elseif curRot ~= prevRot then
				solveNeeded = true
			end
			if solveNeeded then
				prevAbsSize = curAbsSize
				prevRot = curRot
				prevPos = curPos
			end
		end))
		guiChildren[child]:GiveTask(child.Destroying:Connect(function()
			guiChildren[child]:Destroy()
			guiChildren[child] = nil
		end))
		solveNeeded = true
	end

	maid:GiveTask(frame.ChildAdded:Connect(addChild))
	for i, child in ipairs(frame:GetChildren()) do
		addChild(child)
	end
	maid:GiveTask(frame.ChildRemoved:Connect(function(child: Instance)
		if not child:IsA("GuiObject") then return end
		assert(child:IsA("GuiObject"))
		if guiChildren[child] then
			guiChildren[child]:Destroy()
			guiChildren[child] = nil
		end
		solveNeeded = true
	end))
	maid:GiveTask(RunService.RenderStepped:Connect(function()
		if solveNeeded then
			AbsoluteSize:Set(solveSize())
			solveNeeded = false
		end
		-- solveNeeded = true
	end))
	return AbsoluteSize
end



return function(parent: Frame)
	local maid = Maid.new()
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _clone = _fuse.clone
	local _import = _fuse.import
	
	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local target = maid:GiveTask(Instance.new("Frame"))
	target.Name = "Target"
	target.Size = UDim2.fromOffset(300,200)
	target.Position = UDim2.fromScale(0.3,0.2)
	target.Rotation = 45
	target.BackgroundTransparency = 0.7
	target.Parent = parent

	local preview = maid:GiveTask(Instance.new("Frame"))
	preview.Name = "Preview"
	preview.BackgroundColor3 = Color3.new(0,1,1)
	preview.BackgroundTransparency = 0.5
	preview.ZIndex = 10
	preview.Parent = parent

	local a = maid:GiveTask(Instance.new("Frame"))
	a.Name = "A"
	a.Size = UDim2.fromOffset(300,100)
	a.Parent = target

	local b = maid:GiveTask(Instance.new("Frame"))
	b.Name = "B"
	b.Size = a.Size
	b.BackgroundColor3 = Color3.new(1,1,0)
	b.BackgroundTransparency = 0.5
	b.Position = UDim2.fromOffset(300,100)
	b.Parent = target

	local Size = getSolvedAbsoluteSizeState(target, maid)

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		preview.Size = Size:Get()
		preview.Rotation = target.Rotation
		preview.Position = UDim2.fromOffset(
			target.AbsolutePosition.X + target.AbsoluteSize.X/2 - preview.AbsoluteSize.X/2, 
			target.AbsolutePosition.Y + target.AbsoluteSize.Y/2 - preview.AbsoluteSize.Y/2
		)
		target.Size = preview.Size

	end))

	return function()
		maid:Destroy()	
	end
end