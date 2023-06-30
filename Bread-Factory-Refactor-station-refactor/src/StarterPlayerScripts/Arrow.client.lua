--!strict
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Beam: Beam?
local ArrowEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):FindFirstChild("ArrowEvent") :: RemoteEvent

--event to trigger the arrow to the tycoon
local function CreateBeam(beam: Beam, attachment0: Attachment, part: BasePart)
	local attachment1 = part:FindFirstChild("Attachment") :: Attachment?

	if attachment1 then
		beam.Attachment0 = attachment0
		beam.Attachment1 = attachment1
	end
end

ArrowEvent.OnClientEvent:Connect(function(part: BasePart, value: boolean)
	if value == true then
		Beam = ReplicatedStorage:WaitForChild("Beam"):Clone() :: Beam
		assert(Beam)
		local attachment0 = HumanoidRootPart:FindFirstChild("RootRigAttachment") :: Attachment?
		assert(attachment0)
		CreateBeam(Beam, attachment0, part)
		Beam.Parent = Character
	elseif Beam then
		Beam:Destroy()
		Beam = nil
	end
end)
