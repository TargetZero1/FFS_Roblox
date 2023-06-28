--!strict
-- Services
-- Packages
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
-- Modules
local Station = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("Components"):WaitForChild("Station"))
local MidasStateTree = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MidasStateTree"))
local StationModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StationModifierUtil"))

-- Types
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
-- Types
export type WrapperProperties = {
	
} & Station.StationProperties
export type WrapperFunctions<Self> = {
	new: (owner: Player, instance: Model, petSpawnCF: CFrame) -> Self,
} & Station.StationFunctions<Self>
type BaseWrapper<Self> = WrapperProperties & WrapperFunctions<Self>
export type Wrapper = BaseWrapper<BaseWrapper<any>>

-- Constants
local ON_PRESS = "OnWrapPress"

-- Variables
-- References
local BindableEvents = game:GetService("ReplicatedStorage"):WaitForChild("BindableEvents")
local SoundEffectTriggers = BindableEvents:WaitForChild("SoundEffectTriggers")
local SFXEvent = SoundEffectTriggers:WaitForChild("PlayWrappingSound") :: BindableEvent

-- Class
local Wrapper = setmetatable({} :: any, Station) :: Wrapper
Wrapper.__index = Wrapper

function Wrapper.new(owner: Player, instance: Model, petSpawnCF: CFrame): Wrapper

	local self: Wrapper = setmetatable(Station._new(owner, instance, "Wrapper", petSpawnCF), Wrapper) :: any
	self:_TrackModifier("Recharge")
	self:_TrackModifier("Multiplier")

	NetworkUtil.getRemoteEvent(ON_PRESS)
	
	self.OnFire:Connect(function()
		if not self._PetBalanceId then
			NetworkUtil.fireClient(ON_PRESS, self.Owner)
		end
		self:_PlayDropSoundEffect(SFXEvent)
	end)

	self:_BuildPrompt("Bread", "Wrap")

	MidasStateTree.Tycoon.Wrapper.Level.Multiplier(owner, function(): number?
		local balanceId = self.ModifierId.Multiplier
		if balanceId then
			return StationModifierUtil.getLevel(balanceId)
		end
		return nil
	end)

	MidasStateTree.Tycoon.Wrapper.Level.Recharge(owner, function(): number?
		local balanceId = self.ModifierId.Recharge
		if balanceId then
			return StationModifierUtil.getLevel(balanceId)
		end
		return nil
	end)
		
	MidasStateTree.Tycoon.Wrapper.PetBalanceId(owner, function(): any
		return self._PetBalanceId or "None"
	end)

	return self
end

return Wrapper