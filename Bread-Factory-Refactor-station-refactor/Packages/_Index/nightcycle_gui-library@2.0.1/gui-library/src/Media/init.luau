--!strict
-- Services
-- Packages
local Package = script.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local Synthetic = require(Packages:WaitForChild("Synthetic"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))

-- Modules
local MeshIcon = require(script:WaitForChild("MeshIcon"))
local DoubleIconLabel = require(script:WaitForChild("DoubleIconLabel"))
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local PseudoEnum = ModuleProvider.PseudoEnum
local StyleGuide = ModuleProvider.StyleGuide

-- Types
type Maid = Maid.Maid
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
export type Media = {
	__index: Media,
	_Maid: Maid,
	_IsAlive: boolean,
	Destroy: (self: Media) -> nil,
	GetTextLabel: (
		self: Media,
		text: CanBeState<string>?,
		typography: ModuleProvider.GuiTypography?,
		palette: ModuleProvider.GuiColorPalette?,
		layoutOrder: CanBeState<number>?,
		name: CanBeState<string>?
	) -> TextLabel,
	GetIcon: (
		self: Media,
		icon: CanBeState<string>,
		color: State<Color3>,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> GuiObject,
	GetDoubleIcon: (self: Media, config: DoubleIconLabel.GuiParameters) -> GuiObject,
	GetMeshIcon: (self: Media, config: MeshIcon.GuiParameters) -> GuiObject,
	new: (maid: Maid) -> Media,
}
-- Constants
-- Variables
-- References
-- Class
local Media = {}
Media.__index = Media

function Media:Destroy()
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

function Media:GetTextLabel(
	text: CanBeState<string>?,
	typography: ModuleProvider.GuiTypography?,
	palette: ModuleProvider.GuiColorPalette?,
	layoutOrder: CanBeState<number>?,
	name: CanBeState<string>?
): TextLabel
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local Text = _import(text, "")
	local Name = _import(name, "TextLabel")

	palette = palette or PseudoEnum.GuiColorPalette.Primary1
	assert(palette ~= nil)
	typography = typography or PseudoEnum.GuiTypography.Button
	assert(typography ~= nil)

	return _new("TextLabel")({
		Name = Name,
		RichText = true,
		Size = UDim2.fromScale(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = layoutOrder,
		Text = Text,
		TextSize = StyleGuide:GetTextSize(typography),
		FontFace = StyleGuide:GetFont(typography),
		TextColor3 = StyleGuide:GetContrastColor(palette),
		BackgroundTransparency = 1,
	}) :: any
end

function Media:GetDoubleIcon(config: DoubleIconLabel.GuiParameters)
	return DoubleIconLabel(self._Maid, config)
end

function Media:GetMeshIcon(config: MeshIcon.GuiParameters): GuiObject
	return MeshIcon(self._Maid, config)
end

function Media:GetIcon(
	icon: CanBeState<string>,
	color: State<Color3>,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?
): GuiObject
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	return _synth("IconLabel")({
		IconTransparency = 0,
		IconColor3 = color,
		Icon = icon,
		LayoutOrder = layoutOrder,
		Size = _Computed(function(txtSize: number): UDim2
			local iconSize = txtSize * 1.5
			return UDim2.fromOffset(iconSize, iconSize)
		end, StyleGuide:GetTextSize(typography or PseudoEnum.GuiTypography.Button)),
	})
end

function Media.new(maid: Maid)
	local self: Media = setmetatable({}, Media) :: any
	self._IsAlive = true
	self._Maid = maid

	return self
end

return Media
