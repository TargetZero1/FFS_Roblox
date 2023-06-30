--!strict
-- Services
local RunService = game:GetService("RunService")
-- Packages
local Package = script.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))
local Synthetic = require(Packages:WaitForChild("Synthetic"))

-- Modules
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local PseudoEnum = ModuleProvider.PseudoEnum
local DataTable = require(script:WaitForChild("DataTable"))
local StyleGuide = ModuleProvider.StyleGuide

-- Types
type Maid = Maid.Maid
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
export type Layout = {
	__index: Layout,
	_Maid: Maid,
	_IsAlive: boolean,
	Destroy: (self: Layout) -> nil,
	GetDataTable: (
		self: Layout,
		maid: Maid,
		Data: State<{ [number]: { [string]: any } }>,
		columnInputs: { [number]: DataTable.ColumnInput },
		headerTypography: ModuleProvider.GuiTypography?,
		rowTypography: ModuleProvider.GuiTypography?,
		guiDensity: ModuleProvider.GuiDensityModifier?,
		backgroundColorPalette: ModuleProvider.GuiColorPalette?,
		canvasColorPalette: ModuleProvider.GuiColorPalette?,
		rowColorPalette: ModuleProvider.GuiColorPalette?,
		automaticSize: Enum.AutomaticSize?,
		layoutOrder: number?,
		size: CanBeState<UDim2>?
	) -> ScrollingFrame,
	GetUIPadding: (
		self: Layout,
		guiDensityModifier: ModuleProvider.GuiDensityModifier,
		consistentEdges: boolean?
	) -> UIPadding,
	GetVerticalList: (
		self: Layout,
		alignment: ModuleProvider.GuiAlignmentType?,
		density: ModuleProvider.GuiDensityModifier?
	) -> UIListLayout,
	GetHorizontalList: (
		self: Layout,
		alignment: ModuleProvider.GuiAlignmentType?,
		density: ModuleProvider.GuiDensityModifier?
	) -> UIListLayout,
	GetContainer: (
		self: Layout,
		children: { [any]: Instance },
		density: ModuleProvider.GuiDensityModifier?,
		layoutOrder: number?,
		name: CanBeState<string>?,
		palette: ModuleProvider.GuiColorPalette?,
		useAbsolute: boolean?
	) -> Frame,
	new: (maid: Maid) -> Layout,
}
-- Constants
-- Variables
-- References
-- Private functions

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
			math.round(math.max(math.min(upperLeftCorner.X, lowerRightCorner.X, upperRightCorner.X, lowerLeftCorner.X))),
			math.round(math.max(math.min(upperLeftCorner.Y, lowerRightCorner.Y, upperRightCorner.Y, lowerLeftCorner.Y)))
		)
		local relMaxV2 = Vector2.new(
			math.round(math.max(upperLeftCorner.X, lowerRightCorner.X, upperRightCorner.X, lowerLeftCorner.X)),
			math.round(math.max(upperLeftCorner.Y, lowerRightCorner.Y, upperRightCorner.Y, lowerLeftCorner.Y))
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

function getHorizontalAndVerticalAlignment(
	alignment: ModuleProvider.GuiAlignmentType?
): (Enum.HorizontalAlignment, Enum.VerticalAlignment)
	if alignment == PseudoEnum.GuiAlignmentType.Center then
		return Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center
	elseif alignment == PseudoEnum.GuiAlignmentType.Left then
		return Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center
	elseif alignment == PseudoEnum.GuiAlignmentType.Right then
		return Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center
	elseif alignment == PseudoEnum.GuiAlignmentType.Top then
		return Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top
	elseif alignment == PseudoEnum.GuiAlignmentType.Bottom then
		return Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Bottom
	elseif alignment == PseudoEnum.GuiAlignmentType.TopLeft then
		return Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top
	elseif alignment == PseudoEnum.GuiAlignmentType.TopRight then
		return Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Top
	elseif alignment == PseudoEnum.GuiAlignmentType.BottomLeft then
		return Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Bottom
	elseif alignment == PseudoEnum.GuiAlignmentType.BottomRight then
		return Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom
	else
		return Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center
	end
end

function getList(
	const: (any) -> UIListLayout,
	fillDirection: Enum.FillDirection,
	alignment: ModuleProvider.GuiAlignmentType?,
	density: ModuleProvider.GuiDensityModifier?
): UIListLayout
	local horizontal, vertical = getHorizontalAndVerticalAlignment(alignment)

	return const({
		Padding = if density then StyleGuide:GetPadding(density) else UDim.new(0, 0),
		FillDirection = fillDirection,
		HorizontalAlignment = horizontal,
		VerticalAlignment = vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

-- Class
local Layout: Layout = {} :: any
Layout.__index = Layout

function Layout:Destroy()
	if not self._IsAlive then
		return
	end
	self._IsAlive = false
	self._Maid:Destroy()
	local t: any = self
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(t, nil)
	return nil
end

function Layout:GetUIPadding(guiDensityModifier: ModuleProvider.GuiDensityModifier, consistentEdges: boolean?): UIPadding
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local Padding = StyleGuide:GetPadding(guiDensityModifier)
	local SidePadding = if consistentEdges
		then Padding
		else _Computed(function(pad: UDim)
			return UDim.new(pad.Scale * 0.5, math.ceil(pad.Offset * 0.5))
		end, Padding)

	return _new("UIPadding")({
		PaddingTop = Padding,
		PaddingBottom = Padding,
		PaddingLeft = SidePadding,
		PaddingRight = SidePadding,
	}) :: any
end

function Layout:GetDataTable(
	maid: Maid,
	Data: State<{ [number]: { [string]: any } }>,
	columnInputs: { [number]: DataTable.ColumnInput },
	headerTypography: ModuleProvider.GuiTypography?,
	rowTypography: ModuleProvider.GuiTypography?,
	guiDensity: ModuleProvider.GuiDensityModifier?,
	backgroundColorPalette: ModuleProvider.GuiColorPalette?,
	canvasColorPalette: ModuleProvider.GuiColorPalette?,
	rowColorPalette: ModuleProvider.GuiColorPalette?,
	automaticSize: Enum.AutomaticSize?,
	layoutOrder: number?,
	size: CanBeState<UDim2>?
): ScrollingFrame
	return DataTable(
		maid,
		Data,
		columnInputs,
		headerTypography,
		rowTypography,
		guiDensity,
		backgroundColorPalette,
		canvasColorPalette,
		rowColorPalette,
		automaticSize,
		layoutOrder,
		size
	)
end

function Layout:GetVerticalList(
	alignment: ModuleProvider.GuiAlignmentType?,
	density: ModuleProvider.GuiDensityModifier?
): UIListLayout
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	return getList(_new("UIListLayout") :: any, Enum.FillDirection.Vertical, alignment, density)
end

function Layout:GetHorizontalList(
	alignment: ModuleProvider.GuiAlignmentType?,
	density: ModuleProvider.GuiDensityModifier?
): UIListLayout
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	return getList(_new("UIListLayout") :: any, Enum.FillDirection.Horizontal, alignment, density)
end

function Layout:GetContainer(
	children: { [any]: Instance },
	density: ModuleProvider.GuiDensityModifier?,
	layoutOrder: number?,
	name: CanBeState<string>?,
	palette: ModuleProvider.GuiColorPalette?,
	useAbsolute: boolean?
): Frame
	if useAbsolute == nil then
		useAbsolute = false
	end
	assert(useAbsolute ~= nil)
	local maid = self._Maid:GiveTask(Maid.new())
	local _fuse = ColdFusion.fuse(maid)
		
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local frame = maid:GiveTask(Instance.new("Frame"))

	_bind(frame)({
		Name = name,
		LayoutOrder = layoutOrder,
		AutomaticSize = if not useAbsolute then Enum.AutomaticSize.XY else Enum.AutomaticSize.None,
		BackgroundTransparency = if palette == nil then 1 else 0,
		Size = if not useAbsolute then UDim2.fromScale(0, 0) else getSolvedAbsoluteSizeState(frame, maid),
		BackgroundColor3 = if palette then StyleGuide:GetColor(palette) else nil,
		Children = children,
	})

	maid:GiveTask(frame.Destroying:Connect(function()
		maid:Destroy()
	end))


	if palette then
		local corner = _new("UICorner")({
			CornerRadius = StyleGuide.CornerRadius,
		})
		corner.Parent = frame
	end

	if density then
		local padding = self:GetUIPadding(density, true)
		padding.Parent = frame
	end

	return frame
end

function Layout.new(maid: Maid)
	local self: Layout = setmetatable({}, Layout) :: any
	self._IsAlive = true
	self._Maid = maid

	return self
end

return Layout
