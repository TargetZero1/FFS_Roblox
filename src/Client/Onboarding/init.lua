--!strict
-- Services
local RunService = game:GetService("RunService")

-- Packages
local ServiceProxy = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local ColdFusion8 = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Synthetic = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Synthetic"))
local TableUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("TableUtil"))
local GuiLibrary = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("GuiLibrary"))

-- Modules
local PseudoEnum = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PseudoEnum"))
local Quest = require(script:WaitForChild("Quest"))
local Step = require(script:WaitForChild("Step"))
local Panel = require(script:WaitForChild("Panel"))
local Util = require(script:WaitForChild("Util"))

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal

-- Types
export type Step = Step.Step
type Quest<T> = Quest.Quest<T>
type Onboarding = {
	__index: Onboarding,
	_Maid: Maid,
	_IsAlive: boolean,
	_CurrentQuest: Quest<any>,
	_IsCompleted: boolean,
	_IsInitialized: boolean,
	QuestCount: number,
	Quests: {
		Knead: Quest<{
			Knead0: Step,
			Knead1: Step,
			Knead2: Step,
			Knead3: Step,
			Knead4: Step,
			[any]: nil,
		}>,
		Bake: Quest<{
			Bake0: Step,
			Bake1: Step,
			Bake2: Step,
			Bake3: Step,
			Bake4: Step,
			[any]: nil,
		}>,
		Wrap: Quest<{
			Wrap0: Step,
			Wrap1: Step,
			Wrap2: Step,
			Wrap3: Step,
			Wrap4: Step,
			[any]: nil,
		}>,
		Collect: Quest<{
			Collect: Step,
			[any]: nil,
		}>,
		Deposit: Quest<{
			Deposit: Step,
			[any]: nil,
		}>,
		Deliver: Quest<{
			Deliver: Step,
			[any]: nil,
		}>,
		Hatch: Quest<{
			GoTo: Step,
			Hatch: Step,
			[any]: nil,
		}>,
		Assign: Quest<{
			GoToKneader: Step,
			Assign: Step,
			[any]: nil,
		}>,
	},
	Instance: ScreenGui,
	Destroy: (self: Onboarding) -> nil,
	_RegisterQuest: <G>(self: Onboarding, name: string, alignment: PseudoEnum.GuiAlignmentType) -> Quest<G>,
	new: () -> Onboarding,
	init: (maid: Maid) -> nil,
}
-- Constants
-- Variables
-- References
-- Class
local Onboarding: Onboarding = {} :: any
Onboarding.__index = Onboarding

function Onboarding:Destroy()
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

function Onboarding:_RegisterQuest<G>(name: string, alignment: PseudoEnum.GuiAlignmentType)
	assert(self._IsInitialized == false, "onboarding isn't initialized")
	local quest = self._Maid:GiveTask(Quest.new(name, alignment))
	local count = 0
	for k, v in pairs(self.Quests) do
		count += 1
	end
	self.QuestCount = count + 1
	quest:SetIndex(self.QuestCount)
	if self._CurrentQuest == nil then
		self._CurrentQuest = quest
	end
	return quest :: any
end

local currentOnboarding: Onboarding

function Onboarding.new()
	local maid = Maid.new()

	local _fuse = ColdFusion8.fuse(maid)
	local _library = GuiLibrary.new(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local self: Onboarding = setmetatable({}, Onboarding) :: any
	self._IsAlive = true
	self._Maid = maid
	self.QuestCount = 0
	self._IsInitialized = false
	self._IsCompleted = Util.getIfTutorialIsFinished()
	local panel = Panel.init(maid)
	self.Instance = _new("ScreenGui")({
		Name = "OnboardingGui",
		DisplayOrder = 20,
		Parent = if RunService:IsRunning() then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") else nil,
		Children = {
			panel.Instance,
		},
	}) :: any

	-- Initialize quests
	self.Quests = {} :: any

	-- Kneading
	self.Quests.Knead = self:_RegisterQuest("Kneading", PseudoEnum.GuiAlignmentType.Bottom)
	self.Quests.Knead.Steps.Knead0 = self.Quests.Knead:RegisterStep("Knead 5 Dough (0/5)", true)
	self.Quests.Knead.Steps.Knead1 = self.Quests.Knead:RegisterStep("Knead 5 Dough (1/5)", true)
	self.Quests.Knead.Steps.Knead2 = self.Quests.Knead:RegisterStep("Knead 5 Dough (2/5)", true)
	self.Quests.Knead.Steps.Knead3 = self.Quests.Knead:RegisterStep("Knead 5 Dough (3/5)", true)
	self.Quests.Knead.Steps.Knead4 = self.Quests.Knead:RegisterStep("Knead 5 Dough (4/5)", true)

	-- Baking
	self.Quests.Bake = self:_RegisterQuest("Baking", PseudoEnum.GuiAlignmentType.Bottom)
	self.Quests.Bake.Steps.Bake0 = self.Quests.Bake:RegisterStep("Bake 5 Bread (0/5)", true)
	self.Quests.Bake.Steps.Bake1 = self.Quests.Bake:RegisterStep("Bake 5 Bread (1/5)", true)
	self.Quests.Bake.Steps.Bake2 = self.Quests.Bake:RegisterStep("Bake 5 Bread (2/5)", true)
	self.Quests.Bake.Steps.Bake3 = self.Quests.Bake:RegisterStep("Bake 5 Bread (3/5)", true)
	self.Quests.Bake.Steps.Bake4 = self.Quests.Bake:RegisterStep("Bake 5 Bread (4/5)", true)

	-- Wrapping
	self.Quests.Wrap = self:_RegisterQuest("Wrapping", PseudoEnum.GuiAlignmentType.Bottom)
	self.Quests.Wrap.Steps.Wrap0 = self.Quests.Wrap:RegisterStep("Wrap 5 Bread (0/5)", true)
	self.Quests.Wrap.Steps.Wrap1 = self.Quests.Wrap:RegisterStep("Wrap 5 Bread (1/5)", true)
	self.Quests.Wrap.Steps.Wrap2 = self.Quests.Wrap:RegisterStep("Wrap 5 Bread (2/5)", true)
	self.Quests.Wrap.Steps.Wrap3 = self.Quests.Wrap:RegisterStep("Wrap 5 Bread (3/5)", true)
	self.Quests.Wrap.Steps.Wrap4 = self.Quests.Wrap:RegisterStep("Wrap 5 Bread (4/5)", true)

	-- Collecting
	self.Quests.Collect = self:_RegisterQuest("Collecting", PseudoEnum.GuiAlignmentType.Bottom)
	self.Quests.Collect.Steps.Collect = self.Quests.Collect:RegisterStep("Collect Bread from Bread Rack", true)

	-- Depositing
	self.Quests.Deposit = self:_RegisterQuest("Depositing", PseudoEnum.GuiAlignmentType.Bottom)
	self.Quests.Deposit.Steps.Deposit = self.Quests.Deposit:RegisterStep("Deposit Bread in Truck", true)

	-- Delivering
	self.Quests.Deliver = self:_RegisterQuest("Delivering", PseudoEnum.GuiAlignmentType.Bottom)
	self.Quests.Deliver.Steps.Deliver = self.Quests.Deliver:RegisterStep("Deliver Bread with the Truck", true)

	-- Hatching
	self.Quests.Hatch = self:_RegisterQuest("Pet Hatching", PseudoEnum.GuiAlignmentType.Bottom)
	self.Quests.Hatch.Steps.GoTo = self.Quests.Hatch:RegisterStep("Go to the center of the map", true)
	self.Quests.Hatch.Steps.Hatch = self.Quests.Hatch:RegisterStep("Hatch a pet from one of the eggs", true)

	-- Assigning
	self.Quests.Assign = self:_RegisterQuest("Pet Assignment", PseudoEnum.GuiAlignmentType.Bottom)
	self.Quests.Assign.Steps.GoToKneader = self.Quests.Assign:RegisterStep("Go to the kneader", true)
	self.Quests.Assign.Steps.Assign = self.Quests.Assign:RegisterStep("Assign pet to kneader", true)

	for kq: string, quest: Quest<any> in pairs(self.Quests) do
		for ks: string, step: Step in pairs(quest.Steps) do
			step:SetCompletionCondition(function()
				return self._IsCompleted
			end)
		end
		quest:Initialize()
	end

	self._IsInitialized = true

	if self._IsCompleted then
		Panel.Visible:Set(false)
	end

	self._Maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
		if self._IsCompleted then
			return
		end
		if not self._CurrentQuest:GetIfStarted() then
			-- print("Start: ", self._CurrentQuest._Name)
			self._CurrentQuest:Start()
		end
		if self._CurrentQuest:GetIfCompleted() then
			-- print("Quest completed", self._CurrentQuest._Name)
			local quests = TableUtil.values(self.Quests :: any)
			table.sort(quests, function(a: Quest<any>, b: Quest<any>)
				return a.Index < b.Index
			end)
			-- print("Quest index", self._CurrentQuest.Index)
			local nextQuest: Quest<any>?
			for i, quest in ipairs(quests) do
				if self._CurrentQuest.Index + 1 == quest.Index then
					nextQuest = quest
					break
				end
			end
			self._CurrentQuest:Stop()
			if nextQuest then
				-- print("Setting next quest", nextQuest._Name)
				self._CurrentQuest = nextQuest
			else
				-- print("Onboarding completed")
				Panel.Visible:Set(false)
				self:Destroy()
				-- NetworkUtil.fireServer(SET_ONBOARDING_COMPLETE_KEY)
			end
		end
	end))

	currentOnboarding = self

	return self
end

function Onboarding.init(maid: Maid)
	print("Init Onboarding")
	maid:GiveTask(Onboarding.new())
	return nil
end

return ServiceProxy(function()
	return currentOnboarding or Onboarding
end)
