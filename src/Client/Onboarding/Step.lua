--!strict
-- Services
local RunService = game:GetService("RunService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

-- Modules
local PseudoEnum = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PseudoEnum"))
local OnboardingFolder = script.Parent
assert(OnboardingFolder)
local Panel = require(OnboardingFolder:WaitForChild("Panel"))
local Util = require(OnboardingFolder:WaitForChild("Util"))
-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
export type Step = {
	__index: Step,
	_Maid: Maid,
	_IsAlive: boolean,
	_IsInitialized: boolean,
	_Text: string,
	Index: number,
	_IsLockedToFire: boolean,
	_IsStarted: boolean,
	_IsButtonClicked: boolean,
	_IsCompleted: boolean,
	_Conditions: { [number]: () -> boolean },
	_GuiAlignment: PseudoEnum.GuiAlignmentType?,
	_DefaultGuiAlignment: PseudoEnum.GuiAlignmentType,
	_Focuses: { [number]: Instance },
	_Hints: { [() -> boolean]: string },
	_HintHistory: { [string]: number },
	Fire: (self: Step, canPreFire: boolean?) -> nil,
	SetIndex: (self: Step, index: number) -> nil,
	AddToFocus: <T>(self: Step, focus: T & (Instance | { [number]: Instance })) -> T,
	ClearFocus: (self: Step) -> nil,
	SetCompletionCondition: (self: Step, condition: () -> boolean) -> nil,
	SetGuiAlignment: (self: Step, alignment: PseudoEnum.GuiAlignmentType) -> nil,
	Destroy: (self: Step) -> nil,
	Start: (self: Step) -> nil,
	Stop: (self: Step) -> nil,
	GetIfCompleted: (self: Step) -> boolean,
	GetIfStarted: (self: Step) -> boolean,
	Initialize: (self: Step) -> nil,
	RegisterHint: (self: Step, text: string, condition: () -> boolean) -> nil,
	new: (text: string, isEventBound: boolean, alignment: PseudoEnum.GuiAlignmentType) -> Step,
}

-- Constants
local BUTTON_SIGNAL_KEY = "ButtonSignalKey"
local UPDATE_LOOP_KEY = "StepUpdateLoop"
-- local HINT_RELOAD = 60
-- Variables
-- References
-- Private functions

-- Class
local Step = {} :: Step
Step.__index = Step

function Step:Destroy()
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

-- RegisterHint: (text: string) -> Signal,
function Step:RegisterHint(text: string, condition: () -> boolean)
	self._Hints[condition] = text
	return nil
end

function Step:Initialize()
	if self._IsInitialized then
		return
	end
	self._IsInitialized = true
	return nil
end

function Step:SetGuiAlignment(alignment: PseudoEnum.GuiAlignmentType): nil
	self._GuiAlignment = alignment
	return nil
end

function Step:SetCompletionCondition(condition: () -> boolean): nil
	table.insert(self._Conditions, condition)
	return nil
end

function Step:ClearFocus()
	self._Focuses = {}
	return nil
end

function Step:AddToFocus<T>(focus: T & (Instance | { [number]: Instance })): T
	if focus ~= nil then
		if typeof(focus) == "table" then
			local list: { [any]: Instance } = focus :: any
			for k, v in pairs(list) do
				assert(v:IsA("Instance"), "Bad focus inst: " .. tostring(v))
				table.insert(self._Focuses, v)
			end
		else
			local inst: Instance = focus :: any
			assert(inst:IsA("Instance"), "Bad focus inst" .. tostring(inst))
			table.insert(self._Focuses, inst)
		end
	end
	return focus
end

function Step:Fire(canPreFire: boolean?): nil
	if not self:GetIfStarted() and canPreFire ~= true then
		return
	end
	self._IsButtonClicked = true
	return nil
end

function Step:SetIndex(index: number)
	assert(self._IsInitialized == false, "onboarding isn't initialized")
	self.Index = index
	return nil
end

function Step:GetIfStarted()
	return self._IsStarted
end

function Step:Start()
	if self:GetIfStarted() then
		return
	end
	print("STARTING!", self._Text)
	Panel:UpdateTick()
	self._IsStarted = true
	Panel.Description:Set(self._Text)

	self._Maid[BUTTON_SIGNAL_KEY] = Panel.OnClick:Connect(function()
		self._IsButtonClicked = true
	end)

	self._Maid[UPDATE_LOOP_KEY] = RunService.RenderStepped:Connect(function(deltaTime: number)
		-- Update states
		Panel.Alignment:Set(self._GuiAlignment or self._DefaultGuiAlignment)
		Panel.IsInteractable:Set(self._IsLockedToFire)
		Panel.Focuses:Set(self._Focuses)
		Panel.ButtonEnabled:Set(not self._IsLockedToFire)

		-- -- Update hints
		-- for condition, txt in pairs(self._Hints) do
		-- 	if condition() then
		-- 		local history = self._HintHistory[txt]
		-- 		if history == nil or tick() - history > HINT_RELOAD then
		-- 			self._HintHistory[txt] = tick()
		-- 			PageService.Notification:Fire(txt)
		-- 		end
		-- 	end
		-- end
	end)
	return nil
end

function Step:Stop()
	if not self:GetIfStarted() then
		return
	end
	self._IsStarted = false
	self._Maid[UPDATE_LOOP_KEY] = nil
	self._Maid[BUTTON_SIGNAL_KEY] = nil
	return nil
end

function Step:GetIfCompleted()
	if self._IsCompleted then
		return true
	end
	if RunService:IsRunning() and Util.getIfTutorialIsFinished() then
		self._IsCompleted = true
		return true
	else
		if self._IsButtonClicked then
			self._IsCompleted = true
			return true
		else
			for k, condition in pairs(self._Conditions) do
				if condition() then
					self._IsCompleted = true
					return true
				end
			end
		end
		return false
	end
end

function Step.new(text: string, isEventBound: boolean, alignment: PseudoEnum.GuiAlignmentType)
	local maid = Maid.new()

	local self: Step = setmetatable({}, Step) :: any
	self._IsAlive = true
	self._Maid = maid
	self._IsInitialized = false
	self._IsLockedToFire = isEventBound
	self._IsButtonClicked = false
	self._IsCompleted = false
	self._Text = text
	self.Index = 0
	self._IsStarted = false
	self._Conditions = {}
	self._GuiAlignment = nil
	self._DefaultGuiAlignment = alignment
	self._Focuses = {}
	self._Hints = {}
	self._HintHistory = {}
	return self
end

return Step
