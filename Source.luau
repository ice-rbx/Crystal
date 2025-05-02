-- isfile
local isfile = isfile or function(file)
	local success, result = pcall(function() return readfile(file) end)
	return success and result ~= nil and result ~= ""
end

-- delfile
local delfile = delfile or function(file)
	writefile(file, "")
end

-- downloadfile
local function downloadFile(path, content, customAsset)
	path = "Crystal/"..path
	if not isfile(path) then writefile(path, content) end
	return customAsset and path or readfile(path)
end

-- Init folders
for _, folder in {"Crystal", "Crystal/Assets", "Crystal/Configs"} do
	if not isfolder(folder) then makefolder(folder) end
end

-- Services
local Players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local httpService = game:GetService("HttpService")

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
local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function tween(obj, props)
	local t = tweenService:Create(obj, tweenInfo, props)
	t:Play()
	return t
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
