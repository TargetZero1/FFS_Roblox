local CS = game:GetService("CollectionService")
local WINDMILL_TAG = "WindmillMesh"

--function to rotate wind mill
function rotateWindMill(windMillMesh)
	local rotor = windMillMesh:WaitForChild("rotor", 20)
	assert(rotor, "No rotor found on the windmill, please check again")

	--rotate 2 degree per render step
	game:GetService("RunService").Stepped:Connect(function()
		rotor.CFrame *= CFrame.Angles(-math.rad(1), 0, 0)
	end)
end

--get tags of available windmills
for _, windMillMesh in pairs(CS:GetTagged(WINDMILL_TAG)) do
	rotateWindMill(windMillMesh)
end

--when the wind mill is aded
CS:GetInstanceAddedSignal(WINDMILL_TAG):Connect(function(windMillMesh)
	rotateWindMill(windMillMesh)
end)
