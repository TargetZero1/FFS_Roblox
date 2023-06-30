--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local PetVisualUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetVisualUtil"))
local PetModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetModifierUtil"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))
local ChanceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ChanceUtil"))
local DataGamePassDescription = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("GamePassDescription"))
-- local LegibilityUtil = require(ReplicatedStorage.Client.LegibilityUtil)
-- local ExitButton = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ExitButton"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type CanBeState<a> = ColdFusion.CanBeState<a>
type State<a> = ColdFusion.State<a>
type ValueState<a> = ColdFusion.ValueState<a>

export type PetSaveData = {
	Id: string,
	BalanceId: string,
	Assignment: string?,
}

--constants
local BACKGROUND_COLOR = Color3.fromRGB(200, 200, 200)
local SELECTION_COLOR = Color3.fromHSV(0.55, 1, 1)
local PRIMARY_COLOR = Color3.fromRGB(255, 255, 255)
local SECONDARY_COLOR = Color3.fromRGB(150, 150, 150)
local TERTIARY_COLOR = Color3.fromRGB(50, 180, 50)
local DELETE_COLOR = Color3.fromRGB(200, 60, 60)
local MERGE_GLOW_PERIOD = 3

local PADDING_SIZE = UDim.new(0, 10)
local PET_Y_OFFSET = 2.5
local TEXT_SIZE = 21

--local functions
local function getViewport(maid: Maid, model: CanBeState<Model?>, PetData: State<PetSaveData?>, clickFn: () -> ()?, Transparency: State<number>?)
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN

	local _ON_EVENT = _fuse.ON_EVENT

	if typeof(model) == "Instance" then
		model:PivotTo(CFrame.new(0, -PET_Y_OFFSET, 0) * CFrame.Angles(0, math.rad(180), 0))
	else
		if model then
			local intModelVal = model:Get()
			if intModelVal then
				intModelVal:PivotTo(CFrame.new(0, -PET_Y_OFFSET, 0) * CFrame.Angles(0, math.rad(180), 0))
			end
		end
	end

	local camera = _new("Camera")({
		CFrame = CFrame.lookAt(Vector3.new(-4, 4, -4) * 1.2, Vector3.new(0, 0, 0)),
		FieldOfView = 50,
	})

	local viewportFrame = _new("ViewportFrame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ImageTransparency = Transparency,
		CurrentCamera = camera,
		[_CHILDREN] = {
			camera,
			_new("WorldModel")({
				[_CHILDREN] = {
					model,
				},
			}),

			_new("ImageLabel")({
				Size = UDim2.fromScale(0.2, 0.2),
				Position = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(1, 1),
				BackgroundTransparency = 0,
				BackgroundColor3 = _Computed(function(petSelectionVal: PetSaveData?): Color3
					if petSelectionVal then
						local rarityLevel = PetModifierUtil.getLevel(petSelectionVal.BalanceId)
						if rarityLevel == 1 then
							return SECONDARY_COLOR
						elseif rarityLevel == 2 then
							return Color3.fromRGB(52, 142, 64)
						elseif rarityLevel == 3 then
							return Color3.fromRGB(13, 105, 172)
						elseif rarityLevel == 4 then
							return Color3.fromRGB(123, 47, 123)
						elseif rarityLevel == 5 then
							return Color3.fromRGB(196, 40, 28)
						end
					end
					return SECONDARY_COLOR
				end, PetData),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Image = "",
				[_CHILDREN] = {
					_new("UICorner")({
						CornerRadius = UDim.new(0.5, 0),
					}),
					_new("UIStroke")({
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = _Computed(function(petSelectionVal: PetSaveData?): Color3
							if petSelectionVal then
								local metalTier = PetModifierUtil.getMetalTier(petSelectionVal.BalanceId)
								if metalTier == "Normal" then
									return Color3.fromHSV(0, 0, 0.05)
									-- return Color3.fromRGB(106, 57, 9)
								elseif metalTier == "Silver" then
									return Color3.fromRGB(174, 193, 205)
								elseif metalTier == "Gold" then
									return Color3.fromRGB(239, 184, 56)
								elseif metalTier == "Diamond" then
									return Color3.fromRGB(9, 219, 238)
								end
							end
							return SECONDARY_COLOR
						end, PetData),
						Thickness = 5,
					}),
				},
			}),
			_new("ImageLabel")({
				Size = UDim2.fromScale(0.35, 0.35),
				Position = UDim2.fromScale(0.1, 0.9),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Image = _Computed(function(petSelectionVal: PetSaveData?): string
					if petSelectionVal then
						local station = petSelectionVal.Assignment
						if station == "Kneader" then
							return DataGamePassDescription["Super Kneader"].Thumbnail
						elseif station == "Oven" then
							return DataGamePassDescription["Super Oven"].Thumbnail
						elseif station == "Wrapper" then
							return DataGamePassDescription["Super Wrapper"].Thumbnail
						end
					end
					return ""
				end, PetData),
			}),
			_new("UIPadding")({
				PaddingBottom = PADDING_SIZE,
				PaddingTop = PADDING_SIZE,
				PaddingLeft = PADDING_SIZE,
				PaddingRight = PADDING_SIZE,
			}),
		},
	})

	return _new("TextButton")({
		Size = UDim2.fromScale(0.3, 1),
		AutoButtonColor = if clickFn then true else false,
		[_CHILDREN] = {

			_new("UICorner")({}),
			viewportFrame,
			--[[_new("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 3,
				Color = Color3.fromRGB(150, 150, 150),
			}),]]
		},
		[_ON_EVENT("Activated")] = function()
			if clickFn then
				clickFn()
			end
		end,
	})
end

return function(maid: Maid, 
	PetsData: State<{ [number]: PetSaveData }>, 
	PetSelection: State<PetSaveData?>,
	MergeTarget: State<PetSaveData?>,
	OnEquip: Signal,
	OnMerge: Signal, 
	OnDelete: Signal, 
	OnSelect: Signal
)
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Computed = _fuse.Computed
	local _Value = _fuse.Value

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	local inventoryContainer = _new("Frame")({
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		[_CHILDREN] = {
			_new("UIGridLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				CellSize = UDim2.new(0.3, -8, 0.3, -8),
				CellPadding = UDim2.fromOffset(8, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			_new("UIAspectRatioConstraint")({
				AspectRatio = 1,
				DominantAxis = Enum.DominantAxis.Width,
				AspectType = Enum.AspectType.ScaleWithParentSize,
			}),
			_new("UIPadding")({
				PaddingBottom = PADDING_SIZE,
				PaddingTop = PADDING_SIZE,
				PaddingLeft = PADDING_SIZE,
				PaddingRight = PADDING_SIZE,
			}),
		}
	}) :: Frame

	local ContainerHeight = _Value(0)

	local inventoryList = _new("ScrollingFrame")({
		Name = "InventoryList",
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		CanvasSize = _Computed(function(height: number): UDim2
			return UDim2.new(0,0, PADDING_SIZE.Scale, height + PADDING_SIZE.Offset)
		end, ContainerHeight),
		Size = UDim2.fromScale(1, 0.75),
		[_CHILDREN] = {
			_new("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = PADDING_SIZE,
			}),
			inventoryContainer
		},
	})
	local inventoryOptions = _new("Frame")({
		Name = "InventoryOptions",
		Size = UDim2.fromScale(1, 0.25),
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingBottom = PADDING_SIZE,
				PaddingTop = PADDING_SIZE,
				PaddingLeft = PADDING_SIZE,
				PaddingRight = PADDING_SIZE,
			}),
			_new("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = PADDING_SIZE,
			}),
			_new("TextButton")({
				LayoutOrder = 1,
				Text = _Computed(function(mergePet: PetSaveData?, selection: PetSaveData?): string
					if mergePet then
						if selection == mergePet then
							return "CANCEL MERGE"
						elseif selection then
							if PetModifierUtil.getMergeOutcome(mergePet.BalanceId, selection.BalanceId) then
								return "COMPLETE MERGE"
							else
								return "NOT COMPATIBLE"
							end
						else
							return "SELECT PET"
						end
					else
						return "MERGE"
					end
				end, MergeTarget, PetSelection),
				TextColor3 = PRIMARY_COLOR,
				TextSize = TEXT_SIZE,
				AutoButtonColor = true,
				BackgroundColor3 = _Computed(function(petSelection: PetSaveData?, mergePet: PetSaveData?): Color3
					if mergePet then
						if petSelection == mergePet then
							return DELETE_COLOR
						elseif petSelection then
							if PetModifierUtil.getMergeOutcome(mergePet.BalanceId, petSelection.BalanceId) then
								return TERTIARY_COLOR
							else
								return SECONDARY_COLOR
							end
						else
							return TERTIARY_COLOR
						end
					else
						return if petSelection then TERTIARY_COLOR else SECONDARY_COLOR
					end
				end, PetSelection, MergeTarget):Tween(0.1),
				Size = _Computed(function(mergePet: PetSaveData?): UDim2
					if mergePet then
						return UDim2.fromScale(0.7, 0.8)
					else
						return UDim2.fromScale(0.3, 0.8)
					end
				end, MergeTarget):Tween(0.1),
				[_CHILDREN] = _new("UICorner")({}),
				[_ON_EVENT("Activated")] = function()
					OnMerge:Fire(PetSelection:Get())
				end,
			}),
			_new("TextButton")({
				LayoutOrder = 2,
				Text = "EQUIP",
				TextColor3 = PRIMARY_COLOR,
				TextSize = TEXT_SIZE,
				Visible = _Computed(function(mergePet: PetSaveData?): boolean
					return mergePet == nil
				end, MergeTarget),
				AutoButtonColor = true,
				BackgroundColor3 = _Computed(function(petSelection)
					return if petSelection then TERTIARY_COLOR else SECONDARY_COLOR
				end, PetSelection), --TERTIARY_COLOR,
				Size = UDim2.fromScale(0.3, 0.8),
				[_CHILDREN] = _new("UICorner")({}),
				[_ON_EVENT("Activated")] = function()
					OnEquip:Fire(PetSelection:Get())
				end,
			}),
			_new("TextButton")({
				LayoutOrder = 3,
				Text = "DELETE",
				Visible = _Computed(function(mergePet: PetSaveData?): boolean
					return mergePet == nil
				end, MergeTarget),
				TextColor3 = PRIMARY_COLOR,
				TextSize = TEXT_SIZE,
				AutoButtonColor = true,
				BackgroundColor3 = _Computed(function(petSelection)
					return if petSelection then DELETE_COLOR else SECONDARY_COLOR
				end, PetSelection),
				Size = UDim2.fromScale(0.3, 0.8),
				[_CHILDREN] = _new("UICorner")({}),
				[_ON_EVENT("Activated")] = function()
					OnDelete:Fire(PetSelection:Get())
				end,
			}),
		},
	})

	local out = _new("Frame")({
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.fromScale(0.75, 0.75),
		Position = UDim2.fromScale(0.5, 0.2),
		[_CHILDREN] = {
			_new("UICorner")({}),
			_new("UIAspectRatioConstraint")({
				AspectRatio = 1.2,
			}),

			_new("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = PADDING_SIZE,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			_new("UIPadding")({
				PaddingBottom = PADDING_SIZE,
				PaddingTop = PADDING_SIZE,
				PaddingLeft = PADDING_SIZE,
				PaddingRight = PADDING_SIZE,
			}),

			_new("Frame")({
				Name = "Info",
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.4, 1),
				BackgroundColor3 = BACKGROUND_COLOR,

				[_CHILDREN] = {
					_new("UICorner")({}),
					_new("UIPadding")({
						PaddingBottom = PADDING_SIZE,
						PaddingTop = PADDING_SIZE,
						PaddingRight = PADDING_SIZE,
						PaddingLeft = PADDING_SIZE,
					}),
					_new("UIListLayout")({
						FillDirection = Enum.FillDirection.Vertical,
						Padding = PADDING_SIZE,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					_mount(getViewport(
						maid,
						_Computed(function(petSelectionVal: PetSaveData?): Model?
							print(petSelectionVal, " 1")
							if petSelectionVal then
								-- local rarity = ModifierUtil.getPetRarity(petSelectionVal.BalanceId)
								-- local level = ModifierUtil.getPetLevel(petSelectionVal.BalanceId)
								print(petSelectionVal.BalanceId, " 2")
								local model = PetVisualUtil.displayPet(petSelectionVal.BalanceId)
								if model then
									model:PivotTo(CFrame.new(0, -PET_Y_OFFSET, 0) * CFrame.Angles(0, math.rad(180), 0))
								end
								return model
							end
							return nil
						end, PetSelection),
						PetSelection
					))({
						Size = UDim2.fromScale(1, 0.45),
						LayoutOrder = 2,
						Visible = _Computed(function(petSelection)
							return if petSelection then true else false
						end, PetSelection),
					}),
					_new("TextLabel")({
						Name = "PetName",
						LayoutOrder = 1,
						Visible = _Computed(function(petSelection)
							return if petSelection then true else false
						end, PetSelection),
						RichText = true,
						Text = _Computed(function(petSelectionVal: PetSaveData?)
							if petSelectionVal then
								return FormatUtil.bold(PetModifierUtil.getName(petSelectionVal.BalanceId):upper())
								-- local petClass = ModifierUtil.getPetClass(petSelectionVal.BalanceId)
								-- local petMetal = ModifierUtil.getPetMetalTier(petSelectionVal.BalanceId)
								-- local petLevel = ModifierUtil.getPetLevel(petSelectionVal.BalanceId)
								-- local text = petMetal.." "..petClass
								-- if petLevel > 1 then
								-- 	text..=" "..FormatUtil.ToRomanNumerals(petLevel)
								-- end
								-- return "<b>" .. text:upper() .. "</b>"
							else
								return ""
							end
						end, PetSelection),
						TextScaled = true,
						-- TextSize = TEXT_SIZE,
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0.08),
					}),
					_new("TextLabel")({
						Name = "PetRarity",
						LayoutOrder = 1.5,
						Visible = _Computed(function(petSelection)
							return if petSelection then true else false
						end, PetSelection),
						RichText = true,
						Text = _Computed(function(petSelectionVal: PetSaveData?)
							if petSelectionVal then
								local rarityLevel = PetModifierUtil.getLevel(petSelectionVal.BalanceId)
								return FormatUtil.bold(ChanceUtil.RarityNameList[rarityLevel]:upper())
								-- local petClass = ModifierUtil.getPetClass(petSelectionVal.BalanceId)
								-- local petMetal = ModifierUtil.getPetMetalTier(petSelectionVal.BalanceId)
								-- local petLevel = ModifierUtil.getPetLevel(petSelectionVal.BalanceId)
								-- local text = petMetal.." "..petClass
								-- if petLevel > 1 then
								-- 	text..=" "..FormatUtil.ToRomanNumerals(petLevel)
								-- end
								-- return "<b>" .. text:upper() .. "</b>"
							else
								return ""
							end
						end, PetSelection),
						TextScaled = true,
						BackgroundTransparency = 0,
						BackgroundColor3 = _Computed(function(petSelectionVal: PetSaveData?): Color3
							if petSelectionVal then
								local rarityLevel = PetModifierUtil.getLevel(petSelectionVal.BalanceId)
								if rarityLevel == 1 then
									return SECONDARY_COLOR
								elseif rarityLevel == 2 then
									return Color3.fromRGB(52, 142, 64)
								elseif rarityLevel == 3 then
									return Color3.fromRGB(13, 105, 172)
								elseif rarityLevel == 4 then
									return Color3.fromRGB(123, 47, 123)
								elseif rarityLevel == 5 then
									return Color3.fromRGB(196, 40, 28)
								end
							end
							return SECONDARY_COLOR
						end, PetSelection),
						TextColor3 = _Computed(function(petSelectionVal: PetSaveData?): Color3
							if petSelectionVal then
								local rarityLevel = PetModifierUtil.getLevel(petSelectionVal.BalanceId)
								if rarityLevel <= 2 then
									return Color3.fromHSV(0, 0, 0.05)
								elseif rarityLevel <= 5 then
									return Color3.fromHSV(0, 0, 0.95)
								end
							end
							return PRIMARY_COLOR
						end, PetSelection),
						Size = UDim2.fromScale(1, 0.08),
						[_CHILDREN] = {
							_new("UICorner")({}),
						},
					}),
					_new("TextLabel")({
						Name = "BreadMetalTier",
						LayoutOrder = 2.5,
						Visible = _Computed(function(petSelection)
							return if petSelection then true else false
						end, PetSelection),
						RichText = true,
						Size = UDim2.fromScale(1, 0.085),
						Text = _Computed(function(petSelectionVal: PetSaveData?)
							if petSelectionVal then
								local metal = PetModifierUtil.getMetalTier(petSelectionVal.BalanceId)
								return FormatUtil.bold(metal:upper())
							else
								return ""
							end
						end, PetSelection),
						BackgroundColor3 = _Computed(function(petSelectionVal: PetSaveData?): Color3
							if petSelectionVal then
								local metalTier = PetModifierUtil.getMetalTier(petSelectionVal.BalanceId)
								if metalTier == "Normal" then
									-- return Color3.fromHSV(0,0,0.05)
									return Color3.fromRGB(106, 57, 9)
								elseif metalTier == "Silver" then
									return Color3.fromRGB(174, 193, 205)
								elseif metalTier == "Gold" then
									return Color3.fromRGB(239, 184, 56)
								elseif metalTier == "Diamond" then
									return Color3.fromRGB(9, 219, 238)
								end
							end
							return SECONDARY_COLOR
						end, PetSelection),
						TextColor3 = _Computed(function(petSelectionVal: PetSaveData?): Color3
							if petSelectionVal then
								local metalTier = PetModifierUtil.getMetalTier(petSelectionVal.BalanceId)
								if metalTier == "Normal" then
									return Color3.fromHSV(0, 0, 0.95)
								elseif metalTier == "Silver" then
									return Color3.fromHSV(0, 0, 0.05)
								elseif metalTier == "Gold" then
									return Color3.fromHSV(0, 0, 0.05)
								elseif metalTier == "Diamond" then
									return Color3.fromHSV(0, 0, 0.05)
								end
							end
							return PRIMARY_COLOR
						end, PetSelection),
						TextScaled = true,
						BackgroundTransparency = 0,
						[_CHILDREN] = {
							_new("UICorner")({}),
						},
					}),
					_new("TextLabel")({
						Name = "BreadPerMinuteText",
						LayoutOrder = 3,
						Text = _Computed(function(petSelectionVal: PetSaveData?)
							if petSelectionVal then
								local breadPerMinute = PetModifierUtil.getBreadPerMinute(petSelectionVal.BalanceId)
								return "Bread per Minute: " .. FormatUtil.bold(tostring(breadPerMinute))
							else
								return ""
							end
						end, PetSelection),
						Size = UDim2.fromScale(1, 0.1),
						Visible = _Computed(function(petSelection)
							return if petSelection then true else false
						end, PetSelection),
						BackgroundTransparency = 0,
						BackgroundColor3 = SECONDARY_COLOR,
						RichText = true,
						TextColor3 = PRIMARY_COLOR,
						TextScaled = true,
						[_CHILDREN] = {
							_new("UICorner")({}),
						},
					}),
					_new("TextLabel")({
						Name = "Assignment",
						LayoutOrder = 4,
						Visible = _Computed(function(petSelection)
							return if petSelection then true else false
						end, PetSelection),
						BackgroundTransparency = 0,
						BackgroundColor3 = SECONDARY_COLOR,
						RichText = true,
						Size = UDim2.fromScale(1, 0.1),
						Text = _Computed(function(petSelectionVal: PetSaveData?)
							if petSelectionVal and petSelectionVal.Assignment then
								return "Station: " .. FormatUtil.bold(tostring(petSelectionVal.Assignment:upper()))
							else
								return "Station: " .. FormatUtil.bold("NONE")
							end
						end, PetSelection),
						TextColor3 = PRIMARY_COLOR,
						TextScaled = true,
						[_CHILDREN] = {
							_new("UICorner")({}),
						},
					}),
				},
			}),

			_new("Frame")({
				Name = "Inventory",
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.58, 1),
				--BackgroundColor3 = BACKGROUND_COLOR,
				[_CHILDREN] = {
					_new("UIListLayout")({
						FillDirection = Enum.FillDirection.Vertical,
						Padding = PADDING_SIZE,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					inventoryList,
					inventoryOptions,
				},
			}),
		},
	})

	local MergeTargetColor = _Value(Color3.fromHSV(0,1,1))

	PetsData:ForPairs(function(k, petData: PetSaveData, pairMaid: Maid)
		local pairFuse = ColdFusion.fuse(pairMaid)
		local petState: State<PetSaveData?> = pairFuse.Value(petData) :: any
		local petButton = pairMaid:GiveTask(_mount(getViewport(
			pairMaid, 
			PetVisualUtil.displayPet(petData.BalanceId), 
			petState, 
			function()
				OnSelect:Fire(petData)
			end,
			_Computed(function(selected: PetSaveData?, target: PetSaveData?): number
				if target then 
					if PetModifierUtil.getMergeOutcome(target.BalanceId, petData.BalanceId) then
						return 0
					else
						return 0.8
					end
				else
					return 0
				end
			end, PetSelection, MergeTarget):Tween(0.1)
		))({
			LayoutOrder = if petData.Assignment then 1 else 2,
			BackgroundColor3 = _Computed(function(selected: PetSaveData?, target: PetSaveData?, color: Color3)
				if target == petData then 
					return color 
				elseif selected == petData then
					return SELECTION_COLOR
				else
					return PRIMARY_COLOR
				end
			end, PetSelection, MergeTarget, MergeTargetColor):Tween(0.1),
			[_CHILDREN] = {
				_new("UIStroke")({
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = _Computed(function(target: PetSaveData?, color: Color3): Color3
						if target == petData then 
							return color 
						else 
							return TERTIARY_COLOR
						end
					end, MergeTarget, MergeTargetColor):Tween(0.1),
					Thickness = _Computed(function(target: PetSaveData?): number
						if petData.Assignment or target == petData then 
							return 5 
						else 
							return 0
						end
					end, MergeTarget),
				}),
			},
		}))
		petButton.Parent = inventoryContainer
		return k, petData
	end)

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		ContainerHeight:Set(inventoryContainer.AbsoluteSize.Y)
		MergeTargetColor:Set(Color3.fromHSV((tick()%MERGE_GLOW_PERIOD)/MERGE_GLOW_PERIOD, 1, 1))
	end))

	--_Computed(function(petSelectionData: PetSaveData?)
	--	return nil
	--end, PetSelection)

	return out
end
