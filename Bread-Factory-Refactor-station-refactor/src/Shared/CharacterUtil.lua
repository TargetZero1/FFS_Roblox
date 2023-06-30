--!strict
--services

--modules
local characterUtil = {}

function characterUtil.AdjustCharacterScale(plr: Player, scaleNum: number)
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid") :: Humanoid

	local bds = humanoid:WaitForChild("BodyDepthScale") :: any
	local bhs = humanoid:WaitForChild("BodyHeightScale") :: any
	local bws = humanoid:WaitForChild("BodyWidthScale") :: any
	local hs = humanoid:WaitForChild("HeadScale") :: any

	bds.Value, bhs.Value, bws.Value, hs.Value = scaleNum, scaleNum, scaleNum, scaleNum
end

function characterUtil.SetAnimation(character: Model, animId: string, onLoop: boolean)
	local Humanoid = character:FindFirstChild("Humanoid")
	assert(Humanoid, "Unable to find humanoid")
	local Animator = Humanoid:FindFirstChild("Animator") :: Animator
	assert(Animator, "Unable to find animator!")

	local animation = Instance.new("Animation")
	animation.AnimationId = animId
	local animationTrack = Animator:LoadAnimation(animation)
	animationTrack.Looped = onLoop

	animationTrack:Play()
	animationTrack.Ended:Connect(function()
		animation:Destroy()
	end)
end

return characterUtil
