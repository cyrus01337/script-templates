local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")

for _, variable in { "API_KEY", "PLACE_ID", "UNIVERSE_ID" } do
    assert(process.env[variable], `{variable} must be set`)
end

local response = net.request({
    url = `https://apis.roblox.com/universes/v1/{process.env.UNIVERSE_ID}/places/{process.env.PLACE_ID}/versions?versionType=Published`,
    method = "POST",
    headers = {
        ["Content-Type"] = "application/octet-stream",
        ["x-api-key"] = process.env.API_KEY,
    },
    body = fs.readFile("artifact.rbxl"),
})

print(response.statusCode, response.statusMessage)
process.exit(if response.statusCode == 200 then 0 else 1)
