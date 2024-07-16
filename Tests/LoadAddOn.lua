LM = {}

loadfile("../Libs/LibStub/LibStub.lua")()
loadfile("../Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua")()
loadfile("../Libs/AceDB-3.0/AceDB-3.0.lua")()
loadfile("../Libs/AceSerializer-3.0/AceSerializer-3.0.lua")()
loadfile("../Libs/LibDeflate/LibDeflate.lua")()
local mrNamespace = {}
loadfile("../Libs/MountsRarity-2.0/MountsRarity.lua")('MountsRarity', mrNamespace)

function LoadToCFile(path)
        local f, err = loadfile(path)
        if f then
            f('LiteMount', LM)
        else
            print(file)
            print(err)
            os.exit()
        end
end

function LoadToC(path)
 
    tocFiles = { }

    for line in io.lines(path) do
        if not line:match("^#") and line:match('%.lua$') then
            table.insert(tocFiles, line)
        end
    end

    for _,file in ipairs(tocFiles) do
        LoadToCFile("../" .. file)
    end
end

LoadToC("../LiteMount.toc")
LoadToCFile("../UI/UIFilter.lua")
