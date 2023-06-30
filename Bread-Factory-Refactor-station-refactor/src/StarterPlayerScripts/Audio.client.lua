--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SoundEvent = RemoteEvents:WaitForChild("PlaySoundEvent") :: RemoteEvent
-- Class

local TimeLastPlayed = nil

SoundEvent.OnClientEvent:Connect(function(soundName: string)
	local audio = SoundService:FindFirstChild(soundName) :: Sound
	if audio then
		if not audio.IsLoaded then
			audio.Loaded:Wait()
		end

		if soundName == "SplashSound" or soundName == "SplashSound2" then
			if os.difftime(os.time(), TimeLastPlayed) >= 0.5 then
				TimeLastPlayed = os.time()
				audio:Play()
			end
		else
			audio:Play()
		end
	end
end)
