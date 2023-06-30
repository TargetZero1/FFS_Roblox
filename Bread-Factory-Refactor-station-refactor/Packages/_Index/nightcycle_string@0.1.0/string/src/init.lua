local module = {}


--add emoji
local blocks = {}
local emojiKeys = {}
local startIndex = nil

-- Symbols
local null = {}

function module.bake(full)
	full = module.clean(full)
	local str = ""
	for i=1, module.len(full) do
		str ..= tostring(full[i])
	end
	return str
end

function module.list(str: string) --converts str to list
	local characters = {}
	local length = string.len(str)
	for i=1, length do
		table.insert(characters, string.sub(str, i, i))
	end
	return characters
end

function module.sub(pattern, start, finish)
	finish = finish or module.len(pattern)
	local list = {}
	for i=start, finish do
		table.insert(list, pattern[i])
	end
	return list
end

function module.len(pattern)
	local maxIndex = 0
	for k, v in pairs(pattern) do
		maxIndex = math.max(k)
	end
	return maxIndex
end

function module.eq(p1: {[number]: any}, p2: {[number]: any})
	-- print("Start eq", p1, p2)
	local length1 = module.len(p1)
	-- print("L1 complete")
	local length2 = module.len(p2)
	-- print("Len1", length1, "Len2", length2)
	if length1 ~= length2 then return false end
	for i=1, length1 do
		-- print("Comp", p1[i], p2[i])
		if p1[i] ~= p2[i] then
			-- print("Exit")
			return false
		end
	end
	-- print("True")
	return true
end

function module.copy(pattern)
	local list = {}
	for i=1, module.len(pattern) do
		list[i] = pattern[i]
	end
	return list
end

function module.find(fullPattern: {[number]: any}, searchPattern: {[number]: any}, start: number | nil)
	start = start or 1
	-- print("Start", start)
	local searchPatternLen = module.len(searchPattern)
	-- print("Len", searchPatternLen)
	for i=start, module.len(fullPattern) do
		local char = fullPattern[i]
		-- print(i, "Char", char, "vs", searchPattern[1])
		if searchPattern[1] == char then
			-- print("In", i, i+searchPatternLen-1)
			local extraction = module.sub(fullPattern, i, i+searchPatternLen-1)
			-- print("Extraction", extraction)
			if module.eq(extraction, searchPattern) then
				-- print("Return", i)
				return i
			end
		end
	end
end

function module.null()
	return null
end

function module.clean(pattern)
	local list = {}
	local len = module.len(pattern)
	-- print("Length", len)
	for i=1, len do
		-- print(i, pattern[i], pattern[i] ~= nil, pattern[i] ~= null)
		if pattern[i] ~= nil and pattern[i] ~= null then
			table.insert(list, pattern[i])
		end
	end
	-- print("Result", list)
	return list
end

function module.concat(p1, p2)
	local result = module.copy(p1)
	for i=1, module.len(p2) do
		table.insert(result, p2[i])
	end
	-- print("RESULT", result)
	return result
end

function module.split(fullPattern, searchPattern)
	local result = {}
	local fullLength = module.len(fullPattern)
	local searchLength = module.len(searchPattern)
	local index = 1
	-- print("Full len", fullLength)
	-- print("Search len", searchLength)
	repeat
		-- print("I", index)
		local nextIndex = module.find(fullPattern, searchPattern, index)
		if nextIndex then
			-- print("A")
			table.insert(result, module.sub(fullPattern, index, nextIndex-1))
			index = nextIndex+searchLength
			-- table.insert(result, searchPattern)
		else
			-- print("B")
			table.insert(result, module.sub(fullPattern, index))
			break
		end
	until index > fullLength
	-- print("Result", result)
	return result
end

function module.gsub(fullPattern, searchPattern:  {[number]: any}, replacement: {[number]: any}, number: number | nil)
	local fullLength = module.len(fullPattern)
	local searchLength = module.len(searchPattern)
	local result = module.copy(fullPattern)
	-- print("Got copy", result)

	local i = module.find(fullPattern, searchPattern)
	-- print("Retrieved i")
	-- print("Full", fullPattern, searchPattern)
	local isEq1 = module.eq(searchPattern, replacement)
	local nilIndex = i == nil
	local checkNumb = (number and number <= 0)
	-- print("Results", isEq1, nilIndex, checkNumb)
	if nilIndex or isEq1 or checkNumb then
		-- print("Return early")
		return result
	end
	-- print("Survived if")
	if number then number -= 1 end
	-- print("Subtract number")
	local j = i + searchLength
	local sub1 = module.sub(
		fullPattern,
		1,
		i-1
	)
	-- print("Sub1", sub1)
	local con1 = module.concat(sub1,replacement)
	-- print("Con1", con1)
	local sub2 = module.sub(fullPattern, j, fullLength)
	-- print("Sub2", sub2)
	local con2 = module.concat(
		con1,
		sub2
	)
	-- print("Con2", con2)
	return module.gsub(con2, searchPattern, replacement, number)
end

--asterisk formatting
--underline formatting

return module