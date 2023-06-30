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
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local PseudoEnum = ModuleProvider.PseudoEnum
local StyleGuide = ModuleProvider.StyleGuide
-- Types
type Maid = Maid.Maid
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>

export type Checkbox = {
	__index: Checkbox,
	_Maid: Maid,
	_IsAlive: boolean,
	Destroy: (self: Checkbox) -> nil,
	Get: (
		self: Checkbox,
		onClick: (value: boolean) -> nil,
		default: boolean,
		palette: ModuleProvider.GuiColorPalette?,
		backgroundPalette: ModuleProvider.GuiColorPalette?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	GetState: (
		self: Checkbox,
		value: ValueState<boolean>,
		palette: ModuleProvider.GuiColorPalette?,
		backgroundPalette: ModuleProvider.GuiColorPalette?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	new: (maid: Maid) -> Checkbox,
}
-- Constants
local UISounds = Package:WaitForChild("UI") :: Folder
local LockSounds = UISounds:WaitForChild("Lock") :: Folder
local LOCK_SOUND = LockSounds:WaitForChild("A") :: Sound
local UNLOCK_SOUND = LockSounds:WaitForChild("B") :: Sound
-- Variables
-- References
-- Class
local Checkbox: Checkbox = {} :: any
Checkbox.__index = Checkbox

function Checkbox:Destroy()
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

function Checkbox:GetState(
	value: ValueState<boolean>,
	palette: ModuleProvider.GuiColorPalette?,
	backgroundPalette: ModuleProvider.GuiColorPalette?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?
): Frame
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local BorderColor3 = StyleGuide:GetContrastColor(backgroundPalette or PseudoEnum.GuiColorPalette.Surface1)
	local TextColor3 = StyleGuide:GetContrastColor(palette or PseudoEnum.GuiColorPalette.Primary1)
	local BackgroundColor3 = StyleGuide:GetColor(palette or PseudoEnum.GuiColorPalette.Primary1)

	local Output = _synth("Checkbox")({
		Value = value,
		Scale = _Computed(function(txtSize: number)
			return txtSize / 15
		end, StyleGuide:GetTextSize((typography or PseudoEnum.GuiTypography.Button) :: any)),
		BackgroundColor3 = BackgroundColor3,
		BorderColor3 = BorderColor3,
		EnableSound = UNLOCK_SOUND,
		DisableSound = LOCK_SOUND,
		TextColor3 = TextColor3,
		-- BubbleEnabled = true,
		LayoutOrder = layoutOrder,
	})

	return Output
end

function Checkbox:Get(
	onClick: (value: boolean) -> nil,
	default: boolean,
	palette: ModuleProvider.GuiColorPalette?,
	backgroundPalette: ModuleProvider.GuiColorPalette?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?
): Frame
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local value = _Value(default)

	local Output = self:GetState(value, palette, backgroundPalette, typography, layoutOrder)

	value:Connect(function(cur: boolean, prev: boolean?)
		onClick(cur)
	end)

	local destSignal: RBXScriptConnection
	destSignal = Output.Destroying:Connect(function()
		destSignal:Disconnect()
		value:Destroy()
	end)

	return Output
end

function Checkbox.new(maid: Maid)
	local self: Checkbox = setmetatable({}, Checkbox) :: any
	self._IsAlive = true
	self._Maid = maid

	return self
end

return Checkbox
