function GetRealmName() return MockState.realmName end

function UnitName() return MockState.playerName end

function UnitClass() return MockState.playerClass end

function UnitRace() return MockState.playerRace end

function UnitFactionGroup() return MockState.playerFactionGroup end

function UnitIsPlayer(unit) return unit == "player" end

function GetLocale() return MockState.locale end

function GetCurrentRegion() return MockState.region end

function GetAddOnMetadata(name, attr)
    if attr == "Title" then
        return "LiteMount"
    elseif attr == "Version" then
        return "99.9"
    end
end

function IsSubmerged() return MockState.submerged end

function IsFalling() return MockState.falling end

function IsMounted()
    for _, info in pairs(data.GetMountInfoByID) do
        if MockState.buffs[info[2]] then
            return true
        end
    end
    for _, info in pairs(data.GetItemSpell) do
        if MockState.buffs[info[2]] then
            return true
        end
    end
end

function IsFlyableArea() return MockState.flyableArea end

function IsIndoors() return MockState.indoors end

function CanExitVehicle() return MockState.inVehicle end

function GetTime() return socket.gettime() end

function InCombatLockdown() return MockState.inCombat end

function UnitLevel(unit) return MockState.playerLevel end

function GetShapeshiftFormID()
    -- base this off something
end

function GetInstanceInfo()
    return "The Shadowlands", "none", 0, "", 5, 0, false, 2222, 0
end

function HasAction(slotID)
    return true
end

function GetActionInfo(slotID)
    if MockState.extraActionButton then
        return "spell", MockState.extraActionButton
    end
end

function HasExtraActionBar()
    return ( MockState.extraActionButon ~= nil )
end

function GetMirrorTimerInfo()
    if MockState.submerge then
        return "BREATH", nil, nil, -1
    end
end

function IsShiftKeyDown() return MockState.keyDown.shift end
function IsAltKeyDown() return MockState.keyDown.alt end
function IsControlKeyDown() return MockState.keyDown.ctrl end
function IsModifierKeyDown()
    return IsShiftKeyDown() or IsAltKeyDown() or IsControlKeyDown()
end

function GetUnitSpeed()
    return 0, 14, 7, 4.722219940002
end

function table.wipe(tbl)
    for k in pairs(tbl) do tbl[k] = nil end
    return tbl
end

function Mixin(dst, ...)
    for i = 1, select('#', ...) do
        local src = select(i, ...)
        for k, v in pairs(src) do
            dst[k] = v
        end
    end
    return dst
end

function CopyTable(src)
    local dst = {}
    for k,v in pairs(src) do
        if type(v) == 'table' then
            dst[k] = CopyTable(v)
        else
            dst[k] = v
        end
    end
    return dst
end

function strsplit(sep, str)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   str:gsub(pattern, function(c) fields[#fields+1] = c end)
   return unpack(fields)
end

function tContains(tbl, val)
    for _,v in ipairs(tbl) do
        if v == val then return true end
    end
end

local function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil else return a[i], t[a[i]] end
    end
    return iter
end

function DumpTable(o, indent)
    indent = indent or 0
    local pad = string.rep('    ', indent)
    local pad2 = string.rep('    ', indent+1)

    if type(o) == 'table' then
        local s = '{'

        for k,v in pairsByKeys(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .."\n" .. pad2 .. '['..k..'] = ' .. DumpTable(v, indent+1) .. ','
        end

        return s .. "\n" .. pad .. '}'
    else
        if type(o) == 'string' then
            return '"' .. tostring(o) .. '"'
        else
            return tostring(o)
        end
    end
end

-- aliases

strmatch = string.match
strlen = string.len
format = string.format
wipe = table.wipe
tinsert = table.insert
sort = table.sort
