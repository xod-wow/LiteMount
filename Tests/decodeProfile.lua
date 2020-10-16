dofile("mock/WoWAPI.lua")
dofile("LoadAddOn.lua")

local Serializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

SendEvent('ADDON_LOADED', 'LiteMount')

local f = io.open(arg[1], 'r')
local str = f:read('*all')
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
