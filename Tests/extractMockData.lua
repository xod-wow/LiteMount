LM = {}

loadfile("../TableUtil.lua")('LiteMount', LM)
dofile(arg[1])

print(LM.TableToString({ data = LiteMountDB.data }))
