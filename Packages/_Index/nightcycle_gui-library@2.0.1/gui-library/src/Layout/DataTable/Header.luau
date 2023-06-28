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
local Types = require(DataTableModule:WaitForChild("Types"))
local Util = require(DataTableModule:WaitForChild("Util"))
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local PseudoEnum = ModuleProvider.PseudoEnum
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

-- Class
local function getHeaderCell(
	maid: Maid,
	order: number,
	backgroundColorPalette: ModuleProvider.GuiColorPalette,
	guiTypography: ModuleProvider.GuiTypography,
	columnData: ColumnData,
	Header: State<Frame?>,
	Width: State<number>
): (number, TextLabel)
	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local textXAlignment, textYAlignment = Util.getTextAlignment(columnData.Alignment)

	return order,
		_new("TextLabel")({
			Name = columnData.Name,
			Parent = Header,
			BackgroundTransparency = 1,
			Text = columnData.Text,
			Size = _Computed(function(width: number)
				if columnData.WidthWeight then
					width *= columnData.WidthWeight
				end
				return UDim2.fromOffset(width, 0)
			end, Width),
			TextSize = StyleGuide:GetTextSize(guiTypography),
			FontFace = StyleGuide:GetFont(guiTypography),
			TextColor3 = StyleGuide:GetContrastColor(backgroundColorPalette),
			AutomaticSize = Enum.AutomaticSize.Y,
			RichText = true,
			TextWrapped = if columnData.WidthWeight and columnData.WidthWeight < 1 then true else false,
			TextXAlignment = textXAlignment,
			TextYAlignment = textYAlignment,
			Children = {
				_new("UIPadding")({
					PaddingTop = StyleGuide:GetPadding(PseudoEnum.GuiDensityModifier.Default),
					PaddingBottom = StyleGuide:GetPadding(PseudoEnum.GuiDensityModifier.Default),
					PaddingLeft = UDim.new(0, 0),
					PaddingRight = UDim.new(0, 0),
				}),
			} :: { [number]: any },
		}) :: TextLabel
end

return function(
	maid: Maid,
	backgroundColorPalette: ModuleProvider.GuiColorPalette,
	guiTypography: ModuleProvider.GuiTypography,
	guiDensity: ModuleProvider.GuiDensityModifier,
	columnData: { [number]: ColumnData },
	HeaderWidths: State<{ [string]: number }>
): ValueState<Frame?>
	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local Header = _Value(nil :: Frame?)

	Header:Set(_new("Frame")({
		Name = "Header",
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
		Children = {
			_new("UIListLayout")({
				Padding = StyleGuide:GetPadding(guiDensity),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
		} :: { [number]: any },
	}) :: Frame)

	for i, columnData in ipairs(columnData) do
		getHeaderCell(
			maid,
			i,
			backgroundColorPalette,
			guiTypography,
			columnData,
			Header,
			_Computed(function(widths: { [string]: number })
				return widths[columnData.Name]
			end, HeaderWidths)
		)
	end

	return Header
end
