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
local Maid = require(Packages:WaitForChild("Maid"))
-- Modules
local ModuleProvider = require(Package:WaitForChild("ModuleProvider"))

-- Types
type Maid = Maid.Maid
-- Constants
-- Variables
-- References
-- Class
export type ColumnData = {
	Name: string,
	Text: string,
	Order: number,
	Constructor: ((val: any, data: { [string]: any }, maid: Maid) -> GuiObject),
	Format: (val: any) -> string,
	Alignment: ModuleProvider.GuiAlignmentType,
	WidthWeight: number?,
}

return {}
