local Library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/KarwaBlox/UI-Library-Poland-Hub/main/Library.lua')))()


local Filename = "PSXsettings.json"
local json

--Services
local TeleportService = game:GetService("TeleportService")

getgenv().AutoLootbags = false
getgenv().AutoOrbs = false
getgenv().AutoEgg = false
getgenv().AutoFarmSuper = false
getgenv().AutoFarmMulti = false
getgenv().AutoFarm = false
getgenv().AutoSendAllPets = false
getgenv().AutoGifts = false
getgenv().WaitBeforeChangingCoin = 1
getgenv().NameToEnchant = "Enchant"
getgenv().AutoEnchant = false
getgenv().AutoTripleCoin = false
getgenv().AutoTripleDamage = false
getgenv().AutoSuperLucky = false
getgenv().AutoUltraLucky = false
getgenv().AutoServerTripleCoins = false
getgenv().AutoServerTripleDamage = false
getgenv().AutoServerSuperLucky = false
getgenv().AutoFarmRainbowEvent = false
getgenv().AreaToTpEvent = nil
getgenv().AutoRenameRoy = false
getgenv().RenameName = "CometPet"
getgenv().AutoFarmComets = false
getgenv().CometNotify = false
getgenv().CometWebhook = nil
getgenv().AutoIndexPets = false
getgenv().AutoGold = false

local SelectedEnchants = {}
local teleport = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport)
function BypassAntiCheat()
	local Network = require(game:GetService("ReplicatedStorage").Library.Client.Network)
	local functions = Network.Fire, Network.Invoke
	local old 
	old = hookfunction(getupvalue(functions, 1) , function(...) return true end)

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
	local Audio = require(game:GetService("ReplicatedStorage").Library.Audio)
	local OldAudio
	OldAudio = hookfunction(Audio.Play, function(...)
		local Sound = ...
		if Sound == "rbxassetid://7009904957" or Sound == "rbxassetid://7000720081" or Sound == "rbxassetid://7358008634" then
			return nil
		else
			return OldAudio(...)
		end
	end)
	local WorldCmds = require(game:GetService("ReplicatedStorage").Library.Client.WorldCmds)
	for i, v in pairs(getconstants(WorldCmds.Load)) do
		if v == "Sound" then
			setconstant(WorldCmds.Load, i, "ADAWDAWDAWD")
		end
	end
	print("Hooked Functions")
end

BypassAntiCheat()

function ReadSettings(index)
	local HttpService = game:GetService("HttpService")
	local value
	if (readfile and isfile) and isfile(Filename) then
		local settingsTable = json
		settingsTable = HttpService:JSONDecode(readfile(Filename))
		for i, v in pairs(settingsTable) do
			if i == index then
				value = v
			end
		end
		return value
	end
end


--//server hopper
local HttpService = game:GetService("HttpService")
local Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=Asc&limit=100'))
local TeleportService = game:GetService("TeleportService")

function ServerHop()
	local Servers = {}
	for i, v in pairs(Site.data) do
		if v.playing and v.playing ~= v.maxPlayers then
			local ping = nil
			if typeof(v.ping) == "number" then
				ping = v.ping
			elseif typeof(v.ping) == "table" and typeof(v.ping.total) == "number" then
				ping = v.ping.total
			end
			if ping ~= nil and ping > math.random(50,70) and v.playing then
				table.insert(Servers, {ping = ping, server = v})
			end
		end
	end
	table.sort(Servers, function(a, b)
		return a.ping < b.ping
	end)
	local jobid 
	local playerplaying
	local ping
	local Filename = "NiggaScriptAntiSameServer.json"
	for i, v in ipairs(Servers) do
		jobid = v.server.id
		if isfile(Filename) and jobid ~= HttpService:JSONEncode(Filename) and v.server.playing < v.server.maxPlayers then
			local server = v.server
			jobid = v.server.id
			ping = v.server.ping
			TeleportService:TeleportToPlaceInstance(game.PlaceId, jobid, LocalPlayer)
			task.wait(0.1)
		end
	end
	if (writefile) then
		json = HttpService:JSONEncode(jobid)
		writefile(Filename, json)   
	end
	if isfile("CometServer.json") then
		delfile("CometServer.json")
	end
end

function comma_value(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function SendMessage(Webhook, data)
	local webhookcheck =
		is_sirhurt_closure and "Sirhurt" or pebc_execute and "ProtoSmasher" or syn and "Synapse X" or
		secure_load and "Sentinel" or
		KRNL_LOADED and "Krnl" or
		SONA_LOADED and "Sona" or
		"Kid with shit exploit"

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

--//Comet Farming

spawn(function()
	local Network = require(game:GetService("ReplicatedStorage").Library.Client.Network)
	local WorldCmds = require(game:GetService("ReplicatedStorage").Library.Client.WorldCmds)
	local Variables = require(game:GetService("ReplicatedStorage").Library.Variables)
	local Save = require(game:GetService("ReplicatedStorage").Library.Client.Save)
	local function CheckForCometsScript()
		if game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Comets then 
			return true
		else
			return false
		end
	end
	repeat task.wait() until CheckForCometsScript()
	print("Comet Script Enabled")
	local function FindComet()
		for i, v in pairs(Network.Invoke("Comets: Get Data")) do
			if v then
				return v
			else
				return nil
			end	
		end
	end
	local CometsBroke = 0 
	local MiniComets = 0
	local MasiveComets = 0
	local GemsFromComets = 0
	getgenv().CurrentGems = nil
	spawn(function()
		local lib = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
		local function Check()
			if lib.Loaded then
				return true
			end
			if not lib.Loaded then
				return false
			end
		end
		repeat wait() until Check()
		getgenv().CurrentGems = lib.Save.Get().Diamonds
	end)
	local said = false
	local Timetofarmcomets
	while task.wait(0) do
		local table1 = game:GetService("Workspace")["__THINGS"].Lootbags:GetChildren()
		local Coinid
		local CometType
		local Area
		local data
		if getgenv().AutoFarmComets or ReadSettings("Auto Farm Comets") then
			if FindComet() ~= nil then
				local Info = FindComet()
				print("Comet Found")
				if game:GetService("Players").LocalPlayer.PlayerGui.Loading.Enabled == false and WorldCmds.Get() ~= Info.WorldId then
					local WorldHook
					WorldHook = hookfunction(WorldCmds.Load, function(...)
						local world
						local Info = FindComet()
						if Info and Info.WorldId then 
							world = Info.WorldId
							return WorldHook(world)
						else
							return WorldHook(...)
						end
					end)
					if Info then
						print("Hooked Load Function To Instantly Load To "..Info.WorldId)
					end
				end	
				repeat task.wait(0) until WorldCmds.HasLoaded()
				if Info ~= nil and FindComet() ~= nil then
					Coinid = Info.CoinId
					CometType = Info.Type
					Area = Info.AreaId 
				else
					ServerHop()
				end
				if WorldCmds.HasLoaded() and WorldCmds.Get() ~= Info.WorldId and #table1 == 0 then
					WorldCmds.Load(Info.WorldId)
					print("Changing World To "..Info.WorldId)
				end
				if WorldCmds.HasLoaded() and #table1 == 0 then
					Variables.Teleporting = false
					teleport.Teleport(Area, true)
					Variables.Teleporting = false
					print("Teleported To "..CometType)
					task.wait(0.1)
					if Network.Invoke("Get Coins")[Coinid] then
						JoinCoin(Coinid, GetPetsTable())
						FarmCoin(Coinid, GetPetsTable())
						print("Farming Comet")
						Timetofarmcomets = tick()
						CometsBroke = CometsBroke + 1
						MiniComets = MiniComets + 1
						if CometType == "Massive Comet" then
							Network.Invoke("Comets: Open Egg", Info.Id)
							MasiveComets = MasiveComets + 1
							CometsBroke = CometsBroke + 1
						end
					end
					repeat task.wait(0.1) until not Network.Invoke("Get Coins")[Coinid]
				end
			else
				repeat task.wait(0.5) until #table == 0
				if #table1 == 0 then
					task.wait(0.2)
					print("No Comets Found Hopping")
					print("Comets Broke "..CometsBroke)
					if CometsBroke ~= 0 and not said then
						if getgenv().CurrentGems then
							if ReadSettings("Send Discord Notification") or getgenv().CometNotify then
								GemsFromComets = Save.Get().Diamonds - getgenv().CurrentGems
								local function CountAllGemsTogether()
									local HttpService = game:GetService("HttpService")
									local filename = "NiggaScriptTotalGems.json"

									local TotalLocalPlayerGems = {}
									if (readfile) and isfile(filename) then
										local fileContents = readfile(filename)
										if fileContents then
											TotalLocalPlayerGems = HttpService:JSONDecode(fileContents)
										end
									end

									TotalLocalPlayerGems[game:GetService("Players").LocalPlayer.Name] = Save.Get().Diamonds

									if (writefile) then
										local json = HttpService:JSONEncode(TotalLocalPlayerGems)
										writefile(filename, json)
									end
								end
								CountAllGemsTogether()
								local function GetAllDiamonds()
									local HttpService = game:GetService("HttpService")
									local filename = "NiggaScriptTotalGems.json"
									local value = 0
									if (readfile and isfile) and isfile(filename) then
										local settingsTable = json
										settingsTable = HttpService:JSONDecode(readfile(filename))
										for i, v in pairs(settingsTable) do
											value = value + v 
										end
										return comma_value(value)
									end
								end
								local endtimeoffarming = math.floor(tick() - Timetofarmcomets)
								data = {
									content = nil,
									embeds = {
										{
											title = "Comets",
											description = "Mini Comets "..tostring(MiniComets).."\nMasive Comets "..tostring(MasiveComets).."\nTotal Comets "..tostring(CometsBroke).."\nTook "..tostring(endtimeoffarming).."s to break",
											color = 5814783,
											fields = {
												{
													name = "Diamonds",
													value = "💎 Gems Earned "..tostring(comma_value(GemsFromComets)).."\n💎 Gems Total "..tostring(comma_value(Save.Get().Diamonds)).."\n💎 Gems From All Accounts "..tostring(GetAllDiamonds())
												},
												{
													name = "Player",
													value = "Name ||"..game:GetService("Players").LocalPlayer.Name.."||\nDisplay Name ||"..game:GetService("Players").LocalPlayer.DisplayName.."||"
												}
											}
										}
									},
									username = "NiggaScript",
									attachments = {}
								}
								local webhook = getgenv().CometWebhook or ReadSettings("Webhook")
								print("Webhook: "..webhook)
								SendMessage(webhook, data)
								ServerHop()
							end
							print("Got "..GemsFromComets.." Gems From "..CometsBroke.." Comets")
							said = true
							ServerHop()
						end
					end
					ServerHop()
				end
			end
		end
	end
end)

local lib = require(game:GetService("ReplicatedStorage").Framework.Library)

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

function RedeemGifts()
	for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.FreeGifts.Frame.Container.Gifts:GetDescendants()) do
		if v.ClassName == "TextLabel" and v.Text == "Redeem!" then
			local giftName = v.Parent.Name
			local number = string.match(giftName, "%d+")
			lib.Network.Invoke("Redeem Free Gift", tonumber(number))
		end
	end
end
local hoverbrd = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Hoverboards)
function GetGamepasses()
	lib.Save.Get().Gamepasses = {}
	for i, v in pairs(lib.Directory.Gamepasses) do
		table.insert(lib.Save.Get().Gamepasses, v.ID)
	end
end

function GetHoverboards()
	lib.Save.Get().Hoverboards = {}
	for i, v in pairs(lib.Directory.Hoverboards) do
		table.insert(lib.Save.Get().Hoverboards, i)
		lib.Save.Get().EquippedHoverboard = i
	end
	hoverbrd:UpdateGamepassFrame()
	hoverbrd:Update()
	hoverbrd:UpdateCustomizeButton()
	hoverbrd:Scaling()
end

function EquipHoverboard(hoverboard)
	lib.Save.Get().EquippedHoverboard = hoverboard
	hoverbrd:Update()
end

function ReloadServer()
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
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

spawn(function()
	while task.wait(1.5) do
		if getgenv().AutoTripleCoins then
			if not lib.Save.Get().Boosts["Triple Coins"] or lib.Save.Get().Boosts["Triple Coins"] < 5 then
				ActivateBoost("Triple Coins")
			end
		end
	end
end)

spawn(function()
	while task.wait(1.5) do
		if getgenv().AutoTripleDamage then
			if not lib.Save.Get().Boosts["Triple Damage"] or lib.Save.Get().Boosts["Triple Damage"] < 5 then
				ActivateBoost("Triple Damage")
			end
		end
	end
end)

spawn(function()
	while task.wait(1.5) do
		if getgenv().AutoSuperLucky then
			if not lib.Save.Get().Boosts["Super Lucky"] or lib.Save.Get().Boosts["Super Lucky"] < 5 then
				ActivateBoost("Super Lucky")
			end
		end
	end
end)

spawn(function()
	while task.wait(1.5) do
		if getgenv().AutoUltraLucky then
			if not lib.Save.Get().Boosts["Ultra Lucky"] or lib.Save.Get().Boosts["Ultra Lucky"] < 5 then
				ActivateBoost("Ultra Lucky")
			end
		end
	end
end)

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

spawn(function()
	while task.wait(1.5) do
		if getgenv().AutoServerTripleCoins then
			if not lib.ServerBoosts.GetActiveBoosts()["Triple Coins"] or lib.ServerBoosts.GetActiveBoosts()["Triple Coins"].totalTimeLeft < 5 then
				ActivateServerBoost("Triple Coins")
			end
		end
	end
end)

spawn(function()
	while task.wait(1.5) do
		if getgenv().AutoServerTripleDamage then
			if not lib.ServerBoosts.GetActiveBoosts()["Triple Damage"] or lib.ServerBoosts.GetActiveBoosts()["Triple Damage"].totalTimeLeft < 5 then
				ActivateServerBoost("Triple Damage")
			end
		end
	end
end)

spawn(function()
	while task.wait(1.5) do
		if getgenv().AutoServerSuperLucky then
			if not lib.ServerBoosts.GetActiveBoosts()["Super Lucky"] or lib.ServerBoosts.GetActiveBoosts()["Super Lucky"].totalTimeLeft < 5 then
				ActivateServerBoost("Super Lucky")
			end
		end
	end
end)

spawn(function() --LootbagLoop
	while task.wait(0.5) do
		if getgenv().AutoLootbags then
			CollectLtbg()
		end
	end
end)

spawn(function() --OrbLoop
	while task.wait() do
		if getgenv().AutoOrbs then
			CollectOrbs()
		end
	end
end)

spawn(function()
	while task.wait(1) do
		if getgenv().AutoGifts then
			RedeemGifts()
		end
	end
end)

function OpenEgg(Egg, triple, octuple)
	if Egg == nil then 
		print("Select Egg First")
	elseif Egg ~= nil then
		lib.Network.Invoke("Buy Egg", Egg, triple, octuple)
	end
end
getgenv().Egg = nil
getgenv().Triple = false
getgenv().Octuple = false

--OpenEgg("Tropical Doodle Egg", getgenv().Triple, getgenv().Octuple)

spawn(function() --EggLoop
	while task.wait(2.2) do
		if getgenv().HatchMode == "Triple" then
			getgenv().Triple = true
			getgenv().Octuple = false
		elseif getgenv().HatchMode == "Octuple" then
			getgenv().Triple = false
			getgenv().Octuple = true
		elseif getgenv().HatchMode == "Deafult" then
			getgenv().Triple = false
			getgenv().Octuple = false
		end
		if getgenv().AutoEgg then
			OpenEgg(getgenv().Egg, getgenv().Triple, getgenv().Octuple)
		end
	end
end)


function Enchant(PetTable)
	if typeof(PetTable) == "table" then
		if #PetTable > 3 then
			PetTable = {
				[1] = PetTable[1],
				[2] = PetTable[2],
				[3] = PetTable[3]
			}
		end
	end
	lib.Network.Invoke("Enchant Pets", PetTable, false)
end

function Teleport(EggName)
	for i,v in pairs(game:GetService("Workspace")["__MAP"].Eggs:GetDescendants()) do
		if v.Name == "SectionName" and v.Parent.Parent == EggName then
			print(v.CFrame)
		end
	end
end
--//[<Farming Stuff>]

function JoinCoin(Coinid, PetTable)
	if Coinid ~= nil and PetTable ~= nil then
		lib.Network.Invoke("Join Coin", Coinid, PetTable)
	end
end

function FarmCoin(Coinid, PetTable)
	if Coinid ~= nil and PetTable ~= nil then
		for i, v in pairs(PetTable) do
			lib.Network.Fire("Farm Coin", Coinid, v)
		end
	end
end

function GetPetsTable()
	local PetsEquipped = {}
	for i, v in pairs(lib.PetCmds.GetEquipped()) do
		table.insert(PetsEquipped, v.uid)
	end
	return PetsEquipped
end

function FarmCoins(Method, Area, BlacklistedCoins)
	local Coinid
	local CoinName
	local BlackListedIDs = {}
	if Method == "Deafult" then
		for i, v in pairs(lib.Network.Invoke("Get Coins")) do
			if v.a == Area then
				for I, V in pairs(BlacklistedCoins) do
					for ii, vv in pairs(V) do
						if v.n == vv and v.a == Area then
							table.insert(BlackListedIDs, i)
						end 
					end
				end
			end
			if v.a == Area then
				local found = false
				for _, id in pairs(BlackListedIDs) do
					if i == id then
						found = true
						break	
					end
				end
				if not found then
					Coinid = i
					CoinName = v.n
				end	
			end
		end
		if Coinid ~= nil then
			spawn(function()
				JoinCoin(Coinid, GetPetsTable())
				FarmCoin(Coinid, GetPetsTable())
			end)
		end
	end
	if Method == "Highest Coin Multiplier" then
		local highestMultiplier = 0
		local coinmult
		local found
		for i, v in pairs(lib.Network.Invoke("Get Coins")) do
			if v.a == Area then
				for I, V in pairs(BlacklistedCoins) do
					for ii, vv in pairs(V) do
						if v.n == vv and v.a == Area then
							table.insert(BlackListedIDs, i)
						end 
					end
				end
			end
			if v.a == Area then
				found = false
				for _, id in pairs(BlackListedIDs) do
					if i == id then
						found = true
						break
					end
				end
				if not found then
					if v.b then
						if v.b["l"][1]["m"] > highestMultiplier then
							highestMultiplier = v.b["l"][1]["m"]
							Coinid = i
							coinmult = v.b
						end
					end
				end
				if not coinmult and not found then
					Coinid = i
				end
			end
		end
		if Coinid ~= nil then
			spawn(function()
				JoinCoin(Coinid, GetPetsTable())
				FarmCoin(Coinid, GetPetsTable())
			end)
		end
	end
	if Method == "Super Farm" then
		for i, v in pairs(lib.Network.Invoke("Get Coins")) do
			if v.a == Area then
				Coinid = i
				if Coinid ~= nil then
					JoinCoin(Coinid, GetPetsTable())
					FarmCoin(Coinid, GetPetsTable())
				end
			end
		end
	end
	if Method == "Valentines First" then
		local found
		local foundhearts
		for i, v in pairs(lib.Network.Invoke("Get Coins")) do
			if v.a == Area then
				for I, V in pairs(BlacklistedCoins) do
					for ii, vv in pairs(V) do
						if v.n == vv and v.a == Area then
							table.insert(BlackListedIDs, i)
						end 
					end
				end
			end
			if v.a == Area then
				found = false
				for _, id in pairs(BlackListedIDs) do
					if i == id then
						found = true
						break
					end
				end
				if not found then
					if v.n == "Heart Present" or "Heart Pile" or "Giant Valentines Chest" then
						Coinid = i
						foundhearts = true
					end
				end
				if not foundhearts and not found then
					Coinid = i
				end
			end
		end
		if Coinid ~= nil then
			spawn(function()
				JoinCoin(Coinid, GetPetsTable())
				FarmCoin(Coinid, GetPetsTable())
			end)
		end
	end
end

local IsRenaming
function RenameAllRoyDiam(Name)
	local RoyaltyPets = {}
	local UIDs = {}
	for i, v in pairs(lib.Save.Get().Pets) do
		if v.powers then
			for ii, vv in pairs(v.powers) do
				if table.find(vv, "Royalty") then
					RoyaltyPets[i] = v
				end
			end
		end
	end
	for i, v in pairs(RoyaltyPets) do
		for I, V in pairs(v.powers) do
			if table.find(V, "Diamonds") and v.nk ~= getgenv().RenameName then
				table.insert(UIDs, v.uid)
			end
		end
	end
	if #UIDs ~= 0 then
		for i, v in pairs(UIDs) do
			IsRenaming = true
			lib.Network.Invoke("Rename Pet", v, Name)
			task.wait(0.85)
		end
	end
	IsRenaming = false
end

spawn(function()
	while task.wait(2) do
		if getgenv().AutoRenameRoy and not IsRenaming then
			RenameAllRoyDiam(getgenv().RenameName)
		end
	end
end)


getgenv().FarmingMode = "Deafult"
getgenv().SelectedArea = "Town"
getgenv().BlacklistedCoins = {{}}

spawn(function() -- AutoFarm
	while task.wait(0.1) do
		if getgenv().AutoFarm then
			if #GetPetsTable() ~= 0 then
				FarmCoins(getgenv().FarmingMode, getgenv().SelectedArea, getgenv().BlacklistedCoins)
			end
		end
	end 
end)

spawn(function() -- AutoSuperFarm
	while task.wait(1) do
		if getgenv().AutoSuperFarm then
			if #GetPetsTable() ~= 0 then
				FarmCoins("Super Farm", getgenv().SelectedArea, getgenv().BlacklistedCoins)
			end
		end
	end 
end)

--//[<Farming Stuff>]


-- // Pet Enchanting
spawn(function()
	while task.wait(2.12) do
		if getgenv().AutoEnchant then

			local EnchName
			local EnchTier
			local EnchTable = {}
			for i, v in pairs(lib.Directory.Powers) do
				if v.canDrop then
					for indx,val in pairs(v.tiers) do
						local petname = val.title
						for idx, vl in pairs(SelectedEnchants) do
							if petname == table.unpack(SelectedEnchants, idx) then
								EnchName = i
								EnchTier = indx
								EnchTable[EnchName] = EnchTier
							end
						end
					end
				end
			end




			local Blacklistedids = {}
			for I, V in pairs(lib.Save.Get().Pets) do
				if V.nk == getgenv().NameToEnchant then
					if V.powers and V.powers[1] then
						local found_ench = false
						for i, ench in pairs(EnchTable) do
							if V.powers[1][1] == i and V.powers[1][2] == ench then
								found_ench = true
								table.insert(Blacklistedids, V.uid)
							end
						end
					end
					if V.powers and V.powers[2] then
						local found_ench = false
						for i, ench in pairs(EnchTable) do
							if V.powers[2][1] == i and V.powers[2][2] == ench then
								found_ench = true
								table.insert(Blacklistedids, V.uid)
							end
						end
					end
				end
			end

			local UIdsToEnchant = {}
			for i, v in pairs(lib.Save.Get().Pets) do
				if v.nk == getgenv().NameToEnchant then
					local found = false
					for _, uid in pairs(Blacklistedids) do
						if v.uid == uid then
							found = true
							break
						end
					end
					if not found then
						local PetEnchantid = v.uid
						table.insert(UIdsToEnchant, PetEnchantid)
					end
				end
			end
			Enchant(UIdsToEnchant)
		end
	end
end)

--Conversion
function GetPetsToConvert(Machine, ammount, Hardcore, Shiny)
	local PetsDirectory = lib.Directory.Pets
	local ConvertPets = {}
	local Count = 0
	local Pets = {}
	local IDToCheck

	local PetIDs = {}
	for i, v in pairs(lib.Save.Get().Pets) do
		if not v.l and v.nk ~= getgenv().RenameName and not PetsDirectory[v.id].huge and not PetsDirectory[v.id].isPremium and not PetsDirectory[v.id].isGift then
			if (Hardcore and v.hc) or (not Hardcore and not v.hc) and (Shiny and v.sh) or (not Shiny and not v.sh) then
				if Machine == "Gold" and not v.r and not v.g and not v.dm or Machine == "Rainbow" and v.r or Machine == "Dark Matter" and v.dm then
					if not PetIDs[v.id] then
						PetIDs[v.id] = {}
					end
				end
			end
		end
	end
	for PETID, VV in pairs(PetIDs) do
		IDToCheck = PETID
		for i, v in pairs(lib.Save.Get().Pets) do
			if not v.l and v.nk ~= getgenv().RenameName and not PetsDirectory[v.id].huge and not PetsDirectory[v.id].isPremium and not PetsDirectory[v.id].isGift and v.id == IDToCheck then
				if (Hardcore and v.hc) or (not Hardcore and not v.hc) and (Shiny and v.sh) or (not Shiny and not v.sh) then
					if Machine == "Gold" and not v.r and not v.g and not v.dm or Machine == "Rainbow" and v.r or Machine == "Dark Matter" and v.dm then
						Count = Count + 1
						table.insert(PetIDs[IDToCheck], v.uid)
						if #PetIDs[IDToCheck] == ammount then break end
					end
				end
			end
		end
	end
	for i, v in pairs(PetIDs) do
		if #v ~= ammount then
			PetIDs[i] = nil
		end
	end
	return PetIDs
end

getgenv().MachinesSettings = {
	Golden = {
		Ammount = 6,
		Hardcore = false,
		Shiny = false,
	},
	Rainbow = {
		Ammount = 6,
		Hardcore = false,
		Shiny = false,
	},
	DarkMatter = {
		Ammount = 6,
		Hardcore = false,
		Shiny = false,
	}
}
spawn(function()
	while task.wait(1) do
		if getgenv().AutoGold then
			for i, v in pairs(GetPetsToConvert("Gold", getgenv().MachinesSettings.Golden.Ammount, getgenv().MachinesSettings.Golden.Hardcore, getgenv().MachinesSettings.Golden.Shiny)) do
				lib.Network.Invoke("Use Golden Machine", v)
				task.wait(1)
			end
		end
	end
end)

spawn(function()
	while task.wait(1) do
		if getgenv().AutoRainbow then
			for i, v in pairs(GetPetsToConvert("Rainbow", getgenv().MachinesSettings.Golden.Ammount, getgenv().MachinesSettings.Golden.Hardcore, getgenv().MachinesSettings.Golden.Shiny)) do
				lib.Network.Invoke("Use Rainbow Machine", v)
				task.wait(1)
			end
		end
	end
end)

spawn(function()
	local function GetDarkSlots()
		if table.find(lib.Save.Get().Gamepasses, 18674305) then
			return lib.Save.Get().DarkMatterSlots + 2
		else
			return lib.Save.Get().DarkMatterSlots
		end
	end
	local function GetSizeOfQue()
		local count = 0
		for i, v in pairs(lib.Save.Get().DarkMatterQueue) do
			count = count + 1
		end
		return count
	end
	local function ClaimAll()
		for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.DarkMatter.Frame.Queue.Holder:GetChildren()) do
			if v.ClassName == "Frame" and  v.Claim.Visible  then
				lib.Network.Invoke("Redeem Dark Matter Pet", v.Name)
				task.wait(1)
			end
		end
	end
	while task.wait(1) do
		if getgenv().AutoDarkMatter then
			if GetSizeOfQue() ~= GetDarkSlots() then
				for i, v in pairs(GetPetsToConvert("Dark Matter", getgenv().MachinesSettings.Golden.Ammount, getgenv().MachinesSettings.Golden.Hardcore, getgenv().MachinesSettings.Golden.Shiny)) do
					lib.Network.Invoke("Convert To Dark Matter", v)
					task.wait(1)
				end
			end
		end
		if getgenv().AutoClaimDark then
			ClaimAll()
		end
	end
end)

function PetIdToName(id)
	if id ~= nil then
		if lib.Directory.Pets[id] then
			return lib.Directory.Pets[id].name
		else
			return "Invalid Id"
		end
	end
end

function PetIDToEgg(id)
	if id ~= nil then
		for i, v in pairs(lib.Directory.Eggs) do
			if v.drops and typeof(v.drops) == "table" and v.hatchable then
				for I, V in pairs(v.drops) do
					if V[1]== id then
						return i
					end
				end
			end
		end
	end
end

function TeleportToEgg(egg)
	teleport.Teleport("")
end

--Index
spawn(function()
	local Idx = {
		0,
		2,
		4,
		8
	}
	local PetsToIndex = {}
	for i, v in pairs(lib.Directory.Pets) do
		if not v.IsPremium and v.rarity ~= "Exclusive" and not v.huge and PetIDToEgg(i) ~= nil then
			for I, V in pairs(Idx) do
				table.insert(PetsToIndex, {i, V})
			end
		end
	end
	local MaxPets = #PetsToIndex
	getgenv().IndexSettings = {
		AmmountToStop = 1000,
		WebhookOnFinish = true,
		Webhook = nil,
		Bank = "67e7df54-eda9-47d5-8c2b-463d0b763e2c",
		MaxAmmount = MaxPets
	}
	local PlayerBank = lib.Network.Invoke("Get Bank", getgenv().IndexSettings.Bank)
	local CurrentPets = {}
	for i,v in pairs(PlayerBank.Storage.Pets) do
		CurrentPets[v.id] = lib.Shared.PetTypeIndex(v)
	end
	local RestPets = {}
	for i, v in pairs(PetsToIndex) do
		local isOwned = false
		for ii, vv in pairs(CurrentPets) do
			if v[1] == ii and v[2] == vv then
				isOwned = true
			end
		end
		if not isOwned then
			table.insert(RestPets, v)
		end
	end
	for i, v in pairs(RestPets) do
		print(i, v)
	end
	while task.wait(0.2) do
		if getgenv().AutoIndexPets then
			
		end
	end
end)



Playerdisplay = game.Players.LocalPlayer.DisplayName

local main = Library:New({name = "Nigga Script | Pet Simulator X |"})

function CreateSettings()
	local HttpService = game:GetService("HttpService")
	if (isfolder) and (makefolder) then
		makefolder("NiggaScript")
	end
	if (writefile) then
		json = HttpService:JSONEncode(main.Config)
		writefile(Filename, json)   
	end
end


local Tab = main:CreateTab({
	name = "Home"
})

local TabFarm = main:CreateTab({name = "Farming", icon = "rbxassetid://12000177181"})
local TabEgg = main:CreateTab({name = "Eggs"})
local TabMachines = main:CreateTab({name = "Machines", icon = "rbxassetid://12412304458"})
local TabMisc = main:CreateTab({name = "Misc", icon = "rbxassetid://12000213750"})

local Label = Tab:Label({name = "Psx Script By Karwa#1132"})
local ReloadServer = Tab:Button({name = "Reload Server", callback = function() 
	ReloadServer()
end})
local DestroyBtn = Tab:Button({name = "Destroy UI", callback = function() main:DestroyUI() end})
local SaveBtn = Tab:Button({
	name = "Save Settings", 
	callback = function() 
		main:SaveConfig()
		CreateSettings()
	end})

local FarmingSection = TabFarm:Section({name = "Farming"})

local AutoFarm = FarmingSection:Toggle({name = "Auto Farm",deafult = ReadSettings("Auto Farm") , callback = function(v) getgenv().AutoFarm = (v) end})
local AutoSuperFarm = FarmingSection:Toggle({name = "Super Farm", deafult = ReadSettings("Super Farm"), callback = function(v) getgenv().AutoSuperFarm = (v) end})
local AutoFarmMode = FarmingSection:Dropdown({name = "Farming Mode", deafult = ReadSettings("Farming Mode"), callback = function(v) getgenv().FarmingMode = (v) end})
AutoFarmMode:Add("Deafult")
AutoFarmMode:Add("Highest Coin Multiplier")
local AutoFarmArea = FarmingSection:Dropdown({name = "Select Area", deafult = ReadSettings("Select Area"), callback = function(v) getgenv().SelectedArea = (v) end})

local UnSortedTable = {}
for i, v in pairs(lib.Directory.Areas) do
	UnSortedTable[v.id] = v.name
end
for i, v in pairs(UnSortedTable) do
	AutoFarmArea:Add(v)
end


local SectionCollect = TabFarm:Section({name = "Auto Collect"})

local AutoOrbs = SectionCollect:Toggle({name = "Auto Orbs", deafult = ReadSettings("Auto Orbs"), callback = function(v) getgenv().AutoOrbs = (v) end})
local AutoLootbags = SectionCollect:Toggle({name = "Auto Lootbags", deafult = ReadSettings("Auto Lootbags"), callback = function(v) getgenv().AutoLootbags = (v) end})
local AutoGifts = SectionCollect:Toggle({name = "Auto Redeem Gifts", deafult = ReadSettings("Auto Redeem Gifts"), callback = function(v) getgenv().AutoGifts = (v) end})

local BlacklistSection = TabFarm:Section({name = "Blacklist Coins"})


for i, v in pairs(lib.Save.Get()) do
	if typeof(v) == "number" and string.find(i, "Coins") or string.find(i, "Hearts") then
		local Currency = i
		local Dropdowns = BlacklistSection:MultiDropdown({name = i, deafult = ReadSettings(i), callback = function(v) getgenv().BlacklistedCoins[i] = v end})
		for I, V in pairs(lib.Directory.Coins) do
			if V.currencyType == Currency then
				Dropdowns:Add(I)
			end
		end
		Dropdowns:Add("Diamonds")
	end
end

function DisableEggAnim(boolean)
	if boolean then 
		game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = true
	else
		game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = false
	end
end



local EggSection = TabEgg:Section({name = "Auto Eggs"})
local AutoEgg = EggSection:Toggle({name = "Auto Open Egg", deafult = ReadSettings("Auto Open Egg"), callback = function(v) getgenv().AutoEgg = (v) end})
local DisableEggAnim = EggSection:Toggle({name = "Disable Egg Animation", deafult = ReadSettings("Disable Egg Animation"), callback = function(v) DisableEggAnim(v) end})
local DropHatchMode = EggSection:Dropdown({name = "Hatch Mode", deafult = ReadSettings("Hatch Mode"), callback = function(v) getgenv().HatchMode = (v) end})
DropHatchMode:Add("Deafult")
DropHatchMode:Add("Triple")
DropHatchMode:Add("Octuple")

local EggInfoSection = TabEgg:Section({name = "Egg Info"})
local EggTracker = EggInfoSection:Label({name = "Egg Info: (not selected)", icon = false, centerText = true})
local EggOpened = EggInfoSection:Label({name = "Eggs Opened: (not selected)", icon = false, centerText = true})
local EggAvaiable = EggInfoSection:Label({name = "Eggs Available: (not selected)", icon = false, centerText = true})


function CalculateAvaiableEggs(Egg)
	local EggCost	
	if game.PlaceId == 10321372166 and lib.Directory.Eggs[Egg].hardcoreCost then
		EggCost = lib.Directory.Eggs[Egg].hardcoreCost
	else
		EggCost = lib.Directory.Eggs[Egg].cost
	end
	local EggCurrency = lib.Directory.Eggs[Egg].currency
	if game.PlaceId == 10321372166 then
		local Avaiable = math.ceil(lib.Save.Get().HardcoreCurrency[EggCurrency] / EggCost)
		return Avaiable
	else
		local Avaiable = math.ceil(lib.Save.Get()[EggCurrency] / EggCost)
		return Avaiable
	end
end


local EggDrop = EggSection:Dropdown({
	name = "Select Egg",
	deafult = ReadSettings("Select Egg"),
	callback = function(v) 
		getgenv().Egg = (v) 
		EggTracker:SetText("Egg Info: "..v)
		if (v) then
			if lib.Save.Get().EggsOpened[getgenv().Egg] ~= nil then 
				if game.PlaceId == 10321372166 and lib.Save.Get().Hardcore.EggsOpened[getgenv().Egg] ~= nil  then
					EggOpened:SetText("Opened: "..lib.Save.Get().Hardcore.EggsOpened[getgenv().Egg])
				elseif lib.Save.Get().EggsOpened[getgenv().Egg] ~= nil then
					EggOpened:SetText("Opened: "..lib.Save.Get().EggsOpened[getgenv().Egg])
				end
				EggAvaiable:SetText("Available: "..CalculateAvaiableEggs(getgenv().Egg))
			else
				EggOpened:SetText("Opened: 0")
				EggAvaiable:SetText("Available: "..CalculateAvaiableEggs(getgenv().Egg))
			end
		end	
	end})


spawn(function()
	while task.wait(1) do
		if getgenv().Egg then 
			if game.PlaceId == 10321372166 and lib.Save.Get().Hardcore.EggsOpened[getgenv().Egg] ~= nil  then
				EggOpened:SetText("Opened: "..lib.Save.Get().Hardcore.EggsOpened[getgenv().Egg])
				EggAvaiable:SetText("Available: "..CalculateAvaiableEggs(getgenv().Egg))
			elseif lib.Save.Get().EggsOpened[getgenv().Egg] ~= nil then
				EggOpened:SetText("Opened: "..lib.Save.Get().EggsOpened[getgenv().Egg])
				EggAvaiable:SetText("Available: "..CalculateAvaiableEggs(getgenv().Egg))
			end
		end
	end
end)

local sortedEggs = {}
for i, v in pairs(lib.Directory.Eggs) do
	if v.hatchable then
		table.insert(sortedEggs, {index = i, egg = v})
	end
end
table.sort(sortedEggs, function(a, b) return a.index < b.index end)
for i, v in ipairs(sortedEggs) do
	EggDrop:Add(v.index)
end

local EnchantSection = TabMachines:Section({name = "Enchant Pets"})
local EnchantToggle = EnchantSection:Toggle({name = "Auto Enchant", deafult = ReadSettings("Auto Enchant"), callback = function(v) getgenv().AutoEnchant = (v) end})
local EnchantPetName = EnchantSection:TextBox({name = "Name To Enchant", deafult = ReadSettings("Name To Enchant"), callback = function(v) getgenv().NameToEnchant = (v) end})
local EnchantDropdown = EnchantSection:MultiDropdown({name = "Select Enchants", deafult = ReadSettings("Select Enchants"), callback = function(v) SelectedEnchants = (v) end})
for i, v in pairs(lib.Directory.Powers) do
	if v.canDrop then
		for indx,val in pairs(v.tiers) do
			local petname = val.title
			if petname then
				EnchantDropdown:Add(petname)
			end
		end
	end
end
local GamepassesSection = TabMisc:Section({name = "Gamepasses"})
local UnlockGamepasses = GamepassesSection:Button({name = "Unlock Gamepasses", callback = function(v) GetGamepasses() end})
local InfoGamepasses = GamepassesSection:Label({name = "Most of the gamepasses are just visual such as triple hatch pets equipped and more", icon = false})

function ChangeHoverSpeed(Hoverboard, speed)
	local Hover
	if Hoverboard ~= nil and speed ~= nil then
		Hover = lib.Directory.Hoverboards[Hoverboard]
		Hover.speed = tonumber(speed)
	end
end

function ChangeHoverDesc(Hoverboard, desc)
	local Hover
	if Hoverboard ~= nil and desc ~= nil then
		Hover = lib.Directory.Hoverboards[Hoverboard]
		Hover.neededDesc = tostring(desc)
	end
end


local HoverboardsSection = TabMisc:Section({name = "Hoverboards"})
local UnlockHover = HoverboardsSection:Button({name = "Unlock Hoverboards", callback = function(v) GetHoverboards() end})
local DropdownHover = HoverboardsSection:Dropdown({name = "Equip Hoverboard", deafult = ReadSettings("Equip Hoverboard"), callback = function(v) EquipHoverboard(v) end})
for i, v in pairs(lib.Directory.Hoverboards) do
	DropdownHover:Add(i)
end
local ChangeHoverSped = HoverboardsSection:Slider({name = "Hoverboard Speed", deafult2 = ReadSettings("Hoverboard Speed"), min = 1, max = 3, deafult = 2, callback = function(v) ChangeHoverSpeed(lib.Save.Get().EquippedHoverboard, v) end})
local ChangeHoverDesc = HoverboardsSection:TextBox({name = "Change Hoverboard Desc", callback = function(v) ChangeHoverDesc(lib.Save.Get().EquippedHoverboard, v) end})

local BoostsSection = TabMisc:Section({name = "Boosts"})
local ActivateTripleCoins = BoostsSection:Toggle({name = "Auto Activate Triple Coins", deafult = ReadSettings("Auto Activate Triple Coins"), callback = function(v) getgenv().AutoTripleCoins = (v) end})
local ActivateTripleDamage = BoostsSection:Toggle({name = "Auto Activate Triple Damage", deafult = ReadSettings("Auto Activate Triple Damage"), callback = function(v) getgenv().AutoTripleDamage = (v) end})
local ActivateSuperLucky = BoostsSection:Toggle({name = "Auto Activate Super Lucky", deafult = ReadSettings("Auto Activate Super Lucky"), callback = function(v) getgenv().AutoSuperLucky = (v) end})
local ActivateUltraLucky = BoostsSection:Toggle({name = "Auto Activate Ultra Lucky", deafult = ReadSettings("Auto Activate Ultra Lucky"), callback = function(v) getgenv().AutoUltraLucky = (v) end})


local ServerBoostsSection = TabMisc:Section({name = "Server Boosts"})
local ActivateServerTripleCoins = ServerBoostsSection:Toggle({name = "Auto Activate Server Triple Coins",deafult = ReadSettings("Auto Activate Server Triple Coins"), callback = function(v) getgenv().AutoServerTripleCoins = (v) end})
local ActivateServerTripleDamage = ServerBoostsSection:Toggle({name = "Auto Activate Server Triple Damage",deafult = ReadSettings("Auto Activate Server Triple Damage"), callback = function(v) getgenv().AutoServerTripleDamage = (v) end})
local ActivateServerSuperLucky = ServerBoostsSection:Toggle({name = "Auto Activate Server Super Lucky",deafult = ReadSettings("Auto Activate Server Super Lucky"), callback = function(v) getgenv().AutoServerSuperLucky = (v) end})

local RenameSection = TabMisc:Section({name = "Rename"})

local AutoRenameToggle = RenameSection:Toggle({name = "Auto Rename Royalty & Diams", deafult = ReadSettings("Auto Rename Royalty & Diams"), callback = function(v) getgenv().AutoRenameRoy = v end})
local RenameName = RenameSection:TextBox({name = "Select Name", deafult = ReadSettings("Select Name"), callback = function(v) getgenv().RenameName = v end})
local RenameButton = RenameSection:Button({name = "Rename Royalty & Diams", callback = function() RenameAllRoyDiam(getgenv().RenameName) end})

local CometFarmingSection = TabFarm:Section({name = "Comet Farming"})

local AutoFarmComets = CometFarmingSection:Toggle({name = "Auto Farm Comets", deafult = ReadSettings("Auto Farm Comets"), callback = function(v) getgenv().AutoFarmComets = v end})
local DiscordNotification = CometFarmingSection:Toggle({name = "Send Discord Notification", deafult = ReadSettings("Send Discord Notification"), callback = function(v) getgenv().CometNotify = v end})
local WebhookTextBox = CometFarmingSection:TextBox({name = "Webhook", deafult = ReadSettings("Webhook"), callback = function(v) getgenv().CometWebhook = v end})
local GoldenMachineSec = TabMachines:Section({name = "Golden Mahine"})
local AutoGold = GoldenMachineSec:Toggle({name = "Auto Gold", deafult = ReadSettings("Auto Gold"), callback = function(v) getgenv().AutoGold = v end})
local GoldAmmount = GoldenMachineSec:Slider({
	name = "Ammount Of Normal Pets",
	deafult2 = ReadSettings("Ammount Of Normal Pets"),
	min = 1,
	deafult = 6,
	max = 12,
	callback = function(v) getgenv().MachinesSettings.Golden.Ammount = v end
})
local GoldHardcore = GoldenMachineSec:Toggle({name = "Golden Hardcore", deafult = ReadSettings("Golden Hardcore"), callback = function(v) getgenv().MachinesSettings.Golden.Hardcore = v end})
local GoldShiny = GoldenMachineSec:Toggle({name = "Golden Shiny", deafult = ReadSettings("Golden Shiny"), callback = function(v) getgenv().MachinesSettings.Golden.Shiny = v end})
print("Nigga Script Executed")	
