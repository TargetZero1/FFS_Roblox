--!strict
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local ColdFusion8 = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Synthetic = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Synthetic"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

-- Modules
local GuiLibrary = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("GuiLibrary"))
local PseudoEnum = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PseudoEnum"))
local StyleGuide = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("StyleGuide"))
local OnboardingFolder = script.Parent
assert(OnboardingFolder)
local ArrowUtil = require(OnboardingFolder:WaitForChild("ArrowUtil"))

-- Types
type State<T> = ColdFusion8.State<T>
type ValueState<T> = ColdFusion8.ValueState<T>
type Maid = Maid.Maid
type Signal = Signal.Signal
type Panel = {
	__index: Panel,
	_Maid: Maid,
	_IsAlive: boolean,
	_LastUpdate: number,
	Focuses: ValueState<{ [number]: Instance }>,
	Alignment: ValueState<PseudoEnum.GuiAlignmentType>,
	Title: ValueState<string>,
	IsInteractable: ValueState<boolean>,
	Description: ValueState<string>,
	Visible: ValueState<boolean>,
	Instance: Frame,
	ButtonEnabled: ValueState<boolean>,
	Destroy: (self: Panel) -> nil,
	UpdateTick: (self: Panel) -> nil,
	OnClick: Signal,
	init: (maid: Maid) -> Panel,
}

-- Constants
local GLOW_FILL_TRANSPARENCY = 0.6
local ALIGNMENT_DURATION = 0.5
local GLOW_CYCLE_DURATION = 5
local INTERACTION_CYCLE_DURATION = 0.8
local TRANS_TWEEN_DURAITON = 0.5
local BUTTON_DELAY = 0.2
local GROW_WEIGHT = 0.25
local HIGHLIGHT_OVERLAY_DISTANCE = 100
-- local ARROW_UPDATE_DELAY = 0.5
-- Variables
-- References
-- Private functions

function highlightInstance(hostMaid: Maid, inst: Instance, GlowColor: State<Color3>, isInteractable: boolean, guiParent: GuiBase2d)
	-- isInteractable = true
	if not inst then
		return nil
	end

	local maid = Maid.new()
	local _fuse = ColdFusion8.fuse(maid)
	local _library = GuiLibrary.new(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local Scale = _Value(1)
	local IsVisible = _Value(false)
	local DepthMode = _Value(Enum.HighlightDepthMode.Occluded)
	-- local lastArrowUpdate = 0
	maid:GiveTask(RunService.RenderStepped:Connect(function()
		if not inst:IsDescendantOf(workspace) and not inst:IsDescendantOf(game:GetService("Players").LocalPlayer) then
			IsVisible:Set(false)
		else
			IsVisible:Set(true)
		end
		if inst:IsA("Model") or inst:IsA("BasePart") then
			local cf = inst:GetPivot()
			if (workspace.CurrentCamera.CFrame.Position - cf.Position).Magnitude < HIGHLIGHT_OVERLAY_DISTANCE then
				DepthMode:Set(Enum.HighlightDepthMode.Occluded)
			else
				DepthMode:Set(Enum.HighlightDepthMode.AlwaysOnTop)
			end
			local player = Players.LocalPlayer
			if player then
				local character = player.Character
				if character then
					local primPart = character.PrimaryPart
					if primPart then
						if true then -- tick() - lastArrowUpdate > ARROW_UPDATE_DELAY then
							-- print("Test")
							-- lastArrowUpdate = tick()
							local renderMaid = maid:GiveTask(Maid.new())
							local container = ArrowUtil.getContainer(renderMaid)
							local isDone = false

							local altPosition: Vector3?

							if inst:FindFirstChild("PetPosition", true) then
								local posInst = inst:FindFirstChild("PetPosition", true)
								assert(posInst and posInst:IsA("BasePart"))
								altPosition = posInst.Position
							elseif inst:FindFirstChild("CountPart", true) then
								local posInst = inst:FindFirstChild("CountPart", true)
								assert(posInst and posInst:IsA("BasePart"))
								altPosition = posInst.Position * Vector3.new(1, 0, 1) + Vector3.new(0, primPart.Position.Y - 3, 0)
							end

							local points = ArrowUtil.pathFind(primPart.Position - Vector3.new(0, 3, 0), altPosition or cf.Position)
							-- print("POINTS!", #points)
							ArrowUtil.drawArrows(renderMaid, points, container)
							maid._render = function()
								if not isDone then
									pcall(function()
										container:Destroy()
									end)
									repeat
										task.wait()
									until isDone
								end
								renderMaid:Destroy()
							end
							isDone = true
						end
					end
				end
			end
		end
		if isInteractable then
			Scale:Set(1 + GROW_WEIGHT * 0.5 + (0.5 * GROW_WEIGHT * math.sin(math.rad(180) * (tick() / INTERACTION_CYCLE_DURATION))))
		end
	end))

	local FillTransparency = _Value(1)
	local OutlineTransparency = _Value(1)
	hostMaid:GiveTask(function()
		FillTransparency:Set(1)
		OutlineTransparency:Set(1)
		task.delay(TRANS_TWEEN_DURAITON, function()
			maid:Destroy()
		end)
	end)
	maid:GiveTask(inst.Destroying:Connect(function()
		maid:Destroy()
	end))
	local FillTransparencyTween = FillTransparency:Tween(TRANS_TWEEN_DURAITON)
	local OutlineTransparencyTween = OutlineTransparency:Tween(TRANS_TWEEN_DURAITON)

	if inst:IsA("BasePart") or inst:IsA("Model") then
		-- print("A", inst:GetFullName())
		_new("Highlight")({
			Parent = inst,
			Enabled = IsVisible,
			FillTransparency = if isInteractable then 0.1 else FillTransparencyTween,
			FillColor = GlowColor,
			DepthMode = DepthMode,
			OutlineColor = GlowColor,
			OutlineTransparency = OutlineTransparencyTween,
		})
	elseif inst:IsA("GuiObject") then
		-- print("B", inst:GetFullName())
		local AbsoluteSize = _Value(inst.AbsoluteSize)
		local AbsolutePosition = _Value(inst.AbsolutePosition)
		local AbsoluteRotation = _Value(inst.AbsoluteRotation)
		local AnchorPoint = _Value(inst.AnchorPoint)
		local CornerRadius = _Value(UDim.new(0, 0))
		local Size = _Computed(function(size: Vector2, scale: number)
			return UDim2.fromOffset(size.X * scale, size.Y * scale)
		end, AbsoluteSize, Scale)
		_new("Frame")({
			Rotation = AbsoluteRotation,
			AnchorPoint = AnchorPoint,
			Visible = IsVisible,
			Position = _Computed(function(position: Vector2, size: Vector2, anchor: Vector2, rotation: number, scale: number)
				local cornerPos = position + size * anchor
				local anchorOffset = Vector2.new(0.5, 0.5) - anchor
				local overflow = scale - 1
				local x = size.X * math.sign(anchorOffset.X)
				local y = size.Y * math.sign(anchorOffset.Y)
				local offset = Vector2.new(x, y) * overflow
				cornerPos -= offset / 2
				return UDim2.fromOffset(cornerPos.X, cornerPos.Y)
			end, AbsolutePosition, AbsoluteSize, AnchorPoint, AbsoluteRotation, Scale),
			Size = Size,
			Parent = guiParent,
			BackgroundTransparency = FillTransparencyTween,
			BackgroundColor3 = GlowColor,
			Children = {
				_new("UICorner")({
					CornerRadius = CornerRadius,
				}),
				_new("UIStroke")({
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Thickness = _Computed(function(scale: number)
						return if isInteractable then 2 * scale else 0
					end, Scale),
					Color = GlowColor,
					Transparency = OutlineTransparencyTween,
				}),
			} :: { [number]: any },
		})
		maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
			local uiCorner = inst:FindFirstChildOfClass("UICorner")
			if uiCorner then
				CornerRadius:Set(uiCorner.CornerRadius)
			end

			AbsoluteSize:Set(inst.AbsoluteSize)
			AbsolutePosition:Set(inst.AbsolutePosition)
			AbsoluteRotation:Set(inst.AbsoluteRotation)
			AnchorPoint:Set(inst.AnchorPoint)
		end))
	elseif inst:IsA("Folder") then
		-- print("C", inst:GetFullName())
		for i, child in ipairs(inst:GetChildren()) do
			highlightInstance(maid, child, GlowColor, isInteractable, guiParent)
		end
	end

	FillTransparency:Set(GLOW_FILL_TRANSPARENCY)
	OutlineTransparency:Set(0)

	return nil
end
-- Class
local Panel: Panel = {} :: any
Panel.__index = Panel

function Panel:Destroy()
	if not self._IsAlive then
		return
	end
	self._IsAlive = false
	self._Maid:Destroy()
	local t: any = self
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(t, nil)
	return nil
end

function Panel:UpdateTick()
	self._LastUpdate = tick()
	return nil
end

local currentPanel: Panel

function Panel.init(maid: Maid)
	local _fuse = ColdFusion8.fuse(maid)
	local _library = GuiLibrary.new(maid)
	local _synth = Synthetic(maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local self: Panel = setmetatable({}, Panel) :: any
	self._IsAlive = true
	self._Maid = maid
	self.OnClick = self._Maid:GiveTask(Signal.new())
	self.Alignment = _Value(PseudoEnum.GuiAlignmentType.Center)
	self.Title = _Value("")
	self.Visible = _Value(true)
	self.IsInteractable = _Value(false)
	self.Description = _Value("_")
	-- self.Description:Connect(function(cur, prev)
	-- 	print("DESC", prev, "->", cur)
	-- end)
	self.ButtonEnabled = _Value(false)
	self.Focuses = _Value({})
	self._LastUpdate = tick()
	local GlowColor = _Value(Color3.fromHSV(0, 1, 1))

	local Width = _Computed(function(vSize: Vector2)
		return UDim2.fromOffset(math.min(math.ceil(vSize.X * 0.25), 300), 0)
	end, StyleGuide.ViewportSize)

	local ContinueButton = _library.Input.Button:GetFilledRound(function()
		if tick() - self._LastUpdate > BUTTON_DELAY then
			self.OnClick:Fire()
		end
	end, "CONTINUE", PseudoEnum.GuiColorPalette.Primary5, nil, PseudoEnum.GuiTypography.Button, 3)

	local titleLabel = _new("TextLabel")({
		Name = "Title",
		RichText = true,
		TextScaled = false,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		BackgroundTransparency = 1,
		TextSize = StyleGuide:GetTextSize(PseudoEnum.GuiTypography.Headline6),
		FontFace = StyleGuide:GetFont(PseudoEnum.GuiTypography.Headline6),
		TextColor3 = StyleGuide:GetContrastColor(PseudoEnum.GuiColorPalette.Surface5),
		LayoutOrder = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = Width,
	}) :: TextLabel

	local descLabel = _new("TextLabel")({
		Name = "Content",
		RichText = true,
		TextScaled = false,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		BackgroundColor3 = StyleGuide:GetColor(PseudoEnum.GuiColorPalette.Surface6),
		TextSize = StyleGuide:GetTextSize(PseudoEnum.GuiTypography.Body1),
		FontFace = StyleGuide:GetFont(PseudoEnum.GuiTypography.Body1),
		TextColor3 = StyleGuide:GetContrastColor(PseudoEnum.GuiColorPalette.Surface6),
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = Width,
		Children = {
			_library.Layout:GetUIPadding(PseudoEnum.GuiDensityModifier.Default) :: any,
			_library.Effect:GetUICorner(),
		},
	}) :: TextLabel
	self._Maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
		local rawHue = tick() / GLOW_CYCLE_DURATION
		local hue = math.clamp(rawHue - math.floor(rawHue), 0, 1)
		GlowColor:Set(Color3.fromHSV(hue, 1, 1))
		titleLabel.Text = self.Title:Get()
		descLabel.Text = self.Description:Get()
	end))
	self.Instance = _new("Frame")({
		Name = "Panel",
		ZIndex = 10,
		Visible = self.Visible,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = StyleGuide:GetColor(PseudoEnum.GuiColorPalette.Surface5),
		Position = _Computed(function(alignment: PseudoEnum.GuiAlignmentType, pad: UDim): UDim2
			if alignment == PseudoEnum.GuiAlignmentType.TopLeft then
				return UDim2.new(pad.Scale, pad.Offset, pad.Scale, pad.Offset)
			elseif alignment == PseudoEnum.GuiAlignmentType.Top then
				return UDim2.new(0.5, 0, pad.Scale, pad.Offset)
			elseif alignment == PseudoEnum.GuiAlignmentType.TopRight then
				return UDim2.new(1 - pad.Scale, -pad.Offset, pad.Scale, pad.Offset)
			elseif alignment == PseudoEnum.GuiAlignmentType.Left then
				return UDim2.new(pad.Scale, pad.Offset, 0.5, 0)
			elseif alignment == PseudoEnum.GuiAlignmentType.Center then
				return UDim2.fromScale(0.5, 0.5)
			elseif alignment == PseudoEnum.GuiAlignmentType.Right then
				return UDim2.new(1 - pad.Scale, -pad.Offset, 0.5, 0)
			elseif alignment == PseudoEnum.GuiAlignmentType.BottomLeft then
				return UDim2.new(pad.Scale, pad.Offset, 1 - pad.Scale, -pad.Offset)
			elseif alignment == PseudoEnum.GuiAlignmentType.Bottom then
				return UDim2.new(0.5, 0, 1 - pad.Scale, -pad.Offset)
			elseif alignment == PseudoEnum.GuiAlignmentType.BottomRight then
				return UDim2.new(1 - pad.Scale, -pad.Offset, 1 - pad.Scale, -pad.Offset)
			end
			error("Bad alignment")
		end, self.Alignment, StyleGuide:GetPadding(PseudoEnum.GuiDensityModifier.Low)):Tween(ALIGNMENT_DURATION),
		AnchorPoint = _Computed(function(alignment: PseudoEnum.GuiAlignmentType): Vector2
			-- print(alignment.Name)
			if alignment == PseudoEnum.GuiAlignmentType.TopLeft then
				return Vector2.new(0, 0)
			elseif alignment == PseudoEnum.GuiAlignmentType.Top then
				return Vector2.new(0.5, 0)
			elseif alignment == PseudoEnum.GuiAlignmentType.TopRight then
				return Vector2.new(1, 0)
			elseif alignment == PseudoEnum.GuiAlignmentType.Left then
				return Vector2.new(0, 0.5)
			elseif alignment == PseudoEnum.GuiAlignmentType.Center then
				return Vector2.new(0.5, 0.5)
			elseif alignment == PseudoEnum.GuiAlignmentType.Right then
				return Vector2.new(1, 0.5)
			elseif alignment == PseudoEnum.GuiAlignmentType.BottomLeft then
				return Vector2.new(0, 1)
			elseif alignment == PseudoEnum.GuiAlignmentType.Bottom then
				return Vector2.new(0.5, 1)
			elseif alignment == PseudoEnum.GuiAlignmentType.BottomRight then
				return Vector2.new(1, 1)
			end
			error("Bad alignment")
		end, self.Alignment):Tween(ALIGNMENT_DURATION),
		Children = {
			_library.Layout:GetVerticalList(PseudoEnum.GuiAlignmentType.Center, PseudoEnum.GuiDensityModifier.Default) :: any,
			_library.Effect:GetUICorner(),
			_library.Layout:GetUIPadding(PseudoEnum.GuiDensityModifier.Default),
			titleLabel,
			descLabel,
			_new("Frame")({
				Size = Width,
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 3,
				BackgroundTransparency = 1,
				Children = {
					_library.Layout:GetHorizontalList(PseudoEnum.GuiAlignmentType.Right) :: any,
					_Computed(function(enabled: boolean): Frame?
						return if enabled then ContinueButton else nil
					end, self.ButtonEnabled),
				},
			}),
		},
	}) :: any

	self.Focuses:ForValues(function(v: Instance, valueMaid: Maid)
		local parent = self.Instance.Parent
		self._Maid:GiveTask(valueMaid)
		if parent and parent:IsA("GuiBase2d") then
			highlightInstance(valueMaid, v, GlowColor, self.IsInteractable:Get(), parent)
		end
		return v
	end)

	currentPanel = self
	self.Description:Set("")
	return self
end

return ServiceProxy(function()
	return currentPanel or Panel
end)
