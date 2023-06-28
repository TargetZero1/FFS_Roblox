--!strict
-- Services
-- Packages
-- Modules
-- Types
-- Constants
local YIELD_DURATION = 20
-- Variables
-- References
-- Class
return {
	getChild = function(parent: Instance, name: string, yieldDuration: number?): Instance
		return assert(parent:WaitForChild(name, yieldDuration or YIELD_DURATION) :: any)
	end,
	getParent = function(inst: Instance): Instance
		return assert(inst.Parent) :: any
	end,
	getAttribute = function<T>(inst: Instance, name: string): T
		assert(inst:GetAttribute(name) ~= nil)
		return inst:GetAttribute(name) :: any
	end,
}
