--!strict
-- Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
-- Modules
local BreadData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("BreadTypes"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
export type DropData = {
	TypeIndex: number,
	UserId: number,
	Value: number,
}
-- Constants
-- Variables
-- References
-- Private functions
function getBreadTypeName(breadTypeIndex: number): string
	return assert(BreadData.Order[breadTypeIndex])
end

function getBreadTypeData(breadTypeIndex: number): BreadData.BreadType
	local breadData = BreadData.Types[getBreadTypeName(breadTypeIndex)]
	return assert(breadData)
end

-- Class
local Util = {}

function Util.new(breadTypeIndex: number, owner: Player): DropData
	local breadName = getBreadTypeName(breadTypeIndex)
	local breadData = getBreadTypeData(breadTypeIndex)
	local baseValue = breadData.BaseValue
	return {
		TypeIndex = assert(breadTypeIndex, "bad bread type for " .. tostring(breadName)),
		UserId = owner.UserId,
		Value = assert(baseValue, "bad bread type for " .. tostring(breadName)),
	}
end
function Util.set(instance: Instance, data: DropData)
	instance:SetAttribute("TypeIndex", data.TypeIndex)
	instance:SetAttribute("Value", data.Value)
	instance:SetAttribute("UserId", data.UserId)
	Util.setValueLabel(instance)
end
function Util.get(instance: Instance): DropData
	return {
		TypeIndex = assert(instance:GetAttribute("TypeIndex")),
		UserId = assert(instance:GetAttribute("UserId")),
		Value = assert(instance:GetAttribute("Value")),
	}
end
function Util.getIfDrop(hit: BasePart)
	local success = pcall(function()
		Util.get(hit)
	end)
	return success
end

function Util.normalizeQueue(queue: { [number]: DropData }): ()
	local maxModifier = 1
	for i, data in ipairs(queue) do
		local breadData = getBreadTypeData(data.TypeIndex)
		local baseValue = assert(breadData.BaseValue)
		local modifier = data.Value / baseValue
		maxModifier = math.max(modifier, maxModifier)
	end

	for i, data in ipairs(queue) do
		local breadData = getBreadTypeData(data.TypeIndex)
		data.Value = breadData.BaseValue * maxModifier
	end
end

function Util.setValueLabel(instance: Instance)
	local data = Util.get(instance)
	assert(data)

	local gui: BillboardGui
	if instance:FindFirstChild("ValueBillboardGUI") then
		gui = instance:WaitForChild("ValueBillboardGUI") :: BillboardGui
	else
		gui = BreadData.ValueGUI:Clone() :: BillboardGui
		gui.Parent = instance
	end

	local textLabel = gui:WaitForChild("TextLabel", 10) :: TextLabel?
	assert(textLabel)

	local owner = Players:GetPlayerByUserId(data.UserId)
	assert(owner, `no user found with userId {data.UserId}`)

	gui.Enabled = true -- owner:GetAttribute("LoafValueReader")
	textLabel.Text = "$" .. FormatUtil.formatNumber(math.max(math.floor(data.Value), 1))
end

function Util.newDropPrompt(parent: BasePart, objectText: string | () -> string, actionText: string | () -> string, getCooldown: () -> number): Signal
	local maid = Maid.new()
	local onClick = maid:GiveTask(Signal.new())
	--set up proximity prompt
	local clickTick = 0
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "DropTrigger"
	maid:GiveTask(parent.Destroying:Connect(function()
		maid:Destroy()
	end))

	maid:GiveTask(prompt.Triggered:Connect(function(player: Player)
		local cooldown = getCooldown()
		if clickTick + cooldown < tick() then
			clickTick = tick()
			onClick:Fire(player)
		end
	end))
	prompt.HoldDuration = 0 --0.5
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent

	CollectionService:AddTag(prompt, "ProximityPrompt")

	maid:GiveTask(RunService.Heartbeat:Connect(function()
		local cooldown = getCooldown()
		local goal = clickTick + cooldown
		local secRemaining = goal - tick()
		if math.floor(secRemaining * 10) > 0 then
			prompt.ActionText = "wait " .. math.round(secRemaining) .. " seconds"
			prompt.ObjectText = "recharging"
		else
			--prompt.HoldDuration = cooldown
			if type(actionText) == "string" then
				prompt.ActionText = actionText
			else
				prompt.ActionText = actionText()
			end
			if type(objectText) == "string" then
				prompt.ObjectText = objectText
			else
				prompt.ObjectText = objectText()
			end
		end
	end))

	maid:GiveTask(prompt)

	return onClick
end

return Util
