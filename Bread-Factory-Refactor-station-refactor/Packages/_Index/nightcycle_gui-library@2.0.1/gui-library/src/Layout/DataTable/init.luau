--!strict
-- Services
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
-- Packages
local LayoutModule = script.Parent
assert(LayoutModule)
local Package = LayoutModule.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local Signal = require(Packages:WaitForChild("Signal"))
local Synthetic = require(Packages:WaitForChild("Synthetic"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))

-- Modules
local Body = require(script:WaitForChild("Body"))
local Header = require(script:WaitForChild("Header"))
local Types = require(script:WaitForChild("Types"))
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local PseudoEnum = ModuleProvider.PseudoEnum
local StyleGuide = ModuleProvider.StyleGuide

-- Constants
local SCROLL_IMAGE_URL = "rbxassetid://5352896021"

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type Fuse = ColdFusion.Fuse
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>

export type ColumnInput = {
	Name: string,
	Text: string?,
	Constructor: ((val: any, data: { [string]: any }, maid: Maid) -> GuiObject)?,
	Alignment: ModuleProvider.GuiAlignmentType?,
	Format: ((val: any) -> string)?,
	WidthWeight: number?,
}

export type ColumnData = Types.ColumnData


local function buildDefaultCell(
	maid: Maid,
	val: any,
	data: any,
	typography: ModuleProvider.GuiTypography,
	backgroundColorPalette: ModuleProvider.GuiColorPalette,
	guiDensity: ModuleProvider.GuiDensityModifier
): TextLabel
	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	return _new("TextLabel")({
		Text = tostring(val),
		FontFace = StyleGuide:GetFont(typography),
		TextColor3 = StyleGuide:GetContrastColor(backgroundColorPalette),
		TextSize = StyleGuide:GetTextSize(typography),
		RichText = true,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.new(0, 0, 0, 0),
		TextWrapped = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Children = {
			_new("UIPadding")({
				PaddingBottom = StyleGuide:GetPadding(guiDensity),
				PaddingTop = StyleGuide:GetPadding(guiDensity),
				PaddingLeft = StyleGuide:GetPadding(guiDensity),
				PaddingRight = StyleGuide:GetPadding(guiDensity),
			}),
		} :: { [number]: any },
	}) :: TextLabel
end

return function(
	maid: Maid,
	Data: State<{ [number]: { [string]: any } }>,
	columnInputs: { [number]: ColumnInput },
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
	rowTypography = rowTypography or PseudoEnum.GuiTypography.Body1
	assert(rowTypography ~= nil)

	headerTypography = headerTypography or PseudoEnum.GuiTypography.Button
	assert(headerTypography ~= nil)

	guiDensity = guiDensity or PseudoEnum.GuiDensityModifier.High
	assert(guiDensity ~= nil)

	guiDensity = guiDensity or PseudoEnum.GuiDensityModifier.High
	assert(guiDensity ~= nil)

	backgroundColorPalette = backgroundColorPalette or PseudoEnum.GuiColorPalette.Surface1
	assert(backgroundColorPalette ~= nil)

	canvasColorPalette = canvasColorPalette or PseudoEnum.GuiColorPalette.Surface2
	assert(canvasColorPalette ~= nil)

	rowColorPalette = rowColorPalette or PseudoEnum.GuiColorPalette.Surface3
	assert(rowColorPalette ~= nil)

	automaticSize = automaticSize or Enum.AutomaticSize.None
	assert(automaticSize ~= nil)

	layoutOrder = layoutOrder or 0
	assert(layoutOrder ~= nil)

	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local InputSize = _import(size, UDim2.fromOffset(0, 00))
	local HeaderHeight = _Value(0)
	local HeaderWidths = _Value({} :: { [string]: number })
	local automaticCanvasXSize = if automaticSize == Enum.AutomaticSize.XY
			or automaticSize == Enum.AutomaticSize.X
		then Enum.AutomaticSize.None
		else Enum.AutomaticSize.X

	local YAbsoluteSize = _Value(0)
	local XAbsoluteSize = _Value(0)
	local YAbsoluteCanvasSize = _Value(0)
	local XAbsoluteCanvasSize = _Value(0)

	local _YScrollingEnabled = _Computed(function(yAbsSize: number, yCanvasAbsSize: number)
		-- print("Y", yAbsSize, ":", yCanvasAbsSize, "->", yAbsSize < yCanvasAbsSize)
		return yAbsSize < yCanvasAbsSize
	end, YAbsoluteSize, YAbsoluteCanvasSize)
	local XScrollingEnabled = _Computed(function(xAbsSize: number, xCanvasAbsSize: number)
		-- print("X", xAbsSize, ":", xCanvasAbsSize, "->", xAbsSize < xCanvasAbsSize)
		return xAbsSize < xCanvasAbsSize
	end, XAbsoluteSize, XAbsoluteCanvasSize)
	local ScrollBarThickness = StyleGuide:GetTextSize(rowTypography)

	local Size = _Computed(function(iSize: UDim2, xCanvAbs: number, yCanvAbs: number, height: number)
		local xScale = iSize.X.Scale
		local xOffset = iSize.X.Offset
		local yScale = iSize.Y.Scale
		local yOffset = iSize.Y.Offset

		return UDim2.new(xScale, math.min(xOffset, xCanvAbs), yScale, math.min(yOffset, yCanvAbs + height))
	end, InputSize, XAbsoluteCanvasSize, YAbsoluteCanvasSize, HeaderHeight)

	local columnData: { [number]: ColumnData } = {}
	for i, columnInput in ipairs(columnInputs) do
		table.insert(columnData, {
			Name = columnInput.Name,
			Text = columnInput.Text or columnInput.Name,
			Order = i,
			Format = columnInput.Format or function(val: any)
				return tostring(val)
			end,
			Constructor = columnInput.Constructor or function(val: any, data: any, cellMaid: Maid): GuiObject
				return buildDefaultCell(cellMaid, val, data, rowTypography, rowColorPalette, guiDensity)
			end,
			Alignment = columnInput.Alignment or PseudoEnum.GuiAlignmentType.Center,
			WidthWeight = columnInput.WidthWeight,
		})
	end
	local columnRegistry: { [string]: Types.ColumnData } = {}
	for i, cData in ipairs(columnData) do
		local widths = HeaderWidths:Get()
		widths[cData.Name] = 0
		HeaderWidths:Set(widths)
		columnRegistry[cData.Name] = cData
	end

	local HeaderFrame = Header(maid, backgroundColorPalette, headerTypography, guiDensity, columnData, HeaderWidths)
	local BodyFrame =
		Body(maid, canvasColorPalette, rowColorPalette, guiDensity, rowTypography, columnData, Data, HeaderWidths)

	local scrollFrame = _new("ScrollingFrame")({
		Size = _Computed(
			function(height: number, borderSizePixel: number, isXScrolling: boolean, thickness: number, maxWidth: number)
				return UDim2.new(
					0,
					maxWidth + thickness,
					1,
					-height - borderSizePixel - if isXScrolling then thickness else 0
				)
			end,
			HeaderHeight,
			StyleGuide.BorderSizePixel,
			XScrollingEnabled,
			ScrollBarThickness,
			XAbsoluteCanvasSize
		),
		LayoutOrder = 1,
		BackgroundTransparency = 1,
		BorderColor3 = StyleGuide:GetContrastColor(backgroundColorPalette),
		BorderSizePixel = StyleGuide.BorderSizePixel,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = ScrollBarThickness,
		TopImage = SCROLL_IMAGE_URL,
		BottomImage = SCROLL_IMAGE_URL,
		MidImage = SCROLL_IMAGE_URL,
		ScrollBarImageColor3 = StyleGuide:GetContrastColor(backgroundColorPalette),
		AutomaticSize = if automaticSize == Enum.AutomaticSize.XY
			then Enum.AutomaticSize.Y
			elseif automaticSize == Enum.AutomaticSize.X then Enum.AutomaticSize.X
			elseif automaticSize == Enum.AutomaticSize.Y then Enum.AutomaticSize.X
			else Enum.AutomaticSize.X,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Children = {
			_new("UIListLayout")({
				Padding = UDim.new(0, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				FillDirection = Enum.FillDirection.Horizontal,
			}) :: any,
			BodyFrame,
			-- _new("UIPadding")({
			-- 	PaddingBottom = UDim.new(0,0),
			-- 	PaddingTop = UDim.new(0,0),
			-- 	PaddingLeft = UDim.new(0,0),
			-- 	PaddingRight = _Computed(function(thickness: number, isScrolling: boolean)
			-- 		return UDim.new(0, if isScrolling then thickness else 0)
			-- 	end, ScrollBarThickness, YScrollingEnabled),
			-- }),
		},
	}) :: ScrollingFrame
	local outputFrame = _new("ScrollingFrame")({
		Name = "DataTable",
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		Size = Size,
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = automaticSize,
		AutomaticCanvasSize = automaticCanvasXSize,
		CanvasSize = UDim2.fromScale(0, 0),
		BorderColor3 = StyleGuide:GetContrastColor(backgroundColorPalette),
		BorderSizePixel = 0,
		TopImage = SCROLL_IMAGE_URL,
		BottomImage = SCROLL_IMAGE_URL,
		MidImage = SCROLL_IMAGE_URL,
		ScrollBarThickness = ScrollBarThickness,
		ScrollBarImageColor3 = StyleGuide:GetContrastColor(backgroundColorPalette),
		Children = {
			_new("UIListLayout")({
				Padding = _Computed(function(borderSize: number)
					return UDim.new(0, borderSize)
				end, StyleGuide.BorderSizePixel),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}) :: any,
			_new("UIPadding")({
				PaddingBottom = UDim.new(0, 0),
				PaddingTop = UDim.new(0, 0),
				PaddingLeft = StyleGuide:GetPadding(guiDensity),
				PaddingRight = UDim.new(0, 0),
			}),
			scrollFrame,
			HeaderFrame,
		},
	}) :: ScrollingFrame

	maid:GiveTask(RunService.RenderStepped:Connect(function(dT: number)
		local headerFrame = HeaderFrame:Get()

		if headerFrame then
			HeaderHeight:Set(headerFrame.AbsoluteSize.Y)
			local widths = {}
			local headerTextSize = StyleGuide:GetTextSize(headerTypography):Get()
			local headerFont: Font = StyleGuide:GetFont(headerTypography):Get()
			for i, cell in ipairs(headerFrame:GetChildren()) do
				if cell:IsA("GuiObject") then
					widths[cell.Name] = widths[cell.Name] or 0
					local cData = columnRegistry[cell.Name]

					local widthWeight = cData.WidthWeight or 1

					local params = Instance.new("GetTextBoundsParams")
					params.Text = cData.Text
					params.Font = headerFont
					params.Size = headerTextSize
					params.Width = math.huge
			
					local success = pcall(function()
						local textAbsSize = TextService:GetTextBoundsAsync(params)
						widths[cell.Name] = math.max(widths[cell.Name], textAbsSize.X * widthWeight)
					end)
					if not success then
						print("text bound async failed for "..cell.Name)
					end
				end
			end
			HeaderWidths:Set(widths)
		end

		YAbsoluteSize:Set(scrollFrame.AbsoluteWindowSize.Y)
		XAbsoluteSize:Set(outputFrame.AbsoluteWindowSize.X)

		local bodyFrame = BodyFrame:Get()
		if bodyFrame then
			YAbsoluteCanvasSize:Set(bodyFrame.AbsoluteSize.Y)
			XAbsoluteCanvasSize:Set(bodyFrame.AbsoluteSize.X)
		end
	end))

	maid:GiveTask(outputFrame.Destroying:Connect(function()
		maid:Destroy()
	end))

	return outputFrame
end
