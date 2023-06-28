--!strict
-- Services
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Class
return {
	--check if the player owns a gamepass with this ID and run a function if they do
	[72141916] = function(player: Player)
		--save that the player owns this gamepass
		player:SetAttribute("VIP", true)
	end,
	--Double Bread value
	[72142319] = function(player: Player)
		player:SetAttribute("DoubleBread", 2)
	end,
	--Loaf value reader
	[72142124] = function(player: Player)
		player:SetAttribute("LoafValueReader", true)
	end,
	--Ultimate windmill
	[1] = function(player: Player)
		player:SetAttribute("UltimateWindmill", true)
	end,
	--Ultimate kneader
	[84834686] = function(player: Player)
		player:SetAttribute("UltimateKneader", true)
	end,
	--Ultimate oven
	[84834761] = function(player: Player)
		player:SetAttribute("UltimateOven", true)
	end,
	--Ultimate wrapper
	[84834822] = function(player: Player)
		player:SetAttribute("UltimateWrapper", true)
	end,
}
