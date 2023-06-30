--!strict
-- Services
-- Packages
-- Modules
local Station = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("Station"))

-- Types
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
-- Types
export type WindmillProperties = {
	
} & Station.StationProperties
export type WindmillFunctions<Self> = {
	new: (owner: Player, instance: Model, petSpawnCF: CFrame) -> Self,
} & Station.StationFunctions<Self>
type BaseWindmill<Self> = WindmillProperties & WindmillFunctions<Self>
export type Windmill = BaseWindmill<BaseWindmill<any>>

-- Constants
-- Variables
-- References
local BindableEvents = game:GetService("ReplicatedStorage"):WaitForChild("BindableEvents")
local SoundEffectTriggers = BindableEvents:WaitForChild("SoundEffectTriggers")
local SFXEvent = SoundEffectTriggers:WaitForChild("PlayDropperSound") :: BindableEvent

-- Class
local Windmill = setmetatable({} :: any, Station) :: Windmill
Windmill.__index = Windmill

function Windmill.new(owner: Player, instance: Model, petSpawnCF: CFrame): Windmill

	local self: Windmill = setmetatable(Station._new(owner, instance, "Windmill", petSpawnCF), Windmill) :: any
	self:_TrackModifier("Recharge")
	self:_TrackModifier("Value")

	self.OnFire:Connect(function()
		self:_PlayDropSoundEffect(SFXEvent)
	end)

	return self
end

return Windmill