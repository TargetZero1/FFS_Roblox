--!strict
-- Services
local ServerStorage = game:GetService("ServerStorage")
-- Packages
-- Modules
local ReferenceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ReferenceUtil"))
-- Types
export type BreadType = {
	BaseValue: number, --The base value of the drop
	-- MultiplierEffectiveness: number, --The effectiveness of any multipliers 100% being no change.
	-- ValueEffectiveness: number, --The effectiveness of any value adding 100% being no change.
	Dough: BasePart,
	Cooked: BasePart,
	Wrapped: BasePart,
}
-- Constants
-- Variables
-- References
local DropsFolder = ServerStorage:WaitForChild("Drops")
local DoughFolder = DropsFolder:WaitForChild("Dough")
local CookedFolder = DropsFolder:WaitForChild("Cooked")
local WrappedFolder = DropsFolder:WaitForChild("Wrapped")
-- Class

return {
	--Decal to apply to wrapped breads
	BreadDecal = ReferenceUtil.getChild(DropsFolder, "BreadDecal"),
	--BillboardGUI to add to all bread that shows the worth.
	ValueGUI = ReferenceUtil.getChild(DropsFolder, "ValueBillboardGUI"),
	Order = {
		"Sourdough",
		"Tabatiere",
		"Zopf",
		"Pitta",
		"Ciabatta",
		"EpiDeBle",
		"BaguetteFlute",
		"BaguetteFicelle",
		"BaguetteDeCampagne",
		"PainComplet",
		"PainDeMie",
		"PainPolka",
		"PainAuxCereales",
		"PainAuLevain",
		"PainDeSeigleNoir",
		"PainDeCampagne",
	},
	Types = {
		["Sourdough"] = {
			--The base value of the drop
			BaseValue = 1,
			Dough = ReferenceUtil.getChild(DoughFolder, "Sourdough") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "Sourdough") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "Sourdough") :: BasePart,
		} :: BreadType,

		["Tabatiere"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "Tabatiere") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "Tabatiere") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "Tabatiere") :: BasePart,
		} :: BreadType,

		["Zopf"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "Zopf") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "Zopf") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "Zopf") :: BasePart,
		} :: BreadType,

		["Pitta"] = {
			BaseValue = 5,
			Dough = ReferenceUtil.getChild(DoughFolder, "Pitta") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "Pitta") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "Pitta") :: BasePart,
		} :: BreadType,

		["Ciabatta"] = {
			BaseValue = 1,
			Dough = ReferenceUtil.getChild(DoughFolder, "Ciabatta") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "Ciabatta") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "Ciabatta") :: BasePart,
		} :: BreadType,

		["EpiDeBle"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "EpiDeBle") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "EpiDeBle") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "EpiDeBle") :: BasePart,
		} :: BreadType,

		["BaguetteFlute"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "BaguetteFlute") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "BaguetteFlute") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "BaguetteFlute") :: BasePart,
		} :: BreadType,

		["BaguetteFicelle"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "BaguetteFicelle") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "BaguetteFicelle") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "BaguetteFicelle") :: BasePart,
		} :: BreadType,

		["BaguetteDeCampagne"] = {
			BaseValue = 5,
			Dough = ReferenceUtil.getChild(DoughFolder, "BaguetteDeCampagne") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "BaguetteDeCampagne") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "BaguetteDeCampagne") :: BasePart,
		} :: BreadType,

		--PAINs---
		["PainComplet"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "PainComplet") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "PainComplet") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "PainComplet") :: BasePart,
		} :: BreadType,

		["PainDeMie"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "PainDeMie") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "PainDeMie") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "PainDeMie") :: BasePart,
		} :: BreadType,

		["PainPolka"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "PainPolka") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "PainPolka") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "PainPolka") :: BasePart,
		} :: BreadType,

		["PainAuxCereales"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "PainAuxCereales") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "PainAuxCereales") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "PainAuxCereales") :: BasePart,
		} :: BreadType,

		["PainAuLevain"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "PainAuLevain") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "PainAuLevain") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "PainAuLevain") :: BasePart,
		} :: BreadType,

		["PainDeSeigleNoir"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "PainDeSeigleNoir") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "PainDeSeigleNoir") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "PainDeSeigleNoir") :: BasePart,
		} :: BreadType,

		["PainDeCampagne"] = {
			BaseValue = 15,
			Dough = ReferenceUtil.getChild(DoughFolder, "PainDeCampagne") :: BasePart,
			Cooked = ReferenceUtil.getChild(CookedFolder, "PainDeCampagne") :: BasePart,
			Wrapped = ReferenceUtil.getChild(WrappedFolder, "PainDeCampagne") :: BasePart,
		} :: BreadType,
	} :: { [string]: BreadType },
}
