--!strict
-- Services
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Packages
-- Modules
-- Types
-- Constants
local MAX_LOAD_DURATION = 20
local MESSAGES = {
	"Baking Doughs",
	"Delivering the breads",
	"Jumping across tracks",
	"Claiming your Factory",
}

-- Variables
-- References
local Asset = ReplicatedStorage:WaitForChild("Assets")
local ComponentsByLevel = Asset:WaitForChild("ComponentsByLevel")
local Player = Players.LocalPlayer
local LoadingScreen = ReplicatedFirst:WaitForChild("LoadingScreenGui") :: ScreenGui

-- Private Functions
function getAssetIds(): {[number]: string}
	local assetUrls: {[number]: string} = {}

	local function processInstance(inst: Instance)
		if inst:IsA("MeshPart") then
			table.insert(assetUrls, inst.MeshId)
		elseif inst:IsA("Decal") then
			table.insert(assetUrls, inst.Texture)
		elseif inst:IsA("Texture") then
			table.insert(assetUrls, inst.Texture)
		-- elseif inst:IsA("SurfaceAppearance") then
		-- 	if inst.ColorMap ~= "" then
		-- 		table.insert(assetUrls, inst.ColorMap)
		-- 	end
		-- 	if inst.MetalnessMap ~= "" then
		-- 		table.insert(assetUrls, inst.MetalnessMap)
		-- 	end
		-- 	if inst.NormalMap ~= "" then
		-- 		table.insert(assetUrls, inst.NormalMap)
		-- 	end
		-- 	if inst.RoughnessMap ~= "" then
		-- 		table.insert(assetUrls, inst.RoughnessMap)
		-- 	end
		end
	end

	for i, inst in ipairs(ComponentsByLevel:GetDescendants()) do
		processInstance(inst)
	end
	for i, inst in ipairs(StarterGui:GetDescendants()) do
		processInstance(inst)
	end
	for i, inst in ipairs(workspace:WaitForChild("Map"):WaitForChild("Placeholder assets"):GetDescendants()) do
		processInstance(inst)
	end
	for i, inst in ipairs(workspace:WaitForChild("Map"):WaitForChild("Placeholders"):GetDescendants()) do
		processInstance(inst)
	end
	-- for i, inst in ipairs(workspace:WaitForChild("Map"):GetDescendants()) do
	-- 	processInstance(inst)
	-- end
	return assetUrls
end
function displayMessage(screen: ScreenGui)
	local newMessage = MESSAGES[math.random(1, #MESSAGES)]
	local frame = screen:WaitForChild("Frame") :: Frame

	local messageLabel = frame:WaitForChild("Message") :: TextLabel
	messageLabel.TextStrokeTransparency = 1
	messageLabel.TextTransparency = 1
	messageLabel.Text = newMessage

	local tweenA = TweenService:Create(
		messageLabel, 
		TweenInfo.new(
			0.5, 
			Enum.EasingStyle.Sine, 
			Enum.EasingDirection.InOut
		),
		{
			TextStrokeTransparency = 0, 
			TextTransparency = 0
		}
	)
	tweenA:Play()
	tweenA.Completed:Wait()

	task.wait(3)

	local tweenB = TweenService:Create(
		messageLabel, 
		TweenInfo.new(
			0.5, 
			Enum.EasingStyle.Sine, 
			Enum.EasingDirection.InOut
		), 
		{
			TextStrokeTransparency = 1, 
			TextTransparency = 1
		}
	)
	tweenB:Play()
	tweenB.Completed:Wait()

end

-- Class
function boot()
	ReplicatedFirst:RemoveDefaultLoadingScreen()

	repeat task.wait() until game:IsLoaded()

	local loadScreen = LoadingScreen:Clone()
	loadScreen.Parent = Player.PlayerGui

	local shadowFrame = loadScreen:WaitForChild("Shadow") :: Frame
	local mainFrame = loadScreen:WaitForChild("Frame") :: Frame

	local startTick = tick()
	local loadCount = 0
	local assetIds = getAssetIds()
	ContentProvider:PreloadAsync(assetIds, function()
		loadCount += 1
		print(`Load progress: [{loadCount}/{#assetIds}]`)
	end)

	repeat
		displayMessage(loadScreen)
	until loadCount >= #assetIds or tick() - startTick > MAX_LOAD_DURATION

	shadowFrame.BackgroundTransparency = 1
	
	local tweenA = TweenService:Create(
		shadowFrame, 
		TweenInfo.new(
			1, 
			Enum.EasingStyle.Sine, 
			Enum.EasingDirection.InOut
		), 
		{
			BackgroundTransparency = 0
		}
	)
	tweenA:Play()
	tweenA.Completed:Wait()

	mainFrame.Visible = false
	
	task.wait(1)
	
	local tweenB = TweenService:Create(
		shadowFrame, 
		TweenInfo.new(
			1, 
			Enum.EasingStyle.Sine, 
			Enum.EasingDirection.InOut
		), 
		{
			BackgroundTransparency = 1
		}
	)

	tweenB:Play()
	tweenB.Completed:Wait()	
	loadScreen:Destroy()
end

boot()