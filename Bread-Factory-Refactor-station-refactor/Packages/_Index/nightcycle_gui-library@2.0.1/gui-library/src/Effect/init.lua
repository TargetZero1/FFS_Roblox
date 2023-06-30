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
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local PseudoEnum = ModuleProvider.PseudoEnum
local StyleGuide = ModuleProvider.StyleGuide

-- Types
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
export type Effect = {
	__index: Effect,
	_Maid: Maid,
	_IsAlive: boolean,
	Destroy: (self: Effect) -> nil,
	GetUICorner: (self: Effect, weight: number?) -> UICorner,
	GetHint: (
		self: Effect,
		parent: CanBeState<GuiBase2d>,
		text: CanBeState<string>,
		anchorPoint: CanBeState<Vector2>?,
		palette: ModuleProvider.GuiColorPalette?,
		density: ModuleProvider.GuiDensityModifier?,
		typography: ModuleProvider.GuiTypography?
	) -> ScreenGui,
	GetUIOutline: (self: Effect, palette: ModuleProvider.GuiColorPalette, px: CanBeState<number>?) -> UIStroke,
	GetUIContrastOutline: (
		self: Effect,
		background: ModuleProvider.GuiColorPalette,
		goal: ModuleProvider.GuiColorPalette?,
		px: CanBeState<number>?
	) -> UIStroke,
	new: (maid: Maid) -> Effect,
}
-- Constants
-- Variables
-- References
-- Class
local Effect: Effect = {} :: any
Effect.__index = Effect

function Effect:Destroy()
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

function Effect:GetHint(
	parent: CanBeState<GuiBase2d>,
	text: CanBeState<string>,
	anchorPoint: CanBeState<Vector2>?,
	palette: ModuleProvider.GuiColorPalette?,
	density: ModuleProvider.GuiDensityModifier?,
	typography: ModuleProvider.GuiTypography?
): ScreenGui
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	if palette == nil then
		palette = PseudoEnum.GuiColorPalette.Surface1
	end
	assert(palette ~= nil)

	if typography == nil then
		typography = PseudoEnum.GuiTypography.Body2
	end
	assert(typography ~= nil)

	if not anchorPoint then
		anchorPoint = Vector2.new(0.5, 0)
	end
	assert(anchorPoint ~= nil)

	if not density then
		density = PseudoEnum.GuiDensityModifier.High
	end
	assert(density ~= nil)

	return _synth("Hint")({
		Text = text,
		BackgroundColor3 = StyleGuide:GetContrastColor(palette),
		TextColor3 = StyleGuide:GetColor(palette),
		FontFace = StyleGuide:GetFont(typography),
		TextSize = StyleGuide:GetTextSize(typography),
		AnchorPoint = anchorPoint,
		CornerRadius = StyleGuide.CornerRadius,
		Padding = StyleGuide:GetPadding(density),
	})
end

function Effect:GetUICorner(weight: number?): UICorner
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	return _new("UICorner")({
		CornerRadius = if weight then UDim.new(weight, 0) else StyleGuide.CornerRadius,
	}) :: any
end

function Effect:GetUIOutline(palette: ModuleProvider.GuiColorPalette, px: CanBeState<number>?): UIStroke
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	return _new("UIStroke")({
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = StyleGuide:GetColor(palette),
		LineJoinMode = Enum.LineJoinMode.Round,
		Thickness = px or StyleGuide.BorderSizePixel,
		Transparency = 0,
	}) :: UIStroke
end

function Effect:GetUIContrastOutline(
	background: ModuleProvider.GuiColorPalette,
	goal: ModuleProvider.GuiColorPalette?,
	px: CanBeState<number>?
): UIStroke
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	return _new("UIStroke")({
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = StyleGuide:GetContrastColor(background, goal),
		LineJoinMode = Enum.LineJoinMode.Round,
		Thickness = px or StyleGuide.BorderSizePixel,
		Transparency = 0,
	}) :: UIStroke
end

function Effect.new(maid: Maid)
	local self: Effect = setmetatable({}, Effect) :: any
	self._IsAlive = true
	self._Maid = maid

	return self
end

return Effect
