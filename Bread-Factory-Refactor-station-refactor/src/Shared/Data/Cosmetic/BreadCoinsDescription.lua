--!strict
-- Services
-- Packages
-- Modules
local CosmeticType = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Cosmetic"):WaitForChild("CosmeticType"))
-- Types
export type CosmeticData = CosmeticType.CosmeticData
-- Constants
-- Variables
-- References
-- Class
return {
	["1 Bread coin"] = CosmeticType("1 Bread coin", "rbxassetid://10280333047", "rbxassetid://10280333047", 5, 9, "Gain 1 additional Bread coin", 1345945340),
	["10 Bread coins"] = CosmeticType("10 Bread coins", "rbxassetid://10280404574", "rbxassetid://10280404574", 10, 10, "Gain 10 additional Bread coins", 1345949535),
	["25 Bread coins"] = CosmeticType("25 Bread coins", "rbxassetid://10441639350", "rbxassetid://10441639350", 25, 11, "Gain 25 additional Bread coins", 1345949711),
}
