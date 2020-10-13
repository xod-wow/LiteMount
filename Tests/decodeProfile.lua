dofile("mock/WoWAPI.lua")
dofile("LoadAddOn.lua")

local Serializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

SendEvent('ADDON_LOADED', 'LiteMount')

local lines = {}
while true do
    local line = io.stdin:read()
    if not line then break end
    lines[#lines+1] = line
end

local str = table.concat(lines, '')

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

print(LM.TableToString(data))
