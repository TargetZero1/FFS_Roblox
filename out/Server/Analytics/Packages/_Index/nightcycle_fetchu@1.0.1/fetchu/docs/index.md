# Welcome to fetchu

**fetchu** is a lightweight module created to simplify Roblox's HttpService for faster and efficient requests. Our goal is to minimize all the work you do for one request in a single line of code.

Here is an example of a request with **fetchu**

```lua
local import = require(game.ReplicatedStorage.roarn_modules.roarn_tools)

local fetchu = import("fetchu") -- or local fetchu = require(path/to/fetchu)

local response = fetchu.get("https://pokeapi.co/api/v2/pokemon?limit=1", {headers = {
	["Authorization"] = "my token for authorization!"
}, nocache = true})

print(response)

--[[
    Returns:
    {"count":1118,"next":"https://pokeapi.co/api/v2/pokemon?offset=1&limit=1","previous":null,"name":"bulbasaur","url":"https://pokeapi.co/api/v2/pokemon/1/"}
--]]

```
