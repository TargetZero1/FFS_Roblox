--strict
-- this script was generated by nightcycle/pseudo-enum, do not manually edit


export type ContrastStandardType = string

local ContrastStandardTypeList = {"Default","LargeText","Incidental","Logotype",}

export type GuiAlignmentType = string

local GuiAlignmentTypeList = {"Center","Left","Right","Top","Bottom","TopLeft","TopRight","BottomLeft","BottomRight",}

export type GuiColorPalette = string

local GuiColorPaletteList = {"Primary1","Primary2","Primary3","Primary4","Primary5","Primary6","Secondary1","Secondary2","Secondary3","Secondary4","Secondary5","Secondary6","Tertiary1","Tertiary2","Tertiary3","Tertiary4","Tertiary5","Tertiary6","Surface1","Surface2","Surface3","Surface4","Surface5","Surface6","Warning","Error","Loss1","Loss2","Loss3","Loss4","Loss5","Loss6","Gain1","Gain2","Gain3","Gain4","Gain5","Gain6","Dark1","Dark2","Dark3","Dark4","Dark5","Dark6","Light1","Light2","Light3","Light4","Light5","Light6",}

export type GuiDensityModifier = string

local GuiDensityModifierList = {"Default","High","Low",}

export type GuiThemeType = string

local GuiThemeTypeList = {"Dark","Light",}

export type GuiTypography = string

local GuiTypographyList = {"Overline","Caption","Body2","Body1","Subtitle2","Subtitle1","Button","Headline6","Headline5","Headline4","Headline3","Headline2","Headline1",}

export type GuiCategoryType = string

local GuiCategoryTypeList = {"Background","Panel","Card","Frame","Item","Button","Label","Bar","Toggle",}
export type EnumName = string
return {
	getEnumItems = function(enumName: EnumName): {[number]: string}
		if enumName == "ContrastStandardType" then
			return table.clone(ContrastStandardTypeList)
		elseif enumName == "GuiAlignmentType" then
			return table.clone(GuiAlignmentTypeList)
		elseif enumName == "GuiColorPalette" then
			return table.clone(GuiColorPaletteList)
		elseif enumName == "GuiDensityModifier" then
			return table.clone(GuiDensityModifierList)
		elseif enumName == "GuiThemeType" then
			return table.clone(GuiThemeTypeList)
		elseif enumName == "GuiTypography" then
			return table.clone(GuiTypographyList)
		elseif enumName == "GuiCategoryType" then
			return table.clone(GuiCategoryTypeList)
		end
		error("bad enum name: "..tostring(enumName))
	end,
	getEnumItemFromValue = function(enumName: EnumName, value: number): string
		if enumName == "ContrastStandardType" then
			if ContrastStandardTypeList[value] then return ContrastStandardTypeList[value] else error("no enum item of value "..tostring(value).." in enum "..tostring(enumName)) end
		elseif enumName == "GuiAlignmentType" then
			if GuiAlignmentTypeList[value] then return GuiAlignmentTypeList[value] else error("no enum item of value "..tostring(value).." in enum "..tostring(enumName)) end
		elseif enumName == "GuiColorPalette" then
			if GuiColorPaletteList[value] then return GuiColorPaletteList[value] else error("no enum item of value "..tostring(value).." in enum "..tostring(enumName)) end
		elseif enumName == "GuiDensityModifier" then
			if GuiDensityModifierList[value] then return GuiDensityModifierList[value] else error("no enum item of value "..tostring(value).." in enum "..tostring(enumName)) end
		elseif enumName == "GuiThemeType" then
			if GuiThemeTypeList[value] then return GuiThemeTypeList[value] else error("no enum item of value "..tostring(value).." in enum "..tostring(enumName)) end
		elseif enumName == "GuiTypography" then
			if GuiTypographyList[value] then return GuiTypographyList[value] else error("no enum item of value "..tostring(value).." in enum "..tostring(enumName)) end
		elseif enumName == "GuiCategoryType" then
			if GuiCategoryTypeList[value] then return GuiCategoryTypeList[value] else error("no enum item of value "..tostring(value).." in enum "..tostring(enumName)) end
		end
		error("bad enum name: "..tostring(enumName))
	end,

getValueFromEnumItem = function(enumName: EnumName, enumItem: string): number
		if enumName == "ContrastStandardType" then
			local index = table.find(ContrastStandardTypeList, enumItem)
			if index then
				assert(index)
				return index
			else
				error("no enumItem "..enumItem.." in ContrastStandardType")
			end
		elseif enumName == "GuiAlignmentType" then
			local index = table.find(GuiAlignmentTypeList, enumItem)
			if index then
				assert(index)
				return index
			else
				error("no enumItem "..enumItem.." in GuiAlignmentType")
			end
		elseif enumName == "GuiColorPalette" then
			local index = table.find(GuiColorPaletteList, enumItem)
			if index then
				assert(index)
				return index
			else
				error("no enumItem "..enumItem.." in GuiColorPalette")
			end
		elseif enumName == "GuiDensityModifier" then
			local index = table.find(GuiDensityModifierList, enumItem)
			if index then
				assert(index)
				return index
			else
				error("no enumItem "..enumItem.." in GuiDensityModifier")
			end
		elseif enumName == "GuiThemeType" then
			local index = table.find(GuiThemeTypeList, enumItem)
			if index then
				assert(index)
				return index
			else
				error("no enumItem "..enumItem.." in GuiThemeType")
			end
		elseif enumName == "GuiTypography" then
			local index = table.find(GuiTypographyList, enumItem)
			if index then
				assert(index)
				return index
			else
				error("no enumItem "..enumItem.." in GuiTypography")
			end
		elseif enumName == "GuiCategoryType" then
			local index = table.find(GuiCategoryTypeList, enumItem)
			if index then
				assert(index)
				return index
			else
				error("no enumItem "..enumItem.." in GuiCategoryType")
			end
		end
		error("bad enum name: "..tostring(enumName))
	end,
ContrastStandardType = {
	["Default"] = "Default",
	["LargeText"] = "LargeText",
	["Incidental"] = "Incidental",
	["Logotype"] = "Logotype",
},
GuiAlignmentType = {
	["Center"] = "Center",
	["Left"] = "Left",
	["Right"] = "Right",
	["Top"] = "Top",
	["Bottom"] = "Bottom",
	["TopLeft"] = "TopLeft",
	["TopRight"] = "TopRight",
	["BottomLeft"] = "BottomLeft",
	["BottomRight"] = "BottomRight",
},
GuiColorPalette = {
	["Primary1"] = "Primary1",
	["Primary2"] = "Primary2",
	["Primary3"] = "Primary3",
	["Primary4"] = "Primary4",
	["Primary5"] = "Primary5",
	["Primary6"] = "Primary6",
	["Secondary1"] = "Secondary1",
	["Secondary2"] = "Secondary2",
	["Secondary3"] = "Secondary3",
	["Secondary4"] = "Secondary4",
	["Secondary5"] = "Secondary5",
	["Secondary6"] = "Secondary6",
	["Tertiary1"] = "Tertiary1",
	["Tertiary2"] = "Tertiary2",
	["Tertiary3"] = "Tertiary3",
	["Tertiary4"] = "Tertiary4",
	["Tertiary5"] = "Tertiary5",
	["Tertiary6"] = "Tertiary6",
	["Surface1"] = "Surface1",
	["Surface2"] = "Surface2",
	["Surface3"] = "Surface3",
	["Surface4"] = "Surface4",
	["Surface5"] = "Surface5",
	["Surface6"] = "Surface6",
	["Warning"] = "Warning",
	["Error"] = "Error",
	["Loss1"] = "Loss1",
	["Loss2"] = "Loss2",
	["Loss3"] = "Loss3",
	["Loss4"] = "Loss4",
	["Loss5"] = "Loss5",
	["Loss6"] = "Loss6",
	["Gain1"] = "Gain1",
	["Gain2"] = "Gain2",
	["Gain3"] = "Gain3",
	["Gain4"] = "Gain4",
	["Gain5"] = "Gain5",
	["Gain6"] = "Gain6",
	["Dark1"] = "Dark1",
	["Dark2"] = "Dark2",
	["Dark3"] = "Dark3",
	["Dark4"] = "Dark4",
	["Dark5"] = "Dark5",
	["Dark6"] = "Dark6",
	["Light1"] = "Light1",
	["Light2"] = "Light2",
	["Light3"] = "Light3",
	["Light4"] = "Light4",
	["Light5"] = "Light5",
	["Light6"] = "Light6",
},
GuiDensityModifier = {
	["Default"] = "Default",
	["High"] = "High",
	["Low"] = "Low",
},
GuiThemeType = {
	["Dark"] = "Dark",
	["Light"] = "Light",
},
GuiTypography = {
	["Overline"] = "Overline",
	["Caption"] = "Caption",
	["Body2"] = "Body2",
	["Body1"] = "Body1",
	["Subtitle2"] = "Subtitle2",
	["Subtitle1"] = "Subtitle1",
	["Button"] = "Button",
	["Headline6"] = "Headline6",
	["Headline5"] = "Headline5",
	["Headline4"] = "Headline4",
	["Headline3"] = "Headline3",
	["Headline2"] = "Headline2",
	["Headline1"] = "Headline1",
},
GuiCategoryType = {
	["Background"] = "Background",
	["Panel"] = "Panel",
	["Card"] = "Card",
	["Frame"] = "Frame",
	["Item"] = "Item",
	["Button"] = "Button",
	["Label"] = "Label",
	["Bar"] = "Bar",
	["Toggle"] = "Toggle",
},
}