--!strict
-- Services

-- Packages
local DataTableModule = script.Parent
assert(DataTableModule)
local LayoutModule = DataTableModule.Parent
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
local Util = require(DataTableModule:WaitForChild("Util"))
local Types = require(DataTableModule:WaitForChild("Types"))
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local StyleGuide = ModuleProvider.StyleGuide

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type Fuse = ColdFusion.Fuse
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type ColumnData = Types.ColumnData
-- Constants

local function buildCell(
	rowMaid: Maid,
	k: any,
	val: any,
	entry: { [any]: any },
	columnData: ColumnData,
	row: Frame,
	Width: State<number>
)
	local compMaid = Maid.new()
	rowMaid[k] = compMaid

	local _fuse = ColdFusion.fuse(compMaid)
	local _synth = Synthetic(compMaid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local horizontalAlignment, verticalAlignment = Util.getAlignment(columnData.Alignment)

	return _new("Frame")({
		Name = columnData.Name,
		Parent = row,
		LayoutOrder = columnData.Order,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Size = _Computed(function(width: number)
			if columnData.WidthWeight then
				width *= columnData.WidthWeight
			end
			return UDim2.fromOffset(width, 0)
		end, Width),
		Children = {
			_new("UIListLayout")({
				Padding = UDim.new(0, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = verticalAlignment,
				HorizontalAlignment = horizontalAlignment,
				FillDirection = Enum.FillDirection.Vertical,
			}),
			columnData.Constructor(columnData.Format(val), entry, compMaid),
		} :: { [number]: any },
	})
end

local function buildRow(
	rowMaid: Maid,
	order: number,
	entry: { [any]: any },
	backgroundColorPalette: ModuleProvider.GuiColorPalette,
	guiDensity: ModuleProvider.GuiDensityModifier,
	columnData: { [number]: ColumnData },
	Body: State<Frame?>,
	HeaderWidths: State<{ [string]: number }>
): (number, Frame)
	local _fuse = ColdFusion.fuse(rowMaid)
	local _synth = Synthetic(rowMaid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	-- local BorderSizePixel = _import(config.BorderSizePixel, DEFAULT_BORDER_SIZE_PIXEL)
	local RowBackgroundColor3 = StyleGuide:GetColor(backgroundColorPalette)
	local ColumnPadding = StyleGuide:GetPadding(guiDensity)
	local Size = _Computed(function(padding: UDim, widths: { [string]: number }): UDim2
		local full = 0
		for i, columnData in ipairs(columnData) do
			local width = widths[columnData.Name]
			if columnData.WidthWeight then
				width *= columnData.WidthWeight
			end
			full += width + padding.Offset
		end
		return UDim2.fromOffset(full, 0)
	end, ColumnPadding, HeaderWidths)
	local rowFrame: Frame = _new("Frame")({
		Name = "Row",
		Parent = Body,
		Size = Size,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = RowBackgroundColor3,
		LayoutOrder = order,
		Children = {
			_new("UIListLayout")({
				Padding = ColumnPadding,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
			}),
		} :: { [number]: any },
	}) :: Frame

	for k, val in pairs(entry) do
		local specificColumnData: ColumnData? = nil
		for i, columnData in ipairs(columnData) do
			if columnData.Name == k then
				specificColumnData = columnData
			end
		end
		assert(specificColumnData ~= nil)
		buildCell(
			rowMaid,
			k,
			val,
			entry,
			specificColumnData,
			rowFrame,
			_Computed(function(widths: { [string]: number })
				return widths[specificColumnData.Name]
			end, HeaderWidths)
		)
	end
	return order, rowFrame
end

return function(
	maid: Maid,
	canvasPalette: ModuleProvider.GuiColorPalette,
	rowBackgroundPalette: ModuleProvider.GuiColorPalette,
	guiDensity: ModuleProvider.GuiDensityModifier,
	typography: ModuleProvider.GuiTypography,
	columnData: { [number]: ColumnData },
	Data: State<{ [number]: { [string]: any } }>,
	Widths: State<{ [string]: number }>
): ValueState<Frame?>
	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local Body: ValueState<Frame?> = _Value(nil :: Frame?)

	Body:Set(_new("Frame")({
		Name = "Body",
		BackgroundTransparency = 0,
		BackgroundColor3 = StyleGuide:GetColor(canvasPalette),
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = _Computed(function(scrollBarThickness: number): UDim2
			return UDim2.new(0, -scrollBarThickness, 0, 0)
		end, StyleGuide:GetTextSize(typography)),
		Children = {
			_new("UIPadding")({
				PaddingTop = _Computed(function(borderSizePixel: number)
					return UDim.new(0, borderSizePixel)
				end, StyleGuide.BorderSizePixel),
				PaddingBottom = _Computed(function(borderSizePixel: number)
					return UDim.new(0, borderSizePixel)
				end, StyleGuide.BorderSizePixel),
				PaddingLeft = UDim.new(0, 0),
				PaddingRight = UDim.new(0, 0),
			}),
			_new("UIListLayout")({
				Padding = _Computed(function(borderSizePixel: number)
					return UDim.new(0, borderSizePixel)
				end, StyleGuide.BorderSizePixel),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				FillDirection = Enum.FillDirection.Vertical,
			}),
		} :: { [number]: any },
	}) :: Frame)

	Data:ForPairs(function(order: number, entry: { [string]: any }, rowMaid: Maid): (number, { [string]: any })
		buildRow(rowMaid, order, entry, rowBackgroundPalette, guiDensity, columnData, Body, Widths)
		return order, entry
	end)

	return Body
end
