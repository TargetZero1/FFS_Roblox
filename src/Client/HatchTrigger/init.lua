--!strict
-- Services
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

-- Packages
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local TableUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("TableUtil"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))

-- Modules
local CursorTracer = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("CursorTracer"))
local PetModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetModifierUtil"))
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))
local PetVisualUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetVisualUtil"))
local HatchProcess = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("HatchProcess"))

-- Types
type List<T> = TableUtil.List<T>
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type PetClass = PetModifierUtil.PetClass
type Signal = Signal.Signal
type CursorTracer = CursorTracer.CursorTracer
-- Constants
local SCALE = 1.5
local MAX_VIEW_DISTANCE = 40
local MIN_VIEW_DISTANCE = MAX_VIEW_DISTANCE - 10
local EGG_HATCHER_TAG = "EggHatcher"
local PET_METAL_NAME: PetModifierUtil.PetMetal = "Normal"
local PADDING_SIZE = UDim.new(0, 15)
local HATCH_PET = "HatchPet"
local MANUAL_HATCH_EFFECT_TRIGGER = "HatchEffectManualTrigger"

-- Variables
local HatchEnabled = true
-- References
-- Private functions
local function getViewport(maid: Maid, petBalanceId: string, Transparency: State<number>): ViewportFrame
	
	
	local model = maid:GiveTask(PetVisualUtil.displayPet(petBalanceId))
	local primPart = model:WaitForChild("RootPart", 10) :: BasePart?
	assert(primPart, "'primPart' assertion failed")
	model.PrimaryPart = primPart
	assert(primPart, "assertion failed")
	model.WorldPivot = primPart:GetPivot()-- CFrame.fromMatrix(cf.Position+Vector3.new(0,size.Y/2,0), pivCF.XVector, pivCF.YVector, pivCF.ZVector)

	model:PivotTo(CFrame.new(0, 0, 0))
	maid:GiveTask(model)
	
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN

	local _ON_EVENT = _fuse.ON_EVENT

	local camera = _new("Camera")({
		FieldOfView = 35,
		CFrame = CFrame.lookAt(Vector3.new(-4, 4, -4)*1.5, Vector3.new(0,1, 0)),
	})

	return _new("ViewportFrame")({
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
		},
	}) :: ViewportFrame
end

function mainFrame(
	maid: Maid,
	position: Vector3,
	petClass: PetClass,
	color: Color3,
	IsHovering: State<boolean>,
	IsClicked: State<boolean>,
	Transparency: State<number>
): (Frame, TextButton)
	local _fuse = ColdFusion.fuse(maid)
	
	local _new = _fuse.new
	local _import = _fuse.import
	
	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN

	local h,s,v = color:ToHSV()
	local backgroundColor = Color3.fromHSV(h,s,v^1.5)
	local gridBackgroundColor = Color3.fromHSV(h,s^2,v^0.5)
	local buttonColor = Color3.fromHSV(h,1,1)

	local petContainer = _new("Frame")({
		LayoutOrder = 1,
		Size = UDim2.fromScale(1,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = gridBackgroundColor,
		BackgroundTransparency = Transparency,
		[_CHILDREN] = {
			[_CHILDREN] = {
				_new("UICorner")({
					CornerRadius = UDim.new(PADDING_SIZE.Scale*0.75, PADDING_SIZE.Offset*0.75),
				}),

				_new("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = PADDING_SIZE,
				}),	
				-- _new("UIGridLayout")({
				-- 	CellSize = UDim2.fromOffset(80, 80),
				-- 	CellPadding = UDim2.new(PADDING_SIZE, PADDING_SIZE),
				-- }),
				_new("UIPadding")({
					PaddingBottom = PADDING_SIZE,
					PaddingTop = PADDING_SIZE,
					PaddingLeft = PADDING_SIZE,
					PaddingRight = PADDING_SIZE,
				}),
			},
		},
	}) :: Frame

	local ButtonTransparency = _Computed(function(isHover: boolean, isClick: boolean, trans: number): number
		if isClick then
			return math.min(trans + 0.4, 1)
		elseif isHover then
			return math.min(trans + 0.2, 1)
		else
			return trans
		end
	end, IsHovering, IsClicked, Transparency)

	local prefix = ""
	if UserInputService.KeyboardEnabled then
		prefix = "[E] "
	end

	local button = _new("TextButton")({
		LayoutOrder = 2,
		TextSize = _Computed(function(isHover: boolean, isClick: boolean): number
			return 20 * SCALE * if isClick then 1.1 elseif isHover then 1.25 else 1
		end, IsHovering, IsClicked),
		RichText = true,
		Text = FormatUtil.bold(prefix.."HATCH "..tostring(petClass):upper()..": ".. FormatUtil.money(PetModifierUtil.getHatchCost(petClass))),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = buttonColor,
		BackgroundTransparency = ButtonTransparency,
		TextTransparency = ButtonTransparency,
		TextColor3 = LegibilityUtil(Color3.new(1,1,1), buttonColor),
		[_CHILDREN] = {
			_new("UICorner")({
				CornerRadius = UDim.new(PADDING_SIZE.Scale*0.75, PADDING_SIZE.Offset*0.75),
			}),
			_new("UIPadding")({
				PaddingTop = PADDING_SIZE,
				PaddingBottom = PADDING_SIZE,
				PaddingLeft = PADDING_SIZE,
				PaddingRight = PADDING_SIZE,
			}),
		}
	}) :: TextButton

	for i=1, 5 do
		local balanceId = PetModifierUtil.getBalanceId(petClass, PET_METAL_NAME, i)
		_new("Frame")({
			Name = balanceId,
			BackgroundColor3 = backgroundColor,
			Parent = petContainer,
			Size = UDim2.fromOffset(70*SCALE, 70*SCALE),
			BackgroundTransparency = Transparency,
			[_CHILDREN] = {
				_new("UICorner")({
					CornerRadius = UDim.new(PADDING_SIZE.Scale*0.5, PADDING_SIZE.Offset*0.5),
				}),
				_new("UIPadding")({
					PaddingTop = UDim.new(0.05,0),
					PaddingBottom = UDim.new(0.05,0),
					PaddingLeft = UDim.new(0.05,0),
					PaddingRight = UDim.new(0.05,0),
				}),
				_new("TextLabel")({
					Position = UDim2.fromScale(1,1),
					AnchorPoint = Vector2.new(1,1),
					Size = UDim2.fromOffset(0,0),
					AutomaticSize = Enum.AutomaticSize.XY,
					TextSize = 15 * SCALE,
					RichText = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					BackgroundTransparency = Transparency,
					TextTransparency = Transparency,
					Text = FormatUtil.bold(`{math.round(PetModifierUtil.getRarity(balanceId)*1000)/10}%`),
					BackgroundColor3 = gridBackgroundColor,
					TextColor3 = LegibilityUtil(Color3.new(1,1,1), gridBackgroundColor),
					ZIndex = 5,
					[_CHILDREN] = {
						_new("UICorner")({
							CornerRadius = UDim.new(0.5, 0),
						}),
						_new("UIPadding")({
							PaddingTop = UDim.new(0.05,0),
							PaddingBottom = UDim.new(0.05,0),
							PaddingLeft = UDim.new(0,5 * SCALE),
							PaddingRight = UDim.new(0,5 * SCALE),
						}),
					}
				}),
				getViewport(
					maid, 
					balanceId,
					Transparency
				)
			}
		})


	end

	local frame =_new("Frame")({
		Size = UDim2.fromScale(0,0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = backgroundColor,
		Position = UDim2.fromScale(0.5,0.5),
		AnchorPoint = Vector2.new(0.5,0.5),
		BackgroundTransparency = Transparency,
		[_CHILDREN] = {
			_new("UICorner")({
				CornerRadius = UDim.new(PADDING_SIZE.Scale, PADDING_SIZE.Offset),
			}),
			_new("UIPadding")({
				PaddingTop = PADDING_SIZE,
				PaddingBottom = PADDING_SIZE,
				PaddingLeft = PADDING_SIZE,
				PaddingRight = PADDING_SIZE,
			}),
			_new("UIListLayout")({
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = PADDING_SIZE,
			}),	
			petContainer,
			button
		},
	}) :: Frame

	return frame, button
end

-- Class

return function(trackerMaid: Maid, parent: Instance)
	local onClick = trackerMaid:GiveTask(Signal.new())

	local function bootHatcher(hatcher: Instance)
		
		assert(hatcher:IsA("BasePart"))
		assert(CollectionService:HasTag(hatcher, EGG_HATCHER_TAG))
		
		local position: Vector3 = hatcher.Position
		local petClass: PetClass = assert(hatcher:GetAttribute("PetClass")) :: any
		local color: Color3 = hatcher.Color
		local maid = trackerMaid:GiveTask(Maid.new())
		local _fuse = ColdFusion.fuse(maid)
		local _new = _fuse.new
		local _mount = _fuse.mount
		local _import = _fuse.import
	
		local _Value = _fuse.Value
		local _Computed = _fuse.Computed
	
		local _OUT = _fuse.OUT
		local _REF = _fuse.REF
		local _CHILDREN = _fuse.CHILDREN
		local _ON_EVENT = _fuse.ON_EVENT
		local _ON_PROPERTY = _fuse.ON_PROPERTY
	
		local TransparencyBase = _Value(if RunService:IsRunning() then 1 else 0)
		
		local part = _new("Part")({
			Name = "SurfaceGuiMount",
			CanTouch = false,
			CanCollide = false,
			CanQuery = false,
			Locked = true,
			Anchored = true,
			Transparency = 1,
			Parent = hatcher,
			Size = Vector3.new(10, 10, 0.01) * SCALE,
		}) :: Part
	
		local surfaceGui: SurfaceGui = _new("SurfaceGui")({
			Name = petClass.."EggGui",
			Adornee = part,
			Parent = 	parent,
			LightInfluence = 0,
			AlwaysOnTop = true, --for some reason buttons don't work when this isn't enabled?
			Face = Enum.NormalId.Front,
			ResetOnSpawn = false,
			CanvasSize = Vector2.new(550, 550),
			SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
			PixelsPerStud = 25,
		}) :: any
		
		local tracer = CursorTracer.new(surfaceGui)

		local IsHovering = _Value(false)
		local IsClicking = _Value(false)

		local main, button = mainFrame(
			maid,
			position, 
			petClass,
			color,
			IsHovering,
			IsClicking,
			TransparencyBase:Tween(0.5)
		)

		tracer:GetHoverState(button):Connect(function(val: boolean)
			IsHovering:Set(val)
		end)

		if UserInputService.KeyboardEnabled then
			maid:GiveTask(UserInputService.InputBegan:Connect(function(inputObject: InputObject)
				if inputObject.KeyCode == Enum.KeyCode.E and TransparencyBase:Get() == 0 then
					IsClicking:Set(true)
				end
			end))
			maid:GiveTask(UserInputService.InputEnded:Connect(function(inputObject: InputObject)
				if inputObject.KeyCode == Enum.KeyCode.E and TransparencyBase:Get() == 0 then
					onClick:Fire(petClass, color)
					IsClicking:Set(false)
				end
			end))
		end

		tracer:GetClickState(button):Connect(function(val: boolean)
			IsClicking:Set(val)
			if not val and IsHovering:Get() and TransparencyBase:Get() == 0 then
				onClick:Fire(petClass, color)
			end
		end)

		main.Parent = surfaceGui

		maid:GiveTask(main.Destroying:Connect(function()
			maid:Destroy()
		end))
	
		maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
			local offset = (workspace.CurrentCamera.CFrame.Position - position)
			local lVec = workspace.CurrentCamera.CFrame.LookVector
			local offNorm = offset.Unit
			local lookTransparency = math.clamp(1+(math.min(lVec:Dot(offNorm), 0)), 0, 1)
			lookTransparency = if lookTransparency > 0.1 then 1 else 0
			local dist = offset.Magnitude
			local distTransparency = (dist-MIN_VIEW_DISTANCE)/(MAX_VIEW_DISTANCE-MIN_VIEW_DISTANCE)
			distTransparency = if distTransparency > 0.1 then 1 else 0
			TransparencyBase:Set(math.clamp(math.max(distTransparency, lookTransparency), 0, 1))
			part.CFrame = CFrame.new(position, workspace.CurrentCamera.CFrame.Position)
		end))
	
		return main
	end

	trackerMaid:GiveTask(CollectionService:GetInstanceAddedSignal(EGG_HATCHER_TAG):Connect(bootHatcher))
	for i, hatcher in ipairs(CollectionService:GetTagged(EGG_HATCHER_TAG)) do
		bootHatcher(hatcher)
	end

	trackerMaid:GiveTask(onClick:Connect(function(petClass: PetClass, color: Color3)
		if HatchEnabled then
			local petId = NetworkUtil.invokeServer(HATCH_PET, petClass)
			HatchEnabled = false
			if petId then
				HatchProcess(
					{
						{BalanceId = petId,	Color = color,	}
					}, 
					petClass
				)
			end
			HatchEnabled = true
		end
	end))
	trackerMaid:GiveTask(NetworkUtil.onClientEvent(MANUAL_HATCH_EFFECT_TRIGGER, function(petClass: PetClass, petId: string, color: Color3): ()
		print("RECEIVED MANUAL", petClass, petId, color)
		HatchEnabled = false
		HatchProcess(
			{
				{BalanceId = petId,	Color = color,	}
			}, 
			petClass
		)
		HatchEnabled = true
	end))
end