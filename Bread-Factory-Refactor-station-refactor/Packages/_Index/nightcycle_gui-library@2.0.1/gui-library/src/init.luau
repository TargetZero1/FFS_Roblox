--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Packages
local Package = script
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local Signal = require(Packages:WaitForChild("Signal"))
local Synthetic = require(Packages:WaitForChild("Synthetic"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))

-- Modules
local Visualization = require(script:WaitForChild("Visualization"))
local Media = require(script:WaitForChild("Media"))
local Layout = require(script:WaitForChild("Layout"))
local Input = require(script:WaitForChild("Input"))
local Effect = require(script:WaitForChild("Effect"))
local ModuleProvider = require(script:WaitForChild("ModuleProvider"))

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type Synth = Synthetic.Synthetic
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
export type StyleGuide = ModuleProvider.StyleGuide
export type ContrastStandardType = ModuleProvider.ContrastStandardType
export type GuiAlignmentType = ModuleProvider.GuiAlignmentType
export type GuiCategoryType = ModuleProvider.GuiCategoryType
export type GuiColorPalette = ModuleProvider.GuiColorPalette
export type GuiDensityModifier = ModuleProvider.GuiDensityModifier
export type GuiThemeType = ModuleProvider.GuiThemeType
export type GuiTypography = ModuleProvider.GuiTypography
export type GuiLibrary = {
	_Maid: Maid,
	__index: GuiLibrary,
	_IsAlive: boolean,
	Visualization: Visualization.Visualization,
	Media: Media.Media,
	Layout: Layout.Layout,
	Input: Input.Input,
	Effect: Effect.Effect,
	Destroy: (self: GuiLibrary) -> nil,
	new: (maid: Maid) -> GuiLibrary,
	init: (maid: Maid) -> nil,
	setStyleGuide: (styleGuide: StyleGuide) -> nil,
	getStyleGuide: () -> StyleGuide,
	Sound: {
		Click: Sound,
		Lock: Sound,
		Unlock: Sound,
	},
}

-- Class
local GuiLibrary: GuiLibrary = {} :: any
GuiLibrary.__index = GuiLibrary

local UISounds = Package:WaitForChild("UI") :: Folder
local TapSounds = UISounds:WaitForChild("Tap") :: Folder
local LockSounds = UISounds:WaitForChild("Lock") :: Folder

GuiLibrary.Sound = {
	Click = TapSounds:WaitForChild("A") :: Sound,
	Lock = LockSounds:WaitForChild("A") :: Sound,
	Unlock = LockSounds:WaitForChild("B") :: Sound,
}

function GuiLibrary:Destroy()
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


function GuiLibrary.new(maid: Maid): GuiLibrary
	local self: GuiLibrary = setmetatable({}, GuiLibrary) :: any
	self._Maid = maid
	self._IsAlive = true
	self.Visualization = Visualization.new(maid)
	self.Media = Media.new(maid)
	self.Layout = Layout.new(maid)
	self.Input = Input.new(maid)
	self.Effect = Effect.new(maid)

	return self
end

function GuiLibrary.setStyleGuide(styleGuide: StyleGuide)
	ModuleProvider.Override.StyleGuide = styleGuide
	return nil
end

function GuiLibrary.getStyleGuide(): StyleGuide
	return ModuleProvider.StyleGuide
end

local isInitialized = false
function GuiLibrary.init(maid: Maid)
	if not isInitialized then
		isInitialized = true
		ModuleProvider.StyleGuide.init(maid)
		
		local function attemptModule(folder: Instance?)
			if folder then
				if folder:FindFirstChild("StyleGuide") then
					local styleGuide = require(folder:FindFirstChild("StyleGuide") :: any) :: any
					styleGuide.init(maid)
					ModuleProvider.Override.StyleGuide = styleGuide
				end
			end
		end
		attemptModule(ReplicatedStorage:FindFirstChild("Packages"))
		attemptModule(ReplicatedStorage:FindFirstChild("Shared"))
		attemptModule(ReplicatedStorage:FindFirstChild("Client"))
	end
	return nil
end

return GuiLibrary
