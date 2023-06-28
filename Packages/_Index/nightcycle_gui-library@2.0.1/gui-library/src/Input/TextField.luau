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
export type TextField = {
	__index: TextField,
	_Maid: Maid,
	_IsAlive: boolean,
	Destroy: (self: TextField) -> nil,
	_GetState: (
		self: TextField,
		value: ValueState<string>,
		format: (string) -> string,
		isFilled: boolean,
		width: CanBeState<UDim>,
		label: CanBeState<string>,
		palette: ModuleProvider.GuiColorPalette?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?
	) -> Frame,
	GetStateFilled: (
		self: TextField,
		value: ValueState<string>,
		width: CanBeState<UDim>,
		label: CanBeState<string>,
		palette: ModuleProvider.GuiColorPalette?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?,
		format: ((string) -> string)?
	) -> Frame,
	GetStateOutlined: (
		self: TextField,
		value: ValueState<string>,
		width: CanBeState<UDim>,
		label: CanBeState<string>,
		palette: ModuleProvider.GuiColorPalette?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?,
		format: ((string) -> string)?
	) -> Frame,
	GetFilled: (
		self: TextField,
		onUpdate: (value: string) -> string,
		width: CanBeState<UDim>,
		label: CanBeState<string>,
		initialValue: string?,
		palette: ModuleProvider.GuiColorPalette?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?,
		format: ((string) -> string)?
	) -> Frame,
	GetOutlined: (
		self: TextField,
		onUpdate: (value: string) -> string,
		width: CanBeState<UDim>,
		label: CanBeState<string>,
		initialValue: string?,
		palette: ModuleProvider.GuiColorPalette?,
		typography: ModuleProvider.GuiTypography?,
		layoutOrder: CanBeState<number>?,
		format: ((string) -> string)?
	) -> Frame,
	new: (maid: Maid) -> TextField,
}
-- Constants
-- Variables
-- References
-- Private fucntion
function defaultFormat(str: string): string
	return str
end
-- Class
local TextField: TextField = {} :: any
TextField.__index = TextField

function TextField:Destroy()
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

function TextField:_GetState(
	value: ValueState<string>,
	format: (string) -> string,
	isFilled: boolean,
	width: CanBeState<UDim>,
	label: CanBeState<string>,
	palette: ModuleProvider.GuiColorPalette?,
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

	palette = palette or PseudoEnum.GuiColorPalette.Surface1
	assert(palette ~= nil)

	typography = typography or PseudoEnum.GuiTypography.Button
	assert(typography ~= nil)

	local hoverPalette: ModuleProvider.GuiColorPalette, focusPalette: ModuleProvider.GuiColorPalette = Util.getStatePalettes(palette)

	local TextColor = StyleGuide:GetContrastColor(palette)
	local BackgroundColor3 = StyleGuide:GetColor(palette)
	local HoverBackgroundColor3 = StyleGuide:GetColor(hoverPalette)
	local FocusBackgroundColor3 = StyleGuide:GetColor(focusPalette)

	local Output = _synth("TextField")({
		Value = value,
		Text = label,
		LeftIcon = nil,
		RightIcon = nil,
		LowerTextColor3 = TextColor,
		TextColor3 = TextColor,
		BorderColor3 = TextColor,
		BorderSizePixel = StyleGuide.BorderSizePixel,
		BackgroundTransparency = if isFilled then 0 else 1,
		BackgroundColor3 = BackgroundColor3,
		Width = width,
		CornerRadius = StyleGuide.CornerRadius :: any,
		TextSize = StyleGuide:GetTextSize(typography),
		FontFace = StyleGuide:GetFont(typography),
		CharacterLimit = nil,
		MaintainLowerSpacing = false,
		ClearTextOnFocus = true,
		FocusedBackgroundColor3 = FocusBackgroundColor3,
		HoverBackgroundColor3 = HoverBackgroundColor3,
		LayoutOrder = layoutOrder,
	})

	local act: BindableEvent = Output:WaitForChild("OnInputComplete") :: any

	local clickSignal: RBXScriptConnection
	clickSignal = act.Event:Connect(function(val: string)
		value:Set(format(val))
	end)

	local set: BindableFunction = Output:WaitForChild("SetInput") :: any
	set:Invoke(value:Get())

	local destSignal: RBXScriptConnection
	destSignal = Output.Destroying:Connect(function()
		destSignal:Disconnect()
		clickSignal:Disconnect()
	end)

	return Output
end

function TextField:GetStateFilled(
	value: ValueState<string>,
	width: CanBeState<UDim>,
	label: CanBeState<string>,
	palette: ModuleProvider.GuiColorPalette?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?,
	format: ((string) -> string)?
): Frame
	local Output = self:_GetState(value, format or defaultFormat, true, width, label, palette, typography, layoutOrder)

	return Output
end

function TextField:GetStateOutlined(
	value: ValueState<string>,
	width: CanBeState<UDim>,
	label: CanBeState<string>,
	palette: ModuleProvider.GuiColorPalette?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?,
	format: ((string) -> string)?
): Frame
	local Output = self:_GetState(value, format or defaultFormat, false, width, label, palette, typography, layoutOrder)

	return Output
end

function TextField:GetFilled(
	onUpdate: (value: string) -> string,
	width: CanBeState<UDim>,
	label: CanBeState<string>,
	initialValue: string?,
	palette: ModuleProvider.GuiColorPalette?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?,
	format: ((string) -> string)?
): Frame
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local value = _Value(initialValue or "")

	local Output = self:_GetState(value, onUpdate, true, width, label, palette, typography, layoutOrder)

	-- value:Connect(function(cur: string, prev: string?)
	-- 	onUpdate(cur)
	-- end)

	local destSignal: RBXScriptConnection
	destSignal = Output.Destroying:Connect(function()
		destSignal:Disconnect()
		value:Destroy()
	end)

	return Output
end

function TextField:GetOutlined(
	onUpdate: (value: string) -> string,
	width: CanBeState<UDim>,
	label: CanBeState<string>,
	initialValue: string?,
	palette: ModuleProvider.GuiColorPalette?,
	typography: ModuleProvider.GuiTypography?,
	layoutOrder: CanBeState<number>?,
	format: ((string) -> string)?
): Frame
	local _fuse = ColdFusion.fuse(self._Maid)
	local _synth = Synthetic(self._Maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local value = _Value(initialValue or "")

	local Output = self:_GetState(value, onUpdate, true, width, label, palette, typography, layoutOrder)

	-- value:Connect(function(cur: string, prev: string?)
	-- 	onUpdate(cur)
	-- end)

	local destSignal: RBXScriptConnection
	destSignal = Output.Destroying:Connect(function()
		destSignal:Disconnect()
		value:Destroy()
	end)

	return Output
end

function TextField.new(maid: Maid)
	local self: TextField = setmetatable({}, TextField) :: any
	self._IsAlive = true
	self._Maid = maid

	return self
end

return TextField
