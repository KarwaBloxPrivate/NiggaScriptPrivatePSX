local startTime = tick()
repeat task.wait() until game:IsLoaded()
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
print("[Fast Comet Swapper]: Hooked Functions")

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
			if ping ~= nil and ping > math.random(50, 70) and v.playing then
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
			task.wait(0.44)
		end
	end
	if (writefile) then
		json = HttpService:JSONEncode(jobid)
		writefile(Filename, json)   
	end
end 
local Network = require(game:GetService("ReplicatedStorage").Library.Client.Network)
local function FindComet()
	for i, v in pairs(Network.Invoke("Comets: Get Data")) do
		if v then
			return v
		else
			return nil
		end	
	end
end
local CometType
local Area
local data
local Found
if FindComet() ~= nil then
	local Info = FindComet()
	CometType = Info.Type
	Area = Info.AreaId
	local elapsedTime = tick() - startTime
	print("[Fast Comet Swapper]: Time To Determinate If There Is Comet: " .. elapsedTime .. " seconds")
	print("[Fast Comet Swapper]: "..CometType.." Found".." in "..Area)
	Found = true
else
	local elapsedTime = tick() - startTime
	print("[Fast Comet Swapper]: Time To Determinate If There Is Comet: " .. elapsedTime .. " seconds")
	print("[Fast Comet Swapper]: No Comet Found Hopping Servers")
	ServerHop()
end	
