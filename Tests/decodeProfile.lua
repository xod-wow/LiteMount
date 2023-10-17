local LM = {}

loadfile("Mock/WoWAPI.lua")()
loadfile("../Libs/LibStub/LibStub.lua")()
loadfile("../Libs/AceSerializer-3.0/AceSerializer-3.0.lua")()
loadfile("../Libs/LibDeflate/LibDeflate.lua")()
loadfile("../TableUtil.lua")('LiteMount', LM)

local Serializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

local str = ''

local f = io.open(arg[1], 'r')

while true do
    local line = f:read()
    if not line then break end
    str = str .. line:gsub("\r", "")
end

f:close()

local decoded = LibDeflate:DecodeForPrint(str)
if not decoded then
    print('Failed decode')
    os.exit()
end

local deflated = LibDeflate:DecompressDeflate(decoded)
if not deflated then
    print('Failed deflate')
    os.exit()
end

local isValid, data = Serializer:Deserialize(deflated)
if not isValid then
    print('Failed deserialize')
    os.exit()
end

print(LM.TableToString({ LiteMountDB = data }))
