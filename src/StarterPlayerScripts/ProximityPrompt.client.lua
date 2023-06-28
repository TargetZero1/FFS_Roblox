--!strict
-- Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
-- Packages
-- Modules
-- Types
-- Constants
local OWNER_ONLY_TAG = "OwnerOnly"
-- Variables
-- References
local TycoonSpawns = workspace:WaitForChild("TycoonSpawns")
-- Class
function getTycoon(): BasePart?
	for i, tycoon in ipairs(TycoonSpawns:GetChildren()) do
		assert(tycoon:IsA("BasePart"))
		local ownerSign = tycoon:FindFirstChild("PlotOwnerSign")
		if ownerSign then
			local ownerName = ownerSign:GetAttribute("Owner")
			if ownerName and Players.LocalPlayer.Name == ownerName then
				return tycoon
			end
		end
	end
	return nil
end

function processPrompt(prompt: Instance)
	assert(prompt:IsA("ProximityPrompt"))
	local tycoon = getTycoon()
	-- print(prompt:GetFullName(), tycoon, tycoon and not prompt:IsDescendantOf(tycoon) )
	if tycoon and not prompt:IsDescendantOf(tycoon) then
		if CollectionService:HasTag(prompt, OWNER_ONLY_TAG) then
			prompt.Enabled = false
		end
	end
end

CollectionService:GetInstanceAddedSignal("ProximityPrompt"):Connect(processPrompt)

for i, inst in ipairs(CollectionService:GetTagged("ProximityPrompt")) do
	processPrompt(inst)
end
