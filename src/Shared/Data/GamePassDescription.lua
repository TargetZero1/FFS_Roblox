--!strict
-- Services
-- Packages
-- Modules
-- Types
export type GamepassDescription = {
	Name: string,
	Thumbnail: string,
	HoverThumbnail: string,
	Cost: number,
	LayoutOrder: number,
	Description: string,
	ID: number,
}
-- Constants
-- Variables
-- References
-- Class
function addGamePass(gamePassName: string, gamePassThumbnail: string, gamePassHoverThumbnail: string, layoutOrder: number, gamePassDescription: string, id: number): GamepassDescription
	local item: GamepassDescription = {} :: any
	item["Name"] = gamePassName
	item["Thumbnail"] = gamePassThumbnail
	item["HoverThumbnail"] = gamePassHoverThumbnail
	item["LayoutOrder"] = layoutOrder
	item["Description"] = gamePassDescription
	item["ID"] = id

	return item
end

return {
	["Double Bread Value"] = addGamePass("Double Bread Value", "rbxassetid://10441724640", "rbxassetid://10462189644", 1, "Double the value of your bread sales", 72142319),
	["Super Kneader"] = addGamePass("Super Kneader", "rbxassetid://10924745442", "rbxassetid://10924745237", 3, "Supercharge your Kneading Machine! Gain 5 levels in all upgrades.", 84834686),
	["Super Oven"] = addGamePass("Super Oven", "rbxassetid://10924744573", "rbxassetid://10924744278", 4, "Supercharge your Oven! Gain 5 levels in all upgrades.", 84834761),
	["Super Wrapper"] = addGamePass("Super Wrapper", "rbxassetid://10924744004", "rbxassetid://10924743209", 5, "Supercharge your Wrapping Machine! Gain 5 levels in all upgrades.", 84834822),
	["Infinite Tray"] = addGamePass("Infinite Tray", "rbxassetid://10924750965", "rbxassetid://10924751178", 6, "Deliver all of your bread in a single go. No limit to this tray!", 84834888),
}
