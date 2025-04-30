repeat wait() until game:IsLoaded()

local repo = "https://raw.githubusercontent.com/ice-rbx/Crystal/refs/heads/main/Games/"

local success, result = pcall(function()
  return game:HttpGet(repo .. game.PlaceId .. ".luau", true), "Crystal")()
end

if not success or result = "404: Not Found" then
    return loadstring(game:HttpGet(repo .. "Universal.luau", true), "Crystal")()
end
