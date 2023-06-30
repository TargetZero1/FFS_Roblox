--!strict
-- Services
-- Packages
local DataTableModule = script.Parent
assert(DataTableModule)
local LayoutModule = DataTableModule.Parent
assert(LayoutModule)
local Package = LayoutModule.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
-- Modules
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))
local PseudoEnum = ModuleProvider.PseudoEnum

-- Types
-- Constants
-- Variables
-- References
-- Class
local Util = {}

function Util.getAlignment(alignment: ModuleProvider.GuiAlignmentType): (Enum.HorizontalAlignment, Enum.VerticalAlignment)
	local horizontalAlignment: Enum.HorizontalAlignment
	local verticalAlignment: Enum.VerticalAlignment

	if alignment == PseudoEnum.GuiAlignmentType.TopLeft then
		horizontalAlignment = Enum.HorizontalAlignment.Left
		verticalAlignment = Enum.VerticalAlignment.Top
	elseif alignment == PseudoEnum.GuiAlignmentType.Top then
		horizontalAlignment = Enum.HorizontalAlignment.Center
		verticalAlignment = Enum.VerticalAlignment.Top
	elseif alignment == PseudoEnum.GuiAlignmentType.TopRight then
		horizontalAlignment = Enum.HorizontalAlignment.Right
		verticalAlignment = Enum.VerticalAlignment.Top
	elseif alignment == PseudoEnum.GuiAlignmentType.Left then
		horizontalAlignment = Enum.HorizontalAlignment.Left
		verticalAlignment = Enum.VerticalAlignment.Center
	elseif alignment == PseudoEnum.GuiAlignmentType.Center then
		horizontalAlignment = Enum.HorizontalAlignment.Center
		verticalAlignment = Enum.VerticalAlignment.Center
	elseif alignment == PseudoEnum.GuiAlignmentType.Right then
		horizontalAlignment = Enum.HorizontalAlignment.Right
		verticalAlignment = Enum.VerticalAlignment.Center
	elseif alignment == PseudoEnum.GuiAlignmentType.BottomLeft then
		horizontalAlignment = Enum.HorizontalAlignment.Left
		verticalAlignment = Enum.VerticalAlignment.Bottom
	elseif alignment == PseudoEnum.GuiAlignmentType.Bottom then
		horizontalAlignment = Enum.HorizontalAlignment.Center
		verticalAlignment = Enum.VerticalAlignment.Bottom
	elseif alignment == PseudoEnum.GuiAlignmentType.BottomRight then
		horizontalAlignment = Enum.HorizontalAlignment.Right
		verticalAlignment = Enum.VerticalAlignment.Bottom
	end
	return horizontalAlignment, verticalAlignment
end

function Util.getTextAlignment(alignment: ModuleProvider.GuiAlignmentType): (Enum.TextXAlignment, Enum.TextYAlignment)
	local textXAlignment: Enum.TextXAlignment
	local textYAlignment: Enum.TextYAlignment

	if alignment == PseudoEnum.GuiAlignmentType.TopLeft then
		textXAlignment = Enum.TextXAlignment.Left
		textYAlignment = Enum.TextYAlignment.Top
	elseif alignment == PseudoEnum.GuiAlignmentType.Top then
		textXAlignment = Enum.TextXAlignment.Center
		textYAlignment = Enum.TextYAlignment.Top
	elseif alignment == PseudoEnum.GuiAlignmentType.TopRight then
		textXAlignment = Enum.TextXAlignment.Right
		textYAlignment = Enum.TextYAlignment.Top
	elseif alignment == PseudoEnum.GuiAlignmentType.Left then
		textXAlignment = Enum.TextXAlignment.Left
		textYAlignment = Enum.TextYAlignment.Center
	elseif alignment == PseudoEnum.GuiAlignmentType.Center then
		textXAlignment = Enum.TextXAlignment.Center
		textYAlignment = Enum.TextYAlignment.Center
	elseif alignment == PseudoEnum.GuiAlignmentType.Right then
		textXAlignment = Enum.TextXAlignment.Right
		textYAlignment = Enum.TextYAlignment.Center
	elseif alignment == PseudoEnum.GuiAlignmentType.BottomLeft then
		textXAlignment = Enum.TextXAlignment.Left
		textYAlignment = Enum.TextYAlignment.Bottom
	elseif alignment == PseudoEnum.GuiAlignmentType.Bottom then
		textXAlignment = Enum.TextXAlignment.Center
		textYAlignment = Enum.TextYAlignment.Bottom
	elseif alignment == PseudoEnum.GuiAlignmentType.BottomRight then
		textXAlignment = Enum.TextXAlignment.Right
		textYAlignment = Enum.TextYAlignment.Bottom
	end
	return textXAlignment, textYAlignment
end

return Util
