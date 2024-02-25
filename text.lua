local Settings = {
	AutoOpenGifts = true,
	AutoOpenPresents = true,
	Fishing = {
		WaitForLegendary = false
	},
	Mailbox = {
		User = "Nig1r11",
		SendGemsAt = 5000000
	},
	Webhook = {
		url = "https://discord.com/api/webhooks/1209649163982344242/3hdoE80-N4kMF0Xrnm5ylCiearxQdrycU014-E8QjZF1G4VmiSw7smbKn89EqFJuD6WF",
		StatsTimeout = 60*10,
	},
	Log = false,
	Optimization = {
		FpsCap = 10,
		Disable3dRendering = false
	}
}

--[[
		 To do 
		-Auto teleport to fishing area when execute start fishing have also webhook add a check if amount of gems => 5000000 then send to Settings.Mailbox.User GemsAmount - MailboxTax then continue the fishing loop
		-Auto collect orbs/gifts/presents
		-Send stats every 10 minutes or selected amount to webhook with progress made with estimated amount of gems per 1 hours and 1 day 
]]

local ScriptLog = "[Karwa's Fishing Assistant]: "

repeat task.wait() until game:IsLoaded()

game:GetService("Players").LocalPlayer.Idled:connect(function()
	game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	task.wait(0.5)
	game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

local Lib = require(game.ReplicatedStorage:WaitForChild("Library").Client)
local Lib_ = require(game.ReplicatedStorage:WaitForChild("Library"))
local FishingMod 
local ClientMod
local HttpService = game:GetService("HttpService")

spawn(function()
	FishingMod = require(workspace.__THINGS.__INSTANCE_CONTAINER.Active:WaitForChild("AdvancedFishing").ClientModule.FishingGame)
	ClientMod = require(workspace.__THINGS.__INSTANCE_CONTAINER.Active:WaitForChild("AdvancedFishing").ClientModule)
end)

task.wait(6)

game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Disabled = true

if Settings.Optimization.Disable3dRendering then
	game:GetService("RunService"):Set3dRenderingEnabled(false)
end

setfpscap(Settings.Optimization.FpsCap)

function Teleport(CFramee) 
	game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFramee
end

function EnterFishing()
	if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Model") then
		return false, "already in fishing area"
	else
		Teleport(workspace.__THINGS.Instances.AdvancedFishing.Teleports.Enter.CFrame)
		return true, "successfuly entered fishing"
	end
end

function LeaveFishing()
	if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("Model") then
		return false, "already left"
	else
		Teleport(workspace.__THINGS.Instances.AdvancedFishing.Teleports.Leave.CFrame)
		return true, "successfuly left fishing"
	end
end

_G.Hooked = false
_G.Hooked2 = false
_G.FishingFFlags = {
	IN_GAME = false,
	IN_FISHING = false,
	REQUESTED_CAST = false,
	FISH_ON_HOOK = false,
	FISH_LEGENDARY = false,
	REQUESTED_REEL = false,
	SENDING_MAIL = false
}

_G.Stats = {
	START_TIME = os.time(),
	START_GEMS = Lib.CurrencyCmds.Get("Diamonds") or 0,
	GEMS_MADE = 0,
	GEMS_FROM_PRESENTS = 0,
	GEMS_FROM_FISHING = 0,
}

function Round6(number)
	local roundedNumber = math.floor(number * 10^6 + 0.5) / 10^6
	return string.format("%.6f", roundedNumber)
end

function SendMessage(Webhook, data)
	local url = Webhook
	local newdata = game:GetService("HttpService"):JSONEncode(data)
	local headers = {
		["content-type"] = "application/json"
	}
	request = http_request or request or HttpPost or syn.request
	local abcdef = {Url = url, Body = newdata, Method = "POST", Headers = headers}
	request(abcdef)
end

spawn(function()
	local LastTimeCollected = os.time()
	while task.wait(1) do
		if Settings.AutoOpenPresents then
			for i, Present in pairs(game.Workspace.__THINGS:WaitForChild("HiddenPresents"):GetChildren()) do
				if Present.Name == "HiddenPresent" then
					local Id = "ID_"..tostring(Round6(Present.CFrame.x)).."_"..tostring(Round6(Present.CFrame.y)).."_"..tostring(Round6(Present.CFrame.z))
					local x,y,z = Lib.Network.Invoke("Hidden Presents: Found", Id)
					if z and typeof(z) == "number" then
						pcall(function()
							_G.Stats["GEMS_FROM_PRESENTS"] = _G.Stats["GEMS_FROM_PRESENTS"] + z
						end)
					end
					LastTimeCollected = os.time()
					Present:Destroy()
				end
			end
		end
	end	
end)

spawn(function()
	while task.wait(5) do
		if Settings.AutoOpenGifts then
			for i = 1, 12 do
				Lib.Network.Invoke("Redeem Free Gift", i)
			end
		end
	end	
end)

spawn(function()
    local CachedValues = {}
    while Settings.Log do
        for i, v in pairs(_G.FishingFFlags) do
            if CachedValues[i] == nil then
                CachedValues[i] = v
            elseif CachedValues[i] ~= v then
                print(ScriptLog.."Fishing FFlags Changed | "..i.." | "..tostring(v))
                CachedValues[i] = v
            end
        end
        task.wait(0.1)
    end
end)

spawn(function()
	local function SecondsToMinutes(seconds)
		local Minutes = seconds/60 or 0
		return Minutes
	end
	local function SecondsToHours(s)
		local hours = math.floor(s / 3600)
		local minutes = math.floor((s % 3600) / 60)
		local seconds = math.floor(s % 60)
		return string.format("%d Hour%s, %d Minute%s, %d Second%s",
			hours, hours ~= 1 and "s" or "",
			minutes, minutes ~= 1 and "s" or "",
			seconds, seconds ~= 1 and "s" or "")
	end
	local function BeatufyGems(gems)
		local Gems 
		if typeof(gems) == "string" then
			gems = tonumber(gems) or 0
		end
		if gems == 0 or gems == nil then 
			return "0"
		end
		if gems > 1000000 then
			Gems = tostring(gems/1000000)
			Gems = string.format("%.2f", Gems)
			Gems = Gems.."M"
		elseif gems > 1000 then
			Gems = tostring(gems/1000)
			Gems = string.format("%.2f", Gems)
			Gems = Gems.."K"
		elseif gems < 1000 then
			Gems = tostring(gems)
		end
		return Gems
	end
	local function GetPerMinuteRate() 
		local TimeSpentMaking = Settings.Webhook.StatsTimeout
		local DivideAmount = SecondsToMinutes(TimeSpentMaking)
		
		return _G.Stats["GEMS_MADE"] / DivideAmount
	end
	while task.wait(0.1) do
		local currentTime = os.time()
		if currentTime - _G.Stats["START_TIME"] >= Settings.Webhook.StatsTimeout then
			print("Sending Webhook")
			_G.Stats["GEMS_MADE"] = Lib.CurrencyCmds.Get("Diamonds") - _G.Stats["START_GEMS"]
			print(BeatufyGems(_G.Stats["GEMS_FROM_FISHING"]))
			print(BeatufyGems(_G.Stats["GEMS_FROM_PRESENTS"]))
			local Data = {
				content = nil,
				embeds = { {
					title = "Fishing Stats In "..tostring(SecondsToHours(currentTime - _G.Stats["START_TIME"])),
					color = 5814783,
					fields = { {
						name = "💎 Diamonds",
						value = "-Fishing: "..BeatufyGems(_G.Stats["GEMS_FROM_FISHING"] or 0).." \n-Presents: "..BeatufyGems(_G.Stats["GEMS_FROM_PRESENTS"] or 0).." \n**Total**: "..BeatufyGems(_G.Stats["GEMS_MADE"] or 0)
					}, {
						name = "💎 Diamonds Average",
						value = "1 Minute: "..BeatufyGems(GetPerMinuteRate()).." \n1 Hour "..BeatufyGems(GetPerMinuteRate()*60).." \n1 Day "..BeatufyGems(GetPerMinuteRate()*60*24)..""
					} },
					footer = {
						text = game:GetService("Players").LocalPlayer.Name.." | "..BeatufyGems(Lib.CurrencyCmds.Get("Diamonds"))
					}
				} },
				attachments = { }
			}
			SendMessage(Settings.Webhook.url, Data)
			_G.Stats = {
				START_TIME = os.time(),
				START_GEMS = Lib.CurrencyCmds.Get("Diamonds") or 0,
				GEMS_MADE = 0,
				GEMS_FROM_PRESENTS = 0,
				GEMS_FROM_FISHING = 0,
				SHARDS_FISHED = 0,
			}
		end
	end
end)

local Servers = {}
function ServerHop()
	local url = 'https://games.roblox.com/v1/games/8737899170/servers/Public?sortOrder=Asc&limit=100'
	local success, result = false, nil
	
	if not success then
		repeat 
			task.wait(1) 
			success, result = pcall(function()
				return HttpService:JSONDecode(game:HttpGet(url))
			end)
		until success
	end
	
	local RblxServerSite = result
	
	if typeof(RblxServerSite.data) == "table" then
		for i, v in pairs(RblxServerSite.data) do
			table.insert(Servers, v)
		end
	end
	
	for i = #Servers, 2, -1 do
		local j = math.random(i)
		Servers[i], Servers[j] = Servers[j], Servers[i]
	end
	
	for i, v in ipairs(Servers) do
		local jobid = v.id
		if v.playing and v.ping then
			jobid = v.id
			local ping = v.ping
			print(ScriptLog.."Teleporting To "..jobid.." With "..ping.." Ping".." And "..v.playing.."/"..v.maxPlayers.." Players")
			game:GetService("TeleportService"):TeleportToPlaceInstance(8737899170, jobid, LocalPlayer)
			task.wait(1.3)
		end
	end
end

spawn(function() 
	for i, v in pairs(game:GetService("Players"):GetChildren()) do
		if v:IsInGroup(5060810) then
			print(ScriptLog.."Staff detected server hopping")
			ServerHop()
			break
		else
			print(ScriptLog..v.Name.." is not a staff member")
		end
	end
	game:GetService("Players").PlayerAdded:Connect(function(player) 
		if player:IsInGroup(5060810) then
			print(ScriptLog.."Staff detected server hopping")
			ServerHop()
		end
	end)
end)

function Reel()
	Lib.Network.Fire("Instancing_FireCustomFromClient", "AdvancedFishing", "RequestReel") 
	_G.FishingFFlags["REQUESTED_REEL"] = true
	Lib.Network.Invoke("Instancing_InvokeCustomFromClient", "AdvancedFishing", "Clicked")
end

function RandomText()
	local x = {"a","b","c","d","e","f","g","h","i","j","k","1","2","3","4","5","6","7","8","9","0"}
	local RndString = ""
	for i = 1, #x do
		RndString = RndString..x[math.random(1, #x)]
	end
	return RndString
end

while task.wait(5) do
	local SendingMail = false
	local x,y
	if not _G.FishingFFlags["SENDING_MAIL"] and not _G.FishingFFlags["IN_FISHING"] then
		x,y = EnterFishing()
		_G.FishingFFlags["IN_FISHING"] = x
		print(ScriptLog..y)
	end
	if Lib.CurrencyCmds.Get("Diamonds") >= Settings.Mailbox.SendGemsAt and Settings.Mailbox.User ~= game:GetService("Players").LocalPlayer.Name then
		task.wait(6)
		_G.FishingFFlags["SENDING_MAIL"] = true
		local Id, Am = "", 0
		for i, v in pairs(Lib.Save.Get().Inventory.Misc) do
			if v.id == "Magic Shard" then
				Id = i
				Am = v._am
				break
			end
		end
		Lib.Network.Invoke("Mailbox: Send", Settings.Mailbox.User, RandomText(), "Misc", Id, Am)
		task.wait(5)
		for i, v in pairs(Lib.Save.Get().Inventory.Pet) do
			if v.id == "Huge Poseidon Corgi" then
				Lib.Network.Invoke("Mailbox: Send", Settings.Mailbox.User, RandomText(), "Pet", i, 1)
				task.wait(5)
			end
		end
		task.wait(3)
		for i, v in pairs(Lib.Save.Get().Inventory.Currency) do
			if v.id == "Diamonds" then
				Lib.Network.Invoke("Mailbox: Send", Settings.Mailbox.User, RandomText(), "Currency", i, v._am - 10000)
			end
		end
		_G.FishingFFlags["SENDING_MAIL"] = false
	end
	if not _G.FishingFFlags["SENDING_MAIL"] then
		if FishingMod then
			if not _G.Hooked then
				local old1
				old1 = hookfunction(FishingMod.StopGame, function(...)
					_G.FishingFFlags["IN_GAME"] = false
					return old1(...)
				end)
				local old2
				old2 = hookfunction(FishingMod.StartGame, function(tbl)
					_G.FishingFFlags["IN_GAME"] = true
					return old2(tbl)
				end)
				_G.Hooked = true
			end
		end
		if ClientMod then
			if not _G.Hooked2 then
				local old3
				old3 = hookfunction(ClientMod.Networking.Hook, function(x,y,z)
					if y == game:GetService("Players").LocalPlayer then
						_G.FishingFFlags["FISH_ON_HOOK"] = true
						
						if z == "Advanced Legendary" then
							_G.FishingFFlags["FISH_LEGENDARY"] = true
						else
							_G.FishingFFlags["FISH_LEGENDARY"] = false
						end
						
					end
					
					return old3(x,y,z)
				end)
				local old4
				old4 = hookfunction(ClientMod.Networking.Unhook, function(x,y,z)
					if y == game:GetService("Players").LocalPlayer then
						_G.FishingFFlags["FISH_ON_HOOK"] = false
					end
					return old4(x,y,z)
				end) 
				old = hookfunction(ClientMod.Networking.FishingSuccess, function(tbl1, playerInstance, rarity, tbl2)
					if playerInstance == game:GetService("Players").LocalPlayer  then
						_G.FishingFFlags["FISH_ON_HOOK"] = false
						if tbl2.data.id == "Diamonds" then
							pcall(function()
								_G.Stats["GEMS_FROM_FISHING"] = _G.Stats["GEMS_FROM_FISHING"] + tbl2.data._am or 0
							end)
						end
					end
					return old(tbl1, playerInstance, rarity, tbl2)
				end)
				_G.Hooked2 = true
			end
		end
		if _G.Hooked and _G.Hooked2 then
			while task.wait() do
				if not _G.FishingFFlags["REQUESTED_CAST"] then
					Lib.Network.Fire("Instancing_FireCustomFromClient", "AdvancedFishing", "RequestCast", Vector3.new((1410.112498512512 + math.random(0, 49.987645)), 61.625, (-4410.11251251789 + math.random(0, 49.987645))))
					_G.FishingFFlags["REQUESTED_CAST"] = true
				end
				if _G.FishingFFlags["REQUESTED_CAST"] and _G.FishingFFlags["FISH_ON_HOOK"] then
					if Settings.Fishing.WaitForLegendary then
						if not _G.FishingFFlags["FISH_LEGENDARY"] then
							while task.wait() do
								if _G.FishingFFlags["FISH_LEGENDARY"] then break end
							end
						end
					end
					while task.wait(0.1) do
						local co = coroutine.create(Reel)
						local success, errorMsg = coroutine.resume(co)
						if not _G.FishingFFlags["FISH_ON_HOOK"] then
							_G.FishingFFlags["REQUESTED_CAST"] = false
							_G.FishingFFlags["REQUESTED_REEL"] = false
							break
						end
					end
				end
				if _G.FishingFFlags["SENDING_MAIL"] then
					break
				end
			end
		end
	end
end
