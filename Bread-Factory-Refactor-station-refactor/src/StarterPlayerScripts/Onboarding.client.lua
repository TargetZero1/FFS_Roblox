--!strict
-- Services
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

-- Packages
local GuiLibrary = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("GuiLibrary"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))

-- Modules
local StyleGuide = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("StyleGuide"))
local Onboarding = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Onboarding"))
-- Types
type Maid = Maid.Maid
-- Constants
local ON_KNEADER_PRESS = "OnKneaderPress"
local ON_OVEN_PRESS = "OnOvenPress"
local ON_WRAP_PRESS = "OnWrapPress"
local ON_TRAY_GRAB = "OnTrayGrab"
local ON_DEPOSIT = "OnTrayDeposit"
local ON_DELIVER = "OnTruckDeliver"
local ON_PET_HATCH = "OnPetHatch"
local ON_PET_ASSIGNMENT = "OnPetAssignment"

local EGG_ZONE_POSITION = Vector3.new(84.884, 0.144, 119.997)
local EGG_ZONE_RADIUS = 35
local STATION_RADIUS = 20
local KNEADER_TAG = "Kneader"
local OVEN_TAG = "Oven"
local WRAP_TAG = "Wrapper"
local RACK_TAG = "Rack"
local TRUCK_TAG = "DeliveryTruck"
local YIELD_TIMEOUT = 60
-- Variables

-- References
local TycoonSpawns = workspace:WaitForChild("TycoonSpawns")
local HatcherFolder = workspace:WaitForChild("Hatchers")
local Player = Players.LocalPlayer
-- Private Functions
function getTycoonPlot(): BasePart?
	for i, part in ipairs(TycoonSpawns:GetChildren()) do
		if part:IsA("BasePart") then
			local spawnLocation = part:FindFirstChild("SpawnLocation")
			if spawnLocation and Player.RespawnLocation == spawnLocation then
				return part
			end
		end
	end
	return nil
end
function getTycoonModel(): Model?
	local plot = getTycoonPlot()
	if plot then
		local model = plot:FindFirstChild("Template")
		if model and model:IsA("Model") then
			return model
		end
	end
	return nil
end
function getTycoonInstanceByTag(tagName: string): Instance?
	local model = getTycoonModel()
	if model then
		for i, inst in ipairs(model:GetDescendants()) do
			if CollectionService:HasTag(inst, tagName) then
				return inst
			end
		end
	end
	return nil
end

function getCharacterCFrame(): CFrame?
	local character = Player.Character
	if character then
		local hrp = character.PrimaryPart
		if hrp then
			return hrp.CFrame
		end
	end
	return nil
end

function getFlatDistance(a: Vector3, b: Vector3): number
	return ((a - b) * Vector3.new(1, 0, 1)).Magnitude
end

function repeatUntilRetrieved(get: () -> Instance?): Instance
	local inst: Instance?
	local startTick = tick()
	repeat
		inst = get()
		if not inst then
			task.wait(1)
		end
	until inst or tick() - startTick > YIELD_TIMEOUT
	assert(inst, "could not retrieve instance")
	return inst
end

-- Class
function boot(maid: Maid)
	StyleGuide.init(maid)
	GuiLibrary.init(maid)
	GuiLibrary.setStyleGuide(StyleGuide)
	Onboarding.init(maid)

	local function trackProgress(eventName: string, step0: Onboarding.Step, step1: Onboarding.Step, step2: Onboarding.Step, step3: Onboarding.Step, step4: Onboarding.Step)
		local presses = 0
		maid:GiveTask(NetworkUtil.onClientEvent(eventName, function()
			presses += 1
			print(eventName, "PRESS = ", presses)
		end))
		if step4:GetIfCompleted() then
			presses += 5
		elseif step3:GetIfCompleted() then
			presses += 4
		elseif step2:GetIfCompleted() then
			presses += 3
		elseif step1:GetIfCompleted() then
			presses += 2
		elseif step0:GetIfCompleted() then
			presses += 1
		end
		step0:SetCompletionCondition(function()
			return presses >= 1
		end)
		step1:SetCompletionCondition(function()
			return presses >= 2
		end)
		step2:SetCompletionCondition(function()
			return presses >= 3
		end)
		step3:SetCompletionCondition(function()
			return presses >= 4
		end)
		step4:SetCompletionCondition(function()
			return presses >= 5
		end)
	end

	trackProgress(
		ON_KNEADER_PRESS,
		Onboarding.Quests.Knead.Steps.Knead0,
		Onboarding.Quests.Knead.Steps.Knead1,
		Onboarding.Quests.Knead.Steps.Knead2,
		Onboarding.Quests.Knead.Steps.Knead3,
		Onboarding.Quests.Knead.Steps.Knead4
	)
	trackProgress(
		ON_OVEN_PRESS,
		Onboarding.Quests.Bake.Steps.Bake0,
		Onboarding.Quests.Bake.Steps.Bake1,
		Onboarding.Quests.Bake.Steps.Bake2,
		Onboarding.Quests.Bake.Steps.Bake3,
		Onboarding.Quests.Bake.Steps.Bake4
	)
	trackProgress(
		ON_WRAP_PRESS,
		Onboarding.Quests.Wrap.Steps.Wrap0,
		Onboarding.Quests.Wrap.Steps.Wrap1,
		Onboarding.Quests.Wrap.Steps.Wrap2,
		Onboarding.Quests.Wrap.Steps.Wrap3,
		Onboarding.Quests.Wrap.Steps.Wrap4
	)

	maid:GiveTask(NetworkUtil.onClientEvent(ON_TRAY_GRAB, function()
		Onboarding.Quests.Collect.Steps.Collect:Fire(true)
	end))
	maid:GiveTask(NetworkUtil.onClientEvent(ON_DEPOSIT, function()
		Onboarding.Quests.Deposit.Steps.Deposit:Fire(true)
	end))
	maid:GiveTask(NetworkUtil.onClientEvent(ON_DELIVER, function()
		Onboarding.Quests.Deliver.Steps.Deliver:Fire(true)
	end))

	maid:GiveTask(NetworkUtil.onClientEvent(ON_PET_HATCH, function()
		Onboarding.Quests.Hatch.Steps.Hatch:Fire(true)
	end))

	maid:GiveTask(NetworkUtil.onClientEvent(ON_PET_ASSIGNMENT, function()
		Onboarding.Quests.Assign.Steps.Assign:Fire(true)
		Onboarding.Quests.Assign.Steps.GoToKneader:Fire(true)
	end))

	Onboarding.Quests.Hatch.Steps.GoTo:SetCompletionCondition(function(): boolean
		local cf = getCharacterCFrame()
		if cf then
			local dist = getFlatDistance(cf.Position, EGG_ZONE_POSITION)
			if dist <= EGG_ZONE_RADIUS then
				return true
			end
		end
		return false
	end)

	local kneaderModel = repeatUntilRetrieved(function()
		return getTycoonInstanceByTag(KNEADER_TAG)
	end)

	Onboarding.Quests.Assign.Steps.GoToKneader:SetCompletionCondition(function(): boolean
		if kneaderModel and kneaderModel:IsA("Model") then
			local kneaderCF = kneaderModel:GetPivot()
			local cf = getCharacterCFrame()
			if cf then
				local dist = getFlatDistance(cf.Position, kneaderCF.Position)
				if STATION_RADIUS > dist then
					return true
				end
			end
		end
		return false
	end)

	Onboarding.Quests.Assign.Steps.GoToKneader:AddToFocus(kneaderModel)
	Onboarding.Quests.Assign.Steps.Assign:AddToFocus(kneaderModel)
	Onboarding.Quests.Knead.Steps.Knead0:AddToFocus(kneaderModel)
	Onboarding.Quests.Bake.Steps.Bake0:AddToFocus(repeatUntilRetrieved(function()
		return getTycoonInstanceByTag(OVEN_TAG)
	end))
	Onboarding.Quests.Wrap.Steps.Wrap0:AddToFocus(repeatUntilRetrieved(function()
		return getTycoonInstanceByTag(WRAP_TAG)
	end))
	Onboarding.Quests.Collect.Steps.Collect:AddToFocus(repeatUntilRetrieved(function()
		return getTycoonInstanceByTag(RACK_TAG)
	end))
	local truckModel = repeatUntilRetrieved(function()
		return getTycoonInstanceByTag(TRUCK_TAG)
	end)
	Onboarding.Quests.Deposit.Steps.Deposit:AddToFocus(truckModel)
	Onboarding.Quests.Deliver.Steps.Deliver:AddToFocus(truckModel)

	local catHatcher: Model?
	for i, hatcher in ipairs(HatcherFolder:GetChildren()) do
		if hatcher:IsA("Model") then
			local egg = hatcher:FindFirstChild("Egg")
			if egg and egg:GetAttribute("PetClass") == "Cat" then
				catHatcher = hatcher
				break
			end
		end
	end
	assert(catHatcher)

	Onboarding.Quests.Hatch.Steps.GoTo:AddToFocus(catHatcher)
end

local maid = Maid.new()
boot(maid)
