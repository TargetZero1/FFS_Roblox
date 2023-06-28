--!strict
-- Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

-- Packages
local VisModule = script.Parent
assert(VisModule)
local Package = VisModule.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local Signal = require(Packages:WaitForChild("Signal"))
local Synthetic = require(Packages:WaitForChild("Synthetic"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))
local TableUtil = require(Packages:WaitForChild("TableUtil"))
local FormatUtil = require(Packages:WaitForChild("FormatUtil"))

-- Modules
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local PseudoEnum = ModuleProvider.PseudoEnum
local Layout = require(Package:WaitForChild("Layout"))
local Effect = require(Package:WaitForChild("Effect"))
local StyleGuide = ModuleProvider.StyleGuide

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type State<T> = ColdFusion.State<T>
type Dict<K,V> = TableUtil.Dict<K,V>
type List<V> = TableUtil.List<V>
type DataPoint = {
	Key: string,
	Value: Vector2,
}
type LineData = {
	Start: Vector2,
	Finish: Vector2,
	Value: number,
}
type Layout = Layout.Layout
export type DataTable = {
	Data: State<Dict<string, Vector2>>,
	Id: string,
	Name: string,
	Color: CanBeState<Color3>,
	LayoutOrder: number?
}

-- Constants
local ZERO = Vector2.new(0, 0)
local DOT_TO_LINE_RATIO = 2
local GRID_LINE_WEIGHT = 0.5
local GOAL_HORIZONTAL_GRID_LINES = 5
local GOAL_VERTICAL_GRID_LINES = 5
local DESELECTED_GRAPH_TRANSPARENCY = 0.8

-- Ref
local UISounds = Package:WaitForChild("UI") :: Folder
local TapSounds = UISounds:WaitForChild("Tap") :: Folder
local CLICK_SOUND = TapSounds:WaitForChild("A") :: Sound

-- Private functions
local function emptyDataPoint(): DataPoint
	return {
		Key = HttpService:GenerateGUID(false),
		Value = ZERO,
	}
end

local function calculateScale(rawIncrement: number, scale: number?): number?
	if rawIncrement == 0 or rawIncrement == math.huge then
		return nil
	end
	scale = scale or 1
	assert(scale ~= nil)
	if math.abs(scale - rawIncrement) > math.abs(0.1 * scale - rawIncrement) then
		return calculateScale(rawIncrement, 0.1 * scale)
	elseif math.abs(scale - rawIncrement) > math.abs(10 * scale - rawIncrement) then
		return calculateScale(rawIncrement, 10 * scale)
	else
		return scale
	end
end

local function newLine(
	maid: Maid,
	parent: Frame,
	start: DataPoint,
	finish: DataPoint,
	Thickness: State<UDim>,
	Color: State<Color3>,
	Transparency: State<number>
): Frame
	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import
	local _layout = Layout.new(maid)

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local Start: State<DataPoint> = _import(start, emptyDataPoint())
	local Finish: State<DataPoint> = _import(finish, emptyDataPoint())

	local DeltaX = _Computed(function(finish: DataPoint, start: DataPoint)
		return finish.Value.X - start.Value.X
	end, Finish, Start)

	local DeltaY = _Computed(function(finish: DataPoint, start: DataPoint)
		return (1 - finish.Value.Y) - (1 - start.Value.Y)
	end, Finish, Start)

	local Length = _Computed(function(finish: DataPoint, start: DataPoint)
		return (finish.Value - start.Value).Magnitude
	end, Finish, Start)
	local Angle = _Computed(function(deltaX: number, deltaY: number)
		return math.deg(math.atan2(deltaY, deltaX))
	end, DeltaX, DeltaY)

	return _new("Frame")({
		Name = "Line",
		Parent = parent,
		Rotation = Angle,
		BackgroundTransparency = Transparency,
		ZIndex = 9,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color,
		Position = _Computed(function(start: DataPoint, deltaX: number, deltaY: number)
			return UDim2.fromScale(start.Value.X + deltaX * 0.5, 1 - start.Value.Y + deltaY * 0.5)
		end, Start, DeltaX, DeltaY),
		Size = _Computed(function(thickness: UDim, length: number)
			return UDim2.new(UDim.new(length, 0), thickness)
		end, Thickness, Length),
	}) :: any
end

local function newGraphDot(
	maid: Maid,
	parent: Frame,
	dataPoint: DataPoint,
	Thickness: State<UDim>,
	Color: State<Color3>,
	Transparency: State<number>
): Frame
	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import
	local _layout = Layout.new(maid)

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local Data: State<DataPoint> = _import(dataPoint, emptyDataPoint())

	return _new("Frame")({
		Name = "Dot",
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 10,
		BackgroundColor3 = Color,
		BackgroundTransparency = Transparency,
		Position = _Computed(function(data: DataPoint)
			return UDim2.fromScale(data.Value.X, 1 - data.Value.Y)
		end, Data),
		Size = _Computed(function(thickness: UDim)
			local weightedThickness =
				UDim.new(DOT_TO_LINE_RATIO * thickness.Scale, DOT_TO_LINE_RATIO * thickness.Offset)
			return UDim2.new(weightedThickness, weightedThickness)
		end, Thickness),
		Children = {
			_new("UICorner")({
				CornerRadius = UDim.new(0.5, 0),
			}),
		} :: { [number]: any },
	}) :: any
end

function newGridLine(
	maid: Maid,
	parent: Frame,
	start: Vector2,
	finish: Vector2,
	Thickness: State<UDim>,
	Color: State<Color3>,
	Transparency: State<number>
): Frame
	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import
	local _layout = Layout.new(maid)

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local startPoint = emptyDataPoint()
	startPoint.Value = start

	local finishPoint = emptyDataPoint()
	finishPoint.Value = finish

	local line = newLine(maid, parent, startPoint, finishPoint, Thickness, Color, Transparency)
	line.Name = "GridLine"
	line.ZIndex = 6
	return line
end

function newGridLabel(
	maid: Maid,
	parent: Frame,
	value: number,
	anchorPoint: Vector2,
	position: UDim2,
	TextColor: State<Color3>
)
	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import
	local _layout = Layout.new(maid)

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed
	
	value = math.round(100*value)/100
	local valueText = if value > 1 then FormatUtil.insertCommas(value) else tostring(value)

	return _new("TextLabel")({
		Name = "YText",
		BackgroundTransparency = 1,
		AnchorPoint = anchorPoint,
		Position = position,
		Parent = parent,
		Size = UDim2.fromOffset(0, 0),
		FontFace = StyleGuide:GetFont(PseudoEnum.GuiTypography.Body1),
		TextSize = StyleGuide:GetTextSize(PseudoEnum.GuiTypography.Body1),
		TextColor3 = TextColor,
		Text = valueText,
		RichText = true,
		LayoutOrder = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	})
end

function newDataRender(	
	maid: Maid,
	Color: State<Color3>,
	Data: State<Dict<string, Vector2>>,
	BackgroundColor: State<Color3>,
	Thickness: State<UDim>,
	Transparency: State<number>,
	StartCorner: State<Vector2>,
	Range: State<Vector2>
)
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _layout = Layout.new(maid)

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local ScaledData = _Computed(
		function(data: { [string]: Vector2 }, start: Vector2, range: Vector2): { [string]: Vector2 }
			local out = {}
			for key, point in pairs(data) do
				out[key] = (point - start) / range
			end
			return out
		end,
		Data,
		StartCorner,
		Range
	)

	local SortedKeyList = _Computed(function(data: { [string]: Vector2 })
		local keys = TableUtil.keys(data)
		table.sort(keys, function(a: string, b: string)
			local aVal = data[a]
			local bVal = data[b]
			return aVal.X < bVal.X
		end)
		return keys
	end, ScaledData)

	local DataPoints = _Computed(
		function(keys: { [number]: string }, data: { [string]: Vector2 }): { [number]: DataPoint }
			local points: { [number]: DataPoint } = {}
			for i, key in ipairs(keys) do
				local val = data[key]
				table.insert(points, {
					Key = key,
					Value = val,
				} :: DataPoint)
			end
			return points
		end,
		SortedKeyList,
		ScaledData
	)

	local DataVectorPairs = _Computed(
		function(dataPoints: { [number]: DataPoint }): { [number]: { [number]: DataPoint } }
			local dataPairs = {}
			for i, dataPoint in ipairs(dataPoints) do
				local nxtDataPoint = dataPoints[i + 1]
				if nxtDataPoint then
					local dataPair = { dataPoint, nxtDataPoint }
					table.insert(dataPairs, dataPair)
				end
			end
			return dataPairs
		end,
		DataPoints
	)

	local canvas: Frame = _new("Frame")({
		Name = "LineCanvas",
		Size = UDim2.fromScale(1,1),
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		ZIndex = 10,
		Children = {
			_layout:GetUIPadding(PseudoEnum.GuiDensityModifier.High),
		} :: { [number]: any },
	}) :: any

	local LineColor = _Computed(function(backColor: Color3, color: Color3): Color3
		return StyleGuide.getReadableColor(color, backColor)
	end, BackgroundColor, Color)

	DataVectorPairs:ForValues(function(v: { [number]: DataPoint }, processorMaid: Maid)
		local startPoint: DataPoint = v[1]
		local finishPoint: DataPoint = v[2]
		newGraphDot(processorMaid, canvas, startPoint, Thickness, LineColor, Transparency)
		newLine(processorMaid, canvas, startPoint, finishPoint, Thickness, LineColor, Transparency)
		return v
	end)

	return canvas
end

return function(
	maid: Maid,
	dataTables: Dict<any, DataTable>,
	XAxisLabel: State<string>,
	YAxisLabel: State<string>,
	CanvasSize: State<UDim2>,
	Thickness: State<UDim>,
	CanvasColor: State<Color3>,
	GridLineColor: State<Color3>,
	TextColor: State<Color3>,
	SelectedLegendColor: State<Color3>
): Frame
	
	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _layout = Layout.new(maid)
	local _effect = Effect.new(maid)

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local LabelTypography = PseudoEnum.GuiTypography.Body1

	local dataTableList = TableUtil.values(dataTables)
	local dataStateList: List<State<{[string]: Vector2}>> = {}
	for i, dataTable in ipairs(dataTableList) do
		table.insert(dataStateList, dataTable.Data)
	end

	local CompositeDataSet = _Computed(function(...: {[string]: Vector2}): {[string]: Vector2}
		local compData = {}
		for i, data in ipairs({...}) do
			for k, v in pairs(data) do
				local key = k.."_"..tostring(i)
				compData[key] = v
			end
		end
		return compData
	end, unpack(dataStateList))

	local StartCorner = _Computed(function(data: { [string]: Vector2 })
		local minX = math.huge
		for k, v in pairs(data) do
			minX = math.min(v.X, minX)
		end
		local minY = math.huge
		for k, v in pairs(data) do
			minY = math.min(v.Y, minY)
		end
		-- print("MINX", minX, "MINY", minY)
		return Vector2.new(minX, minY)
	end, CompositeDataSet)

	local FinishCorner = _Computed(function(data: { [string]: Vector2 })
		local maxX = -math.huge
		for k, v in pairs(data) do
			maxX = math.max(v.X, maxX)
		end
		local maxY = -math.huge
		for k, v in pairs(data) do
			maxY = math.max(v.Y, maxY)
		end
		-- print("MAXX", maxX, "MAXY", maxY)
		return Vector2.new(maxX, maxY)
	end, CompositeDataSet)

	local Range = _Computed(function(start: Vector2, finish: Vector2)
		-- print("RANGE",finish - start )
		return finish - start
	end, StartCorner, FinishCorner)

	local YLabelWidth = _Value(0)
	local YLabelSize = _Computed(function(size: UDim2, width: number): UDim2
		return UDim2.new(UDim.new(0, width), size.Y)
	end, CanvasSize, YLabelWidth)
	local yLabels: Frame = _new("Frame")({
		Name = "YLabels",
		LayoutOrder = 2,
		BackgroundTransparency = 1,
		Size = YLabelSize,
		AutomaticSize = Enum.AutomaticSize.X,
	}) :: any
	local XLabelHeight = _Value(0)
	local XLabelSize = _Computed(function(size: UDim2, height: number): UDim2
		return UDim2.new(size.X, UDim.new(0, height))
	end, CanvasSize, XLabelHeight)
	local xLabels: Frame = _new("Frame")({
		Name = "XLabels",
		LayoutOrder = 2,
		BackgroundTransparency = 1,
		Size = XLabelSize,
		AutomaticSize = Enum.AutomaticSize.Y,
	}) :: any

	local canvas: Frame = _new("Frame")({
		Name = "Canvas",
		Size = CanvasSize,
		ClipsDescendants = true,
		BackgroundTransparency = 0,
		BackgroundColor3 = CanvasColor,
		LayoutOrder = 3,
		ZIndex = 1,
		Children = {} :: { [number]: any },
	}) :: any

	local graphInstance: Frame = _layout:GetContainer({
		_layout:GetVerticalList(PseudoEnum.GuiAlignmentType.TopRight, PseudoEnum.GuiDensityModifier.High) :: any,
		xLabels,
		_layout:GetContainer({
			yLabels,
			_layout:GetHorizontalList(PseudoEnum.GuiAlignmentType.TopRight, PseudoEnum.GuiDensityModifier.High) :: any,
			_new("Frame")({
				Name = "YText",
				BackgroundTransparency = 1,
				Size = _Computed(function(size: UDim2, txtSize: number): UDim2
					return UDim2.new(UDim.new(0, txtSize), size.Y)
				end, YLabelSize, StyleGuide:GetTextSize(PseudoEnum.GuiTypography.Button)),
				LayoutOrder = 1,
				AutomaticSize = Enum.AutomaticSize.None,
				Children = {
					_new("TextLabel")({
						Name = "TextLabel",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0, 0),
						FontFace = StyleGuide:GetFont(LabelTypography),
						TextSize = StyleGuide:GetTextSize(LabelTypography),
						TextColor3 = TextColor,
						Text = YAxisLabel,
						RichText = true,
						LayoutOrder = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Rotation = -90,
						AutomaticSize = Enum.AutomaticSize.XY,
					}),
				} :: { [number]: any },
			}),

			canvas :: any,
		}, nil, 1, "Container", nil),
		_new("TextLabel")({
			Name = "XText",
			BackgroundTransparency = 1,
			Size = XLabelSize,
			FontFace = StyleGuide:GetFont(LabelTypography),
			TextSize = StyleGuide:GetTextSize(LabelTypography),
			TextColor3 = TextColor,
			Text = XAxisLabel,
			RichText = true,
			LayoutOrder = 3,
			AutomaticSize = Enum.AutomaticSize.Y,
		}),
	}, nil, nil, "Graph", nil)

	local function getIncrement(start: number, range: number, count: number): number?
		local rawIncrement = range / count
		local scale = calculateScale(rawIncrement)
		if scale then
			local increment: number
			if math.abs(scale - rawIncrement) > math.abs(2.5 * scale - rawIncrement) then
				if math.abs(2.5 * scale - rawIncrement) < math.abs(5 * scale - rawIncrement) then
					increment = 2.5 * scale
				else
					increment = 5 * scale
				end
			else
				if math.abs(0.5 * scale - rawIncrement) < math.abs(scale - rawIncrement) then
					if math.abs(0.25 * scale - rawIncrement) < math.abs(0.5 * scale - rawIncrement) then
						increment = 0.25 * scale
					else
						increment = 0.5 * scale
					end
				else
					increment = scale
				end
			end
			return increment
		else
			return nil
		end
	end

	local function getStart(sVal: number, increment: number)
		local iStart = sVal
		local sRemainder = sVal % increment
		if sRemainder ~= 0 then
			iStart -= sRemainder
			iStart += increment
		end
		return iStart
	end

	local function getReps(rVal: number, increment: number)
		return math.floor(rVal / increment)
	end

	local HorizontalLineData = _Computed(function(range: Vector2, start: Vector2): { [number]: LineData }
		local list = {}
		local sVal = start.Y
		local rVal = range.Y
		local count = GOAL_HORIZONTAL_GRID_LINES

		local increment = getIncrement(sVal, rVal, count)
		if not increment then
			return list
		end
		assert(increment ~= nil)

		local iStart = getStart(sVal, increment)
		local reps = getReps(rVal, increment)

		for i = 0, reps do
			local value = iStart + i * increment
			local alpha = (value - sVal) / rVal
			local data: LineData = {
				Value = value,
				Start = Vector2.new(0, alpha),
				Finish = Vector2.new(1, alpha),
			}
			table.insert(list, data)
		end

		return list
	end, Range, StartCorner)

	local VerticalLineData = _Computed(function(range: Vector2, start: Vector2): { [number]: LineData }
		local list = {}
		local sVal = start.X
		local rVal = range.X
		local count = GOAL_VERTICAL_GRID_LINES

		local increment = getIncrement(sVal, rVal, count)
		if not increment then
			return list
		end
		assert(increment ~= nil)

		local iStart = getStart(sVal, increment)
		local reps = getReps(rVal, increment)

		for i = 0, reps do
			local value = iStart + i * increment
			local alpha = (value - sVal) / rVal
			local data: LineData = {
				Value = value,
				Start = Vector2.new(alpha, 0),
				Finish = Vector2.new(alpha, 1),
			}
			table.insert(list, data)
		end

		return list
	end, Range, StartCorner)

	local GridLineThickness = _Computed(function(thickness: UDim)
		return UDim.new(thickness.Scale * GRID_LINE_WEIGHT, math.ceil(thickness.Offset * GRID_LINE_WEIGHT))
	end, Thickness)

	HorizontalLineData:ForValues(function(v: LineData, processorMaid: Maid)
		local scale = 1 - v.Start.Y
		if scale >= 0 and scale <= 1 then
			newGridLine(processorMaid, canvas, v.Start, v.Finish, GridLineThickness, GridLineColor, _Value(0))
			newGridLabel(processorMaid, yLabels, v.Value, Vector2.new(1, 0.5), UDim2.fromScale(1, scale), TextColor)
		end
		return v
	end)

	VerticalLineData:ForValues(function(v: LineData, processorMaid: Maid)
		local scale = v.Start.X
		if scale >= 0 and scale <= 1 then
			newGridLine(processorMaid, canvas, v.Start, v.Finish, GridLineThickness, GridLineColor, _Value(0))
			newGridLabel(processorMaid, xLabels, v.Value, Vector2.new(0.5, 0), UDim2.fromScale(scale, 0), TextColor)
		end
		return v
	end)

	local SelectedDataTable: ValueState<string?> = _Value(nil :: string?)
	local transparencyRegistry: Dict<string, State<number>> = {}

	for k, dataTable in pairs(dataTables) do
		local DataColorState = _import(dataTable.Color, Color3.new(0,0,1))
		transparencyRegistry[dataTable.Id] = _Computed(function(id: string?)
			if id == nil or id == dataTable.Id then
				return 0
			else
				return DESELECTED_GRAPH_TRANSPARENCY
			end
		end, SelectedDataTable):Tween()
		local dataRender = newDataRender(
			maid,
			DataColorState,
			dataTable.Data,
			CanvasColor,
			Thickness,
			transparencyRegistry[dataTable.Id]:Tween(),
			StartCorner,
			Range
		)
		dataRender.Parent = canvas
	end

	maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
		local xMaxHeight = 0
		for i, child in ipairs(xLabels:GetChildren()) do
			if child:IsA("TextLabel") then
				xMaxHeight = math.max(child.AbsoluteSize.Y, xMaxHeight)
			end
		end
		local yMaxWidth = 0
		for i, child in ipairs(yLabels:GetChildren()) do
			if child:IsA("TextLabel") then
				yMaxWidth = math.max(child.AbsoluteSize.X, yMaxWidth)
			end
		end
		XLabelHeight:Set(xMaxHeight)
		YLabelWidth:Set(yMaxWidth)
	end))
	local legendInstances = {
		_layout:GetVerticalList(PseudoEnum.GuiAlignmentType.TopRight, PseudoEnum.GuiDensityModifier.High) :: any,
		graphInstance
	}
	for id, _Transparency in pairs(transparencyRegistry) do
		local dataTable: DataTable? = nil
		for k, possibleTable in pairs(dataTables) do
			if possibleTable.Id == id then
				dataTable = possibleTable
			end
		end
		assert(dataTable)
		local ButtonColor = _Computed(function(selected: string?, defColor: Color3, selColor: Color3)
			if selected ~= id then
				return defColor
			else
				return selColor
			end
		end, SelectedDataTable, CanvasColor, SelectedLegendColor, TextColor):Tween()

		local ButtonTextColor = _Computed(function(buttonColor: Color3, textColor: Color3)
			return StyleGuide.getReadableColor(textColor, buttonColor)
		end, ButtonColor, TextColor)

		local button = _new("TextButton")({
			Name = id,
			AutoButtonColor = true,
			BackgroundColor3 = ButtonColor,
			LayoutOrder = dataTable.LayoutOrder,
			Events = {
				Activated = function()
					SoundService:PlayLocalSound(CLICK_SOUND)
					if SelectedDataTable:Get() == id then
						SelectedDataTable:Set(nil)
					else
						SelectedDataTable:Set(id)
					end
				end,
			},
			AutomaticSize = Enum.AutomaticSize.XY,
			Children = {
				_layout:GetHorizontalList(PseudoEnum.GuiAlignmentType.Center, PseudoEnum.GuiDensityModifier.High) :: any,
				_effect:GetUICorner(),
				_layout:GetUIPadding(PseudoEnum.GuiDensityModifier.High, true),
				_new("Frame")({
					BackgroundColor3 = dataTable.Color,
					Size = _Computed(function(txtSize: number)
						local iconSize = math.round(0.6*txtSize)
						return UDim2.fromOffset(iconSize, iconSize)
					end, StyleGuide:GetTextSize(LabelTypography)),
					Children = {
						_effect:GetUICorner(1),
					},
				}),
				_new("TextLabel")({
					Name = "ButtonText",
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(0,0),
					FontFace = StyleGuide:GetFont(LabelTypography),
					TextSize = StyleGuide:GetTextSize(LabelTypography),
					TextColor3 = ButtonTextColor,
					Text = dataTable.Name,
					RichText = true,
					LayoutOrder = 3,
					AutomaticSize = Enum.AutomaticSize.XY,
				}),
			},
		})
		table.insert(legendInstances, button)
	end

	local legend = _layout:GetContainer(legendInstances, "High", 2, "Legend", nil)

	local inst = _layout:GetContainer({
		_layout:GetHorizontalList(PseudoEnum.GuiAlignmentType.TopRight, PseudoEnum.GuiDensityModifier.High) :: any,
		graphInstance,
		legend
	}, "High", nil, "Graph", nil)
	
	return inst
end
