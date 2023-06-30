--!strict
-- Services
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Class
export type CosmeticData = {
	Name: string,
	Thumbnail: string,
	HoverThumbnail: string,
	Cost: number,
	LayoutOrder: number,
	Description: string,
	ID: number?,
}
return function(gamePassName: string, gamePassThumbnail: string, gamePassHoverThumbnail: string, gamePassPrice: number, layoutOrder: number, gamePassDescription: string, id: number?): CosmeticData
	local item: CosmeticData = {
		Name = gamePassName,
		Thumbnail = gamePassThumbnail,
		HoverThumbnail = gamePassHoverThumbnail,
		Cost = gamePassPrice,
		LayoutOrder = layoutOrder,
		Description = gamePassDescription,
		ID = id,
	}

	return item
end
