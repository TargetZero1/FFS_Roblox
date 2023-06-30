--!strict
-- Services
-- Packages
local Package = script.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
-- Modules
local Button = require(script:WaitForChild("Button"))
local Checkbox = require(script:WaitForChild("Checkbox"))
local ColorPicker = require(script:WaitForChild("ColorPicker"))
local RadioButton = require(script:WaitForChild("RadioButton"))
local Switch = require(script:WaitForChild("Switch"))
local TextField = require(script:WaitForChild("TextField"))

-- Types
type Maid = Maid.Maid
export type Input = {
	__index: Input,
	_Maid: Maid,
	_IsAlive: boolean,
	Button: Button.Button,
	Checkbox: Checkbox.Checkbox,
	RadioButton: RadioButton.RadioButton,
	Switch: Switch.Switch,
	TextField: TextField.TextField,
	Destroy: (self: Input) -> nil,
	GetColorPicker: (self: Input, config: ColorPicker.GuiParameters) -> Frame,
	new: (maid: Maid) -> Input,
}
-- Constants
-- Variables
-- References
-- Class
local Input = {}
Input.__index = Input

function Input:Destroy()
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

function Input:GetColorPicker(config: ColorPicker.GuiParameters): Frame
	return ColorPicker(self._Maid, config)
end

function Input.new(maid: Maid)
	local self: Input = setmetatable({}, Input) :: any
	self._IsAlive = true
	self._Maid = maid
	self.Button = Button.new(maid)
	self.Checkbox = Checkbox.new(maid)
	self.RadioButton = RadioButton.new(maid)
	self.Switch = Switch.new(maid)
	self.TextField = TextField.new(maid)

	return self
end

return Input
