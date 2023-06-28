--!strict
-- Services
local Players = game:GetService("Players")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- Modules
local HatchTrigger = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("HatchTrigger"))
-- Types
type Maid = Maid.Maid
-- Constants
-- Variables
-- References
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui") :: PlayerGui
-- Class
HatchTrigger(Maid.new(), PlayerGui)
