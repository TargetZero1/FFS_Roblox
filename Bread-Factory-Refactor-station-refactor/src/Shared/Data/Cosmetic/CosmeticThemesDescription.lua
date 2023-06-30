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
	["Default"] = CosmeticType("Default", "rbxassetid://69395121", "rbxassetid://69395121", 0, 0, "Revert To Default Theme"),
	["Cartoon Theme"] = CosmeticType("Cartoon Theme", "rbxassetid://11314184160", "rbxassetid://11314184160", 0, 1, "Buy Cartoon Theme"),
	["Beach Theme"] = CosmeticType("Beach Theme", "rbxassetid://11314183921", "rbxassetid://11314183921", 0, 2, "Buy Beach Theme"),
	["Vintage Theme"] = CosmeticType("Vintage Theme", "rbxassetid://11314183710", "rbxassetid://11314183710", 0, 3, "Buy Vintage Theme"),
}
