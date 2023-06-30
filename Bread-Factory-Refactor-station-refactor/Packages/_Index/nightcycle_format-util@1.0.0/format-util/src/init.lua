--!strict
-- Service
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Packages
local Package = script
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local Signal = require(Packages:WaitForChild("Signal"))
local NetworkUtil = require(Packages:WaitForChild("NetworkUtil"))
local PhysicsUtil = require(Packages:WaitForChild("PhysicsUtil"))

-- Constants
local CENSOR_KEY = "GetCensoredText"

-- Modules
type Maid = Maid.Maid
type Signal = Signal.Signal

local Util = {}

function Util.time(timeInSeconds: number, goMaxLength: boolean?): string
	local days = math.floor(timeInSeconds / 86400)
	local hours = math.floor((timeInSeconds % 86400) / 3600)
	local minutes = math.floor((timeInSeconds % 3600) / 60)
	local seconds = math.floor(timeInSeconds % 60)
	if days > 0 or goMaxLength then
		if seconds == 0 then
			return string.format("%dd %02dh %02dm", days, hours, minutes)
		else
			return string.format("%dd %02dh %02dm %02ds", days, hours, minutes, seconds)
		end
	elseif hours > 0 then
		if seconds == 0 then
			return string.format("%2dh %02dm", hours, minutes)
		else
			return string.format("%2dh %02dm %02ds", hours, minutes, seconds)
		end
	else
		return string.format("%2dm %02ds", minutes, seconds)
	end
end

function Util.getIdFromString(str: string): number
	local val = 0
	for i = 1, string.len(str) do
		val += string.byte(str, i, i)
	end
	return val
end

function Util.insertCommas(amount: number): string
	if amount < 10 then
		amount = math.round(amount * 100) / 100
	elseif amount < 100 then
		amount = math.round(amount * 10) / 10
	else
		amount = math.round(amount)
	end
	local formatted = tostring(amount)
	while true do
		local i: number
		formatted, i = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if i == 0 then
			break
		end
	end
	return formatted
end

function round(val: number, decimal: number?)
	if decimal then
		return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
	else
		return math.floor(val + 0.5)
	end
end

function formatNumber(amount: number, decimal: number?, prefix: string?, neg_prefix: string?)
	local formatted: string, famount: number, remain: number

	decimal = decimal or 2 -- default 2 decimal places
	assert(decimal ~= nil)
	neg_prefix = neg_prefix or "-" -- default negative sign
	assert(neg_prefix ~= nil)

	famount = math.abs(round(amount, decimal))
	famount = math.floor(famount)

	remain = round(math.abs(amount) - famount, decimal)

	-- comma to separate the thousands
	formatted = Util.insertCommas(famount)

	-- attach the decimal portion
	if decimal > 0 then
		local str_remain: string = string.sub(tostring(math.round(remain * 100) / 100), 3)
		formatted = formatted .. "." .. str_remain .. string.rep("0", decimal - string.len(str_remain))
	end

	-- attach prefix string e.g '$'
	formatted = (prefix or "") .. formatted

	-- if value is negative then format accordingly
	if amount < 0 then
		if neg_prefix == "()" then
			formatted = "(" .. formatted .. ")"
		else
			formatted = neg_prefix .. formatted
		end
	end

	return formatted
end

local reductionLabels = { "", "K", "M", "B", "T", "Q" }
function getReductionExponent(amount: number): number
	local exp = 0
	while math.abs(amount) > 10 ^ exp and exp < 3 * (#reductionLabels - 1) do
		exp += 3
	end
	return math.max(exp - 3, 0)
end

function getReductionLabel(exp: number): string
	return reductionLabels[1 + exp / 3]
end

function getReduction(amount: number): number
	local exp = getReductionExponent(amount)
	return 10 ^ exp
end

function getReductionBase(amount: number): string
	local reduction = getReduction(amount)

	local val = math.abs(amount / reduction)
	-- print(amount, "RED", reduction, "VAL", val)
	if val > 100 then
		return formatNumber(val, 0)
	elseif val > 10 then
		return formatNumber(val, 1)
	else
		return formatNumber(val, 2)
	end
end

function Util.color(txt: string, col: Color3): string
	local hex = col:ToHex()
	return '<font color="#' .. tostring(hex:upper()) .. '">' .. txt .. "</font>"
end

function Util.bold(txt: string): string
	return "<b>" .. txt .. "</b>"
end

function Util.italic(txt: string): string
	return "<i>" .. txt .. "</i>"
end

function Util.underline(txt: string): string
	return "<u>" .. txt .. "</u>"
end

function Util.smallcaps(txt: string): string
	return "<sc>" .. txt .. "</sc>"
end

function Util.br(txt: string): string
	return "<s>" .. txt .. "</s>"
end

function Util.size(txt: string, size: number): string
	return '<font size="' .. tostring(size) .. '">' .. txt .. "</font>"
end

function Util.font(txt: string, font: Enum.Font): string
	return '<font face="' .. tostring(font.Name) .. '">' .. txt .. "</font>"
end

function Util.shortNumber(
	amount: number,
	prefix: string?,
	suffix: string?,
	lowercaseLabel: boolean?,
	visualizePositive: boolean?
): string
	local label = getReductionLabel(getReductionExponent(amount))
	if lowercaseLabel then
		string.lower(label)
	end
	local base = getReductionBase(amount)
	prefix = prefix or ""
	assert(prefix ~= nil)
	local lead = ""
	if amount < 0 then
		lead = "-"
	elseif visualizePositive then
		lead = "+"
	end
	return lead .. prefix .. base .. label
end

function Util.mass(kg: number): string
	if kg < 1 then
		return tostring(math.round(PhysicsUtil.Conversions.Mass.Kilogram.toGram(kg))) .. "g"
	elseif kg < 1000 then
		return tostring(math.round(kg)) .. "kg"
	else
		return Util.insertCommas(PhysicsUtil.Conversions.Mass.Kilogram.toTonne(kg)) .. "t"
	end
end

function Util.money(amount: number, visualizePositive: boolean?): string
	return Util.shortNumber(amount, "$", nil, false, visualizePositive)
end

function Util.numbersOnly(str: string)
	local noLetters = string.gsub(str, "%a", "")

	local noSpaces = string.gsub(noLetters, "%s", "")
	local noWeirdos = string.gsub(noSpaces, "%c", "")
	local noNull = string.gsub(noWeirdos, "%z", "")
	local savePeriods = string.gsub(noNull, "%.", "p")
	local noPunct = string.gsub(savePeriods, "%p", "")
	local addPeriods = string.gsub(noPunct, "p", ".")
	return addPeriods
end

function Util.lettersOnly(str: string): string
	return string.gsub(str, "[^%a]", "")
end

function Util.pseudoWord(len: number)
	local txt = ""
	for i = 1, len do
		local char = string.char(64 + math.random(26))
		if i == 1 then
			char = string.upper(char)
		else
			char = string.lower(char)
		end
		txt ..= char
	end
	return txt
end

function Util.pseudoPhrase(words: number, avgWordLen: number, stDev: number)
	local txt = ""
	for i = 1, words do
		local wordLen = avgWordLen + (math.random(stDev * 2) - stDev)
		txt ..= Util.pseudoWord(wordLen)
		if i ~= words then
			txt ..= " "
		end
	end
	return txt
end

function Util.censor(txt, writerId: number?, context: Enum.TextFilterContext?)
	if RunService:IsClient() then
		local censorResult: string = NetworkUtil.invokeServerAt(CENSOR_KEY, Package, txt, writerId, context)
		return censorResult
	else
		assert(typeof(writerId) == "number", "Bad user id")
		local result: TextFilterResult?
		for i = 1, 5 do
			local success, msg = pcall(function()
				local textFilterContext: Enum.TextFilterContext = context or Enum.TextFilterContext.PublicChat
				assert(textFilterContext ~= nil)
				result = TextService:FilterStringAsync(
					txt, 
					writerId, 
					textFilterContext
				) :: any
				return nil
			end)
			if success then
				break
			else
				warn(msg)
			end
			task.wait(0.5)
		end
		if result == nil then
			return string.gsub(txt, ".", "#")
		else
			local finalText
			for i = 1, 5 do
				local success, tempResult = pcall(function()
					return result:GetNonChatStringForBroadcastAsync()
				end)
				finalText = tempResult
				if success then
					break
				end
				task.wait(0.5)
			end
			if finalText then
				return finalText
			else
				return string.gsub(txt, ".", "#")
			end
		end
	end
end

-- Copyright (C) 2012 LoDC
-- https://gist.github.com/efrederickson/4080372

-- local map = {
-- 	I = 1,
-- 	V = 5,
-- 	X = 10,
-- 	L = 50,
-- 	C = 100,
-- 	D = 500,
-- 	M = 1000,
--  }
local numbers = { 1, 5, 10, 50, 100, 500, 1000 }
local chars = { "I", "V", "X", "L", "C", "D", "M" }

function Util.ToRomanNumerals(s: number)
	s = math.abs(s)
	if s == math.huge then
		error("Unable to convert infinity")
	end
	s = math.floor(s)

	local ret = ""
	for i = #numbers, 1, -1 do
		local num = numbers[i]
		while s - num >= 0 and s > 0 do
			ret = ret .. chars[i]
			s = s - num
		end
		--for j = i - 1, 1, -1 do
		for j = 1, i - 1 do
			local n2 = numbers[j]
			if s - (num - n2) >= 0 and s < num and s > 0 and num - n2 ~= n2 then
				ret = ret .. chars[j] .. chars[i]
				s = s - (num - n2)
				break
			end
		end
	end
	return ret
end

function Util.init(maid: Maid) 
	if RunService:IsServer() then
		
		NetworkUtil.onClientInvokeAt(CENSOR_KEY, Package, function(player: Player, txt: string, writerId: number?, context: Enum.TextFilterContext?)
			return Util.censor(txt, writerId, context)
		end)
	end
end

return Util
