--!strict
-- Services
local Players = game:GetService("Players")

-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local PlayerGUI = Players.LocalPlayer:WaitForChild("PlayerGui", 30) :: PlayerGui?
assert(PlayerGUI)

-- Class

task.wait(5)

--force the orientation to landscape
PlayerGUI.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
