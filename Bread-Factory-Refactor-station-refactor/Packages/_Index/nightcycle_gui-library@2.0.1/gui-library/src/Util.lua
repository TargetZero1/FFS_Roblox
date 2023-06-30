--!strict
-- Services
local SoundService = game:GetService("SoundService")
-- Packages
local Package = script.Parent
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
local UISounds = Package:WaitForChild("UI") :: Folder
local TapSounds = UISounds:WaitForChild("Tap") :: Folder
local LockSounds = UISounds:WaitForChild("Lock") :: Folder
local CLICK_SOUND = TapSounds:WaitForChild("A") :: Sound
local LOCK_SOUND = LockSounds:WaitForChild("A") :: Sound
local UNLOCK_SOUND = LockSounds:WaitForChild("B") :: Sound
-- Class
local Util = {}

function Util.playClickSound(): nil
	SoundService:PlayLocalSound(CLICK_SOUND)
	return nil
end

function Util.playLockSound(): nil
	SoundService:PlayLocalSound(LOCK_SOUND)
	return nil
end

function Util.playUnlockSound(): nil
	SoundService:PlayLocalSound(UNLOCK_SOUND)
	return nil
end

function Util.getStatePalettes(palette: ModuleProvider.GuiColorPalette): (ModuleProvider.GuiColorPalette, ModuleProvider.GuiColorPalette)
	local hoverPalette: ModuleProvider.GuiColorPalette
	local selectPalette: ModuleProvider.GuiColorPalette

	local base = string.gsub(palette, "%d", "")
	local num: number? = tonumber(string.gsub(palette, "%a", ""))

	if num then
		if num == 6 then
			hoverPalette = PseudoEnum.GuiColorPalette[base .. tostring(num - 1)]
			selectPalette = PseudoEnum.GuiColorPalette[base .. tostring(num - 2)]
		elseif num == 1 then
			hoverPalette = PseudoEnum.GuiColorPalette[base .. tostring(num + 1)]
			selectPalette = PseudoEnum.GuiColorPalette[base .. tostring(num + 2)]
		else
			hoverPalette = PseudoEnum.GuiColorPalette[base .. tostring(num + 1)]
			selectPalette = PseudoEnum.GuiColorPalette[base .. tostring(num - 1)]
		end
	else
		hoverPalette = palette
		selectPalette = palette
	end

	return hoverPalette, selectPalette
end

return Util
