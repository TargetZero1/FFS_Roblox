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
export type Switch = {
	__index: Switch,
	_Maid: Maid,
	_IsAlive: boolean,
	Destroy: (self: Switch) -> nil,
	GetState: (
		self: Switch,
		value: ValueState<boolean>,
		palette: ModuleProvider.GuiColorPalette?,
		backgroundPalette: ModuleProvider.GuiColorPalette?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	Get: (
		self: Switch,
		onClick: (value: boolean) -> nil,
		default: boolean,
		palette: ModuleProvider.GuiColorPalette?,
		backgroundPalette: ModuleProvider.GuiColorPalette?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	new: (maid: Maid) -> Switch,
}
-- Constants
local UISounds = Package:WaitForChild("UI") :: Folder
local LockSounds = UISounds:WaitForChild("Lock") :: Folder
local LOCK_SOUND = LockSounds:WaitForChild("A") :: Sound
local UNLOCK_SOUND = LockSounds:WaitForChild("B") :: Sound
-- Variables
-- References
-- Class
local Switch: Switch = {} :: any
Switch.__index = Switch

function Switch:Destroy()
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

function Switch:GetState(
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

	local Output = _synth("Switch")({
		Value = value,
		Scale = _Computed(function(txtSize: number)
			return txtSize / 15
		end, StyleGuide:GetTextSize((typography or PseudoEnum.GuiTypography.Button) :: any)),
		BackgroundColor3 = backgroundColor3,
		EnabledColor3 = enabledColor3,
		EnableSound = UNLOCK_SOUND,
		DisableSound = LOCK_SOUND,
		BubbleEnabled = true,
		LayoutOrder = layoutOrder,
	})

	return Output
end

function Switch:Get(
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

function Switch.new(maid: Maid)
	local self: Switch = setmetatable({}, Switch) :: any
	self._IsAlive = true
	self._Maid = maid

	return self
end

return Switch
