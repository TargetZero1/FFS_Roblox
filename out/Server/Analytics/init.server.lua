--!strict
-- this script was generated by nightcycle/midas-clt, do not manually edit

-- packages
local Maid = require(script:WaitForChild("Packages"):WaitForChild("Maid"))
local Midas = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Midas"))

type Maid = Maid.Maid

function init(maid: Maid): nil
	
-- configure package 
Midas:Configure({
		["Version"] = {
			["Major"] = 1,
			["Minor"] = 0,
			["Patch"] = 7,
			["hotfix"] = 0,
		},
		["Encoding"] = {
			["Marker"] = "~",
			["Dictionary"] = {
				["Properties"] = {
					["Textures"] = "~H",
					["Cat_Normal_4"] = "~L",
					["Mouse_Normal_1"] = "~O",
					["Bird_Normal_5"] = "~#K",
					["Recharge"] = "~#R",
					["TimedReward"] = "~+",
					["Chat"] = "~#4",
					["Cat_Diamond_3"] = "~&L",
					["TerrainGraphics"] = "~$4",
					["Dog_Diamond_1"] = "~#H",
					["Cat_Normal_1"] = "~&C",
					["PeakFriends"] = "~&7",
					["Level5"] = "~#",
					["Mouse_Normal_5"] = "~&;",
					["Bird_Gold_1"] = "~%A",
					["Mouse_Normal_4"] = "~4",
					["Level11"] = "~C",
					["Easy"] = "~#'",
					["SpatialHash"] = "~%8",
					["Truck"] = "~&Q",
					["Gamepass"] = "~&E",
					["Dog_Diamond_5"] = "~%3",
					["Bird_Silver_4"] = "~&=",
					["Signals"] = "~%1",
					["Windmill"] = "~%;",
					["Total"] = "~Q",
					["Value"] = "~$'",
					["PetManagement"] = "~&?",
					["SpeakingDistance"] = "~%*",
					["Cat_Silver_3"] = "~$#",
					["Order"] = "~%#",
					["IdleTycoon"] = "~$M",
					["Dog_Normal_2"] = "~&0",
					["Dog_Silver_2"] = "~$T",
					["Script"] = "~%Y",
					["Dog_Gold_3"] = "~$9",
					["Major"] = "~%(",
					["Level2"] = "~$D",
					["Server"] = "~5",
					["X"] = "~&9",
					["Cat_Normal_3"] = "~%I",
					["Bird_Diamond_5"] = "~%7",
					["Dog_Gold_2"] = "~$A",
					["UpgradingTycoon"] = "~&A",
					["Kneader"] = "~%)",
					["LastMessage"] = "~W",
					["Demographics"] = "~#Q",
					["Id"] = "~$G",
					["Dog_Silver_4"] = "~%P",
					["Cat_Silver_5"] = "~%R",
					["Purchase"] = "~#W",
					["Completed"] = "~&B",
					["Deposit"] = "~;",
					["Mouse_Diamond_4"] = "~#%",
					["Cash"] = "~#$",
					["HttpCache"] = "~$I",
					["Onboarding"] = "~#9",
					["SystemLanguage"] = "~#(",
					["Level10"] = "~%O",
					["IsStudio"] = "~Z",
					["Bird_Silver_2"] = "~&G",
					["IsInGroup"] = "~%&",
					["MovingParts"] = "~$)",
					["Internal"] = "~#S",
					["SuperOven"] = "~$P",
					["Friends"] = "~#T",
					["DoubleBread"] = "~%S",
					["Spending"] = "~%4",
					["Dog_Gold_1"] = "~$8",
					["DoubleBreadValue"] = "~&H",
					["SuperWrapper"] = "~A",
					["Level7"] = "~%?",
					["Cat_Normal_5"] = "~$J",
					["Bake"] = "~%C",
					["Population"] = "~$",
					["LastDelivery"] = "~&O",
					["Patch"] = "~%",
					["Dog_Silver_5"] = "~%+",
					["PhysicsParts"] = "~#?",
					["TerrainVoxels"] = "~#<",
					["Mouse"] = "~I",
					["NSG"] = "~#@",
					["Market"] = "~&3",
					["Send"] = "~%=",
					["Hatch"] = "~#-",
					["User"] = "~$C",
					["ActiveTimer"] = "~%D",
					["Guis"] = "~$+",
					["Price"] = "~%U",
					["GlobalTimer"] = "~$.",
					["Cat_Gold_4"] = "~$S",
					["Performance"] = "~&$",
					["Mouse_Silver_4"] = "~&N",
					["Obby"] = "~&%",
					["Name"] = "~$-",
					["Dog_Gold_4"] = "~U",
					["Bird_Gold_2"] = "~&,",
					["Explore"] = "~#2",
					["Bird_Silver_1"] = "~&+",
					["Cat_Gold_2"] = "~8",
					["Level9"] = "~%G",
					["Mouse_Gold_4"] = "~$;",
					["Rebirths"] = "~&T",
					["Receive"] = "~#C",
					["Level4"] = "~.",
					["Mouse_Diamond_1"] = "~@",
					["Dog_Normal_5"] = "~&4",
					["Dog_Normal_3"] = "~$O",
					["Cat_Diamond_1"] = "~$L",
					["Bird_Normal_3"] = "~2",
					["Knead"] = "~#6",
					["Wrap"] = "~S",
					["Gamepad"] = "~-",
					["CSG"] = "~'",
					["Weights"] = "~#*",
					["Cat_Silver_4"] = "~$5",
					["SoundsStreaming"] = "~&.",
					["Level12"] = "~$Q",
					["PetBalanceId"] = "~%0",
					["Mouse_Diamond_3"] = "~$R",
					["Level1"] = "~K",
					["Build"] = "~#D",
					["Z"] = "~N",
					["Dog_Diamond_4"] = "~%9",
					["Cat_Gold_1"] = "~0",
					["AccountAge"] = "~B",
					["Count"] = "~$=",
					["LuaHeap"] = "~$?",
					["Keyboard"] = "~%6",
					["Groups"] = "~$2",
					["Cat_Gold_3"] = "~&<",
					["CharacterTextures"] = "~<",
					["Pets"] = "~$V",
					["RebirthCount"] = "~M",
					["Accelerometer"] = "~$>",
					["Cat_Silver_1"] = "~$,",
					["Ping"] = "~T",
					["Mouse_Diamond_5"] = "~$$",
					["PhysicsCollision"] = "~&D",
					["Index"] = "~#M",
					["Gamepasses"] = "~%%",
					["Gyroscope"] = "~%5",
					["Hard"] = "~#7",
					["Dog_Diamond_2"] = "~$0",
					["VisitTycoon"] = "~#N",
					["Mouse_Diamond_2"] = "~%@",
					["Bird_Gold_4"] = "~#E",
					["HeartRate"] = "~#G",
					["Tycoon"] = "~$B",
					["Place"] = "~$%",
					["Timer"] = "~&)",
					["Mouse_Silver_3"] = "~&1",
					["ScreenRatio"] = "~&/",
					["Cat_Silver_2"] = "~(",
					["Mouse_Gold_1"] = "~V",
					["InfiniteTray"] = "~$7",
					["Deliver"] = "~%T",
					["Mouse_Silver_1"] = "~9",
					["MeshPart"] = "~%W",
					["Dog_Silver_1"] = "~&F",
					["Cat_Gold_5"] = "~&2",
					["Platform"] = "~$Y",
					["Minor"] = "~#P",
					["Animations"] = "~%<",
					["Wrapper"] = "~#;",
					["Mouse_Gold_3"] = "~&#",
					["Oven"] = "~%$",
					["Bird_Gold_3"] = "~#L",
					["Particle"] = "~&&",
					["ServerTime"] = "~$*",
					["Duration"] = "~$E",
					["Mouse_Silver_2"] = "~$N",
					["EventsPerMinute"] = "~7",
					["ScreenSize"] = "~#8",
					["Mouse_Normal_3"] = "~#1",
					["Mouse_Gold_2"] = "~%N",
					["Dog_Normal_1"] = "~%M",
					["Event"] = "~&M",
					["RobloxLangugage"] = "~$6",
					["RunningStation"] = "~#B",
					["Touch"] = "~$H",
					["Bird_Gold_5"] = "~#,",
					["Mouse_Gold_5"] = "~Y",
					["Bird_Normal_1"] = "~$!",
					["Network"] = "~3",
					["Storage"] = "~/",
					["Cat_Diamond_2"] = "~#X",
					["Bird_Silver_5"] = "~?",
					["Rack"] = "~%F",
					["Physics"] = "~&*",
					["Session"] = "~#)",
					["Bird_Normal_4"] = "~&I",
					["Collect"] = "~$U",
					["Level8"] = "~#.",
					["Assign"] = "~#O",
					["Part"] = "~$W",
					["Bird_Diamond_3"] = "~$X",
					["Cat_Diamond_5"] = "~E",
					["Memory"] = "~,",
					["Instances"] = "~#V",
					["PositionPercent"] = "~%'",
					["GameplayEvent"] = "~$1",
					["Level3"] = "~#F",
					["Bird_Silver_3"] = "~$&",
					["Team"] = "~#=",
					["DayReward"] = "~%/",
					["DeliveryCount"] = "~&P",
					["Product"] = "~#I",
					["PetHatch"] = "~$3",
					["Cat_Diamond_4"] = "~%Q",
					["Bird_Diamond_2"] = "~$F",
					["Mouse_Normal_2"] = "~%B",
					["Bird_Diamond_4"] = "~>",
					["Dog_Gold_5"] = "~#+",
					["Pathfinding"] = "~%E",
					["IsUnlocked"] = "~&S",
					["Dog_Normal_4"] = "~%,",
					["Multiplier"] = "~&",
					["Data"] = "~#3",
					["SuperKneader"] = "~G",
					["Level"] = "~&5",
					["Additions"] = "~#5",
					["Dog_Silver_3"] = "~%V",
					["Bird_Normal_2"] = "~&-",
					["Dog_Diamond_3"] = "~%>",
					["Bird_Diamond_1"] = "~%K",
					["SoundsData"] = "~&8",
					["Version"] = "~R",
					["Cat_Normal_2"] = "~#U",
					["Level6"] = "~#>",
					["Mouse_Silver_5"] = "~X",
				},
				["Values"] = {
					["Timer"] = {
						["Level1"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
						["Level2"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
						["Level3"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
						["Level4"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
						["Level5"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
						["Level6"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
						["Level7"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
						["Level8"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
						["Level9"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
						["Level10"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
						["Level11"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
						["Level12"] = {
							["Available"] = "~%L",
							["Locked"] = "~)",
							["Reloading"] = "~##",
						},
					},
					["Tycoon"] = {
						["Wrapper"] = {
							["PetBalanceId"] = {
								["None"] = "~#/",
								["Cat_Silver_1"] = "~$,",
								["Cat_Gold_1"] = "~0",
								["Cat_Diamond_1"] = "~$L",
								["Cat_Normal_1"] = "~&C",
								["Dog_Silver_1"] = "~&F",
								["Dog_Gold_1"] = "~$8",
								["Dog_Diamond_1"] = "~#H",
								["Dog_Normal_1"] = "~%M",
								["Mouse_Silver_1"] = "~9",
								["Mouse_Gold_1"] = "~V",
								["Mouse_Diamond_1"] = "~@",
								["Mouse_Normal_1"] = "~O",
								["Bird_Silver_1"] = "~&+",
								["Bird_Gold_1"] = "~%A",
								["Bird_Diamond_1"] = "~%K",
								["Bird_Normal_1"] = "~$!",
								["Cat_Silver_2"] = "~(",
								["Cat_Gold_2"] = "~8",
								["Cat_Diamond_2"] = "~#X",
								["Cat_Normal_2"] = "~#U",
								["Dog_Silver_2"] = "~$T",
								["Dog_Gold_2"] = "~$A",
								["Dog_Diamond_2"] = "~$0",
								["Dog_Normal_2"] = "~&0",
								["Mouse_Silver_2"] = "~$N",
								["Mouse_Gold_2"] = "~%N",
								["Mouse_Diamond_2"] = "~%@",
								["Mouse_Normal_2"] = "~%B",
								["Bird_Silver_2"] = "~&G",
								["Bird_Gold_2"] = "~&,",
								["Bird_Diamond_2"] = "~$F",
								["Bird_Normal_2"] = "~&-",
								["Cat_Silver_3"] = "~$#",
								["Cat_Gold_3"] = "~&<",
								["Cat_Diamond_3"] = "~&L",
								["Cat_Normal_3"] = "~%I",
								["Dog_Silver_3"] = "~%V",
								["Dog_Gold_3"] = "~$9",
								["Dog_Diamond_3"] = "~%>",
								["Dog_Normal_3"] = "~$O",
								["Mouse_Silver_3"] = "~&1",
								["Mouse_Gold_3"] = "~&#",
								["Mouse_Diamond_3"] = "~$R",
								["Mouse_Normal_3"] = "~#1",
								["Bird_Silver_3"] = "~$&",
								["Bird_Gold_3"] = "~#L",
								["Bird_Diamond_3"] = "~$X",
								["Bird_Normal_3"] = "~2",
								["Cat_Silver_4"] = "~$5",
								["Cat_Gold_4"] = "~$S",
								["Cat_Diamond_4"] = "~%Q",
								["Cat_Normal_4"] = "~L",
								["Dog_Silver_4"] = "~%P",
								["Dog_Gold_4"] = "~U",
								["Dog_Diamond_4"] = "~%9",
								["Dog_Normal_4"] = "~%,",
								["Mouse_Silver_4"] = "~&N",
								["Mouse_Gold_4"] = "~$;",
								["Mouse_Diamond_4"] = "~#%",
								["Mouse_Normal_4"] = "~4",
								["Bird_Silver_4"] = "~&=",
								["Bird_Gold_4"] = "~#E",
								["Bird_Diamond_4"] = "~>",
								["Bird_Normal_4"] = "~&I",
								["Cat_Silver_5"] = "~%R",
								["Cat_Gold_5"] = "~&2",
								["Cat_Diamond_5"] = "~E",
								["Cat_Normal_5"] = "~$J",
								["Dog_Silver_5"] = "~%+",
								["Dog_Gold_5"] = "~#+",
								["Dog_Diamond_5"] = "~%3",
								["Dog_Normal_5"] = "~&4",
								["Mouse_Silver_5"] = "~X",
								["Mouse_Gold_5"] = "~Y",
								["Mouse_Diamond_5"] = "~$$",
								["Mouse_Normal_5"] = "~&;",
								["Bird_Silver_5"] = "~?",
								["Bird_Gold_5"] = "~#,",
								["Bird_Diamond_5"] = "~%7",
								["Bird_Normal_5"] = "~#K",
							},
						},
						["Kneader"] = {
							["PetBalanceId"] = {
								["None"] = "~#/",
								["Cat_Silver_1"] = "~$,",
								["Cat_Gold_1"] = "~0",
								["Cat_Diamond_1"] = "~$L",
								["Cat_Normal_1"] = "~&C",
								["Dog_Silver_1"] = "~&F",
								["Dog_Gold_1"] = "~$8",
								["Dog_Diamond_1"] = "~#H",
								["Dog_Normal_1"] = "~%M",
								["Mouse_Silver_1"] = "~9",
								["Mouse_Gold_1"] = "~V",
								["Mouse_Diamond_1"] = "~@",
								["Mouse_Normal_1"] = "~O",
								["Bird_Silver_1"] = "~&+",
								["Bird_Gold_1"] = "~%A",
								["Bird_Diamond_1"] = "~%K",
								["Bird_Normal_1"] = "~$!",
								["Cat_Silver_2"] = "~(",
								["Cat_Gold_2"] = "~8",
								["Cat_Diamond_2"] = "~#X",
								["Cat_Normal_2"] = "~#U",
								["Dog_Silver_2"] = "~$T",
								["Dog_Gold_2"] = "~$A",
								["Dog_Diamond_2"] = "~$0",
								["Dog_Normal_2"] = "~&0",
								["Mouse_Silver_2"] = "~$N",
								["Mouse_Gold_2"] = "~%N",
								["Mouse_Diamond_2"] = "~%@",
								["Mouse_Normal_2"] = "~%B",
								["Bird_Silver_2"] = "~&G",
								["Bird_Gold_2"] = "~&,",
								["Bird_Diamond_2"] = "~$F",
								["Bird_Normal_2"] = "~&-",
								["Cat_Silver_3"] = "~$#",
								["Cat_Gold_3"] = "~&<",
								["Cat_Diamond_3"] = "~&L",
								["Cat_Normal_3"] = "~%I",
								["Dog_Silver_3"] = "~%V",
								["Dog_Gold_3"] = "~$9",
								["Dog_Diamond_3"] = "~%>",
								["Dog_Normal_3"] = "~$O",
								["Mouse_Silver_3"] = "~&1",
								["Mouse_Gold_3"] = "~&#",
								["Mouse_Diamond_3"] = "~$R",
								["Mouse_Normal_3"] = "~#1",
								["Bird_Silver_3"] = "~$&",
								["Bird_Gold_3"] = "~#L",
								["Bird_Diamond_3"] = "~$X",
								["Bird_Normal_3"] = "~2",
								["Cat_Silver_4"] = "~$5",
								["Cat_Gold_4"] = "~$S",
								["Cat_Diamond_4"] = "~%Q",
								["Cat_Normal_4"] = "~L",
								["Dog_Silver_4"] = "~%P",
								["Dog_Gold_4"] = "~U",
								["Dog_Diamond_4"] = "~%9",
								["Dog_Normal_4"] = "~%,",
								["Mouse_Silver_4"] = "~&N",
								["Mouse_Gold_4"] = "~$;",
								["Mouse_Diamond_4"] = "~#%",
								["Mouse_Normal_4"] = "~4",
								["Bird_Silver_4"] = "~&=",
								["Bird_Gold_4"] = "~#E",
								["Bird_Diamond_4"] = "~>",
								["Bird_Normal_4"] = "~&I",
								["Cat_Silver_5"] = "~%R",
								["Cat_Gold_5"] = "~&2",
								["Cat_Diamond_5"] = "~E",
								["Cat_Normal_5"] = "~$J",
								["Dog_Silver_5"] = "~%+",
								["Dog_Gold_5"] = "~#+",
								["Dog_Diamond_5"] = "~%3",
								["Dog_Normal_5"] = "~&4",
								["Mouse_Silver_5"] = "~X",
								["Mouse_Gold_5"] = "~Y",
								["Mouse_Diamond_5"] = "~$$",
								["Mouse_Normal_5"] = "~&;",
								["Bird_Silver_5"] = "~?",
								["Bird_Gold_5"] = "~#,",
								["Bird_Diamond_5"] = "~%7",
								["Bird_Normal_5"] = "~#K",
							},
						},
						["Oven"] = {
							["PetBalanceId"] = {
								["None"] = "~#/",
								["Cat_Silver_1"] = "~$,",
								["Cat_Gold_1"] = "~0",
								["Cat_Diamond_1"] = "~$L",
								["Cat_Normal_1"] = "~&C",
								["Dog_Silver_1"] = "~&F",
								["Dog_Gold_1"] = "~$8",
								["Dog_Diamond_1"] = "~#H",
								["Dog_Normal_1"] = "~%M",
								["Mouse_Silver_1"] = "~9",
								["Mouse_Gold_1"] = "~V",
								["Mouse_Diamond_1"] = "~@",
								["Mouse_Normal_1"] = "~O",
								["Bird_Silver_1"] = "~&+",
								["Bird_Gold_1"] = "~%A",
								["Bird_Diamond_1"] = "~%K",
								["Bird_Normal_1"] = "~$!",
								["Cat_Silver_2"] = "~(",
								["Cat_Gold_2"] = "~8",
								["Cat_Diamond_2"] = "~#X",
								["Cat_Normal_2"] = "~#U",
								["Dog_Silver_2"] = "~$T",
								["Dog_Gold_2"] = "~$A",
								["Dog_Diamond_2"] = "~$0",
								["Dog_Normal_2"] = "~&0",
								["Mouse_Silver_2"] = "~$N",
								["Mouse_Gold_2"] = "~%N",
								["Mouse_Diamond_2"] = "~%@",
								["Mouse_Normal_2"] = "~%B",
								["Bird_Silver_2"] = "~&G",
								["Bird_Gold_2"] = "~&,",
								["Bird_Diamond_2"] = "~$F",
								["Bird_Normal_2"] = "~&-",
								["Cat_Silver_3"] = "~$#",
								["Cat_Gold_3"] = "~&<",
								["Cat_Diamond_3"] = "~&L",
								["Cat_Normal_3"] = "~%I",
								["Dog_Silver_3"] = "~%V",
								["Dog_Gold_3"] = "~$9",
								["Dog_Diamond_3"] = "~%>",
								["Dog_Normal_3"] = "~$O",
								["Mouse_Silver_3"] = "~&1",
								["Mouse_Gold_3"] = "~&#",
								["Mouse_Diamond_3"] = "~$R",
								["Mouse_Normal_3"] = "~#1",
								["Bird_Silver_3"] = "~$&",
								["Bird_Gold_3"] = "~#L",
								["Bird_Diamond_3"] = "~$X",
								["Bird_Normal_3"] = "~2",
								["Cat_Silver_4"] = "~$5",
								["Cat_Gold_4"] = "~$S",
								["Cat_Diamond_4"] = "~%Q",
								["Cat_Normal_4"] = "~L",
								["Dog_Silver_4"] = "~%P",
								["Dog_Gold_4"] = "~U",
								["Dog_Diamond_4"] = "~%9",
								["Dog_Normal_4"] = "~%,",
								["Mouse_Silver_4"] = "~&N",
								["Mouse_Gold_4"] = "~$;",
								["Mouse_Diamond_4"] = "~#%",
								["Mouse_Normal_4"] = "~4",
								["Bird_Silver_4"] = "~&=",
								["Bird_Gold_4"] = "~#E",
								["Bird_Diamond_4"] = "~>",
								["Bird_Normal_4"] = "~&I",
								["Cat_Silver_5"] = "~%R",
								["Cat_Gold_5"] = "~&2",
								["Cat_Diamond_5"] = "~E",
								["Cat_Normal_5"] = "~$J",
								["Dog_Silver_5"] = "~%+",
								["Dog_Gold_5"] = "~#+",
								["Dog_Diamond_5"] = "~%3",
								["Dog_Normal_5"] = "~&4",
								["Mouse_Silver_5"] = "~X",
								["Mouse_Gold_5"] = "~Y",
								["Mouse_Diamond_5"] = "~$$",
								["Mouse_Normal_5"] = "~&;",
								["Bird_Silver_5"] = "~?",
								["Bird_Gold_5"] = "~#,",
								["Bird_Diamond_5"] = "~%7",
								["Bird_Normal_5"] = "~#K",
							},
						},
					},
					["Market"] = {
						["Purchase"] = {
							["Product"] = {
								["Name"] = {
									["Donate5"] = "~&!",
									["Donate10"] = "~&(",
									["Donate25"] = "~%!",
									["Donate50"] = "~P",
									["Donate100"] = "~=",
									["Donate200"] = "~1",
									["Donate500"] = "~%.",
									["DoubleBread2"] = "~$/",
									["DoubleBread5"] = "~%J",
									["DoubleBread10"] = "~D",
									["DoubleBread15"] = "~&J",
									["DoubleBread30"] = "~&K",
									["DoubleBread60"] = "~$(",
									["ServerDoubleBread2"] = "~&6",
									["ServerDoubleBread5"] = "~$@",
									["ServerDoubleBread10"] = "~F",
									["ServerDoubleBread15"] = "~6",
									["ServerDoubleBread30"] = "~#&",
									["ServerDoubleBread60"] = "~%X",
									["Cash5k"] = "~$<",
									["Cash10k"] = "~&@",
									["Cash50k"] = "~$K",
									["Cash100k"] = "~&>",
									["Cash250k"] = "~#J",
									["Cash500k"] = "~#Y",
								},
							},
							["Gamepass"] = {
								["Name"] = {
									["DoubleBreadValue"] = "~&H",
									["SuperKneader"] = "~G",
									["SuperOven"] = "~$P",
									["SuperWrapper"] = "~A",
									["InfiniteTray"] = "~$7",
								},
							},
						},
					},
					["Demographics"] = {
						["Platform"] = {
							["ScreenRatio"] = {
								["16:10"] = "~%H",
								["16:9"] = "~%2",
								["5:4"] = "~#A",
								["5:3"] = "~J",
								["3:2"] = "~*",
								["4:3"] = "~&'",
								["9:16"] = "~%-",
								["uncommon"] = "~#0",
							},
						},
					},
				},
			},
			["Arrays"] = {
				["Groups"] = 				{
									"NSG",
				},
				["GameplayEvent"] = {
					["Obby"] = 					{
											"Easy",
											"Hard",
					},
				},
				["Market"] = {
					["Gamepasses"] = 					{
											"DoubleBreadValue",
											"SuperKneader",
											"SuperOven",
											"SuperWrapper",
											"InfiniteTray",
					},
				},
			},
		},
		["SendDeltaState"] = false,
		["PrintLog"] = false,
		["SendDataToPlayFab"] = true,
		["Templates"] = {
			["Join"] = true,
			["Chat"] = true,
			["Population"] = true,
			["ServerPerformance"] = true,
			["Market"] = true,
			["Exit"] = true,
			["Character"] = false,
			["Player"] = false,
			["Demographics"] = true,
			["ClientPerformance"] = false,
			["Group"] = {
				["NSG"] = 11827920,
			},
		},
	})
	
-- initialize playfab http request variables 
Midas.init("FAF6D", "P8RTXB1RG6WPACT7UEEM1M5PFQGFQJKMJHFR7CG3ON9R6XX5YO")
	
maid:GiveTask(Midas)
	
return nil
end

local maid = Maid.new()
maid:GiveTask(script.Destroying:Connect(function() maid:Destroy() end))
init(maid)