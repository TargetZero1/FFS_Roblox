--!strict
-- Services
local StarterGui = game:GetService("StarterGui")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
--disable reset button option
local success, message = pcall(function()
	StarterGui:SetCore("ResetButtonCallback", false)
end)
if not success then
	warn(message)
end
