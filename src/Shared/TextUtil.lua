--!strict
-- Services
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Class
local TextUltilities = {}

local suffixes = {
	"k",
	"M", -- 7 digits
	"B", -- 10 digits
	"T", -- 13 digits
	"QD", -- 16 digits
	"QT", -- 19 digits
	"SXT", -- 22 digits
	"SEPT", -- 25 digits
	"OCT", -- 28 digits
	"NON", -- 31 digits
	"DEC", -- 34 digits
	"UDEC", -- 37 digits
	"DDEC", -- 40 digits
}

--Takes a given value and applies a suffix to shorten the text length.
TextUltilities.applySuffix = function(value: number | string): string
	if value == "MAXED" then
		return value
	end

	local num_value: number? = tonumber(value)
	assert(num_value)
	--If the value is less than 1000 then it doesn't need a suffix.
	if num_value < 1000 then
		return tostring(num_value)
	end
	--Get how many zeroes the number has
	local numberOfZeros = math.floor(math.log10(num_value))
	--Each suffix is every three zeros so divide the number of zeros by 3
	local suffix = math.floor(numberOfZeros / 3)

	return string.format("%0.1f%s", num_value / 10 ^ (suffix * 3), suffixes[suffix] or "")
end

return TextUltilities
