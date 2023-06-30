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
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))
-- Gamework
-- Modules
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local PseudoEnum = ModuleProvider.PseudoEnum
local StyleGuide = ModuleProvider.StyleGuide

-- Types
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
-- Constants
-- Variables
-- References
-- Class
return function(coreGui: Frame)
	local maid: Maid.Maid = Maid.new()

	task.spawn(function()
		local _fuse = ColdFusion.fuse(maid)
		local _new = _fuse.new
		local _bind = _fuse.bind
		local _import = _fuse.import

		local _Value = _fuse.Value
		local _Computed = _fuse.Computed


		StyleGuide.init(maid)

		local DataTable = require(script.Parent)
		local columnInputs: { [number]: DataTable.ColumnInput } = {
			{
				FitWidthToHeader = true,
				Alignment = PseudoEnum.GuiAlignmentType.Center,
				Name = "ABC",
				Text = "ABC Name",
				TextWrapped = true,
				Width = nil,
			},
			{
				FitWidthToHeader = true,
				Alignment = PseudoEnum.GuiAlignmentType.Center,
				Name = "DEF",
				Text = "DEF Name",
				TextWrapped = true,
				Width = nil,
			},
			{
				FitWidthToHeader = true,
				Alignment = PseudoEnum.GuiAlignmentType.Center,
				Name = "GHI",
				Text = "GHI Name SUPER LONG N A M E",
				TextWrapped = true,
				Width = nil,
			},
			{
				FitWidthToHeader = true,
				Alignment = PseudoEnum.GuiAlignmentType.Center,
				Name = "JKL",
				Text = "JKL Name",
				TextWrapped = true,
				Width = nil,
			},
			{
				FitWidthToHeader = true,
				Alignment = PseudoEnum.GuiAlignmentType.Center,
				Name = "LMN",
				Text = "LMN Name",
				TextWrapped = true,
				Width = nil,
			},
		}
		local Data: State<{ [number]: { [string]: any } }> = _Value({
			{
				ABC = 123,
				DEF = 456,
				GHI = 789,
				JKL = "test A",
				LMN = "test B",
			},
			{
				ABC = 123,
				DEF = 456,
				GHI = 789,
				JKL = "test A",
				LMN = "test B",
			},
			{
				ABC = 123,
				DEF = 456,
				GHI = 789,
				JKL = "test A",
				LMN = "test B",
			},
			{
				ABC = 123,
				DEF = 456,
				GHI = 789,
				JKL = "test A",
				LMN = "test B",
			},
			{
				ABC = 123,
				DEF = 456,
				GHI = 789,
				JKL = "test A",
				LMN = "test B",
			},
			{
				ABC = 123,
				DEF = 456,
				GHI = 789,
				JKL = "test A",
				LMN = "test B",
			},
			{
				ABC = 123,
				DEF = 456,
				GHI = 789,
				JKL = "test A",
				LMN = "test B",
			},
		})

		local parentFrame = _new("Frame")({
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = StyleGuide:GetColor(PseudoEnum.GuiColorPalette.Surface1),
			Parent = coreGui,
		})

		local frame = DataTable(
			maid,
			Data,
			columnInputs,
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			Enum.AutomaticSize.X,
			nil,
			UDim2.fromOffset(0, 300)
		)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Parent = parentFrame
	end)

	return function()
		maid:Destroy()
	end
end
