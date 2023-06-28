--!strict
-- Services
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

-- Modules
local PetModifierUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetModifierUtil"))
local Pets = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"))

-- Types
type Maid = Maid.Maid
type ModifiedPet = (Pets.Pet & {
	BreadPerMinute: number,
	IsRunning: boolean,
})
-- Constants
-- Variables
-- References
-- Class

return function(maid: Maid, owner: Player, balanceId: string?, cf: CFrame, inst: Instance, enabled: boolean?, getIfEquipped: () -> boolean, getBreadCount: () -> number, onActivate: () -> ())
	if balanceId then
		local petClassName = PetModifierUtil.getClass(balanceId)

		local petModule: Pets.PetFunctions<Pets.Pet> = Pets[petClassName]
		assert(petModule, "Unable to find the pet class!")

		local newPet: ModifiedPet = petModule.new(balanceId, owner, cf, workspace) :: any
		maid._pet = newPet
		newPet.IsRunning = false

		local petLevel = PetModifierUtil.getLevel(balanceId)

		--adjusting the pet update method
		newPet.Update = function()
			petModule.Update(newPet)

			--refresh time update
			newPet.BreadPerMinute = petLevel * 10
			-- print(newPet.BreadPerMinute, " updated refresh time!")
		end

		newPet:Update()

		-- print("1")
		if enabled ~= nil then
			-- print("2")
			newPet:SetEquip(enabled)
			local petPosition = inst:FindFirstChild("PetPosition") :: BasePart
			-- print(enabled, petPosition)
			if enabled == true and petPosition then
				-- print("3")
				task.spawn(function()
					-- print("C1")
					newPet.PetModel:PivotTo(petPosition.CFrame)
					newPet:SetAnimation("Work")
					-- print("Test")
					--newPet:MoveTo(petPosition :: BasePart)
				end)
				--newPet.PetModel:PivotTo(petPosition.CFrame)
			end
		end

		local lastActivation = 0

		-- local lastAnimActivation = 0

		-- local animWaitTime = math.random(200, 300) / 100
		newPet.Maid:GiveTask(RunService.Stepped:Connect(function()
			-- -- print("BALANCE", balanceId, "INST", inst:GetFullName())
			local breadPerMinute = PetModifierUtil.getBreadPerMinute(balanceId)
			if tick() - lastActivation >= 60 / breadPerMinute then
				if getBreadCount() > 0 then
					lastActivation = tick()
					newPet.IsRunning = true
					if getIfEquipped() then
						--play animation
						task.spawn(function()
							local rand = math.random(1, 5)
							newPet:SetAnimation(
								if rand == 1 then "Work" elseif rand == 2 then "Spin" elseif rand == 3 then "BigSpin" elseif rand == 4 then "BackFlip" elseif rand == 5 then "SideFlip" else "Rise"
							)
						end)

						--do bread production
						onActivate()
					end
					newPet.IsRunning = false
				end
			end

			--pet animation
			--[[if (tick() - lastAnimActivation) >= animWaitTime then
				lastAnimActivation = tick()

				local rand = math.random(1, 5)

				newPet:SetAnimation( 
					if rand == 1 then "Work"
						elseif rand == 2 then "Spin"
						elseif rand == 3 then "BigSpin"
						elseif rand == 4 then "BackFlip"
						elseif rand == 5 then "SideFlip"
					else "Rise" 
				)
				animWaitTime = math.random(200,300)/100 
			end]]
		end))
	else
		maid._pet = nil
	end
end
