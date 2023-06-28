--!strict
-- Services
-- Packages
local InputModule = script.Parent
assert(InputModule)
local Package = InputModule.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local Synthetic = require(Packages:WaitForChild("Synthetic"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))
-- Modules
local Util = require(Package:WaitForChild("Util"))
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local PseudoEnum = ModuleProvider.PseudoEnum
local StyleGuide = ModuleProvider.StyleGuide
-- Types
type Maid = Maid.Maid
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>

export type Button = {
	__index: Button,
	_Maid: Maid,
	_IsAlive: boolean,
	Destroy: (self: Button) -> nil,
	_Get: (
		self: Button,
		onClick: () -> nil,
		text: CanBeState<string>?,
		palette: ModuleProvider.GuiColorPalette?,
		density: ModuleProvider.GuiDensityModifier?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?,
		isFilled: boolean?,
		isOutlined: boolean?,
		cornerRadius: CanBeState<UDim>?
	) -> Frame,
	GetFilled: (
		self: Button,
		onClick: () -> nil,
		text: CanBeState<string>?,
		palette: ModuleProvider.GuiColorPalette?,
		density: ModuleProvider.GuiDensityModifier?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	GetFilledRound: (
		self: Button,
		onClick: () -> nil,
		text: CanBeState<string>?,
		palette: ModuleProvider.GuiColorPalette?,
		density: ModuleProvider.GuiDensityModifier?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	GetOutlined: (
		self: Button,
		onClick: () -> nil,
		text: CanBeState<string>?,
		palette: ModuleProvider.GuiColorPalette?,
		density: ModuleProvider.GuiDensityModifier?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	GetOutlinedRound: (
		self: Button,
		onClick: () -> nil,
		text: CanBeState<string>?,
		palette: ModuleProvider.GuiColorPalette?,
		density: ModuleProvider.GuiDensityModifier?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	GetText: (
		self: Button,
		onClick: () -> nil,
		text: CanBeState<string>?,
		palette: ModuleProvider.GuiColorPalette?,
		density: ModuleProvider.GuiDensityModifier?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	new: (maid: Maid) -> Button,
}
-- Constants
local UISounds = Package:WaitForChild("UI") :: Folder
local TapSounds = UISounds:WaitForChild("Tap") :: Folder
local CLICK_SOUND = TapSounds:WaitForChild("A") :: Sound
-- Variables
-- References
-- Class
local Button: Button = {} :: any
Button.__index = Button

function Button:Destroy()
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

function Button:_Get(
	onClick: () -> nil,
	text: CanBeState<string>?,
	palette: ModuleProvider.GuiColorPalette?,
	density: ModuleProvider.GuiDensityModifier?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?,
	isFilled: boolean?,
	isOutlined: boolean?,
	cornerRadius: CanBeState<UDim>?
): Frame
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local Text = _import(text, "")

	palette = palette or PseudoEnum.GuiColorPalette.Primary1
	assert(palette ~= nil)
	density = density or PseudoEnum.GuiDensityModifier.Default
	assert(density ~= nil)
	typography = typography or PseudoEnum.GuiTypography.Button
	assert(typography ~= nil)

	local hoverPalette: ModuleProvider.GuiColorPalette, selectPalette: ModuleProvider.GuiColorPalette = Util.getStatePalettes(palette)


	local Output: Frame = _synth("Button")({
		Name = _Computed(function(txt: string): string
			return txt .. "Button"
		end, Text),

		TextColor3 = StyleGuide:GetContrastColor(palette),
		HoverTextColor3 = StyleGuide:GetContrastColor(hoverPalette),
		SelectedTextColor3 = StyleGuide:GetContrastColor(selectPalette),

		TextTransparency = 0,

		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,

		BackgroundColor3 = StyleGuide:GetColor(palette),
		HoverBackgroundColor3 = StyleGuide:GetColor(hoverPalette),
		SelectedBackgroundColor3 = StyleGuide:GetColor(selectPalette),

		BackgroundTransparency = if isFilled then 0 else 1,
		BorderTransparency = if isOutlined then 0 else 1,

		TextSize = StyleGuide:GetTextSize(typography),
		Padding = StyleGuide:GetPadding(density),

		TextOnly = not isFilled and not isOutlined,
		Text = Text,
		LayoutOrder = layoutOrder :: any,
		AnchorPoint = Vector2.new(0.5, 0.5),
		CornerRadius = cornerRadius or StyleGuide.CornerRadius,
		ClickSound = CLICK_SOUND,
	}) :: any

	local act: BindableEvent = Output:WaitForChild("Activated") :: any

	local clickSignal: RBXScriptConnection
	clickSignal = act.Event:Connect(function()
		onClick()
	end)

	local destSignal: RBXScriptConnection
	destSignal = Output.Destroying:Connect(function()
		destSignal:Disconnect()
		clickSignal:Disconnect()
	end)

	return Output
end

function Button:GetFilled(
	onClick: () -> nil,
	text: CanBeState<string>?,
	palette: ModuleProvider.GuiColorPalette?,
	density: ModuleProvider.GuiDensityModifier?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?
): Frame
	return self:_Get(onClick, text, palette, density, typography, layoutOrder, true, false, StyleGuide.CornerRadius)
end

function Button:GetFilledRound(
	onClick: () -> nil,
	text: CanBeState<string>?,
	palette: ModuleProvider.GuiColorPalette?,
	density: ModuleProvider.GuiDensityModifier?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?
): Frame
	return self:_Get(onClick, text, palette, density, typography, layoutOrder, true, false, UDim.new(0.5, 0))
end

function Button:GetOutlined(
	onClick: () -> nil,
	text: CanBeState<string>?,
	palette: ModuleProvider.GuiColorPalette?,
	density: ModuleProvider.GuiDensityModifier?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?
): Frame
	return self:_Get(onClick, text, palette, density, typography, layoutOrder, false, true, StyleGuide.CornerRadius)
end

function Button:GetOutlinedRound(
	onClick: () -> nil,
	text: CanBeState<string>?,
	palette: ModuleProvider.GuiColorPalette?,
	density: ModuleProvider.GuiDensityModifier?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?
): Frame
	return self:_Get(onClick, text, palette, density, typography, layoutOrder, false, true, UDim.new(0.5, 0))
end

function Button:GetText(
	onClick: () -> nil,
	text: CanBeState<string>?,
	palette: ModuleProvider.GuiColorPalette?,
	density: ModuleProvider.GuiDensityModifier?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?
): Frame
	return self:_Get(onClick, text, palette, density, typography, layoutOrder, false, false, UDim.new(0, 0))
end

function Button.new(maid: Maid)
	local self: Button = setmetatable({}, Button) :: any
	self._IsAlive = true
	self._Maid = maid

	return self
end

return Button
