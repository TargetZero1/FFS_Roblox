--!strict
local TextService = game:GetService("TextService")
local Package = script.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
type Maid = Maid.Maid

return function(coreGui: Frame)
	local maid: Maid.Maid = Maid.new()
	task.spawn(function()
		local fontRegistry: {[Font]: {[number]: number}} = {}
		local function getTextSize(font: Font, size: number)
			size = math.round(size)
			if not fontRegistry[font] then
				fontRegistry[font] = {}
			end
			if fontRegistry[font][size] then
				return fontRegistry[font][size]
			else
				local params = Instance.new("GetTextBoundsParams")
				params.Text = "hello world!"
				params.Font = font
				params.Size = size
				params.Width = math.huge
		
				local textBounds = TextService:GetTextBoundsAsync(params)
				local textHeight = textBounds.Y
				fontRegistry[font][size] = textHeight
			end
			assert(fontRegistry[font][size])
			return fontRegistry[font][size]
		end
		for j, enumItem in ipairs(Enum.Font:GetEnumItems()) do
			if enumItem ~= Enum.Font.Unknown then
				local font = Font.fromEnum(enumItem)
				for i=8, 100 do
					getTextSize(font, i)
				end
			end
		end
		print(fontRegistry)
	end)

	return function()
		maid:Destroy()
	end
end
