--!strict
-- Services
local HttpService = game:GetService("HttpService")

-- Packages
local MediaModule = script.Parent
assert(MediaModule)
local Package = MediaModule.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local Signal = require(Packages:WaitForChild("Signal"))
local Synthetic = require(Packages:WaitForChild("Synthetic"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))
local GeometryUtil = require(Packages:WaitForChild("GeometryUtil"))

-- Modules

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type Fuse = ColdFusion.Fuse
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
export type GuiParameters = {
	Maid: Maid?,
	Name: CanBeState<string>?,
	Parent: CanBeState<Instance>?,
	MeshPart: CanBeState<MeshPart?>,
	BackgroundColor3: CanBeState<Color3>?,
	BackgroundTransparency: CanBeState<number>?,
	BorderColor3: CanBeState<Color3>?,
	BorderSizePixel: CanBeState<number>?,
	MeshColor3: CanBeState<Color3>?,
	TextureEnabled: CanBeState<boolean>?,
	MeshScale: CanBeState<number>?,
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	SizeConstraint: CanBeState<Enum.SizeConstraint>?,
	LayoutOrder: CanBeState<number>?,
	AnchorPoint: CanBeState<Vector2>?,
	MeshMaterial: CanBeState<Enum.Material>?,
	MeshMaterialVariant: CanBeState<string>?,
	Zoom: CanBeState<number>?,
}
export type Output = ViewportFrame
export type Constructor = (config: GuiParameters) -> Output

function Constructor(config: GuiParameters): Output
	-- Unpack workspace
	local _maid = config.Maid or Maid.new()
	local _fuse = ColdFusion.fuse(_maid)
	local _synth = Synthetic(_maid)
	local _new = _fuse.new
	local _bind = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	-- Import parameters
	local Name = _import(config.Name, script.Name)
	local Parent = _import(config.Parent, nil :: Instance?)
	local BackgroundColor3 = _import(config.BackgroundColor3, Color3.new(1, 1, 1))
	local BackgroundTransparency = _import(config.BackgroundTransparency, 1)
	local BorderSizePixel = _import(config.BorderSizePixel, 0)
	local LayoutOrder = _import(config.LayoutOrder, 0)
	local SizeConstraint = _import(config.SizeConstraint, Enum.SizeConstraint.RelativeXY)
	local BorderColor3 = _import(config.BorderColor3, Color3.new(1, 1, 1))
	local MeshColor3 = _import(config.MeshColor3, Color3.new(1, 1, 1))
	local TextureEnabled = _import(config.TextureEnabled, true)
	local MeshScale = _import(config.MeshScale, 1)
	local MeshTemplate = _import(config.MeshPart, nil :: MeshPart?)
	local MeshMaterial = _import(config.MeshMaterial, Enum.Material.SmoothPlastic)
	local MeshMaterialVariant = _import(config.MeshMaterialVariant, "")
	local Position = _import(config.Position, UDim2.fromScale(0, 0))
	local Size = _import(config.Size, UDim2.fromOffset(50, 50))
	local AnchorPoint = _import(config.AnchorPoint, Vector2.new(0, 0))
	local Zoom = _import(config.Zoom, 1)

	-- Construct internal states
	local id = HttpService:GenerateGUID(false)
	local MeshCFrame = _Value(CFrame.new(0, 0, 0))
	local Mesh = _Computed(
		function(
			template: MeshPart?,
			color: Color3,
			material: Enum.Material,
			variant: string,
			cf: CFrame,
			textureEnabled: boolean
		): MeshPart?
			if not template then
				local part = Instance.new("Part")
				part.Transparency = 1
				_maid["_currentMeshPart" .. id] = part

				return part :: any
			end
			assert(template ~= nil)
			local meshPart = template:Clone()
			if meshPart:IsA("MeshPart") and textureEnabled == false then
				meshPart.TextureID = ""
			end
			meshPart.Color = color
			meshPart.Material = material
			meshPart.MaterialVariant = variant
			meshPart.CFrame = cf
			_maid["_currentMeshPart" .. id] = meshPart
			return meshPart
		end,
		MeshTemplate,
		MeshColor3,
		MeshMaterial,
		MeshMaterialVariant,
		MeshCFrame,
		TextureEnabled
	)

	-- Construct instances
	local MaxDimension = _Computed(function(mesh: MeshPart?): number
		if not mesh then
			return 0
		end
		assert(mesh ~= nil)
		return math.max(mesh.Size.X, mesh.Size.Y, mesh.Size.Z)
	end, MeshTemplate)
	local FieldOfView = _Computed(function(maxDimension: number, cf: CFrame, scale: number): GeometryUtil.Degree
		return math.deg(2 * math.atan(maxDimension * 0.5 / (maxDimension * scale)))
	end, MaxDimension, MeshCFrame, MeshScale)
	local Camera = _new("Camera")({
		CFrame = _Computed(function(meshCF: CFrame, dim: number, zoom: number): CFrame
			return CFrame.new(meshCF.Position + Vector3.new(0, 0, dim / zoom), meshCF.Position)
		end, MeshCFrame, MaxDimension, Zoom),
		FieldOfView = FieldOfView,
	})

	local Output: ViewportFrame = _new("ViewportFrame")({
		Name = Name,
		Parent = Parent,
		Position = Position,
		Size = Size,
		SizeConstraint = SizeConstraint,
		AnchorPoint = AnchorPoint,
		BackgroundColor3 = BackgroundColor3,
		LayoutOrder = LayoutOrder,
		BackgroundTransparency = BackgroundTransparency,
		BorderSizePixel = BorderSizePixel,
		BorderColor3 = BorderColor3,
		CurrentCamera = Camera,
		Ambient = Color3.new(1, 1, 1),
		LightColor = Color3.new(1, 1, 1),
		Children = {
			Camera,
			Mesh :: any,
		},
	}) :: any

	return Output
end

return function(maid: Maid, config: GuiParameters): Output
	local inst = Constructor(config)
	if maid then
		maid:GiveTask(inst)
	end
	return inst
end
