--!strict
-- Services
-- Packages
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
-- Modules
local Station = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("Station"))

-- Types
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
-- Types
export type KneaderProperties = {
	
} & Station.StationProperties
export type KneaderFunctions<Self> = {
	new: (owner: Player, instance: Model, petSpawnCF: CFrame) -> Self,
} & Station.StationFunctions<Self>
type BaseKneader<Self> = KneaderProperties & KneaderFunctions<Self>
export type Kneader = BaseKneader<BaseKneader<any>>

-- Constants
local ON_PRESS = "OnKneaderPress"

-- Variables
-- References
local BindableEvents = game:GetService("ReplicatedStorage"):WaitForChild("BindableEvents")
local SoundEffectTriggers = BindableEvents:WaitForChild("SoundEffectTriggers")
local SFXEvent = SoundEffectTriggers:WaitForChild("PlayKneaderSound") :: BindableEvent

-- Class
local Kneader = setmetatable({} :: any, Station) :: Kneader
Kneader.__index = Kneader

function Kneader.new(owner: Player, instance: Model, petSpawnCF: CFrame): Kneader

	local self: Kneader = setmetatable(Station._new(owner, instance, "Kneader", petSpawnCF), Kneader) :: any
	self:_TrackModifier("Recharge")
	self:_TrackModifier("Multiplier")

	NetworkUtil.getRemoteEvent(ON_PRESS)

	self.OnFire:Connect(function()
		if not self._PetBalanceId then
			NetworkUtil.fireClient(ON_PRESS, self.Owner)
		end
		self:_PlayDropSoundEffect(SFXEvent)
	end)

	self:_BuildPrompt("Dough", "Knead")

	return self
end

return Kneader