--!strict
-- Services
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
-- Modules
local ReferenceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ReferenceUtil"))

-- Types
-- Constants
local GROUP_ID = 11827920 --your group id

-- Variables
-- References
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local PlayerLoadedEvent = BindableEvents:WaitForChild("PlayerLoadedEvent") :: BindableEvent

-- Private functions
local _getChild = ReferenceUtil.getChild
local _getParent = ReferenceUtil.getParent
local _getAttr = ReferenceUtil.getAttribute

-- Class
PlayerLoadedEvent.Event:Connect(function(player)
	------ ADMIN SETTINGS -----
	--reference to the admin controls script that sets key data
	local adminSettings = ReplicatedFirst:WaitForChild("AdminControls")

	--check if player is in the group
	local isInGroup = false
	pcall(function()
		isInGroup = player:IsInGroup(GROUP_ID)
	end)
	if isInGroup then
		local role = player:GetRoleInGroup(GROUP_ID)

		if adminSettings then
			if adminSettings:GetAttribute("RoleOnlyAccess") ~= nil then
				if adminSettings:GetAttribute("RoleOnlyAccess") == true then
					if role ~= "Tester" and role ~= "Developer" and role ~= "Owner" then
						player:Kick("You do not have access to this experience, please apply to be a tester")
					end
				else
					--hide options tab
					local optionsButton = assert(player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui", 20))
					assert(optionsButton:WaitForChild("OptionsButton", 30) :: GuiObject?).Visible = false
				end
			end
		end

		--if the joining player is a member of the team
		local screenGui = _getChild(_getChild(player, "PlayerGui"), "ScreenGui") :: ScreenGui
		if role == "Developer" or role == "Owner" then
			--get a reference to the opionsUI
			local optionsUI = _getChild(_getChild(player, "PlayerGui"), "OptionsUI")
			local optionsFrame = _getChild(optionsUI, "OptionsFrame") :: Frame;

			(_getChild(screenGui, "OptionsButton") :: GuiObject).Visible = true

			local reset = _getChild(optionsFrame, "ResetButton") :: ImageButton

			--turn on the reset button
			reset.Visible = true

			local teleport = _getChild(optionsFrame, "TeleportButton") :: ImageButton

			--turn on the teleport button
			teleport.Visible = true
		else
			--hide options tab
			local optionsButton = _getChild(screenGui, "OptionsButton") :: ImageButton
			optionsButton.Visible = false
		end
	else
		if adminSettings then
			if adminSettings:GetAttribute("RoleOnlyAccess") ~= nil then
				if adminSettings:GetAttribute("RoleOnlyAccess") == true then
					player:Kick("You do not have access to this experience, please apply to be a tester")
				else
					--hide options tab
					local screenGui = _getChild(_getChild(player, "PlayerGui"), "ScreenGui") :: ScreenGui
					local optionsButton = _getChild(screenGui, "OptionsButton") :: ImageButton
					optionsButton.Visible = false
				end
			end
		end
	end
end)
