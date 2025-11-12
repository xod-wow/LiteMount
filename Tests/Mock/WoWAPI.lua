socket = require "socket"

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

local function IsIndexTable(t)
    if type(t) ~= 'table' then
        return false
    end
    for k in pairs(t) do
        if type(k) ~= 'number' then
            return false
        end
    end
    return true
end

function MockGetFromData(mTable, mKey, mIndex)
    local _, info
    if mIndex then
        mKey = MockGetKVFromData(mTable, mKey, mIndex)
        if not mKey then return end
    end
    info = mTable[mKey]
    if IsIndexTable(info) then
        return unpack(info, 1, maxn(info))
    else
        return info
    end
end

dofile("Mock/Data.lua")
dofile("Mock/GlobalStrings.lua")

dofile("Mock/Functions.lua")

dofile("Mock/Color.lua")
dofile("Mock/Constants.lua")
dofile("Mock/Enum.lua")
dofile("Mock/Macro.lua")
dofile("Mock/Spell.lua")
dofile("Mock/C_AddOns.lua")
dofile("Mock/C_Calendar.lua")
dofile("Mock/C_ChallengeMode.lua")
dofile("Mock/C_Container.lua")
dofile("Mock/C_CreatureInfo.lua")
dofile("Mock/C_DateAndTime.lua")
dofile("Mock/C_Item.lua")
dofile("Mock/C_Map.lua")
dofile("Mock/C_MountJournal.lua")
dofile("Mock/C_PetJournal.lua")
dofile("Mock/C_QuestLog.lua")
dofile("Mock/C_Scenario.lua")
dofile("Mock/C_Spell.lua")
dofile("Mock/C_Transmog.lua")
dofile("Mock/C_UnitAuras.lua")
dofile("Mock/C_ZoneAbility.lua")
dofile("Mock/Vector2D.lua")
dofile("Mock/UI_Frame.lua")
dofile("Mock/UI_Button.lua")
dofile("Mock/UI_ChatFrame.lua")
dofile("Mock/UI_ModelScene.lua")
dofile("Mock/UI_GlobalFrames.lua")
dofile("Mock/UI_PlayerModel.lua")

dofile("Mock/MockState.lua")

math.randomseed(os.time())
