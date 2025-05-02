-- Services
local Players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local httpService = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")
local marketplaceService = game:GetService("MarketplaceService")

-- Variables
local localPlayer = Players.LocalPlayer

-- Init interface
local Crystal = game:GetObjects("rbxassetid://135771270894798")[1]
Crystal.Parent = (function()
	if protect_gui then protect_gui(Crystal) end

	for _, try in {
		function() return gethui() end,
		function()
			local gui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
			gui:GetFullName()
			return gui
		end,
		function()
			local core = game:GetService("CoreGui")
			core:GetFullName()
			return core
		end,
		function() return localPlayer:WaitForChild("PlayerGui") end
	} do
		local success, result = pcall(try)
		if success and result then return result end
	end

	return nil
end)()

local container = Crystal.Shadow.Window


-- Switch tabs

local function tween(obj, props, info)
	return tweenService:Create(obj, info or TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function toMainPage(page)
	tween(container.Main, {Position = UDim2.new()})
	tween(page, {Position = UDim2.fromScale(1, 0)})
end

for _, tab in pairs(container.Main.Tabs:GetChildren()) do
	if tab:IsA("TextButton") then
		local tabPage = container.TabPages:FindFirstChild(tab.Name)
		if tabPage then
			tab.MouseButton1Click:Connect(function()
				tween(container.Main, {Position = UDim2.fromScale(-1, 0)})
				tween(tabPage, {Position = UDim2.new()})
			end)
			tabPage.Title.Back.MouseButton1Click:Connect(function()
				toMainPage(tabPage)
			end)
		end
	end
end

-- Button interact colors
local originalColors = {}
for _, button in pairs(container:GetDescendants()) do
	if button:IsA("TextButton") then
		originalColors[button] = button.BackgroundColor3

		local function changeColor(btn, amount)
			if type(amount) == "number" then
				local color = btn.BackgroundColor3
				local newColor = Color3.new(
					math.clamp(color.R + amount / 255, 0, 1),
					math.clamp(color.G + amount / 255, 0, 1),
					math.clamp(color.B + amount / 255, 0, 1)
				)
				tween(button, {BackgroundColor3 = newColor})
			else
				tween(button, {BackgroundColor3 = originalColors[btn]})
			end
	    	end

	    button.MouseEnter:Connect(function()
		changeColor(button, 10)
	    end)

	    button.MouseLeave:Connect(function()
		changeColor(button, true)
	    end)

	    button.MouseButton1Down:Connect(function()
		changeColor(button, 20)
	    end)

	    button.MouseButton1Up:Connect(function()
		changeColor(button, true)
	    end)
	end
end

-- Home page
local homePage = container.TabPages.Home.Components

local playerInfo = homePage.PlayerInfo

playerInfo.DisplayName.Text = localPlayer.DisplayName
playerInfo.UserName.Text = localPlayer.Name
playerInfo.Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..localPlayer.UserId.."&width=420&height=420&format=png"

-- Session info

-- https://github.com/SiriusSoftwareLtd/Sirius/blob/request/source.lua#L2360-L2364
local function format(n) return string.format("%02i", n) end

local function toHMS(sec)
	local m = (sec - sec%60)/60
	sec = sec - m*60
	local h = (m - m%60)/60
	m = m - h*60
	return format(h)..":"..format(m)..":"..format(sec)
end

task.spawn(function()
	while task.wait(1) do
		playerInfo.Latency.Amount.Text = math.floor(math.clamp(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue(), 10, 700)).."ms"
		playerInfo.SessionTime.Amount.Text = toHMS(time())
	end
end)

-- Server info
local gameInfo = homePage.GameInfo
local actualGameInfo = marketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)

gameInfo.Icon.Image = "rbxassetid://"..actualGameInfo.IconImageAssetId
gameInfo.GameName.Text = actualGameInfo.Name
gameInfo.GameOwner.Text = "by " .. actualGameInfo.Creator.Name

local function updatePlayersText() gameInfo.Players.Amount.Text = #Players:GetPlayers().."/"..Players.MaxPlayers end
updatePlayersText()
Players.PlayerAdded:Connect(updatePlayersText)
Players.PlayerRemoving:Connect(updatePlayersText)

-- Rejoin (https://github.com/SiriusSoftwareLtd/Sirius/blob/request/source.lua#L2144-L2153)
gameInfo.Rejoin.MouseButton1Click:Connect(function()
	pcall(function() queueonteleport(game:HttpGet("https://raw.githubusercontent.com/ice-rbx/Crystal/refs/heads/main/Source.luau", true)) end)

	if #Players:GetPlayers() <= 1 then
		teleportService:Teleport(game.PlaceId, localPlayer)
	else
		teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
	end
end)

-- Serverhop (https://github.com/SiriusSoftwareLtd/Sirius/blob/request/source.lua#L2155-L2176) sorry, this script is heavily pasted
gameInfo.Serverhop.MouseButton1Click:Connect(function()
	local highestPlayers = 0
	local servers = {}

	for _, server in pairs(httpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data) do
		if type(server) == "table" and server.maxPlayers > server.playing and server.id ~= game.JobId then
			if server.playing > highestPlayers then
				highestPlayers = server.playing
				servers[1] = server.id
			end
		end
	end

	if #servers > 0 then
		task.wait(0.3)
		pcall(function() queueonteleport(game:HttpGet("https://raw.githubusercontent.com/ice-rbx/Crystal/refs/heads/main/Source.luau", true)) end)
		teleportService:TeleportToPlaceInstance(game.PlaceId, servers[1])
	end
end)

-- Join discord
local request = request or http_request or (http and http.request)

homePage.DiscordInvite.MouseButton1Click:Connect(function()
	request({
			Url = "http://127.0.0.1:6463/rpc?v=1",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Origin"] = "https://discord.com"
			},
			Body = httpService:JSONEncode({
				cmd = "INVITE_BROWSER",
				args = {code = "9rruBeaD8y"},
				nonce = httpService:GenerateGUID(false)
			})
	})
end)
