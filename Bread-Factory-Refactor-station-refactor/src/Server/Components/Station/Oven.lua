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
export type OvenProperties = {
	
} & Station.StationProperties
export type OvenFunctions<Self> = {
	new: (owner: Player, instance: Model, petSpawnCF: CFrame) -> Self,
} & Station.StationFunctions<Self>
type BaseOven<Self> = OvenProperties & OvenFunctions<Self>
export type Oven = BaseOven<BaseOven<any>>

-- Constants
local ON_PRESS = "OnOvenPress"

-- Variables
-- References
local BindableEvents = game:GetService("ReplicatedStorage"):WaitForChild("BindableEvents")
local SoundEffectTriggers = BindableEvents:WaitForChild("SoundEffectTriggers")
local SFXEvent = SoundEffectTriggers:WaitForChild("PlayOvenSound") :: BindableEvent

-- Class
local Oven = setmetatable({} :: any, Station) :: Oven
Oven.__index = Oven

function Oven.new(owner: Player, instance: Model, petSpawnCF: CFrame): Oven

	local self: Oven = setmetatable(Station._new(owner, instance, "Oven", petSpawnCF), Oven) :: any
	self:_TrackModifier("Recharge")
	self:_TrackModifier("Value")

	NetworkUtil.getRemoteEvent(ON_PRESS)
	
	self.OnFire:Connect(function()
		if not self._PetBalanceId then
			NetworkUtil.fireClient(ON_PRESS, owner)
		end
		self:_PlayDropSoundEffect(SFXEvent)
	end)

	self:_BuildPrompt("Dough", "Bake")

	return self
end

return Oven