--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- Modules
local Hatch = require(script.Parent)
local PetModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetModifierUtil"))

-- Types
type Maid = Maid.Maid
-- Constants
-- Variables
-- References
-- Class
return function(coreGui: Frame)
	local maid = Maid.new()

	task.spawn(function()
		-- maid:GiveTask(
		Hatch({
			{
				BalanceId = PetModifierUtil.getBalanceId("Dog", "Normal", 1),
				Color = Color3.fromHSV(0.6, 1, 1),
			},
			{
				BalanceId = PetModifierUtil.getBalanceId("Dog", "Normal", 2),
				Color = Color3.fromHSV(0.6, 1, 1),
			},
			{
				BalanceId = PetModifierUtil.getBalanceId("Dog", "Normal", 3),
				Color = Color3.fromHSV(0.6, 1, 1),
			},
		}, "Dog")
		-- )
	end)

	return function()
		maid:Destroy()
	end
end
