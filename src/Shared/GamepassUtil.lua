--!strict
-- Services
local MarketplaceService = game:GetService("MarketplaceService")
-- Packages
-- Modules
local DataGamePassDescription = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("GamePassDescription"))
-- Types
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

function Util.getIfDoubleBreadOwned(userId: number): boolean
	return MarketplaceService:UserOwnsGamePassAsync(userId, DataGamePassDescription["Double Bread Value"].ID)
end

function Util.getIfSuperKneaderOwned(userId: number): boolean
	return MarketplaceService:UserOwnsGamePassAsync(userId, DataGamePassDescription["Super Kneader"].ID)
end

function Util.getIfSuperOvenOwned(userId: number): boolean
	return MarketplaceService:UserOwnsGamePassAsync(userId, DataGamePassDescription["Super Oven"].ID)
end

function Util.getIfSuperWrapperOwned(userId: number): boolean
	return MarketplaceService:UserOwnsGamePassAsync(userId, DataGamePassDescription["Super Wrapper"].ID)
end

function Util.getIfInfiniteTrayOwned(userId: number): boolean
	return MarketplaceService:UserOwnsGamePassAsync(userId, DataGamePassDescription["Infinite Tray"].ID)
end

return Util
