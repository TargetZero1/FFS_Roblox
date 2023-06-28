--!strict
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
local GeometryUtil = require(Packages:WaitForChild("GeometryUtil"))

-- Modules

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type Fuse = ColdFusion.Fuse
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

type CanBeState<T> = (State<T> | T)

export type GuiParameters = {
	Maid: Maid?,
	Parent: CanBeState<Instance>,
	PrimaryInputs: CanBeState<{ [string]: State<number> }>,
	SecondaryInputs: CanBeState<{ [string]: State<number> }>?,
	PrimaryColor: CanBeState<Color3>?,
	SecondaryColor: CanBeState<Color3>?,
	LineColor: CanBeState<Color3>?,
	LineThickness: CanBeState<number>?,
	FillTransparency: CanBeState<number>?,
	Size: CanBeState<UDim2>?,
	Position: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,
}
export type Output = Frame
export type Constructor = (config: GuiParameters) -> Output

type EdgeData = {
	Longest: Vector2,
	Other: Vector2,
	Position: Vector2,
}

type EnhancedEdgeData = EdgeData & {
	Angle: GeometryUtil.Radian,
	X: number,
	Y: number,
}

function Constructor(config: GuiParameters): Output
	local _maid = config.Maid or Maid.new()
	local _fuse = ColdFusion.fuse(_maid)
	local _synth = Synthetic(_maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	-- Unpack parameters
	local PrimaryColor = _import(config.PrimaryColor, Color3.fromHSV(0, 1, 1))
	local SecondaryColor = _import(config.SecondaryColor, Color3.fromHSV(0.5, 1, 1))
	local LineColor = _import(config.LineColor, Color3.fromHSV(0, 0.0, 1))
	local LineThickness = _import(config.LineThickness, 3)
	local Size = _import(config.Size, UDim2.fromOffset(150, 150))
	local Position = _import(config.Position, UDim2.fromScale(0.5, 0.5))
	local AnchorPoint = _import(config.AnchorPoint, Vector2.new(0.5, 0.5))
	local PrimaryInputs = _import(config.PrimaryInputs, {})
	local SecondaryInputs = _import(config.SecondaryInputs, {})
	local FillTransparency = _import(config.FillTransparency, 0.5)
	local Parent = _import(config.Parent, nil :: GuiObject?)

	local function newDot(
		point: State<Vector2>,
		color: CanBeState<Color3>,
		thickness: State<number>,
		zIndex: number,
		dotTransparency: number?
	): Frame
		return _new("Frame")({
			Name = "Dot",
			BackgroundTransparency = dotTransparency,
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = _Computed(function(p: Vector2)
				return UDim2.fromOffset(p.X, p.Y)
			end, point),
			Size = _Computed(function(thick: number)
				return UDim2.fromOffset(thick * 3, thick * 3)
			end, thickness),
			ZIndex = zIndex,
			Children = {
				_new("UICorner")({
					CornerRadius = UDim.new(0.5, 0),
				}),
			} :: { [number]: any },
		}) :: Frame
	end

	local function newLabel(
		txt: CanBeState<string>,
		position: State<Vector2>,
		origin: State<Vector2>,
		color: CanBeState<Color3>
	): TextLabel
		return _new("TextLabel")({
			Name = "Label",
			Text = txt,
			Size = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1,
			TextColor3 = color,
			FontFace = Enum.Font.SourceSansBold,
			AutomaticSize = Enum.AutomaticSize.XY,
			Position = _Computed(function(pos: Vector2): UDim2
				return UDim2.fromOffset(pos.X, pos.Y)
			end, position),
			AnchorPoint = _Computed(function(pos: Vector2, ori: Vector2): Vector2
				local dir = (pos - ori).Unit * -2
				-- print("Dir", dir)
				return Vector2.new(
					math.sign(dir.X) * math.round(math.abs(dir.X)),
					math.sign(dir.Y) * math.round(math.abs(dir.Y))
				).Unit
			end, position, origin),
		}) :: TextLabel
	end

	local function newTriangle(
		aState: State<Vector2>,
		bState: State<Vector2>,
		cState: State<Vector2>,
		extra: number,
		color: CanBeState<Color3>,
		transparency: State<number>,
		zIndex: number
	)
		local function dotv2(_a: Vector2, _b: Vector2)
			return _a.X * _b.X + _a.Y * _b.Y
		end

		local function rotateV2(vec: Vector2, angle: GeometryUtil.Radian): Vector2
			local x = vec.X * math.cos(angle) + vec.Y * math.sin(angle)
			local y = -vec.X * math.sin(angle) + vec.Y * math.cos(angle)
			return Vector2.new(x, y)
		end

		local edges = _Computed(function(a: Vector2, b: Vector2, c: Vector2)
			local list: { [number]: EdgeData } = {
				{ Longest = (c - b), Other = (a - b), Position = b },
				{ Longest = (a - c), Other = (b - c), Position = c },
				{ Longest = (b - a), Other = (c - a), Position = a },
			}
			table.sort(list, function(edge0: EdgeData, edge1: EdgeData)
				return edge0.Longest.Magnitude > edge1.Longest.Magnitude
			end)
			return list
		end, aState, bState, cState)

		local edge = _Computed(function(eds): EnhancedEdgeData
			local eRef: EdgeData = eds[1]
			local angle = math.acos(dotv2(eRef.Longest.Unit, eRef.Other.Unit))
			return {
				Longest = eRef.Longest,
				Other = eRef.Other,
				Position = eRef.Position,
				Angle = angle,
				X = eRef.Other.Magnitude * math.cos(angle),
				Y = eRef.Other.Magnitude * math.sin(angle),
			}
		end, edges)

		local r = _Computed(function(e: EnhancedEdgeData): Vector2
			return e.Longest.Unit * e.X - e.Other
		end, edge)

		local rotation = _Computed(function(rDir: Vector2): GeometryUtil.Radian
			return math.atan2(rDir.Y, rDir.X) - math.pi / 2
		end, r)

		local tp = _Computed(function(e: EnhancedEdgeData): Vector2
			return -e.Other
		end, edge)

		local tx = _Computed(function(e: EnhancedEdgeData): Vector2
			return (e.Longest.Unit * e.X) - e.Other
		end, edge)

		local nz = _Computed(function(p: Vector2, x: Vector2): number
			return p.X * x.Y - p.Y * x.X
		end, tp, tx)

		local t1c1 = _Computed(function(e: EnhancedEdgeData): Vector2
			return e.Position + e.Other
		end, edge)
		local t1c2 = _Computed(function(e: EnhancedEdgeData, z: number, x: Vector2): Vector2
			return z > 0 and e.Position + e.Longest - x or e.Position - x
		end, edge, nz, tx)

		local tasize = _Computed(function(c1: Vector2, c2: Vector2, e: EnhancedEdgeData)
			return Vector2.new((c1 - c2).Magnitude, e.Y)
		end, t1c1, t1c2, edge)
		local tbsize = _Computed(function(s: Vector2, e: EnhancedEdgeData): Vector2
			return Vector2.new(e.Longest.Magnitude - s.X, e.Y)
		end, tasize, edge)

		local center1 = _Computed(function(z: number, e: EnhancedEdgeData): Vector2
			return z <= 0 and e.Position + ((e.Longest + e.Other) / 2) or (e.Position + e.Other / 2)
		end, nz, edge)
		local center2 = _Computed(function(z: number, e: EnhancedEdgeData): Vector2
			return z > 0 and e.Position + ((e.Longest + e.Other) / 2) or (e.Position + e.Other / 2)
		end, nz, edge)

		local finalt1c1 = _Computed(function(t1: Vector2, c1: Vector2, rot: GeometryUtil.Radian): Vector2
			return c1 + rotateV2(t1 - c1, rot)
		end, t1c1, center1, rotation)
		local finalt1c2 = _Computed(function(t2: Vector2, c2: Vector2, rot: GeometryUtil.Radian): Vector2
			return c2 + rotateV2(t2 - c2, rot)
		end, t1c2, center2, rotation)

		local triA = _new("ImageLabel")({
			Name = "TriangleA",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "rbxassetid://319692171",
			ImageTransparency = transparency,
			ImageColor3 = color,
			Position = _Computed(function(final: Vector2): UDim2
				return UDim2.new(0, final.X, 0, final.Y)
			end, finalt1c1),
			Size = _Computed(function(size: Vector2): UDim2
				return UDim2.fromOffset(size.X + extra, size.Y + extra)
			end, tbsize),
			Rotation = _Computed(function(rot: GeometryUtil.Radian): GeometryUtil.Degree
				return math.deg(rot)
			end, rotation),
			ZIndex = zIndex,
		})

		local triB = _new("ImageLabel")({
			Name = "TriangleB",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "rbxassetid://319692151",
			ImageTransparency = transparency,
			ImageColor3 = color,
			Position = _Computed(function(final: Vector2): UDim2
				return UDim2.new(0, final.X, 0, final.Y)
			end, finalt1c2),
			Size = _Computed(function(size: Vector2): UDim2
				return UDim2.fromOffset(size.X + extra, size.Y + extra)
			end, tasize),
			Rotation = _Computed(function(rot: GeometryUtil.Radian): GeometryUtil.Degree
				return math.deg(rot)
			end, rotation),
			ZIndex = zIndex,
		})

		return triA, triB
	end

	local function newLine(
		p1: State<Vector2>,
		p2: State<Vector2>,
		color: CanBeState<Color3>,
		thickness: State<number>,
		zIndex: number,
		transparency: number?
	)
		return _new("Frame")({
			Name = "Line",
			BackgroundColor3 = color,
			BackgroundTransparency = transparency,
			BorderSizePixel = 0,
			ZIndex = zIndex,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = _Computed(function(a: Vector2, b: Vector2)
				local result = a + (b - a) * 0.5
				return UDim2.fromOffset(result.X, result.Y)
			end, p1, p2),
			Rotation = _Computed(function(a: Vector2, b: Vector2)
				local result = (b - a)
				return math.deg(math.atan2(result.Y, result.X))
			end, p1, p2),
			Size = _Computed(function(a: Vector2, b: Vector2, thick: number)
				local length = (b - a).Magnitude
				return UDim2.fromOffset(length, thick)
			end, p1, p2, thickness),
			Children = {
				_new("UICorner")({
					CornerRadius = UDim.new(0.5, 0),
				}),
			} :: { [number]: any },
		})
	end

	local function fill(Inputs: State<{ [string]: State<number> }>, fillColor: State<Color3>, baseZIndex: number)
		local Data = _Value({})
		-- print("Inputs")
		local TweenInputs = _Computed(function(inputs: { [string]: State<number> }): { [string]: State<number> }
			local tweenInputs = {}
			for k, value in pairs(inputs) do
				tweenInputs[k] = value:Tween()
			end
			return tweenInputs
		end, Inputs)
		local inputMaid = Maid.new()
		_Computed(function(tweenInputs: { [string]: State<number> }): nil
			inputMaid:DoCleaning()
			local function update()
				local data = {}
				for k, state in pairs(tweenInputs) do
					data[k] = math.clamp(state:Get(), 0.001, 1)
				end
				Data:Set(data)
			end
			for k, state in pairs(tweenInputs) do
				inputMaid:GiveTask(state:Connect(update))
			end
			update()
			return nil
		end, TweenInputs)

		local lineMaid = Maid.new()
		_maid:GiveTask(lineMaid)
		-- local minRadius = 2
		return _Computed(function(tweenInputs: { [string]: State<number> }, size: UDim2, maxThickness: number)
			lineMaid:DoCleaning()

			local objects: { [number]: Instance } = {}
			local order: { [number]: string } = {}
			for k, vState in pairs(tweenInputs) do
				table.insert(order, k)
			end

			local sliceAngle = math.rad(360 / #order)
			local maxRadius = size.X.Offset / 2
			local origin = Vector2.new(maxRadius, maxRadius)

			local centerPoint = newDot(_Value(origin), LineColor, _Value(maxThickness * 0.5), 2, 0)
			table.insert(objects, centerPoint)

			local function ring(radius, thickness, zIndex, transparency, dotTransparency)
				for i, k in ipairs(order) do
					local sOffset =
						Vector2.new(math.sin(sliceAngle * (i - 1)) * radius, math.cos(sliceAngle * (i - 1)) * radius)

					local sFinish = Vector2.new(math.sin(sliceAngle * i) * radius, math.cos(sliceAngle * i) * radius)

					local start = _Value(origin + sOffset)
					local finish = _Value(origin + sFinish)
					local thickState = _Value(math.ceil(thickness))

					local point = newDot(start, LineColor, thickState, 2, dotTransparency)
					local line = newLine(start, finish, LineColor, thickState, zIndex, transparency)

					lineMaid:GiveTask(point)
					lineMaid:GiveTask(line)

					table.insert(objects, point)
					table.insert(objects, line)
				end
			end
			ring(maxRadius * 0.25, maxThickness * 0.5, 1, 0.8, 1)
			ring(maxRadius * 0.5, maxThickness * 0.5, 1, 0.8, 1)
			ring(maxRadius * 0.75, maxThickness * 0.5, 1, 0.8, 1)
			ring(maxRadius, maxThickness, 1, 0, 0)

			for index, k in ipairs(order) do
				local vState: State<number> = (tweenInputs :: any)[k] :: any

				local offset = _Computed(function(v: number): Vector2
					local radius = math.clamp(v, 0.001, 1) * maxRadius
					local i = index - 1
					return Vector2.new(math.sin(sliceAngle * i) * radius, math.cos(sliceAngle * i) * radius)
				end, vState)

				local finish = _Computed(function(off: Vector2)
					return origin + off
				end, offset)
				local maxFinish = _Computed(function(off: Vector2)
					return origin + off.Unit * (maxRadius + 10)
				end, offset)
				local dot = newDot(finish, fillColor, _Value(maxThickness * 0.75), baseZIndex + 2, nil)
				lineMaid:GiveTask(dot)

				local label = newLabel(k, maxFinish, _Value(origin), LineColor)
				table.insert(objects, label)
				_maid:GiveTask(label)

				local index2 = index + 1
				local k2 = order[index2]
				if not k2 then
					k2 = order[1]
				end
				if k2 then
					local edgeOffset = _Computed(function(off: Vector2)
						return origin + off
					end, offset)
					local nextOffset = _Computed(function(v2: number)
						local radius2 = v2 * maxRadius
						return Vector2.new(
							math.sin(sliceAngle * (index2 - 1)) * radius2,
							math.cos(sliceAngle * (index2 - 1)) * radius2
						) + origin
					end, tweenInputs[k2])

					local line = newLine(nextOffset, finish, fillColor, _Value(maxThickness), baseZIndex + 4, nil)
					lineMaid:GiveTask(line)

					local tObjects = {
						newTriangle(
							_Value(origin),
							edgeOffset,
							nextOffset,
							2,
							fillColor,
							FillTransparency,
							baseZIndex + 1
						),
					}

					for _, obj in ipairs(tObjects) do
						lineMaid:GiveTask(obj)
						table.insert(objects, obj)
					end

					table.insert(objects, line)
				end

				table.insert(objects, dot)
			end

			return objects
		end, TweenInputs, Size, LineThickness)
	end

	local Output: Frame = _new("Frame")({
		BackgroundTransparency = 1,
		Size = Size,
		AnchorPoint = AnchorPoint,
		Parent = Parent,
		Position = Position,
		Children = {
			fill(PrimaryInputs, PrimaryColor, 10),
			fill(SecondaryInputs, SecondaryColor, 6),
		} :: { [number]: any },
	}) :: any

	_maid:GiveTask(Output.Destroying:Connect(function()
		_maid:Destroy()
	end))

	return Output
end

return function(maid: Maid, config: GuiParameters): Output
	local inst = Constructor(config)
	maid:GiveTask(inst)
	return inst
end
