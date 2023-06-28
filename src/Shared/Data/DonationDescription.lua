--!strict
-- Services
-- Packages
-- Modules
-- Types
export type DonationUpgradeType = {
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

function addDonation(
	gamePassName: string,
	gamePassThumbnail: string,
	gamePassHoverThumbnail: string,
	gamePassPrice: number,
	layoutOrder: number,
	gamePassDescription: string,
	id: number
): DonationUpgradeType
	local item: DonationUpgradeType = {} :: any
	item["Name"] = gamePassName
	item["Thumbnail"] = gamePassThumbnail
	item["HoverThumbnail"] = gamePassHoverThumbnail
	item["Cost"] = gamePassPrice
	item["LayoutOrder"] = layoutOrder
	item["Description"] = gamePassDescription
	item["ID"] = id
	return item
end

return {
	["5 Robux"] = addDonation("5 Robux", "rbxassetid://10441176225", "rbxassetid://10462022183", 5, 1, "Donate 5 Robux", 1296962698),
	["25 Robux"] = addDonation("25 Robux", "rbxassetid://10441176225", "rbxassetid://10462022183", 10, 2, "Donate 25 Robux", 1296962478),
	["50 Robux"] = addDonation("50 Robux", "rbxassetid://10441245642", "rbxassetid://10462041262", 25, 3, "Donate 50 Robux", 1296962640),
	["100 Robux"] = addDonation("100 Robux", "rbxassetid://10441245642", "rbxassetid://10462041262", 50, 4, "Donate 100 Robux", 1296962786),
	["200 Robux"] = addDonation("200 Robux", "rbxassetid://10441298177", "rbxassetid://10462086497", 100, 5, "Donate 200 Robux", 1296962751),
	["500 Robux"] = addDonation("500 Robux", "rbxassetid://10441298177", "rbxassetid://10462086497", 200, 6, "Donate 500 Robux", 1296962602),
}
