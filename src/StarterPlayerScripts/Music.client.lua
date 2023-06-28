--!strict
-- Services
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local Music = SoundService:WaitForChild("Music")
-- Private Functions
-- Class
function playMusic()
	task.wait()
	for i, inst in ipairs(Music:GetChildren()) do
		if inst:IsA("Sound") then
			for i, other in ipairs(workspace.CurrentCamera:GetChildren()) do
				if other:IsA("Sound") then
					other:Stop()
					Debris:AddItem(other)
				end
			end

			local sound: Sound = inst:Clone()
			sound.PlaybackSpeed = 1
			sound.Volume = 0.5
			sound.Looped = false
			sound.Parent = workspace.CurrentCamera
			if Players.LocalPlayer.Name ~= "CJ_Oyer" and Players.LocalPlayer.Name ~= "aryoseno11" then
				sound:Play()
			end
			sound.Ended:Wait()
			-- task.wait(sound.TimeLength / sound.PlaybackSpeed)
		end
	end
	playMusic()
end
playMusic()
