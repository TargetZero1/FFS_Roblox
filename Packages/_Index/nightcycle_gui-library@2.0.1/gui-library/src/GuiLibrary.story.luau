--!strict
local Package = script.Parent
assert(Package)
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))

return function(coreGui: Frame)
	local maid: Maid.Maid = Maid.new()

	task.spawn(function()
		local GuiLibrary = require(script.Parent)
		local _library = GuiLibrary.new(maid)
	end)

	return function()
		maid:Destroy()
	end
end
