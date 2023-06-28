--!strict
-- Packages
local MediaModule = script.Parent
assert(MediaModule)
local Package = MediaModule.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local Signal = require(Packages:WaitForChild("Signal"))
local Synthetic = require(Packages:WaitForChild("Synthetic"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))

-- Modules
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local PseudoEnum = ModuleProvider.PseudoEnum
local StyleGuide = ModuleProvider.StyleGuide

type Maid = Maid.Maid
type Signal = Signal.Signal
type Fuse = ColdFusion.Fuse
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
export type GuiParameters = {
	Scale: CanBeState<number>?,
	MainColor3: CanBeState<Color3>?,
	SecondaryColor3: CanBeState<Color3>?,
	MainIcon: CanBeState<string>?,
	SecondaryIcon: CanBeState<string>?,
	IconTransparency: CanBeState<number>?,
	MainScale: CanBeState<number>?,
	SecondaryScale: CanBeState<number>?,
	[any]: any?,
}
export type Output = Frame
export type Constructor = (config: GuiParameters) -> Output

function Constructor(config: GuiParameters): Output
	local _maid = config.Maid or Maid.new()
	local _fuse = ColdFusion.fuse(_maid)
	local _synth = Synthetic(_maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local Name = _import(config.Name, "DoubleIconLabel")
	local Scale = _import(config.Scale, 1)
	local MainColor3 = _import(config.MainColor3, Color3.new(1, 1, 1))
	local SecondaryColor3 = _import(config.SecondaryColor3, Color3.new(1, 1, 1))
	local MainIcon = _import(config.MainIcon, Color3.new(1, 1, 1))
	local SecondaryIcon = _import(config.SecondaryIcon, Color3.new(1, 1, 1))
	local IconTransparency = _import(config.IconTransparency, 0)
	local MainScale = _import(config.MainScale, 0.75)
	local SecondaryScale = _import(config.SecondaryScale, 0.25)

	local Width = _Computed(function(scale: number, textSize: number)
		return scale * textSize
	end, Scale, StyleGuide:GetTextSize(PseudoEnum.GuiTypography.Body1))

	local parameters = {
		Name = Name,
		Size = _Computed(function(width: number)
			return UDim2.fromOffset(width, width)
		end, Width),
		BackgroundTransparency = 1,
		-- Attributes = {
		-- 	ClassName = script.Name,
		-- },
		Children = {
			_synth("IconLabel")({
				Name = "PrimaryIconLabel",
				IconColor3 = MainColor3,
				IconTransparency = IconTransparency,
				Icon = MainIcon :: any,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = _Computed(function(width: number, scale: number)
					local iconWidth = scale * width
					return UDim2.fromOffset(iconWidth, iconWidth)
				end, Width, MainScale),
			}) :: any,
			_synth("IconLabel")({
				Name = "SecondaryIconLabel",
				IconColor3 = SecondaryColor3,
				IconTransparency = IconTransparency,
				Icon = SecondaryIcon :: any,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = _Computed(function(width: number, scale: number)
					local iconWidth = scale * width
					return UDim2.fromOffset(iconWidth, iconWidth)
				end, Width, SecondaryScale),
				Visible = _Computed(function(icon)
					if not icon or icon == "" then
						return false
					end
					return true
				end, SecondaryIcon),
			}) :: any,
		},
	}

	config.Name = nil
	config.Scale = nil
	config.MainColor3 = nil
	config.SecondaryColor3 = nil
	config.MainIcon = nil
	config.SecondaryIcon = nil
	config.IconTransparency = nil
	config.MainScale = nil
	config.SecondaryScale = nil

	for k, v in pairs(config) do
		if parameters[k] == nil then
			parameters[k] = v :: any
		end
	end

	local Output = _new("Frame")(parameters :: any) :: Frame
	return Output
end

return function(maid: Maid, config: GuiParameters): Output
	local inst = Constructor(config)
	if maid then
		maid:GiveTask(inst)
	end
	return inst
end
