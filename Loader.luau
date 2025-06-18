local repo = 'https://raw.githubusercontent.com/v537/vware/refs/heads/main/games/'
local success, result = pcall(game.HttpGetAsync,game,repo..game.PlaceId..'.luau',true)
if success and result and result ~= '404: Not Found' then loadstring(result)() else loadstring(game:HttpGetAsync(repo..'universal.luau',true))()end
