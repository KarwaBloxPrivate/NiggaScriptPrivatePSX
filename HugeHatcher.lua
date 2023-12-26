--Huge Hatcher
--To Do List 
--[[
	Farm Banana Fruits when under (selected amount)
	Farm coins to have enough to open (selected amount) eggs
	Get the newest egg with huges
	Auto best team loadout
	Farm again coins when no left to hatch 
	Webhook Notifier with huge hatched 
	Stats how many huges hatcher per acc and which huges (per selected amount of hrs)
	Auto Event farmer (50x luck huge finder)
]]

local Settings = {
	FarmFruits = {
		Farm = true,
		FarmOption = "Server Hop", --Normal | Server Hop
		MinAmount = 150,
		MaxAmount = 200
	},
	HatchWhenSelectedAmountEggsAvailable = 10000,
	EggSettings = {
		triple = false,
		octuple = true,
		DisableEggAnim = true
	},
	AreaToFarm = "AreaOfEgg", -- AreaOfEgg is gonna farm Area that egg is in or just the area
	EggToHatch = "Barn Doodle Egg", --Newest one with huge is gonna get the newest egg that has huge in it and hatch it or you can select any egg you want
	AreaOfEggIfAreaIsNil = "Doodle Barn",
	BestTeamLoadout = true,
	WebhookNotify = {
		Webhook = "https://discord.com/api/webhooks/1123611155303235604/he0sQyBFyGfMx5YIYYKVvNqYNMyWqIdvb7pkmUZ6slxrR1B4DXusPwUo0S42GjnCjHDj",
		SendMythical = false,
		SendSecret = false,
		SendHuge = true
	},
	WebhookStats = {
		TimeToSend = 60*60*4,
		SaveSecrets = false,
	},
	Boosts = {
		TripleDamage = true,
		TripleCoins = true,
		SuperLucky = true,
		UltaryLucky = true
	},
	ServerBoosts = {
		TripleCoins = true,
		TripleDamage = true,
		SuperLucky = true,
	},
	Optimization = {
		FpsCap = 20,
		Disable3dRenderingOnAltTab = false,
		ChangeBackTo60FpsOnTabbed = false
	},
	BlacklistedUsers = {
	},
	Stop = false
}

local BlacklistedWorlds = {
	"Diamond Mine",
	"Dog",
	"Void",
	"Summer Event",
	"Yeet",
	"Halloween Event",
	"Limbo"
}

local BlacklistedAreas = {
	"VIP",
	"Portals",
	"Cat Throne Room",
	"Secret House",
	"Secret Vault",
	"Doodle Barn",
	"Steampunk Chest",
	"Alien Chest",
	"Limbo",
	"Shop",
	"Fantasy Shop",
	"Tech Shop",
	"The Void",
	"Tech Entry"
}

local BlacklistedFruits = {
}

repeat task.wait() until game:IsLoaded()

local ScriptLog = "[Karwa's Scripts Huge Hatcher] "

if table.find(Settings.BlacklistedUsers, game:GetService("Players").LocalPlayer.Name) then
	print(ScriptLog.."Farming Stopped Beacuse Username Is On Blacklist")
	return
elseif Settings.Stop then
	print(ScriptLog.."Farming Stopped")
	return
end

task.wait(5)

local lib = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"))

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local Servers = {}

function UpdateServers()
	print(ScriptLog.."Getting Servers...")
	local url = 'https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=Asc&limit=100'
	local success, result = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(url))
	end)
	if success then
		for i, v in pairs(result.data) do
			if v.playing > 0 and v.playing < v.maxPlayers then
				Servers[i] = v
			end
		end
		for i = #Servers, 2, -1 do
			local j = math.random(i)
			Servers[i], Servers[j] = Servers[j], Servers[i]
		end
		print(ScriptLog.."Got Servers")
	else
		print(ScriptLog.."Failed To Get Servers")
	end
end

function RemoveValueFromTable(tbl, value)
	local i = 1
	while i <= #tbl do
		if tbl[i] == value then
			table.remove(tbl, i)
		else
			i = i + 1
		end
	end
end

if not getgenv().HookedAntiCheat then
	local functions = lib.Network.Fire, lib.Network.Invoke
	local NetworkHook 
	NetworkHook = hookfunction(getupvalue(functions, 1) , function(...) return true end)
	local Blunder = require(game:GetService("ReplicatedStorage"):FindFirstChild("BlunderList", true))
	local OldGet = Blunder.getAndClear
	setreadonly(Blunder, false)
	local function OutputData(Message)
		return Message
	end
	Blunder.getAndClear = function(...)
		local Packet = ...
		for i,v in next, Packet.list do
			if v.message ~= "PING" then
				OutputData(v.message)
				table.remove(Packet.list, i)
			end
		end
		return OldGet(Packet)
	end
	local OldAudio
	OldAudio = hookfunction(lib.Audio.Play, function(Sound, ...)
		local args = {Sound, ..., Stop = function(...) end}
		if Sound == "rbxassetid://7009904957" or Sound == "rbxassetid://7000720081" or Sound == "rbxassetid://7358008634" then
			return nil
		end
		return args
	end)
	for i, v in pairs(getconstants(lib.WorldCmds.Load)) do
		if v == "Sound" then
			setconstant(lib.WorldCmds.Load, i, "ADAWDAWDAWD")
		end
	end
	game:GetService("Players").LocalPlayer.PlayerScripts["Idle Tracking"].Enabled = false
	getgenv().HookedAntiCheat = true
end

function GetNewestEgg()
	local Result
	local TempTable = {}

	for i, v in pairs(lib.Directory.Eggs) do
		if v.hatchable and typeof(v.drops) == "table" then
			for ii, vv in pairs(v.drops) do
				local Info = {
					Id = vv[1],
					Egg = i
				}
				table.insert(TempTable, Info)
				--local IsHardcore = vv[3] and "[Hardcore Only: true]" or "[Hardcore Only: false]" 
			end
		end
	end

	table.sort(TempTable, function(a, b) return tonumber(a.Id) < tonumber(b.Id) end)

	for i, v in pairs(TempTable) do
		Result = v.Egg
	end

	return Result
end

setfpscap(Settings.Optimization.FpsCap)

if Settings.Optimization.Disable3dRenderingOnAltTab then
	game:GetService("RunService"):Set3dRenderingEnabled(false)
	game:GetService("UserInputService").WindowFocusReleased:Connect(function()
		game:GetService("RunService"):Set3dRenderingEnabled(false)
		setfpscap(Settings.Optimization.FpsCap)
	end)
	game:GetService("UserInputService").WindowFocused:Connect(function()
		game:GetService("RunService"):Set3dRenderingEnabled(true)
		if Settings.Optimization.ChangeBackTo60FpsOnTabbed then
			setfpscap(Settings.Optimization.FpsCap)
		end
	end)
end

local Teleport = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport)

function GetEggCFrame(EggName)
	local Result = "Egg Not Found"
	local EggModel = lib.Directory.Eggs[EggName].model or nil
	for i, v in pairs(game:GetService("Workspace").__MAP.Eggs:GetDescendants()) do
		if v.ClassName == "MeshPart" and v.TextureID == EggModel.TextureID then
			Result = v.CFrame
		end
	end
	return Result
end

function TeleportPlayer(Cframe)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Cframe
end

function TeleportToEgg(Egg)
	local Area = "Town"
	Area = lib.Directory.Eggs[Egg].area == "" and Settings.AreaOfEggIfAreaIsNil or lib.Directory.Eggs[Egg].area 
	local TpChecks = 0
	if lib.Variables.Teleporting then repeat TpChecks = TpChecks + 1 task.wait() until not lib.Variables.Teleporting or TpChecks > 500 end
	if TpChecks > 500 then lib.Variables.Teleporting = false end
	Teleport.Teleport(Area, true)
	local EggCFrame = GetEggCFrame(Egg)
	if EggCFrame ~= "Egg Not Found" then
		TeleportPlayer(EggCFrame)
	else
		print(ScriptLog.."Egg not found")
	end
	return Area
end

function GetMasteryLvl(Mastery)
	local Result = 0
	for i, v in pairs(lib.Save.Get().Mastery) do
		if i == Mastery then
			Result = v
		end
	end
	Result = lib.Shared.MasteryXPToLevel(Result)
	return Result
end

function GetAvailableEggs(Egg)
	local MasteryToCheck = (lib.Directory.Eggs[Egg].isGolden == true and "Golden Eggs") or (lib.Directory.Eggs[Egg].isGolden == false and "Eggs")
	local EggDiscount = 0
	if MasteryToCheck == "Eggs" then
		if GetMasteryLvl(MasteryToCheck) >= 35 and GetMasteryLvl(MasteryToCheck) <= 75 then
			EggDiscount = 0.1
		elseif GetMasteryLvl(MasteryToCheck) >= 75 then
			EggDiscount = 0.2
		end
	elseif MasteryToCheck == "Golden Eggs" then
		if GetMasteryLvl(MasteryToCheck) >= 35 and GetMasteryLvl(MasteryToCheck) <= 75 then
			EggDiscount = 0.05
		elseif GetMasteryLvl(MasteryToCheck) >= 75 then
			EggDiscount = 0.15
		end
	end
	local EggPrice = (lib.Directory.Eggs[Egg].cost) - (lib.Directory.Eggs[Egg].cost * EggDiscount)
	local CurrencyAmount = lib.Save.Get()[lib.Directory.Eggs[Egg].currency]
	local AvailableEggs = math.round(CurrencyAmount/EggPrice)
	return AvailableEggs
end

function GetFruitAmmount(Fruit) 
	return math.round(lib.FruitCmds.Get(LocalPlayer, Fruit))
end	

function GetEquipped()
	local Equipped = {}
	for i, v in pairs(lib.PetCmds.GetEquipped()) do
		table.insert(Equipped, v.uid)
	end
	return Equipped
end

function CollectLtbg()
	for i, v in pairs(game:GetService("Workspace")["__THINGS"].Lootbags:GetChildren()) do	
		local id = v:GetAttribute("ID")
		local cframe = v.CFrame.p
		lib.Network.Fire("Collect Lootbag", id, cframe)
	end	
end

function CollectOrbs()
	local OrbTbl = {}
	for i, v in pairs(game:GetService("Workspace")["__THINGS"].Orbs:GetChildren()) do	
		table.insert(OrbTbl, v.Name)
	end
	if OrbTbl[1] == nil then

	else
		lib.Network.Fire("Claim Orbs", OrbTbl)
	end
	return OrbTbl
end

function ActivateBoost(Boost)
	if (Boost ~= nil) then
		if Boost == "Triple Coins" or "Triple Damage" or "Super Lucky" or "Ultra Lucky" or "Triple Diamonds" then
			if lib.Save.Get().BoostsInventory[Boost] then
				lib.Network.Fire("Activate Boost", Boost)
			end
		else
			print("Boost is not right named")
		end
	else 
		print("Boost is nil")
	end
end
function ActivateServerBoost(Boost)
	if (Boost ~= nil) then
		if Boost == "Triple Coins" or "Triple Damage" or "Super Lucky" then
			if lib.Save.Get().BoostsInventory[Boost] > 20 then
				lib.Network.Fire("Activate Server Boost", Boost)
			end
		else
			print("Boost is not right named")
		end
	else 
		print("Boost is nil")
	end
end

function DisableEggAnim(boolean)
	if boolean then 
		game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = true
	else
		game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = false
	end
end

function SendMessage(Webhook, data) --Skidded from v3rmilion
	local url =
		Webhook
	local newdata = game:GetService("HttpService"):JSONEncode(data)

	local headers = {
		["content-type"] = "application/json"
	}
	request = http_request or request or HttpPost or syn.request
	local abcdef = {Url = url, Body = newdata, Method = "POST", Headers = headers}
	request(abcdef)
end

DisableEggAnim(Settings.EggSettings.DisableEggAnim)

function GetEggsOpened(Egg)
	local restult = "unknown"
	result = lib.Save.Get().EggsOpened[Egg]
	return result
end

if not getgenv().ListeningToPetsHatched then
	getgenv().ListeningToPetsHatched = true
	spawn(function()
		local BeforeTableSize = #lib.Save.Get().Pets
		local BeforeUIDS = {}
		for i, v in pairs(lib.Save.Get().Pets) do
			table.insert(BeforeUIDS, v.uid)
		end
		local FormatOdds = require(game:GetService("ReplicatedStorage").Library.Functions.FormatOdds)
		local function GetEggOddsById(id)
			local Result = "Unknown"
			for i, v in pairs(lib.Directory.Eggs) do
				if typeof(v.drops) == "table" then
					for ii, vv in pairs(v.drops) do
						if vv[1] == id then
							Result = vv[2]
							break
						end			
					end
				end
			end
			return Result
		end
		local function GetEggById(id)
			local Result = "Unknown"
			for i, v in pairs(lib.Directory.Eggs) do
				if typeof(v.drops) == "table" then
					for ii, vv in pairs(v.drops) do
						if vv[1] == id then
							Result = i
							break
						end			
					end
				end
			end
			return Result
		end
		while task.wait(0.1) do
			if getgenv().HatchingEgg then
				local CurrentTableSize = #lib.Save.Get().Pets
				for i, v in pairs(lib.Save.Get().Pets) do
					if not table.find(BeforeUIDS, v.uid) then
						local CheckForNormal = not v.g and not v.r and not v.dm
						local CheckForGolden = v.g and not v.r and not v.dm
						local CheckForRainbow = not v.g and v.r and not v.dm
						local CheckForDarkMatter = not v.g and not v.r and v.dm
						local Info = {
							Name = lib.Directory.Pets[v.id].name,
							Variant = CheckForNormal and "Normal" or CheckForGolden and "Golden" or CheckForRainbow and "Rainbow" or CheckForDarkMatter and "Dark Matter",
							Shiny = v.sh and "Shiny " or not v.sh and "",
							Enchants = "in work",
							Chance = GetEggOddsById(v.id),
							Rarity = lib.Directory.Pets[v.id].rarity,
						}
						if Info.Rarity == "Mythical" and Settings.WebhookNotify.SendMythical or Info.Rarity == "Secret" and Settings.WebhookNotify.SendSecret or Info.Rarity == "Exclusive" and Settings.WebhookNotify.SendHuge then
							local AssetId
							if Info.Variant == "Rainbow" or Info.Variant == "Normal" then
								AssetId = lib.Directory.Pets[v.id].thumbnail
							elseif Info.Variant == "Golden" then
								AssetId = lib.Directory.Pets[v.id].goldenThumbnail
							end
							AssetId = string.gsub(AssetId, "rbxassetid://", "")
							local String = "https://thumbnails.roblox.com/v1/assets?assetIds="..AssetId.."&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false"
							Image = game:GetService("HttpService"):JSONDecode(game:HttpGet(String))
							local shiny = v.sh and "true" or not v.sh and "false"
							local Data = {
								content = nil,
								embeds = { {
									title = Info.Shiny..Info.Variant.." "..Info.Name.."",
									description = "**Chance: "..Info.Chance.."**\n**Variant: "..Info.Variant.."**\n**Shiny: "..shiny.."**\n**Egg: "..GetEggById(v.id).."**\n**Opened Egg: "..GetEggsOpened(GetEggById(v.id)).." Times**",
									color = 5814783,
									thumbnail = {
										url = Image.data[1].imageUrl
									},
									footer = {
										text = game.Players.LocalPlayer.Name
									},
								} },
								attachments = { }
							}
							SendMessage(Settings.WebhookNotify.Webhook, Data)
							table.insert(BeforeUIDS, v.uid) 
						end
					end
				end
			end
		end
	end)
end
local EggToTeleport = (Settings.EggToHatch == "Newest one with huge" and GetNewestEgg()) or (Settings.EggToHatch)
local AreaToFarm = Settings.AreaToFarm == "AreaOfEgg" and lib.Directory.Eggs[EggToTeleport].area or Settings.AreaToFarm

local Areas = {
	"Pixel Vault",
	"Pixel Kyoto",
	"Pixel Alps",
	"Pixel Forest",
	"Cat Backyard",
	"Cat Paradise",
	"Cat Taiga"
}

local BlacklistedAreas = {}

function RemoveOptionByValue(tAble, value)
	local index 
	for i, v in pairs(tAble) do
		if v == value then
			index = i
			break
		end
	end
	if index ~= nil then
		table.remove(tAble, index)
	end
end
local AreaToFarmFruits

spawn(function()
	while task.wait(0.8) do
		if not isfile("FarmFruits.json") then
			if GetFruitAmmount(lib.Directory.Fruits.Banana) == 200 then
				writefile("FarmFruits.json", "false")
			end

			if GetFruitAmmount(lib.Directory.Fruits.Banana) < 150 then
				writefile("FarmFruits.json", "true")
			end
		end
		local FarmFruits
		if isfile("FarmFruits.json") then
			FarmFruits = HttpService:JSONDecode(readfile("FarmFruits.json"))
		end
		if (Settings.FarmFruits.Farm and Settings.FarmFruits.FarmOption == "Normal" and GetFruitAmmount(lib.Directory.Fruits.Banana) < Settings.FarmFruits.MinAmount) or (Settings.FarmFruits.Farm and Settings.FarmFruits.FarmOption == "Server Hop" and (GetFruitAmmount(lib.Directory.Fruits.Banana) < Settings.FarmFruits.MinAmount) or (FarmFruits == "true" or FarmFruits == nil)) then
			if Settings.FarmFruits.FarmOption == "Normal" then
				if not isfile("BlacklistedAreas.json") then
					writefile("BlacklistedAreas.json", game:GetService("HttpService"):JSONEncode(BlacklistedAreas))
				else
					json = readfile("BlacklistedAreas.json")
					BlacklistedAreas = game:GetService("HttpService"):JSONDecode(json)
				end
				for i, v in pairs(Areas) do
					if not table.find(BlacklistedAreas, v) then
						AreaToFarmFruits = v
						table.insert(BlacklistedAreas, AreaToFarmFruits)
						writefile("BlacklistedAreas.json", game:GetService("HttpService"):JSONEncode(BlacklistedAreas)) 
						break
					end
				end		
				if AreaToFarmFruits ~= nil then	
					getgenv().HatchingEgg = false
					print(ScriptLog.."Amount Of Banana Fruits Is Too Low Farming Fruits")
					repeat task.wait() until lib.WorldCmds.HasLoaded()
					print(ScriptLog.."Double Checking If Its Really Too Low")
					if GetFruitAmmount(lib.Directory.Fruits.Banana) < Settings.FarmFruits.MinAmount then
						print(ScriptLog.."It Really Is")
						repeat task.wait() until lib.WorldCmds.HasLoaded()
						Teleport.Teleport(AreaToFarmFruits, true)
						task.wait(0.3)
						while task.wait(0.1) do
							local UsedIds = {}
							for i, v in pairs(lib.Network.Invoke("Get Coins")) do
								if v.a == AreaToFarmFruits then
									for I, V in pairs(GetEquipped()) do
										if not table.find(UsedIds, V) then
											lib.Network.Invoke("Join Coin", i, {V})
											lib.Network.Fire("Farm Coin", i, V)
											table.insert(UsedIds, V)
											task.wait(0.02)
											break
										end
									end
								end
								if #UsedIds == #GetEquipped() then break end
							end
							if GetFruitAmmount(lib.Directory.Fruits.Banana) >= Settings.FarmFruits.MaxAmount then print(ScriptLog.."Maxed Fruits") RemoveOptionByValue(BlacklistedAreas, AreaToFarmFruits) writefile("BlacklistedAreas.json", game:GetService("HttpService"):JSONEncode(BlacklistedAreas)) break end
						end
					else
						print(ScriptLog.."It Really Isnt")
					end
				end
			end
			if Settings.FarmFruits.FarmOption == "Server Hop" then
				local Fruits = {}
				for i, v in pairs(lib.Directory.Fruits) do
					if not table.find(BlacklistedFruits, i) then
						table.insert(Fruits, v.Coin)
					end
				end

				local Areas = {}
				for i, v in pairs(lib.Directory.Areas) do
					if not v.hidden and not table.find(BlacklistedAreas, v.name) and not table.find(BlacklistedWorlds, v.world) then
						Areas[v.id] = i
					end
				end

				local Worlds = {}
				for i, v in pairs(lib.Directory.Areas) do
					if not v.hidden and not table.find(BlacklistedAreas, v.name) and not table.find(BlacklistedWorlds, v.world) and not table.find(Worlds, v.world) then
						table.insert(Worlds, v.world)
					end
				end

				local CurrentArea
				local AreasWithFruits = {}
				for i, v in pairs(Worlds) do
					if lib.WorldCmds.Get() ~= v then
						lib.WorldCmds.Load(v)
					end
					local StartTime = tick()
					while task.wait() do
						if lib.WorldCmds.HasLoaded() then break end
						if tick() - StartTime > 6 then
							UpdateServers()
							for i, v in pairs(Servers) do
								print(ScriptLog.."Teleporting To "..v.id.." With "..v.ping.." Ping".." And "..v.playing.."/"..v.maxPlayers.." Players")
								TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
								task.wait(1.4)
								break
							end
						end
					end
					repeat task.wait() until lib.WorldCmds.HasLoaded()
					for ii, vv in pairs(lib.Network.Invoke("Get Coins")) do
						if table.find(Fruits, vv.n) and not table.find(AreasWithFruits, vv.a) then
							CurrentArea = vv.a
							Teleport.Teleport(vv.a, true)
							table.insert(AreasWithFruits, vv.a)
						end
						if vv.a == CurrentArea and table.find(Fruits, vv.n) then
							print("Farming "..vv.n.." Fruit")
							lib.Network.Invoke("Join Coin", ii, GetEquipped())
							for I, V in pairs(GetEquipped()) do
								lib.Network.Fire("Farm Coin", ii, V)
							end
						end
					end
				end

				task.wait(0.5)
				if GetFruitAmmount(lib.Directory.Fruits.Banana) == 200 then
					writefile("FarmFruits.json", "false")
				end
	
				if GetFruitAmmount(lib.Directory.Fruits.Banana) < 150 then
					writefile("FarmFruits.json", "true")
				end
				UpdateServers()
				for i, v in pairs(Servers) do
					print(ScriptLog.."Teleporting To "..v.id.." With "..v.ping.." Ping".." And "..v.playing.."/"..v.maxPlayers.." Players")
					TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
					task.wait(1.4)
					break
				end
			end
		end
		if GetAvailableEggs(EggToTeleport) <= Settings.HatchWhenSelectedAmountEggsAvailable then
			getgenv().HatchingEgg = false
			print(ScriptLog.."Not Enough Eggs Available Farming Coins")
			repeat task.wait() until lib.WorldCmds.HasLoaded()
			Teleport.Teleport(AreaToFarm, true)
			while task.wait(0.05) do
				local Coins = {}
				for i, v in pairs(lib.Network.Invoke("Get Coins")) do
					if v.a == AreaToFarm then
						v.ID = i
						v.Mult = (v.b and v.b.l[1].m) or (0)
						table.insert(Coins, v)
					end
				end
				table.sort(Coins, function(a, b) return a.Mult > b.Mult end)
				for i, v in pairs(Coins) do
					if v.a == AreaToFarm then
						lib.Network.Invoke("Join Coin", v.ID, GetEquipped())
						for I, V in pairs(GetEquipped()) do
							lib.Network.Fire("Farm Coin", v.ID, V)
						end
						break
					end
				end
				if GetAvailableEggs(EggToTeleport) >= Settings.HatchWhenSelectedAmountEggsAvailable then print(ScriptLog.."Got Enough Eggs Available") break end
			end
		end
		local checkforeggs = GetAvailableEggs(EggToTeleport) >= Settings.HatchWhenSelectedAmountEggsAvailable
		function CheckForFruits()
			if not Settings.FarmFruits.Farm then
				return true
			end
			if Settings.FarmFruits.Farm then
				if FarmFruits == "false" then
					return true
				else
					return false
				end
			end
		end
		local checkforfruits = CheckForFruits()
		local checkforalreadyhatching = getgenv().HatchingEgg
		print(checkforeggs, checkforfruits, checkforalreadyhatching)
		if checkforeggs and checkforfruits and not checkforalreadyhatching then
			print(ScriptLog.."Teleporting To "..EggToTeleport)
			repeat task.wait() until lib.WorldCmds.HasLoaded()
			TeleportToEgg(EggToTeleport)
			print(ScriptLog.."Hatching "..EggToTeleport)
			while task.wait(2.2) do
				getgenv().HatchingEgg = true
				lib.Network.Invoke("Buy Egg", EggToTeleport, Settings.EggSettings.triple, Settings.EggSettings.octuple)
				if GetAvailableEggs(EggToTeleport) <= 20 or Settings.FarmFruits.Farm and GetFruitAmmount(lib.Directory.Fruits.Banana) < Settings.FarmFruits.MinAmount then getgenv().HatchingEgg = false break end
			end
		end
	end
end)

spawn(function()
	while task.wait(0.1) do
		CollectLtbg()
		CollectOrbs()
		for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.FreeGifts.Frame.Container.Gifts:GetDescendants()) do
			if v.ClassName == "TextLabel" and v.Text == "Redeem!" then
				local giftName = v.Parent.Name
				local number = string.match(giftName, "%d+")
				lib.Network.Invoke("Redeem Free Gift", tonumber(number))
			end
		end
	end
end)

spawn(function()
	while task.wait(1) do
		if Settings.Boosts.SuperLucky then
			if not lib.Save.Get().Boosts["Super Lucky"] or lib.Save.Get().Boosts["Super Lucky"] < 5 then
				ActivateBoost("Super Lucky")
				if lib.Save.Get().BoostsInventory["Super Lucky"] then
					print(ScriptLog.."Enabled Super Lucky")
				end
			end
		end
		if Settings.Boosts.UltaryLucky then
			if not lib.Save.Get().Boosts["Ultra Lucky"] or lib.Save.Get().Boosts["Ultra Lucky"] < 5 then
				ActivateBoost("Ultra Lucky")
				if lib.Save.Get().BoostsInventory["Ultra Lucky"] then
					print(ScriptLog.."Enabled Ultra Lucky")
				end
			end
		end
		if Settings.Boosts.TripleCoins then
			if not lib.Save.Get().Boosts["Triple Coins"] or lib.Save.Get().Boosts["Triple Coins"] < 5 then
				ActivateBoost("Triple Coins")
				if lib.Save.Get().BoostsInventory["Triple Coins"] then
					print(ScriptLog.."Enabled Triple Coins")
				end
			end
		end
		if Settings.Boosts.TripleDamage then
			if not lib.Save.Get().Boosts["Triple Damage"] or lib.Save.Get().Boosts["Triple Damage"] < 5 then
				ActivateBoost("Triple Damage")
				if lib.Save.Get().BoostsInventory["Triple Damage"] then
					print(ScriptLog.."Enabled Triple Damage")
				end
			end
		end
		if Settings.ServerBoosts.SuperLucky then
			if not lib.ServerBoosts.GetActiveBoosts()["Super Lucky"] or lib.ServerBoosts.GetActiveBoosts()["Super Lucky"].totalTimeLeft < 5 then
				ActivateServerBoost("Super Lucky")
				if lib.Save.Get().BoostsInventory["Super Lucky"] >= 20 then
					print(ScriptLog.."Enabled Server Super Lucky")
				end
			end
		end
		if Settings.ServerBoosts.TripleCoins then
			if not lib.ServerBoosts.GetActiveBoosts()["Triple Coins"] or lib.ServerBoosts.GetActiveBoosts()["Triple Coins"].totalTimeLeft < 5 then
				ActivateServerBoost("Triple Coins")
				if lib.Save.Get().BoostsInventory["Triple Coins"] >= 20  then
					print(ScriptLog.."Enabled Server Triple Coins")
				end
			end
		end
		if Settings.ServerBoosts.TripleDamage then
			if not lib.ServerBoosts.GetActiveBoosts()["Triple Damage"] or lib.ServerBoosts.GetActiveBoosts()["Triple Damage"].totalTimeLeft < 5 then
				ActivateServerBoost("Triple Damage")
				if lib.Save.Get().BoostsInventory["Triple Damage"] >= 20 then
					print(ScriptLog.."Enabled Server Triple Damage")
				end
			end
		end
	end
end)
