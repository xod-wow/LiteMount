function GetRealmName() return MockState.realmName end

function UnitName() return MockState.playerName end

function UnitClass() return MockState.playerClass end

function UnitFullName(unit) return MockState.playerName, MockState.realmName end

function UnitRace() return MockState.playerRace end

function UnitExists() return math.random() <= 0.5 end

function UnitFactionGroup() return MockState.playerFactionGroup end

function UnitIsPlayer(unit) return unit == "player" end

function UnitPlayerOrPetInParty(unit) return true end

function UnitPlayerOrPetInRaid(unit) return true end

function UnitIsFriend(unit) return math.random() <= 0.5 end

function UnitAffectingCombat(unit) return MockState.inCombat end

function UnitIsDead(unit) return false end

function UnitIsPVP(unit) return false end

function UnitIsUnit(unit1, unit2) return unit1 == unit2 end

function UnitSex(unit) return math.random(2) + 1 end

function GetLocale() return MockState.locale end

function GetCurrentRegion() return MockState.region end

function GetProfessions() return end

function GetNumTrackingTypes() return 0 end

function GetAddOnMetadata(name, attr)
    if attr == "Title" then
        return "LiteMount"
    elseif attr == "Version" then
        return "99.9"
    end
end

function IsSubmerged() return MockState.submerged end

function IsFalling() return MockState.falling end

function IsFlying() return MockState.flying end

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

function IsOutdoors() return not MockState.indoors end

function IsStealthed()
    local class = UnitClass('player')
    if class == 'DRUID' or class == 'ROGUE' then
        return math.random() < 0.25
    end
end
    
function IsResting() return math.random() < 0.5 end

function CanExitVehicle() return MockState.inVehicle end

function GetTime() return socket.gettime() end

function InCombatLockdown() return MockState.inCombat end

function UnitLevel(unit) return MockState.playerLevel end

local roles = { 'TANK', 'HEALER', 'DAMAGER' }

function UnitGroupRolesAssigned(unit)
    return roles[math.random(#roles)]
end

function IsInGroup(groupType)
    if math.random() < 0.2 then
        return true
    else
        return false
    end
end

IsInRaid = IsInGroup

function GetTalentTierInfo(tier)
    return true, math.random(3), 10
end

function GetSpecialization()
    local class = UnitClass('player')
    if class == 'DEMONHUNTER' then
        return math.random(2)
    elseif class == 'DRUID' then
        return math.random(4)
    else
        return math.random(3)
    end
end

function GetSpecializationInfo()
    -- too complicated to handle for now
end

function GetShapeshiftForm()
    -- Assume you're a balance druid since it's the most complex
    if UnitClass('player') == 'DRUID' then
        if MockState.buffs[783] then
            return 4
        elseif math.random() < 0.1 then
            return 1
        elseif math.random() < 0.1 then
            return 2
        else
            return 3
        end
    elseif UnitClass('player') == 'SHAMAN' and MockState.buffs[2645] then
        return 1
    else
        return 0
    end
end

function HasTempShapeshiftActionBar()
    local id = GetShapeshiftFormID()
    local class = UnitClass('player')
    if class == 'DRUID' then
        return id == 1 or id == 3 or id == 31
    else
        return false
    end
end

local DruidBuffFormIDMap = {
       [768] = 1,  -- cat
       [783] = 29, -- travel
      [5487] = 3,  -- bear
     [24858] = 31, -- monkkin rank 1
    [231042] = 31, -- moonkin rank 2
}

function GetShapeshiftFormID()
    if UnitClass('player') == 'SHAMAN' and MockState.buffs[2645] then
        return 16
    elseif UnitClass('player') == 'DRUID' then
        for spellID, formID in pairs(DruidBuffFormIDMap) do
            if MockState.buffs[spellID] then
                return MockState.buffs[spellID]
            end
        end
    end
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

-- id, name, points, completed, month, day, year, desc, flags, icon, rewardText, isGuild, mine, char
function GetAchievementInfo(id)
    local now = os.date('*t')
    local char = UnitName('player')
    local name = "FakeAchievement"
    if math.random(2) == 1 then
        return id, name, 20, true, now.month, now.day, now.year, name, 0x0, nil, name, false, true, char
    else
        return id, name, 20, false, nil, nil, nil, name, 0x0, nil, name, false, true, char
    end
end

local CLASSINFO = {
    { "Warrior", "WARRIOR", 1 },
    { "Paladin", "PALADIN", 2 },
    { "Hunter", "HUNTER", 3 },
    { "Rogue", "ROGUE", 4 },
    { "Priest", "PRIEST", 5 },
    { "Death Knight", "DEATHKNIGHT", 6 },
    { "Shaman", "SHAMAN", 7 },
    { "Mage", "MAGE", 8 },
    { "Warlock", "WARLOCK", 9 },
    { "Monk", "MONK", 10 },
    { "Druid", "DRUID", 11 },
    { "Demon Hunter", "DEMONHUNTER", 12 },
}

function GetClassInfo(index)
    return unpack(data.GetClassInfo[index])
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
unpack = table.unpack
sort = table.sort
time = os.time
