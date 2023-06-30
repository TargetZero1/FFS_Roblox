--!strict
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

-- Packages
local InputModule = script.Parent
assert(InputModule)
local Package = InputModule.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local Signal = require(Packages:WaitForChild("Signal"))
local Synthetic = require(Packages:WaitForChild("Synthetic"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))
-- Modules
-- Constants
local DEFAULT_PALETTE = {}

local medStoneGreyCount = 0
for i = 1, 1032 do
	local val: BrickColor?
	pcall(function()
		val = BrickColor.new(i)
	end)
	if val then
		-- print(i, val.Name)
		local isMedStone = ("Medium stone grey" == val.Name)
		if medStoneGreyCount == 0 or isMedStone == false then
			table.insert(DEFAULT_PALETTE, val.Color)
		end
		if isMedStone then
			medStoneGreyCount += 1
		end
	end
end

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type Fuse = ColdFusion.Fuse
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>

export type GuiParameters = {
	Maid: Maid?,

	Name: CanBeState<string>?,
	Parent: CanBeState<Instance>?,
	Value: ValueState<Color3>,
	BackgroundColor3: CanBeState<Color3>?,
	BackgroundTransparency: CanBeState<number>?,
	TextColor3: CanBeState<Color3>?,
	SelectionBackgroundColor3: CanBeState<Color3>?,
	SelectionTextColor3: CanBeState<Color3>?,
	Palette: CanBeState<{ [number]: Color3 }>?,
	TextSize: CanBeState<number>?,
	Font: CanBeState<Enum.Font>?,
	Padding: CanBeState<UDim>?,
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	ClickSound: CanBeState<Sound?>,
	SizeConstraint: CanBeState<Enum.SizeConstraint>?,
	LayoutOrder: CanBeState<number>?,
	AnchorPoint: CanBeState<Vector2>?,
}
export type Output = Frame
export type Constructor = (config: GuiParameters) -> Output

local function newChip(
	maid: Maid,
	text: string,
	LayoutOrder: number,
	SelState: ValueState<string>,
	BackgroundColor: State<Color3>,
	TextColor: State<Color3>,
	SelBackColor: State<Color3>,
	SelTextColor: State<Color3>,
	TextSize: State<number>,
	FontFace: State<Font>,
	Sound: State<Sound>
)
	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local Padding = _Computed(function(txtSize: number)
		return UDim.new(0, txtSize * 0.25)
	end, TextSize)
	local SidePadding = _Computed(function(txtSize: number)
		return UDim.new(0, txtSize * 0.5)
	end, TextSize)

	return _new("TextButton")({
		Name = text,
		Text = text,
		LayoutOrder = LayoutOrder,
		TextSize = TextSize,
		FontFace = FontFace,
		AutomaticSize = Enum.AutomaticSize.XY,
		AutoButtonColor = _Computed(function(sel: string)
			return sel ~= text
		end, SelState):Tween(),
		TextColor3 = _Computed(function(sel: string, base: Color3, prim: Color3)
			if sel == text then
				return prim
			else
				return base
			end
		end, SelState, TextColor, SelTextColor):Tween(),
		BackgroundColor3 = _Computed(function(sel: string, base: Color3, prim: Color3)
			if sel == text then
				return prim
			else
				return base
			end
		end, SelState, BackgroundColor, SelBackColor):Tween(),
		Events = {
			Activated = function()
				SelState:Set(text)
				local sound = Sound:Get()
				if sound then
					SoundService:PlayLocalSound(sound)
				end
			end,
		},
		Children = {
			_new("UIPadding")({
				PaddingTop = Padding,
				PaddingBottom = Padding,
				PaddingLeft = SidePadding,
				PaddingRight = SidePadding,
			}),
			_new("UICorner")({
				CornerRadius = UDim.new(0.5, 0),
			}),
		} :: { [number]: any },
	})
end

local function newSwatchPanel(
	maid: Maid,
	Value: ValueState<Color3>,
	Colors: State<{ [number]: Color3 }>,
	TextSize: State<number>,
	BackgroundColor3: State<Color3>,
	TextColor3: State<Color3>,
	SelectionColor3: State<Color3>,
	Visible: State<boolean>
)
	local Canvas: Frame
	local function swatchButton(i: number, color: Color3, swatchMaid: Maid): (number, TextButton)
		local _fuse = ColdFusion.fuse(swatchMaid)
		local _synth = Synthetic(swatchMaid)
		local _new = _fuse.new
		local _bind = _fuse.bind
		local _import = _fuse.import

		local _Value = _fuse.Value
		local _Computed = _fuse.Computed

		local h, s, v = color:ToHSV()

		return i,
			_new("TextButton")({
				Name = color:ToHex(),
				LayoutOrder = h * 10 ^ 6 + v * 10 ^ 3 + s,
				BackgroundColor3 = color,
				AutoButtonColor = _Computed(function(col: Color3)
					return color ~= col
				end, Value),
				Parent = Canvas,
				ZIndex = _Computed(function(col: Color3)
					if color == col then
						return 3
					else
						return 0
					end
				end, Value),
				Size = _Computed(function(txtSize: number)
					local width = txtSize * 2
					return UDim2.fromOffset(width, width)
				end, TextSize),
				Events = {
					Activated = function()
						Value:Set(color)
					end,
				},
				Children = {
					_new("UICorner")({
						CornerRadius = UDim.new(0.5, 0),
					}),
					_new("UIStroke")({
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = SelectionColor3,
						Thickness = _Computed(function(col: Color3)
							if color == col then
								return 2
							else
								return 0
							end
						end, Value),
					}),
				} :: { [number]: any },
			}) :: any
	end

	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local ScrollBarThickness = _Computed(function(txtSize: number)
		return txtSize
	end, TextSize)

	local Padding = _Computed(function(txtSize: number)
		return UDim.new(0, txtSize * 0.2)
	end, TextSize)

	local AbsoluteSize = _Value(Vector2.new(0, 0))

	Canvas = _new("Frame")({
		Size = _Computed(function(pad: UDim, thick: number)
			return UDim2.new(1, -(pad.Offset + thick), 0, 0)
		end, Padding, ScrollBarThickness),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Children = {
			-- _new("UIPadding")({
			-- 	PaddingBottom = Padding,
			-- 	PaddingTop = Padding,
			-- 	PaddingLeft = Padding,
			-- 	PaddingRight = _Computed(function(pad: UDim, thick: number)
			-- 		return UDim.new(0,pad.Offset + thick)
			-- 	end, Padding, ScrollBarThickness),
			-- }) :: any,
			_new("UIGridLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				-- FillDirectionMaxCells = _Computed(function(absSize: Vector2, txtSize: number): number
				-- 	return math.floor(absSize.X / (txtSize * 2 + txtSize*0.2))
				-- end, AbsoluteSize, TextSize),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				StartCorner = Enum.StartCorner.TopLeft,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				CellPadding = _Computed(function(txtSize: number)
					local width = txtSize * 0.2
					return UDim2.fromOffset(width, width)
				end, TextSize),
				CellSize = _Computed(function(txtSize: number)
					local width = txtSize * 2
					return UDim2.fromOffset(width, width)
				end, TextSize),
			}) :: any,
		},
	}) :: any

	maid:GiveTask(RunService.RenderStepped:Connect(function(dT: number)
		AbsoluteSize:Set(Canvas.AbsoluteSize)
	end))

	Colors:ForPairs(swatchButton)

	return _new("ScrollingFrame")({
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundColor3 = BackgroundColor3,
		ScrollBarImageColor3 = TextColor3,
		ScrollBarThickness = ScrollBarThickness,
		Visible = Visible,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Children = {
			Canvas :: any,
		},
	})
end

local function newSpectrumPanel(
	maid: Maid,
	Value: ValueState<Color3>,
	TextSize: State<number>,
	BackgroundColor3: State<Color3>,
	TextColor3: State<Color3>,
	SelectionColor3: State<Color3>,
	Visible: State<boolean>
): Instance
	local _fuse = ColdFusion.fuse(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local Padding = _Computed(function(txtSize: number): UDim
		return UDim.new(0, txtSize * 0.5)
	end, TextSize)

	local iH, iS, iV = Value:Get():ToHSV()
	local OutputValue = _Value(iV)
	local OutputHue = _Value(iH)
	local OutputSat = _Value(iS)

	local OutputColor = _Computed(function(h: number, s: number, v: number)
		return Color3.fromHSV(h, s, v)
	end, OutputHue, OutputSat, OutputValue)

	local ContrastFrame = _new("Frame")({
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Children = {
			_new("UIGradient")({
				Rotation = -90,
				Color = _Computed(function(v: number)
					return ColorSequence.new(Color3.fromHSV(0, 0, v))
				end, OutputValue),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		} :: { [number]: any },
	}) :: any

	local HueFrame: TextButton = _new("TextButton")({
		Size = _Computed(function(txtSize: number, padding: UDim)
			return UDim2.new(1, -1.5 * txtSize - padding.Offset, 1, 0)
		end, TextSize, Padding),
		TextTransparency = 1,
		LayoutOrder = 1,
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Children = {
			_new("Frame")({
				ZIndex = 10,
				Size = _Computed(function(txtSize: number)
					return UDim2.fromOffset(txtSize, txtSize)
				end, TextSize),
				Position = _Computed(function(h: number, s: number)
					return UDim2.fromScale(h, 1 - s)
				end, OutputHue, OutputSat),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Value,
				Children = {
					_new("UICorner")({
						CornerRadius = UDim.new(0.5, 0),
					}),
					_new("UIStroke")({
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = _Computed(function(h: number, s: number, v: number)
							return Color3.fromHSV(h, 1 - s, 1 - v)
						end, OutputHue, OutputSat, OutputValue),
						Thickness = _Computed(function(pad: UDim)
							return pad.Offset
						end, Padding),
					}),
				} :: { [number]: any },
			}),
			_new("UIGradient")({
				Rotation = 0,
				Color = _Computed(function(v: number)
					return ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, v)),
						ColorSequenceKeypoint.new(0.1, Color3.fromHSV(0.1, 1, v)),
						ColorSequenceKeypoint.new(0.2, Color3.fromHSV(0.2, 1, v)),
						ColorSequenceKeypoint.new(0.3, Color3.fromHSV(0.3, 1, v)),
						ColorSequenceKeypoint.new(0.4, Color3.fromHSV(0.4, 1, v)),
						ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, v)),
						ColorSequenceKeypoint.new(0.6, Color3.fromHSV(0.6, 1, v)),
						ColorSequenceKeypoint.new(0.7, Color3.fromHSV(0.7, 1, v)),
						ColorSequenceKeypoint.new(0.8, Color3.fromHSV(0.8, 1, v)),
						ColorSequenceKeypoint.new(0.9, Color3.fromHSV(0.9, 1, v)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, v)),
					})
				end, OutputValue),
			}),
			ContrastFrame,
		} :: { [number]: any },
	}) :: any

	local ValueFrame: TextButton = _new("TextButton")({
		Size = _Computed(function(txtSize: number, padding: UDim)
			return UDim2.new(0, 1.5 * txtSize, 1, 0)
		end, TextSize, Padding),
		LayoutOrder = 2,
		TextTransparency = 1,
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Children = {
			_new("UIGradient")({
				Rotation = -90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 0, 1)),
				}),
			}) :: any,
			_new("Frame")({
				Size = _Computed(function(padding: UDim)
					return UDim2.new(UDim.new(1, 0), padding)
				end, Padding),
				BackgroundColor3 = _Computed(function(hsVal: number, col: Color3)
					local h = col:ToHSV()
					return Color3.fromHSV(h, (1 - (math.abs(hsVal - 0.5) * 2)) ^ 1.5, 1 - hsVal)
				end, OutputValue, SelectionColor3),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = _Computed(function(hsVal: number)
					return UDim2.fromScale(0.5, 1 - hsVal)
				end, OutputValue),
			}) :: any,
		} :: { [number]: any },
	}) :: any

	maid:GiveTask(HueFrame.MouseButton1Down:Connect(function(x: number, y: number)
		OutputHue:Set(((x - HueFrame.AbsolutePosition.X) / HueFrame.AbsoluteSize.X))
		OutputSat:Set(1 - ((y - HueFrame.AbsolutePosition.Y) / HueFrame.AbsoluteSize.Y))
	end))

	maid:GiveTask(ValueFrame.MouseButton1Down:Connect(function(x: number, y: number)
		OutputValue:Set(1 - ((y - ValueFrame.AbsolutePosition.Y) / ValueFrame.AbsoluteSize.Y))
	end))

	maid:GiveTask(OutputColor:Connect(function(cur: Color3)
		-- print(cur:ToHSV())
		Value:Set(cur)
	end))

	maid:GiveTask(Value:Connect(function(change: Color3)
		local h, s, v = change:ToHSV()
		OutputValue:Set(v)
		OutputHue:Set(h)
		OutputSat:Set(s)
	end))

	local Canvas = _new("Frame")({
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		BackgroundTransparency = 1,
		Visible = Visible,
		Children = {
			ValueFrame,
			HueFrame,
			_new("UIListLayout")({
				Padding = Padding,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}) :: any,
		} :: { [number]: any },
	})

	return Canvas
end

function Constructor(config: GuiParameters): Output
	-- Unpack workspace
	local _maid = config.Maid or Maid.new()
	local _fuse = ColdFusion.fuse(_maid)
	local _synth = Synthetic(_maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	-- Import parameters
	local Value = config.Value
	local Palette = _import(config.Palette, DEFAULT_PALETTE)

	local Name = _import(config.Name, script.Name)
	local Parent = _import(config.Parent, nil :: Instance?)

	local BackgroundColor3 = _import(config.BackgroundColor3, Color3.fromHSV(1, 0, 0.3))
	local TextColor3 = _import(config.TextColor3, Color3.new(1, 1, 1))
	local SelectionBackgroundColor3 = _import(config.SelectionBackgroundColor3, Color3.fromHSV(0.6, 1, 0.8))
	local SelectionTextColor3 = _import(config.SelectionTextColor3, Color3.new(1, 1, 1))
	local FontFace = _import(config.Font, Font.fromEnum(Enum.Font.Gotham))

	local TextSize = _import(config.TextSize, 12)

	local LayoutOrder = _import(config.LayoutOrder, 0)
	local Padding = _import(config.Padding, UDim.new(0, 2))

	local SizeConstraint = _import(config.SizeConstraint, Enum.SizeConstraint.RelativeXY)
	local Position = _import(config.Position, UDim2.fromScale(0, 0))
	local Size = _import(config.Size, UDim2.fromOffset(250, 250))
	local AnchorPoint = _import(config.AnchorPoint, Vector2.new(0, 0))

	local Sound = _import(config.ClickSound, nil :: Sound?)

	-- Private states
	local Mode = _Value("Swatches")

	-- Instances
	local Palettes = newSwatchPanel(
		_maid,
		Value,
		Palette,
		TextSize,
		BackgroundColor3,
		TextColor3,
		SelectionBackgroundColor3,
		_Computed(function(mode: string)
			return mode == "Swatches"
		end, Mode)
	)
	local Spectrum = newSpectrumPanel(
		_maid,
		Value,
		TextSize,
		BackgroundColor3,
		TextColor3,
		SelectionBackgroundColor3,
		_Computed(function(mode: string)
			return mode == "Spectrum"
		end, Mode)
	)

	-- local Field = newFieldPanel(
	-- 	_maid,
	-- 	Value,
	-- 	TextSize,
	-- 	BackgroundColor3,
	-- 	TextColor3,
	-- 	Font,
	-- 	SelectionBackgroundColor3,
	-- 	_Computed(function(mode: string)
	-- 		return mode == "Input"
	-- 	end, Mode)
	-- )

	local Output: Frame = _new("Frame")({
		Name = Name,
		Parent = Parent,
		Position = Position,
		Size = Size,
		SizeConstraint = SizeConstraint,
		AnchorPoint = AnchorPoint,
		LayoutOrder = LayoutOrder,
		BackgroundTransparency = 1,
		Children = {
			_new("UIListLayout")({
				Padding = Padding,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			_new("Frame")({
				Name = "Canvas",
				LayoutOrder = 1,
				BackgroundTransparency = 1,
				Size = _Computed(function(txtSize: number)
					return UDim2.new(1, 0, 1, -txtSize)
				end, TextSize),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Children = {
					-- _new("UIPadding")({
					-- 	PaddingBottom = Padding,
					-- 	PaddingTop = Padding,
					-- 	PaddingLeft = Padding,
					-- 	PaddingRight = Padding,
					-- }) :: any,
					-- _new("UIListLayout")({
					-- 	Padding = UDim.new(0,0),
					-- 	FillDirection = Enum.FillDirection.Vertical,
					-- 	HorizontalAlignment = Enum.HorizontalAlignment.Center,
					-- 	SortOrder = Enum.SortOrder.LayoutOrder,
					-- 	VerticalAlignment = Enum.VerticalAlignment.Center,
					-- }),
					-- Field,
					Spectrum,
					Palettes,
				} :: { [number]: any },
			}),
			_new("Frame")({
				Name = "Menu",
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				Size = _Computed(function(txtSize: number)
					return UDim2.new(1, 0, 0, txtSize)
				end, TextSize),
				Children = {
					-- _new("UIPadding")({
					-- 	PaddingBottom = Padding,
					-- 	PaddingTop = Padding,
					-- 	PaddingLeft = Padding,
					-- 	PaddingRight = Padding,
					-- }) :: any,
					_new("UIListLayout")({
						Padding = Padding,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Top,
					}) :: any,
					newChip(
						_maid,
						"Swatches",
						1,
						Mode,
						BackgroundColor3,
						TextColor3,
						SelectionBackgroundColor3,
						SelectionTextColor3,
						TextSize,
						FontFace,
						Sound
					),
					newChip(
						_maid,
						"Spectrum",
						2,
						Mode,
						BackgroundColor3,
						TextColor3,
						SelectionBackgroundColor3,
						SelectionTextColor3,
						TextSize,
						FontFace,
						Sound
					),
					-- newChip(_maid,"Input", 3, Mode, BackgroundColor3, TextColor3, SelectionBackgroundColor3, SelectionTextColor3, TextSize, Font, Sound),
				} :: { [number]: any },
			}),
		} :: { [number]: any },
	}) :: any

	return Output
end

return function(maid: Maid, config: GuiParameters): Output
	local inst = Constructor(config)
	maid:GiveTask(inst)
	return inst
end
