--!strict
-- Services
-- Packages
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))

-- Modules

-- Types
type ProgressData = {
	Knead: {
		Knead0: boolean,
		Knead1: boolean,
		Knead2: boolean,
		Knead3: boolean,
		Knead4: boolean,
		[any]: nil,
	},
	Bake: {
		Bake0: boolean,
		Bake1: boolean,
		Bake2: boolean,
		Bake3: boolean,
		Bake4: boolean,
		[any]: nil,
	},
	Wrap: {
		Wrap0: boolean,
		Wrap1: boolean,
		Wrap2: boolean,
		Wrap3: boolean,
		Wrap4: boolean,
		[any]: nil,
	},
	Collect: {
		Collect: boolean,
		[any]: nil,
	},
	Deposit: {
		Deposit: boolean,
		[any]: nil,
	},
	Deliver: {
		Deliver: boolean,
		[any]: nil,
	},
	Hatch: {
		GoTo: boolean,
		Hatch: boolean,
		[any]: nil,
	},
	Assign: {
		GoToKneader: boolean,
		Assign: boolean,
		[any]: nil,
	},
}

-- Constants
local GET_ONBOARDING_PROGRESS_KEY = "GET_ONBOARDING_PROGRESS"
local SET_STAGE_COMPLETE = "SET_STAGE_COMPLETE"
local QUEST_ORDER = { "Knead", "Bake", "Wrap", "Collect", "Deposit", "Deliver", "Hatch", "Assign" }
local STEP_ORDER = {
	Knead = {
		"Knead0",
		"Knead1",
		"Knead2",
		"Knead3",
		"Knead4",
	},
	Bake = {
		"Bake0",
		"Bake1",
		"Bake2",
		"Bake3",
		"Bake4",
	},
	Wrap = {
		"Wrap0",
		"Wrap1",
		"Wrap2",
		"Wrap3",
		"Wrap4",
	},
	Collect = {
		"Collect",
	},
	Deposit = {
		"Deposit",
	},
	Deliver = {
		"Deliver",
	},
	Hatch = {
		"GoTo",
		"Hatch",
	},
	Assign = {
		"GoToKneader",
		"Assign",
	},
}

-- Variables
local ProgressData: ProgressData?
-- References
-- Private Functions
local function getProgressData(): ProgressData
	if not ProgressData then
		repeat
			task.wait(0.2)
		until ProgressData
		print("PROGRESS", ProgressData)
	end
	assert(ProgressData)

	return ProgressData
end
function getQuestName(index: number): string
	local questName = QUEST_ORDER[index]
	assert(questName, "no quest for index " .. tostring(index))
	return questName
end
function getStepName(questIndex: number, stepIndex: number): string
	local questName = getQuestName(questIndex)
	local stepName = STEP_ORDER[questName][stepIndex]
	assert(stepName, "no step for index " .. tostring(stepName) .. " in quest " .. tostring(questName))
	return stepName
end

-- Class
local Util = {}

function Util.getIfTutorialIsFinished()
	local progressData = getProgressData()
	for k, quest in pairs(progressData) do
		for step, isDone in pairs(quest) do
			if not isDone then
				return false
			end
		end
	end
	return false
end

function Util.getIfStepIsFinished(questIndex: number, stepIndex: number): boolean
	local progressData = getProgressData()
	local questName = getQuestName(questIndex)
	local stepName = getStepName(questIndex, stepIndex)
	local result = progressData[questName][stepName]
	-- print(questName, stepName, "=", result)
	return result
end

function Util.completeStep(questIndex: number, stepIndex: number)
	local progressData = getProgressData()

	local questName = getQuestName(questIndex)
	local stepName = getStepName(questIndex, stepIndex)

	progressData[questName][stepName] = true
	NetworkUtil.fireServer(SET_STAGE_COMPLETE, questName, stepName)
end

task.spawn(function()
	repeat
		ProgressData = NetworkUtil.invokeServer(GET_ONBOARDING_PROGRESS_KEY)
		if not ProgressData then
			task.wait(2)
		end
	until ProgressData
end)

return Util
