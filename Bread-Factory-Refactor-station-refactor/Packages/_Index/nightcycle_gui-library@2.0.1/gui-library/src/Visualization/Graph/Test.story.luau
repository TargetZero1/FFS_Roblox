--!strict
-- Services
local HttpService = game:GetService("HttpService")

-- Packages
local GraphModule = script.Parent
assert(GraphModule)
local VisModule = GraphModule.Parent
assert(VisModule)
local Package = VisModule.Parent
assert(Package)
assert(Package)
local Packages = Package.Parent
assert(Packages)

local Maid = require(Packages:WaitForChild("Maid"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))
local TableUtil = require(Packages:WaitForChild("TableUtil"))
-- Modules
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local StyleGuide = ModuleProvider.StyleGuide
local Graph = require(script.Parent)

-- Types
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type Maid = Maid.Maid
type Dict<K,V> = TableUtil.Dict<K,V>
type List<V> = TableUtil.List<V>
type DataTable = Graph.DataTable

-- Constants
-- Variables
-- References
-- Class
return function(coreGui: Frame)
	local maid = Maid.new()

	task.spawn(function()
		StyleGuide.init(maid)

		local _fuse = ColdFusion.fuse(maid)
		local _new = _fuse.new
		local _bind = _fuse.bind
		local _import = _fuse.import

		local _Value = _fuse.Value
		local _Computed = _fuse.Computed


		local XAxisLabel: State<string> = _Value("X-Axis")
		local YAxisLabel: State<string> = _Value("Y-Axis")

		local dataTables: Dict<any, DataTable> = {}

		local tableCount = 3
		for j=1, tableCount do
			local data = {}
			local color = Color3.fromHSV(j/tableCount, 1, 1)
			local count = 50
			local id = HttpService:GenerateGUID(false)
			local dataTable:any = {
				Color = _Value(color),
				Id = id,
				Name = "Data "..tostring(j),
				Data = _Value(data),
			}
			dataTables[dataTable.Id] = dataTable
			for i = 1, count do
				data[HttpService:GenerateGUID(false)] = Vector2.new(i, math.random() * i / count)
				dataTable.Data:Set(data)
			end
			-- task.spawn(function()
			-- 	for i=count, count+30 do
			-- 		task.wait(0.05)
			-- 		data[HttpService:GenerateGUID(false)] = Vector2.new(i, math.random() * i / count)
			-- 		dataTable.Data:Set(data)
			-- 	end
			-- end)
		end

		local CanvasSize: State<UDim2> = _Value(UDim2.fromOffset(400, 400))
		local Thickness: State<UDim> = _Value(UDim.new(0, 3))
		local CanvasColor: State<Color3> = _Value(Color3.fromHSV(1, 0, 0.3))
		local GridLineColor: State<Color3> = _Value(Color3.fromHSV(1, 0, 0.1))

		local TextColor: State<Color3> = _Value(Color3.fromHSV(1, 0, 0.5))
		local SelButtonColor: State<Color3> = _Value(Color3.fromHSV(0.15, 1, 1))
		local graph = Graph(
			maid,
			dataTables,
			XAxisLabel,
			YAxisLabel,
			CanvasSize,
			Thickness,
			CanvasColor,
			GridLineColor,
			TextColor,
			SelButtonColor
		)
		graph.Position = UDim2.fromScale(0.5,0.5)
		graph.AnchorPoint = Vector2.new(0.5,0.5)
		graph.Parent = coreGui
	end)

	return function()
		maid:Destroy()
	end
end
