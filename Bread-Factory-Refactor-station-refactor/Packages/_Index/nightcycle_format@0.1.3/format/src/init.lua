local module = {}
local emojiDictionary = require(script:WaitForChild("Emoji"))
local String = require(script.Parent:WaitForChild("string"))

-- symbols
local italics = {}
local bold = {}
local bolditalics = {}
local underline = {}
local strikethrough = {}

return function(str)
	-- print("Str", str)
	str = String.list(str)
	-- print("List", str)
	local function replacePairs(full, pattern, startRep, closeRep)
		-- print("Replace", full, pattern)
		local firstIndex = String.find(full, pattern)
		if not firstIndex then return full end

		local secondIndex = String.find(full, pattern, firstIndex + 1)
		if not secondIndex then return full end

		full = String.gsub(full, pattern, startRep, 1)
		-- print("C1", full)
		full = String.gsub(full, pattern, closeRep, 1)
		-- print("C2", full)
		if String.find(full, pattern) then
			-- print("Recurse")
			return replacePairs(full, pattern, startRep, closeRep)
		else
			-- print("Return")
			return full
		end
	end
	str = String.gsub(str, String.list("***"), {bolditalics})
	str = replacePairs(str, {bolditalics}, {"<b><i>"}, {"</i></b>"})
	
	str = String.gsub(str, String.list("**"), {bold})
	str = replacePairs(str, {bold}, {"<b>"}, {"</b>"})

	str = String.gsub(str, String.list("*"), {italics})
	str = replacePairs(str, {italics}, {"<i>"}, {"</i>"})

	str = String.gsub(str, String.list("__"), {underline})
	str = replacePairs(str, {underline}, {"<u>"}, {"</u>"})

	str = String.gsub(str, String.list("~~"), {strikethrough})
	str = replacePairs(str, {strikethrough}, {"<s>"}, {"</s>"})

	-- if String.find(str, ":") then
	-- 	for key, result in pairs(emojiDictionary) do
	-- 		str = String.gsub(str, String.list(":"..key..":"), String.list(result))
	-- 	end
	-- end
	local result = String.bake(str)
	-- print("Result", result)
	return result
end