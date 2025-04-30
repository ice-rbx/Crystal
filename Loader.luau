repeat wait() until game:IsLoaded()

local repo = "https://raw.githubusercontent.com/ice-rbx/Crystal/refs/heads/main/games/"

local success, result = pcall(function()
  return game:HttpGet(repo .. game.PlaceId .. ".luau"), "Crystal")()
end

if not success or result = "404: Not Found" then
    return loadstring(game:HttpGet(repo .. "Universal.luau"), "Crystal")()
end
