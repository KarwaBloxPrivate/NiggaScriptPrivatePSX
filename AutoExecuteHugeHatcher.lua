repeat task.wait() until game:IsLoaded()

ChatProperties = {
	Color = Color3.fromRGB(0,255,255); 
	Font = Enum.Font.SourceSansBold;
	TextSize = 18;
}
local StarterGui = game:GetService("StarterGui")
game:GetService("Players").LocalPlayer.Idled:connect(
function()
	game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame);
	wait(0.5);
	game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame);
end
);

local function chat(msg)
	ChatProperties.Text = msg
	StarterGui:SetCore("ChatMakeSystemMessage", ChatProperties)
end


chat("Anti Afk Enabled")

local Lib = require(game.ReplicatedStorage.Library.Client)
local HttpService = game:GetService("HttpService")

function CollectPresent(Id)
	return Lib.Network.Invoke("Hidden Presents: Found", Id)
end

function Round6(number)
	local roundedNumber = math.floor(number * 10^6 + 0.5) / 10^6
	return string.format("%.6f", roundedNumber)
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

local TotalMaadeGems = 0
function GetPresents()
	for i, Present in pairs(game.Workspace.__THINGS:WaitForChild("HiddenPresents"):GetChildren()) do
		if Present.Name == "HiddenPresent" then
			local Id = "ID_"..tostring(Round6(Present.CFrame.x)).."_"..tostring(Round6(Present.CFrame.y)).."_"..tostring(Round6(Present.CFrame.z))
			print(Id)
			local x,y,z = CollectPresent(Id)
			TotalMaadeGems = TotalMaadeGems + (z or 0)
			Present:Destroy()
		end
	end
	if TotalMaadeGems ~= 0 then
		local Data = {
			content = nil,
			embeds = { {
				title = "Made "..tostring(TotalMaadeGems),
				description = game.Players.LocalPlayer.Name,
				color = nil,
				author = {
					name = "Gems from presents"
				}
			} },
			attachments = { }
		}
		SendMessage("https://discord.com/api/webhooks/1123611155303235604/he0sQyBFyGfMx5YIYYKVvNqYNMyWqIdvb7pkmUZ6slxrR1B4DXusPwUo0S42GjnCjHDj", Data)
		TotalMaadeGems = 0
	end
end


print("Collecting Presents")
spawn(function()
	while task.wait(1) do
		GetPresents()
	end	
end)
