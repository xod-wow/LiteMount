socket = require "socket"
date = require "date"

math.randomseed(math.floor(socket.gettime()))

function MockGetKVFromData(mTable, mKey, mIndex)
    for k, v in pairs(mTable) do
        if v[mIndex] == mKey then
            return k, v
        end
    end
end

local function maxn(t)
    local n = 0
    for k in pairs(t) do
        if type(k) == 'number' then
            n = math.max(k, n)
        end
    end
    return n
end

function MockGetFromData(mTable, mKey, mIndex)
    local _, info
    if mIndex then
        mKey = MockGetKVFromData(mTable, mKey, mIndex)
        if not mKey then return end
    end
    info = mTable[mKey]
    if type(info) == "table" then
        return unpack(info, 1, maxn(info))
    else
        return info
    end
end

dofile("Mock/Data.lua")

dofile("Mock/Constants.lua")
dofile("Mock/Enum.lua")
dofile("Mock/Functions.lua")
dofile("Mock/Item.lua")
dofile("Mock/Macro.lua")
dofile("Mock/Spell.lua")
dofile("Mock/Frame.lua")
dofile("Mock/Button.lua")
dofile("Mock/ChatFrame.lua")
dofile("Mock/PlayerModel.lua")
dofile("Mock/C_Calendar.lua")
dofile("Mock/C_DateAndTime.lua")
dofile("Mock/C_Map.lua")
dofile("Mock/C_MountJournal.lua")
dofile("Mock/C_PetJournal.lua")
dofile("Mock/C_QuestLog.lua")
dofile("Mock/C_Scenario.lua")
dofile("Mock/C_Transmog.lua")
dofile("Mock/C_ZoneAbility.lua")
dofile("Mock/GlobalFrames.lua")
dofile("Mock/ModelScene.lua")
dofile("Mock/Vector2D.lua")

dofile("Mock/MockState.lua")

math.randomseed(os.time())
