[![Frame 594|690x215](https://raw.githubusercontent.com/imacodr/fetchu/main/assets/banner.png)](https://imacodr.github.io/fetchu)

<div align="center">

[[📘Documentation]](https://imacodr.github.io/fetchu) | [[📁 Source Code]](https://github.com/imacodr/fetchu)

fetchu is a lightweight module created to simplify Roblox's HttpService for faster and efficient requests. Our goal is to minimize all the work you do for one request in a single line of code.

<hr />

[**Why fetchu?**](https://imacodr.github.io/fetchu/)

Using a tool like fetchu can simplify all Http requests out of Roblox to a single line of code while fetchu handles all errors. Its as easy as doing this:

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

<hr />

[**Installation**](https://imacodr.github.io/fetchu/installation/)

_with Roarn (recommended for Rojo users)_

To install **fetchu** with Roarn you can simply do the following command:

```bash
roarn install fetchu
```

[Learn more](https://docs.roarn.space/) on how Roarn, a Roblox package manager helps your workspace.

_with Roblox_

If you are preferably using Roblox Studio to develop code you can also install our module through the Roblox marketplace.

[Roblox Module](https://www.roblox.com/library/8145888425/fetchu)

_with GitHub_

You can also install our package from [GitHub releases](https://github.com/imacodr/fetchu/releases) easily. We have ZIP files available for Rojo users although we would prefer you using [Roarn](https://docs.roarn.space/) for a more organized workspace.

<hr />

**Questions?**

If you have any questions on how fetchu works, please reply on this post! I'll be answering all questions here.

If you have more concerns or need help with fetchu we have community servers!

[![1024-gold 2|40x40](./assets/discord.png)](https://discord.gg/SYtrv9m)

</div>
