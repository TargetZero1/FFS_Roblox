--!strict
-- Services
-- Packages
-- Modules
-- Types
export type CurrentUpgradeType = {
	Name: string,
	Thumbnail: string,
	LayoutOrder: number,
	Description: string,
	ID: number,
}
-- Constants
-- Variables
-- References
-- Class
function addCurrency(gamePassName: string, gamePassThumbnail: string, layoutOrder: number, gamePassDescription: string, id: number): CurrentUpgradeType
	local item: CurrentUpgradeType = {} :: any
	item["Name"] = gamePassName
	item["Thumbnail"] = gamePassThumbnail
	item["LayoutOrder"] = layoutOrder
	item["Description"] = gamePassDescription
	item["ID"] = id

	return item
end

return {
	--Normal Currencies
	-- ["10,000"] = addCurrency(
	-- 	"10,000",
	-- 	"rbxassetid://10916594710",
	-- 	2,
	-- 	"Get 10,000 additional in game coins",
	-- 	1296964815
	-- ),
	-- ["50,000"] = addCurrency(
	-- 	"50,000",
	-- 	"rbxassetid://10916594409",
	-- 	3,
	-- 	"Get 50,000 additional in game coins",
	-- 	1296964856
	-- ),
	-- ["100,000"] = addCurrency(
	-- 	"100,000",
	-- 	"rbxassetid://10916594214",
	-- 	4,
	-- 	"Get 100,000 additional in game coins",
	-- 	1296964903
	-- ),
	-- ["5,000"] = addCurrency("5,000", "rbxassetid://10916593098", 1, "Get 5,000 additional in game coins", 1296964955),
	-- ["250,000"] = addCurrency(
	-- 	"250,000",
	-- 	"rbxassetid://10916593796",
	-- 	5,
	-- 	"Get 250,000 additional in game coins",
	-- 	1296965017
	-- ),
	-- ["500,000"] = addCurrency(
	-- 	"500,000",
	-- 	"rbxassetid://10916593583",
	-- 	6,
	-- 	"Get 500,000 additional in game coins",
	-- 	1296965074
	-- ),
	--Dynamic Currencies
	["Dynamic 50"] = addCurrency("Dynamic 50", "rbxassetid://10916593583", 7, "Get (50 x Bread Value) Cash", 1316662852),
	["Dynamic 100"] = addCurrency("Dynamic 100", "rbxassetid://10916593583", 8, "Get (100 x Bread Value) Cash", 1316663047),
	["Dynamic 500"] = addCurrency("Dynamic 500", "rbxassetid://10916593583", 9, "Get (500 x Bread Value) Cash", 1316663368),
	["Dynamic 1000"] = addCurrency("Dynamic 1000", "rbxassetid://10916593583", 10, "Get (1000 x Bread Value) Cash", 1316663558),
	["Dynamic 2500"] = addCurrency("Dynamic 2500", "rbxassetid://10916593583", 11, "Get (2500 x Bread Value) Cash", 1316663723),
	["Dynamic 5000"] = addCurrency("Dynamic 5000", "rbxassetid://10916593583", 12, "Get (5000 x Bread Value) Cash", 1316663884),
}
