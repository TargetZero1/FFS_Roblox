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
	["Logo 1"] = CosmeticType("Logo 1", "rbxassetid://10441176225", "rbxassetid://10462022183", 5, 1, "Buy Logo 1"),
	["Logo 2"] = CosmeticType("Logo 2", "rbxassetid://10441176225", "rbxassetid://10462022183", 10, 2, "Buy Logo 2"),
	["Logo 3"] = CosmeticType("Logo 3", "rbxassetid://10441245642", "rbxassetid://10462041262", 25, 3, "Buy Logo 3"),
	["Logo 4"] = CosmeticType("Logo 4", "rbxassetid://10441245642", "rbxassetid://10462041262", 50, 4, "Buy Logo 4"),
	["Logo 5"] = CosmeticType("Logo 5", "rbxassetid://10441298177", "rbxassetid://10462086497", 100, 5, "Buy Logo 5"),
}
