local Settings = {
	AutoOpenGifts = true,
	AutoOpenPresents = true,
	Mailbox = {
		User = "Nig1r11"
	},
	Webhook = {
		url = "https://discord.com/api/webhooks/1209649163982344242/3hdoE80-N4kMF0Xrnm5ylCiearxQdrycU014-E8QjZF1G4VmiSw7smbKn89EqFJuD6WF",
		StatsTimeout = 60*10,
	},
	Log = false,
	Optimization = {
		FpsCap = 60,
		Disable3dRendering = false
	}
}

--[[
		 To do 
		-Auto teleport to fishing area when execute start fishing have also webhook add a check if amount of gems => 5000000 then send to Settings.Mailbox.User GemsAmount - MailboxTax then continue the fishing loop
		-Auto collect orbs/gifts/presents
		-Send stats every 10 minutes or selected amount to webhook with progress made with estimated amount of gems per 1 hours and 1 day 
]]

local ScriptLog = "[Karwa's Auto Chest]: "

repeat task.wait() until game:IsLoaded()

game:GetService("Players").LocalPlayer.Idled:connect(function()
	game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	task.wait(0.5)
	game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

repeat 
	local MainGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
	print(MainGui.Enabled)
	task.wait()
until MainGui.Enabled

local Lib = require(game.ReplicatedStorage:WaitForChild("Library").Client)
local Lib_ = require(game.ReplicatedStorage:WaitForChild("Library"))
local a = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Breakables["Breakables Frontend"])
local HttpService = game:GetService("HttpService")

game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Disabled = true

if Settings.Optimization.Disable3dRendering then
	game:GetService("RunService"):Set3dRenderingEnabled(false)
end

setfpscap(Settings.Optimization.FpsCap)

function Teleport(CFramee) 
	game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFramee
end

local HardcodedCFrames = { --ik its bad
	{Cframe = CFrame.new(124.515366, 13.7197285, 576.186096, 1, 0, 0, 0, 1, 0, 0, 0, 1), Id = "SandcastleChest"},
	{Cframe = CFrame.new(1488.86597, 17.1771889, 1759.89807, 0.976195097, 2.51867469e-08, -0.216894269, -2.43103315e-08, 1, 6.70889966e-09, 0.216894269, -1.27642374e-09, 0.976195097), Id = "HellChest"},
	{Cframe = CFrame.new(574.376404, 13.6939154, 3284.6394, 0, 0, -1, 0, 1, 0, 1, 0, 0), Id = "EnchantedChest"},
	{Cframe = CFrame.new(10.3855515, 113.63295, 5647.01904, 1, 0, 0, 0, 1, 0, 0, 0, 1), Id = "AngelChest"},
}

function FindChest(id)
	local Found = false
	local CoinId = ""
	for i, v in pairs(workspace.__THINGS.Breakables:GetChildren()) do
		if v.ClassName == "Model" then
			local Breakable = a.getBreakable(v.Name)
			if Breakable then 
				if Breakable.class then
					if Breakable.class == "Chest" and Breakable.id == id then
						Found = true
						CoinId = v.Name
						print(ScriptLog.."Found "..id)
					end
				end
			end
		end
	end
	return Found, CoinId
end

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

getgenv().CframeToTeleport = HardcodedCFrames[1].Cframe

local IsAnyChest = true
for i, v in pairs(HardcodedCFrames) do
	Teleport(v.Cframe)
	print(ScriptLog.."Teleporting to "..v.Id)
	IsAnyChest, CoinId = FindChest(v.Id)
	local StartTime = os.time()
	repeat task.wait() IsAnyChest, CoinId = FindChest(v.Id) until IsAnyChest or os.time() - StartTime >= 3
	if IsAnyChest then
		while task.wait(0.1) do
			Lib.Network.Fire("Breakables_PlayerDealDamage", CoinId)
			IsAnyChest, CoinId = FindChest(v.Id)
			if not IsAnyChest then
				break
			end
		end
	end
end

ServerHop()
