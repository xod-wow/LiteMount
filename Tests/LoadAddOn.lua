LM = {}

loadfile("../Libs/LibStub/LibStub.lua")()
loadfile("../Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua")()
loadfile("../Libs/AceDB-3.0/AceDB-3.0.lua")()
loadfile("../Libs/AceSerializer-3.0/AceSerializer-3.0.lua")()
loadfile("../Libs/LibDeflate/LibDeflate.lua")()
local mrNamespace = {}
loadfile("../Libs/MountsRarity-2.0/Version.lua")('MountsRarity', mrNamespace)
loadfile("../Libs/MountsRarity-2.0/Data.lua")('MountsRarity', mrNamespace)
loadfile("../Libs/MountsRarity-2.0/MountsRarity.lua")('MountsRarity', mrNamespace)
 
tocFiles = { }

local f = io.open("../LiteMount.toc", "r")
for line in io.lines("../LiteMount.toc") do
    if not line:match("^#") and line:match('%.lua$') then
        table.insert(tocFiles, line)
    end
end

for _,file in ipairs(tocFiles) do
    local f, err = loadfile("../" .. file)
    if f then
        f('LiteMount', LM)
    else
        print(file)
        print(err)
        os.exit()
    end
end
