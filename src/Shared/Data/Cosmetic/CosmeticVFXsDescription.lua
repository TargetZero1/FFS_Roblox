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
	["VFX 1"] = CosmeticType("VFX 1", "rbxassetid://10441176225", "rbxassetid://10462022183", 5, 1, "Buy VFX 1"),
	["VFX 2"] = CosmeticType("VFX 2", "rbxassetid://10441176225", "rbxassetid://10462022183", 10, 2, "Buy VFX 2"),
	["VFX 3"] = CosmeticType("VFX 3", "rbxassetid://10441245642", "rbxassetid://10462041262", 25, 3, "Buy VFX 3"),
	["VFX 4"] = CosmeticType("VFX 4", "rbxassetid://10441245642", "rbxassetid://10462041262", 50, 4, "Buy VFX 4"),
	["VFX 5"] = CosmeticType("VFX 5", "rbxassetid://10441298177", "rbxassetid://10462086497", 100, 5, "Buy VFX 5"),
}
