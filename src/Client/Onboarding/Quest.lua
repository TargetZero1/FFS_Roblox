--!strict
-- Services
local RunService = game:GetService("RunService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local TableUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("TableUtil"))

-- Modules
local OnboardingFolder = script.Parent
assert(OnboardingFolder)
local PseudoEnum = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PseudoEnum"))
local Step = require(OnboardingFolder:WaitForChild("Step"))
local Panel = require(OnboardingFolder:WaitForChild("Panel"))
local Util = require(OnboardingFolder:WaitForChild("Util"))
-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type Step = Step.Step
export type Quest<T> = {
	__index: Quest<T>,
	_IsAlive: boolean,
	_Maid: Maid,
	_Name: string,
	Index: number,
	_CurrentStep: Step,
	_IsInitialized: boolean,
	_DefaultAlignment: PseudoEnum.GuiAlignmentType,
	_IsStarted: boolean,
	_SkipConditions: { [number]: () -> boolean },
	Steps: T,
	StepCount: number,
	Destroy: (self: Quest<T>) -> nil,
	GetIfStarted: (self: Quest<T>) -> boolean,
	GetIfCompleted: (self: Quest<T>) -> boolean,
	SetIndex: (self: Quest<T>, index: number) -> nil,
	RegisterStep: (self: Quest<T>, text: string, isEventBound: boolean) -> Step,
	SetSkipCondition: (self: Quest<T>, condition: () -> boolean) -> nil,
	GetNextStep: (self: Quest<T>, step: Step) -> Step?,
	Initialize: (self: Quest<T>) -> nil,
	Start: (self: Quest<T>) -> nil,
	Stop: (self: Quest<T>) -> nil,
	new: (name: string, alignment: PseudoEnum.GuiAlignmentType) -> Quest<T>,
}
-- Constants
local UPDATE_LOOP_KEY = "QuestUpdateLoop"
-- Variables
-- References
-- Class
local Quest = {} :: Quest<any>
Quest.__index = Quest

function Quest:Destroy()
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

function Quest:GetIfStarted()
	return self._IsStarted
end

function Quest:GetNextStep(step: Step): Step?
	local steps = TableUtil.values(self.Steps)
	table.sort(steps, function(a: Step, b: Step)
		return a.Index < b.Index
	end)
	return steps[step.Index + 1]
end

function Quest:SetIndex(index: number)
	assert(self._IsInitialized == false, "onboarding isn't initialized")
	self.Index = index
	return nil
end

function Quest:RegisterStep(text: string, isEventBound: boolean)
	assert(self._IsInitialized == false, "onboarding isn't initialized")
	local step = self._Maid:GiveTask(Step.new(text, isEventBound, self._DefaultAlignment))
	local count = 0
	for k, v in pairs(self.Steps) do
		count += 1
	end
	self.StepCount = count + 1
	step:SetIndex(self.StepCount)
	if self._CurrentStep == nil then
		self._CurrentStep = step
	end

	step:SetCompletionCondition(function()
		return self._IsInitialized and Util.getIfStepIsFinished(self.Index, step.Index)
	end)

	return step
end

function Quest:SetSkipCondition(condition: () -> boolean)
	table.insert(self._SkipConditions, condition)
	return nil
end

function Quest:Initialize()
	if self._IsInitialized then
		return
	end
	self._IsInitialized = true

	for k, v: Step in pairs(self.Steps) do
		v:Initialize()
	end
	return nil
end

function Quest:Start()
	if self:GetIfStarted() then
		return
	end
	self._IsStarted = true
	Panel.Title:Set(string.upper(self._Name))
	self._Maid[UPDATE_LOOP_KEY] = RunService.RenderStepped:Connect(function(deltaTime: number)
		if not self._CurrentStep:GetIfStarted() then
			-- print("Starting step: ", self._CurrentStep._Text)
			self._CurrentStep:Start()
		end
		local isCompleted = self._CurrentStep:GetIfCompleted()
		-- print(self._Name, ":", self._CurrentStep._Text, "STEP COMPLETION: ", isCompleted)
		if isCompleted then
			local nxtStep = self:GetNextStep(self._CurrentStep)
			self._CurrentStep:Stop()
			Util.completeStep(self.Index, self._CurrentStep.Index)
			-- print("NXT", nxtStep ~= nil)
			if nxtStep then
				-- print("Next step begun: ", nxtStep._Text, ":", nxtStep.Index, "vs", self._CurrentStep.Index)
				nxtStep:Start()
				self._CurrentStep = nxtStep
			end
		end
	end)
	return nil
end

function Quest:GetIfCompleted()
	for i, condition in ipairs(self._SkipConditions) do
		if condition() then
			return true
		end
	end
	local allCompleted = true
	for k, step in pairs(self.Steps) do
		if not step:GetIfCompleted() then
			allCompleted = false
		end
	end
	return allCompleted
end

function Quest:Stop()
	if not self:GetIfStarted() then
		return
	end
	self._IsStarted = false
	self._Maid[UPDATE_LOOP_KEY] = nil
	for k, step in pairs(self.Steps) do
		step:Stop()
	end
	return nil
end

function Quest.new(name: string, alignment: PseudoEnum.GuiAlignmentType)
	local maid = Maid.new()

	local self: Quest<any> = setmetatable({}, Quest) :: any
	self.Steps = {}
	self._IsAlive = true
	self._Maid = maid

	self._Name = name
	self.Index = 0
	self.StepCount = 0
	self._DefaultAlignment = alignment
	self._IsInitialized = false
	self._IsStarted = false
	self._SkipConditions = {}

	return self
end

return Quest
