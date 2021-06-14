socket = require "socket"
math.randomseed(socket.gettime())

dofile("Mock/ClassData.lua")
dofile("Mock/ItemData.lua")
dofile("Mock/MapData.lua")
dofile("Mock/MountData.lua")
dofile("Mock/SpellData.lua")

dofile("Mock/Constants.lua")
dofile("Mock/Functions.lua")
dofile("Mock/Item.lua")
dofile("Mock/Macro.lua")
dofile("Mock/Spell.lua")
dofile("Mock/Frame.lua")
dofile("Mock/Button.lua")
dofile("Mock/ChatFrame.lua")
dofile("Mock/PlayerModel.lua")
dofile("Mock/C_Map.lua")
dofile("Mock/C_MountJournal.lua")
dofile("Mock/C_QuestLog.lua")
dofile("Mock/C_Scenario.lua")
dofile("Mock/C_Transmog.lua")
dofile("Mock/C_ZoneAbility.lua")
dofile("Mock/GlobalFrames.lua")

dofile("Mock/MockState.lua")

math.randomseed(os.time())
