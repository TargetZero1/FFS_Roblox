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
export type RadioButton = {
	__index: RadioButton,
	_Maid: Maid,
	_IsAlive: boolean,
	Destroy: (self: RadioButton) -> nil,
	GetState: (
		self: RadioButton,
		value: ValueState<boolean>,
		palette: ModuleProvider.GuiColorPalette?,
		backgroundPalette: ModuleProvider.GuiColorPalette?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	Get: (
		self: RadioButton,
		onClick: (value: boolean) -> nil,
		default: boolean,
		palette: ModuleProvider.GuiColorPalette?,
		backgroundPalette: ModuleProvider.GuiColorPalette?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	new: (maid: Maid) -> RadioButton,
}
-- Constants
local UISounds = Package:WaitForChild("UI") :: Folder
local LockSounds = UISounds:WaitForChild("Lock") :: Folder
local LOCK_SOUND = LockSounds:WaitForChild("A") :: Sound
local UNLOCK_SOUND = LockSounds:WaitForChild("B") :: Sound
-- Variables
-- References
-- Class
local RadioButton: RadioButton = {} :: any
RadioButton.__index = RadioButton

function RadioButton:Destroy()
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

function RadioButton:GetState(
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

	local backgroundColor3 = StyleGuide:GetContrastColor(backgroundPalette or PseudoEnum.GuiColorPalette.Surface1)
	local enabledColor3 = StyleGuide:GetColor(palette or PseudoEnum.GuiColorPalette.Primary1)

	local Output = _synth("RadioButton")({
		Value = value,
		Scale = _Computed(function(txtSize: number)
			return txtSize / 15
		end, StyleGuide:GetTextSize((typography or PseudoEnum.GuiTypography.Button) :: any)),

		BorderColor3 = backgroundColor3,
		BackgroundColor3 = enabledColor3,

		EnableSound = UNLOCK_SOUND,
		DisableSound = LOCK_SOUND,
		LayoutOrder = layoutOrder,
	})

	return Output
end

function RadioButton:Get(
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

function RadioButton.new(maid: Maid)
	local self: RadioButton = setmetatable({}, RadioButton) :: any
	self._IsAlive = true
	self._Maid = maid

	return self
end

return RadioButton
