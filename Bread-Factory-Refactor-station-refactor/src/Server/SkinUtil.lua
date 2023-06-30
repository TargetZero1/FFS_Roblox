--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
-- Packages
-- Modules
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))

-- Types
-- Constants
local COMPONENT_SKIN_TAG = "ComponentSkin"
local COMPONENT_COLLISION_GROUP_NAME = "Component"

-- Variables
-- References
local Assets = ReplicatedStorage:WaitForChild("Assets")
local ComponentsByLevel = Assets:WaitForChild("ComponentsByLevel")

-- Private function
function getSkinTemplateFolder(category: string): Folder
	local folder = ComponentsByLevel:WaitForChild(category, 5) :: Folder?
	assert(folder, "no folder exists for category: " .. tostring(category))
	return folder
end

function getSkinTemplate(category: string, index: number): Instance
	local folder = getSkinTemplateFolder(category)
	local inst = folder:WaitForChild(tostring(index), 5)
	assert(inst, "no asset at index " .. tostring(category) .. "->" .. tostring(index))

	CollectionService:AddTag(inst, COMPONENT_SKIN_TAG)

	return inst :: BasePart | Model
end

function getSkinName(category: string, index: number): string
	return category .. "Skin" .. tostring(index)
end

function getSkins(component: Instance): { [number]: Instance }
	local skins: { [number]: Instance } = {}
	for i, desc in ipairs(component:GetDescendants()) do
		if CollectionService:HasTag(desc, COMPONENT_SKIN_TAG) then
			if desc:IsA("Model") or desc:IsA("BasePart") then
				table.insert(skins, desc)
			end
		end
	end
	return skins
end

function getSkinCFrame(component: Instance, skinName: string): CFrame?
	for i, skin in ipairs(getSkins(component)) do
		if FormatUtil.lettersOnly(skin.Name) == FormatUtil.lettersOnly(skinName) then
			if skin:IsA("BasePart") then
				return skin:GetPivot()
			elseif skin:IsA("Model") then
				return skin:GetPivot()
			end
		end
	end
	return nil
end

function clearSkins(component: Instance)
	local skins = getSkins(component)
	for i, skin in ipairs(skins) do
		skin:Destroy()
	end
end

function getSkinCount(category: string): number
	local folder = getSkinTemplateFolder(category)
	return #folder:GetChildren()
end

function getSkinIndex(modifierId: string): number
	local level = StationModifierUtil.getLevel(modifierId)
	local maxLevel = StationModifierUtil.getPropertyMaxLevel(modifierId)
	local progress = level / maxLevel
	local skinCount = getSkinCount(StationModifierUtil.getCategory(modifierId))
	return math.ceil(progress * skinCount)
end

function getIfSkinAlreadyExists(component: Instance, category: string, index: number)
	local instName = getSkinName(category, index)
	for i, skin in ipairs(getSkins(component)) do
		if skin.Name == instName then
			return true
		end
	end
	return false
end

-- Class
local Util = {}

function Util.get(component: Instance, modifierId: string): (BasePart | Model)?
	local index = getSkinIndex(modifierId)
	local category = StationModifierUtil.getCategory(modifierId)
	local skinName = getSkinName(category, index)
	for i, skin in ipairs(getSkins(component)) do
		print(skin.Name .. " vs " .. skinName)
		if FormatUtil.lettersOnly(skin.Name) == FormatUtil.lettersOnly(skinName) then
			return skin :: BasePart | Model
		end
	end
	return nil
end

function Util.set(component: Instance, modifierId: string, force: boolean): ()
	local index = getSkinIndex(modifierId)
	local category = StationModifierUtil.getCategory(modifierId)

	if not force and getIfSkinAlreadyExists(component, category, index) then
		return
	end

	local skinName = getSkinName(category, index)
	local cf = getSkinCFrame(component, skinName)
	assert(cf, "no cframe found from the previous skin: " .. tostring(skinName) .. " for component " .. component:GetFullName())

	clearSkins(component)

	local skin = getSkinTemplate(category, index):Clone()
	skin.Name = skinName
	if skin:IsA("Model") then
		skin:PivotTo(cf)
		for i, inst in ipairs(skin:GetDescendants()) do
			if inst:IsA("BasePart") then
				inst.Anchored = true
				inst.CanCollide = true
				inst.CollisionGroup = COMPONENT_COLLISION_GROUP_NAME
			end
		end
	elseif skin:IsA("BasePart") then
		skin:PivotTo(cf)
		skin.CollisionGroup = COMPONENT_COLLISION_GROUP_NAME
		skin.CanCollide = true
		skin.Anchored = true
	else
		error("Asset " .. tostring(skin.Name) .. " isn't Model or BasePart, class is " .. tostring(skin.ClassName))
	end

	skin.Parent = component
end

return Util
