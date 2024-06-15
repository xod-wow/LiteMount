--[[----------------------------------------------------------------------------
  LiteMount/Location.lua

  Some basics about the current game state with respect to mounting. Most of
  the mojo is done by IsSpellUsable to know if a mount can be cast, this just
  helps with the prioritization.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.Environment = LM.CreateAutoEventFrame("Frame")
LM.Environment:RegisterEvent("PLAYER_LOGIN")

function LM.Environment:Initialize()
    self.combatTravelForm = nil

    self:InitializeHolidays()
    self:UpdateSwimTimes()

    self.startedFalling = 0
    self.stoppedFalling = 0
    self.stoppedMoving = GetTime()

    self:SetScript('OnUpdate', self.OnUpdate)

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
    self:RegisterEvent("PLAYER_STARTED_MOVING")
    self:RegisterEvent("PLAYER_STOPPED_MOVING")
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
end

-- I hate OnUpdate handlers but there are just no good events for determining
-- falling and jumping. Keep an eye on it to make sure it's not using up
-- too much CPU.  Though given WeakAuras, it's hard to see how anyone would
-- notice.

local onUpdateElapsed = 0
local IsFalling = IsFalling

function LM.Environment:OnUpdate(delta)
    onUpdateElapsed = onUpdateElapsed + delta
    if onUpdateElapsed > 0.05 then
        if IsFalling() then
            if self.startedFalling < self.stoppedFalling then
                self.startedFalling = GetTime()
            end
        else
            if self.stoppedFalling <= self.startedFalling then
                self.stoppedFalling = GetTime()
            end
        end
        onUpdateElapsed = 0
    end
end

function LM.Environment:IsFalling()
    return IsFalling() and
        self.startedFalling > self.stoppedFalling and
        GetTime() - self.startedFalling >= 0.45
end

-- A jump in place takes approximately 0.83 seconds

function LM.Environment:GetJumpTime()
    local airTime = self.stoppedFalling - self.startedFalling
    if airTime > 0.73 and airTime < 0.93 then
        local timeSinceLanded = GetTime() - self.stoppedFalling
        return timeSinceLanded
    end
end

function LM.Environment:GetStationaryTime()
    if not self.stoppedMoving then
        return 0
    else
        return GetTime() - math.max(self.stoppedMoving, self.stoppedFalling)
    end
end

function LM.Environment:UpdateSwimTimes()
    if not IsSubmerged() then
        self.lastDryTime = GetTime()
    end
end

function LM.Environment:IsFloating()
    return IsSubmerged() and not self:CantBreathe() and
           ( GetTime() - (self.lastDryTime or 0 ) < 1.0)
end

function LM.Environment:IsMovingOrFalling()
    return (GetUnitSpeed("player") > 0 or IsFalling())
end

function LM.Environment:IsTheMaw(mapPath)
    local instanceID = select(8, GetInstanceInfo())

    -- This is the instanced starting experience
    if instanceID == 2364 then return true end

    -- This is the instanced post-Maldraxxus questing
    if instanceID == 2456 then return true end

    -- Otherwise, The Maw is just zones in instance 2222
    return LM.Environment:IsMapInPath(1543, mapPath)
end

-- Now that we have to ignore some mounts that are duplicates for the Kalimdor
-- cup but still trigger the condition, do this the old fashioned way iterating
-- over the mount journal. Assumption is that you can't summon a dragonriding
-- mount in a non-dragonriding area.

function LM.Environment:IsDragonriding()
    local mountIDs = C_MountJournal.GetMountIDs()
    for _, id in ipairs(mountIDs) do
        local _, _, _, isActive, _, _, _, _, _, _, _, _, isForDragonriding = C_MountJournal.GetMountInfoByID(id)
        if isActive then
            return isForDragonriding
        end
    end
end

function LM.Environment:PLAYER_LOGIN()
    self:Initialize()
end

function LM.Environment:PLAYER_STARTED_MOVING()
    self.stoppedMoving = nil
end

function LM.Environment:PLAYER_STOPPED_MOVING()
    self.stoppedMoving = GetTime()
end

function LM.Environment:MOUNT_JOURNAL_USABILITY_CHANGED()
    self:UpdateSwimTimes()
end

function LM.Environment:PLAYER_ENTERING_WORLD()
    LM.Options:RecordInstance()
end

function LM.Environment:ZONE_CHANGED()
    LM.Options:RecordInstance()
end

function LM.Environment:ZONE_CHANGED_INDOORS()
    LM.Options:RecordInstance()
end

function LM.Environment:ZONE_CHANGED_NEW_AREA()
    LM.Options:RecordInstance()
end

-- encounterID, encounterName, difficultyID, groupSize
function LM.Environment:ENCOUNTER_START(event, ...)
    LM.Debug("Encounter started: %d (%s)", ...)
    self.currentEncounter = { ... }
end

function LM.Environment:ENCOUNTER_END(event, ...)
    self.currentEncounter = nil
end

-- If you do the pulling then you get ENCOUNTER_START after PLAYER_REGEN_DISABLED
-- and the combat setup doesn't work. Hopefully in this case you are targeting the
-- boss so we can fake it up. This is pretty much all for Tindral Sageswift and I
-- hope never gets needed again.

local function GetUnitNPCID(unit)
    local guid = UnitGUID(unit)
    if guid then
        local _, _, _, _, _, id = strsplit('-', guid)
        -- No check for unitType because id will be nil and tonumber(nil) == nil
        return tonumber(id)
    end
end

local EncounterByNPCID = {
    -- Tindral Sageswift, Amirdrassil (Dragonflight)
    [209539] = 2786,
}

function LM.Environment:GetEncounterInfo()
    if self.currentEncounter then
        return unpack(self.currentEncounter)
    end
    local npcid = GetUnitNPCID('target')
    if npcid and EncounterByNPCID[npcid] then
        local name = UnitName('target')
        local _, _, difficultyID, _, _, _, _, _, groupSize = GetInstanceInfo()
        return EncounterByNPCID[npcid], name, difficultyID, groupSize
    end
end

local herbSpellName = C_Spell.GetSpellName(2366)
local mineSpellName = C_Spell.GetSpellName(2575)
-- local mineSpellName2 = C_Spell.GetSpellName(195122)

function LM.Environment:UNIT_SPELLCAST_SUCCEEDED(ev, unit, guid, spellID)
    if unit == 'player' then
        local spellName = C_Spell.GetSpellName(spellID)
        if spellName == herbSpellName then
            self.lastHerbTime = GetTime()
        elseif spellName == mineSpellName then
            self.lastMineTime = GetTime()
        end
    end
end

function LM.Environment:GetHerbTime()
    return self.lastHerbTime or 0
end

function LM.Environment:GetMineTime()
    return self.lastMineTime or 0
end

function LM.Environment:UPDATE_SHAPESHIFT_FORM()
    if GetShapeshiftFormID() == 3 and InCombatLockdown() then
        LM.Debug("Changed to travel form in combat.")
        self.combatTravelForm = true
    else
        self.combatTravelForm = nil
    end
end

function LM.Environment:IsCombatTravelForm()
    return self.combatTravelForm
end

function LM.Environment:IsCantSummonForm()
    local formID = GetShapeshiftFormID()
    -- cat, bear, treant druid forms can't be mounted from with SummonByID
    if formID == 1 or formID == 5 or formID == 36 then
        return true
    else
        return false
    end
end

function LM.Environment:MapIsMap(a, b, checkGroup)
    if a == b then
        return true
    end
    if checkGroup then
        -- avoid nil == nil case
        local aGroup = C_Map.GetMapGroupID(a)
        if aGroup and aGroup == C_Map.GetMapGroupID(b) then
            return true
    end
    end
    return false
end

function LM.Environment:IsOnMap(mapID, checkGroup)
    local currentMapID = C_Map.GetBestMapForUnit('player')
    if currentMapID then
        return self:MapIsMap(currentMapID, mapID, checkGroup)
    end
end

function LM.Environment:GetMapPath()
    local out = {}
    local mapID = C_Map.GetBestMapForUnit('player')
    while mapID and mapID > 0 do
        table.insert(out, mapID)
        mapID = C_Map.GetMapInfo(mapID).parentMapID
    end
    return out
end

-- C_Map.GetMapInfo use a terrific amount of (garbage collected) memory, which
-- is why this takes a mapPath optional argument so we can save the mapPath in
-- the context for actions.

function LM.Environment:IsMapInPath(mapID, mapPath, checkGroup)
    for _, pathMapID in ipairs(mapPath or self:GetMapPath()) do
        if self:MapIsMap(mapID, pathMapID, checkGroup) then return true end
    end
    return false
end

function LM.Environment:InInstance(...)
    local currentID = select(8, GetInstanceInfo())
    for i = 1, select('#', ...) do
        local id = select(i, ...)
        if currentID == id then return true end
    end
    return false
end

-- Apprentice Riding  (60% ground) = IsPlayerSpell(33388)
-- Journeyman Riding (100% ground) = IsPlayerSpell(33391)
-- Expert Riding     (150% flying) = IsPlayerSpell(34090)
-- Artisan Riding    (280% flying) = IsPlayerSpell(34091) - removed but characters can still have it
-- Master Riding     (320% flying) = IsPlayerSpell(90265)

-- These are in this order because it's more likely you are high level and
-- know the most advanced one. Non-obviously you forget the earlier ones when
-- you learn a later one.

function LM.Environment:KnowsRidingSkill()
    return IsPlayerSpell(54197)
        or IsPlayerSpell(34091)
        or IsPlayerSpell(34090)
        or IsPlayerSpell(33391)
        or IsPlayerSpell(33388)
end

function LM.Environment:KnowsFlyingSkill()
    return IsPlayerSpell(54197)
        or IsPlayerSpell(34091)
        or IsPlayerSpell(34090)
end

local InstanceFlyableOverride = {
    -- IsFlyableArea() seems to be broken for all of WoD in the Shadowlands prepatch
    -- unless you have the old achievement completed.
    [1116] = true,          -- Draenor (WoD)
    [1152] = true,          -- Horde Garrison Level 1
    [1330] = true,          -- Horde Garrison Level 2
    [1153] = true,          -- Horde Garrison Level 3
    [1154] = true,          -- Horde Garrison Level 4 (?)
    [1158] = true,          -- Alliance Garrison Level 1
    [1331] = true,          -- Alliance Garrison Level 2
    [1159] = true,          -- Alliance Garrison Level 3
    [1160] = true,          -- Alliance Garrison Level 4 (?)
    [1464] = true,          -- Tanaan Jungle (WoD)

    -- Some people report IsFlyableArea() broken for Broken Isles (Legion) too
    [1220] = true,          -- Broken Isles

    [ 754] = false,         -- Throne of the Four Winds
    [1107] = false,         -- Dreadscar Rift (Warlock)
    [1191] = false,         -- Ashran PVP Area
    [1265] = false,         -- Tanaan Jungle Intro
    [1463] = false,         -- Helheim Exterior Area
    [1469] = false,         -- Heart of Azeroth (Shaman)
    [1479] = false,         -- Skyhold (Warrior)
    [1500] = false,         -- Broken Shore DH Scenario
    [1514] = false,         -- Wandering Isle (Monk)
    [1519] = false,         -- Fel Hammer (DH)
    [1604] = false,         -- Niskara, priest legion campaign
    [1669] = false,         -- Argus
    [1688] = false,         -- The Deadmines (Pet Battle)
    [1750] = false,         -- Azuremyst Isle (Legion Scenario?)
    [1760] = false,         -- Ruins of Lordaeron BfA opening
    [1763] = false,         -- Atal'Dazar instance
    [1803] = false,         -- Battleground: Seething Shore
    [1813] = false,         -- Island Expedition Un'gol Ruins
    [1814] = false,         -- Island Expedition Havenswood
    [1879] = false,         -- Island Expedition Jorundall
    [1882] = false,         -- Island Expedition Verdant Wilds
    [1883] = false,         -- Island Expedition Whispering Reef
    [1892] = false,         -- Island Expedition Rotting Mire
    [1893] = false,         -- Island Expedition The Dread Chain
    [1897] = false,         -- Island Expedition Molten Cay
    [1898] = false,         -- Island Expedition Skittering Hollow
    [1906] = false,         -- Zuldazar Continent Finale
    [1907] = false,         -- Island Expedition Snowblossom Village
    [2124] = false,         -- Island Expedition Crestfall
    [2275] = false,         -- Lesser Vision Vale of Eternal Twilight
    [2278] = false,         -- Revendreth Scenario
    [2291] = false,         -- De Other Side
    [2293] = false,         -- Theater of Pain
    [2296] = false,         -- Castle Nathria
    [2363] = false,         -- Queen's Winter Conservatory
    [2364] = false,         -- The Maw (Starting Experience)
    [2464] = false,         -- Battle of Ardenweald (9.1)
}

-- Note that these have 3 possible return values, true, false, nil (no override)

local InstanceDragonridableOverride = {
    [2549] =            -- Amirdrassil Raid
        function ()
            -- Dragonriding debuff Blessing of the Emerald Dream (429226)
            -- This is an approximation, it doesn't make the area dragonriding
            -- it just forces the journal dragonriding mounts to work. Notably
            -- Soar does not work with it, so there is a hack there too.
            if LM.UnitAura('player', 429226, 'HARMFUL') then return true end
        end,
    [2597] = false,     -- Zaralek Caverns - Chapter 1 Scenario
                        -- The debuff "Hostile Airways" (406608) but it's always up
}

function LM.Environment:ForceFlyable(instanceID)
    instanceID = instanceID or select(8, GetInstanceInfo())
    InstanceFlyableOverride[instanceID] = true
end

function LM.Environment:CanDragonride(mapPath)
    -- If you can't fly you can't dragonride
    if not self:KnowsFlyingSkill() then
        return false
    end

    if not C_MountJournal.IsDragonridingUnlocked() then
        return false
    end

    local instanceID = select(8, GetInstanceInfo())
    local override = InstanceDragonridableOverride[instanceID]
    if type(override) == 'function' then
        local value = override(mapPath)
        if value ~= nil then return value end
    else
        if override ~= nil then return override end
    end

    -- Dragon Isles and Khaz Algar and everything in them are correctly flagged IsAdvancedFlyableArea
    -- if you can dragonride, and you can't fly there unless you unlock it.

    if self:IsMapInPath(1978, mapPath) or self:IsMapInPath(2274, mapPath) then
        return IsAdvancedFlyableArea()
    end


    -- Can't dragonride in Warfronts either
    if C_Scenario and C_Scenario.IsInScenario() then
        local scenarioType = select(10, C_Scenario.GetInfo())
        if scenarioType == LE_SCENARIO_TYPE_WARFRONT then
            return false
        end
    end

    -- Lots of non-Dragon Isles areas are wrongly flagged IsAdvancedFlyableArea
    return IsAdvancedFlyableArea() and IsFlyableArea()
end

-- Can't fly if you haven't learned a flying skill. Various expansion
-- continents from Draenor onwards need achievement unlocks to be able to fly.

function LM.Environment:CanFly()

    -- If you don't know how to fly, you can't fly
    if not self:KnowsFlyingSkill() then
        return false
    end

    local instanceID = select(8, GetInstanceInfo())

    if InstanceFlyableOverride[instanceID] ~= nil then
        return InstanceFlyableOverride[instanceID]
    end

    if WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
        -- Classic Northrend requires Cold Weather Flying in WotLK Classic
        if self:InInstance(571) then
            if not IsSpellKnown(54197) then
                return false
            end
        end
    end

    -- Memories of Sunless Skies / Shadowlands Flying (63893)
    -- It seems like flying in Shadowlands is also unlocked by completing the
    -- Zereth Mortis Flying (65539) unlock even if you never did MoSS.
    -- ZM achievement: select(4, GetAchievementInfo(15514))
    if self:InInstance(2222) then
        if not C_QuestLog.IsQuestFlaggedCompleted(63893) and
           not C_QuestLog.IsQuestFlaggedCompleted(65539) then
                return false
        end
    end

    -- Can't fly in Warfronts
    if C_Scenario and C_Scenario.IsInScenario() then
        local scenarioType = select(10, C_Scenario.GetInfo())
        if scenarioType == LE_SCENARIO_TYPE_WARFRONT then
            return false
        end
    end

    return IsFlyableArea()
end

function LM.Environment:CantBreathe()
    local name, _, _, rate = GetMirrorTimerInfo(2)
    return (name == "BREATH" and rate < 0)
end

function LM.Environment:GetLocation()
    local path = { }
    for _, mapID in ipairs(self:GetMapPath()) do
        local info = C_Map.GetMapInfo(mapID)
        tinsert(path, format("%s (%d)", info.name, info.mapID))
    end

    local info = { GetInstanceInfo() }
    return {
        "map: " .. ( path[1] or "" ),
        "mapPath: " .. table.concat(path, " -> "),
        "instance: " .. string.format("%s (%d)", info[1], info[8]),
        "zoneText: " .. GetZoneText(),
        "subZoneText: " .. GetSubZoneText(),
        "IsFlyableArea(): " .. tostring(IsFlyableArea()),
        IsAdvancedFlyableArea and
            "IsAdvancedFlyableArea(): " .. tostring(IsAdvancedFlyableArea()),
    }
end

local ModelScanFrame = CreateFrame('PlayerModel')
ModelScanFrame:Hide()

function LM.Environment:GetPlayerModel()
    ModelScanFrame:Show()
    ModelScanFrame:SetUnit('player')
    local id = ModelScanFrame:GetModelFileID()
    ModelScanFrame:Hide()
    return id
end

-- The level of black magic shenanigans here is off the charts. What on earth
-- is ModelSceneID 290? I don't know but it's what DressUpFrame uses so ...
-- This used in conditions to check if we're wearing a transmog outfit.

local ModelSceneScanFrame = CreateFrame('ModelScene')
Mixin(ModelSceneScanFrame, ModelSceneMixin)
ModelSceneScanFrame:OnLoad()

function LM.Environment:GetPlayerTransmogInfo()
    ModelSceneScanFrame:Show()
    ModelSceneScanFrame:TransitionToModelSceneID(290, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true)
    local actor = ModelSceneScanFrame:GetPlayerActor()
    actor:SetModelByUnit("player")
    local infoList = actor:GetItemTransmogInfoList()
    ModelSceneScanFrame:Hide()
    return infoList
end

local maxMapID
function LM.Environment:GetMaxMapID()
    if not maxMapID then
        -- 10000 is a guess at something way over the current maximum

        for i = 1, 10000 do
            if C_Map.GetMapInfo(i) then
                maxMapID = i
            end
        end
    end
    return maxMapID
end

local ShowMapOverride = {
    [407] = true,   -- Darkmoon Island (mapType Orphan)
    [647] = true,   -- Acherus: The Ebon Hold (mapType Micro)
}

local function ValidDisplayMap(info, group, seenGroups)
    if not info then
        return false
    end

    if ShowMapOverride[info.mapID] then
        return true
    end

    local out

    if C_Map.IsMapValidForNavBarDropDown then
        out = C_Map.IsMapValidForNavBarDropDown(info.mapID)
    else
        out = info.mapType <= Enum.UIMapType.Zone
    end

    -- Suppress second and on members of a group. Note they must have
    -- matched above correctly first.

    if group then
        if seenGroups[group] then
            out = false
        else
            seenGroups[group] = true
        end
    end

    return out
end

function LM.Environment:GetMaps(str)
    local searchStr = string.lower(str or "")

    local lines = {}
    local seenGroups = {}

    for i = 1, self:GetMaxMapID() do
        local info = C_Map.GetMapInfo(i)
        local group = C_Map.GetMapGroupID(i)
        if ValidDisplayMap(info, group, seenGroups) then
            local searchName = string.lower(info.name)
            if info.mapID == tonumber(str) or searchName:find(searchStr) then
                tinsert(lines, string.format("% 4d : %s (parent %d)", info.mapID, info.name, info.parentMapID or 0))
            end
        end
    end
    return lines
end

function LM.Environment:GetContinents(str)
    local searchStr = string.lower(str or "")

    local lines = {}

    for i = 1, self:GetMaxMapID() do
        local info = C_Map.GetMapInfo(i)
        if info
            and info.mapType == Enum.UIMapType.Continent
            and info.parentMapID > 0
            and C_Map.IsMapValidForNavBarDropDown(i) then
            local searchName = string.lower(info.name)
            if info.mapID == tonumber(str) or searchName:find(searchStr) then
                tinsert(lines, format("% 4d : %s", info.mapID, info.name))
            end
        end
    end
    return lines
end

function LM.Environment:GetInstances()
    return LM.Options:GetInstances()
end

local function FillChildren(info, seenGroups)
    for _, child in ipairs(C_Map.GetMapChildrenInfo(info.mapID)) do
        local group = C_Map.GetMapGroupID(child.mapID)
        if ValidDisplayMap(child, group, seenGroups) then
            FillChildren(child, seenGroups)
            table.insert(info, child)
        end
    end
    table.sort(info, function (a,b) return a.name < b.name end)
end

-- IsMapValidForNavBarDropDown is dynamic somehow, so this has to be
-- rebuilt each time even though that's inefficient.

function LM.Environment:GetMapTree()
    local mapTree = C_Map.GetMapInfo(946)
    local seenGroups = {}
    FillChildren(mapTree, seenGroups)
    return mapTree
end

-- It's possible to pull the GetInstanceInfo() instance number from the
-- encounter journal, but it's buried down in the encounter info and not
-- in the actual instance info return which is annoying.
-- This really FUBARs the Encounter journal, but I'm not sure if it's
-- taint-safe to put it back. Wah!

function LM.Environment:GetEJInstances()
    LoadAddOn("Blizzard_EncounterJournal")

    -- Save EJ state
    EncounterJournal:UnregisterEvent("EJ_DIFFICULTY_UPDATE")
    local originalTier = EJ_GetCurrentTier()
    local origInstanceID = EncounterJournal.instanceID

    local out = {}

    for tier = 1, EJ_GetNumTiers() do
        EJ_SelectTier(tier)
        for _, isRaid in ipairs({ true, false }) do
            local index = 1
            while true do
                local id, name, _, _, _, _, _, _, showDifficulty  = EJ_GetInstanceByIndex(index, isRaid)
                if not name or not showDifficulty then break end
                EJ_SelectInstance(id)
                local i = 1
                while true do
                    local n, _, _, _, _, _, _, instanceID = EJ_GetEncounterInfoByIndex(i)
                    if not n then break end
                    if instanceID then
                        out[instanceID] = name
                        break
                    end
                    i = i + 1
                end
                index = index + 1
            end
        end
    end

    -- Restore EJ state
    EJ_SelectTier(originalTier)
    if origInstanceID then EJ_SelectInstance(origInstanceID) end
    EncounterJournal:RegisterEvent("EJ_DIFFICULTY_UPDATE")

    return out
end

local CALENDAR_FILTER_CVARS = {
    ["calendarShowHolidays"] = 1,
    ["calendarShowDarkmoon"] = 1,
    ["calendarShowLockouts"] = 0,
    ["calendarShowWeeklyHolidays"] = 0,
    ["calendarShowBattlegrounds"] = 0,
    ["calendarShowResets"] = 0,
};


function LM.Environment:InitializeHolidays()
    self.holidaysByID = {}

    local savedCVars = {}
    for cvar, value in pairs(CALENDAR_FILTER_CVARS) do
        savedCVars[cvar] = GetCVar(cvar)
        SetCVar(cvar, value)
    end

    local now = C_DateAndTime.GetCurrentCalendarTime()
    local saved = C_Calendar.GetMonthInfo()

    local holidaysByTitle = {}

    C_Calendar.SetAbsMonth(now.month, now.year)
    for monthDelta = 1, 12 do
        -- Advance by one, easier than doing our own date arithmetic
        C_Calendar.SetMonth(1)
        local monthInfo = C_Calendar.GetMonthInfo()
        for monthDay = 1, monthInfo.numDays do
            for i = 1, C_Calendar.GetNumDayEvents(0, monthDay) do
                local eventInfo = C_Calendar.GetDayEvent(0, monthDay, i)
                if eventInfo.calendarType == 'HOLIDAY' and not self.holidaysByID[eventInfo.eventID] then
                    self.holidaysByID[eventInfo.eventID] = eventInfo.title
                    holidaysByTitle[eventInfo.title] = holidaysByTitle[eventInfo.title] or {}
                    table.insert(holidaysByTitle[eventInfo.title], eventInfo.eventID)
                end
            end
        end
    end

    -- if we see the same titled event with different IDs delete them all
    -- as they're probably something dumb like Turbulent Timeways and not real
    -- holidays
    for _, IDs in pairs(holidaysByTitle) do
        if #IDs > 1 then
            for _, id in ipairs(IDs) do self.holidaysByID[id] = nil end
        end
    end

    -- Restore settings
    for cvar, value in pairs(savedCVars) do SetCVar(cvar, value) end
    C_Calendar.SetAbsMonth(saved.month, saved.year)
end

function LM.Environment:IsHolidayActive(idOrTitle)
    -- The calendar API is stateful so this is going to mess up the UI. We
    -- could save and restore the current month but the user might be editing
    -- or viewing something which will be lost.
    if CalendarFrame and CalendarFrame:IsShown() then return end

    local now = C_DateAndTime.GetCurrentCalendarTime()
    C_Calendar.SetAbsMonth(now.month, now.year)

    for i = 1, C_Calendar.GetNumDayEvents(0, now.monthDay) do
        local eventInfo = C_Calendar.GetDayEvent(0, now.monthDay, i)
        if eventInfo.eventID == idOrTitle or eventInfo.title == idOrTitle then
            return
                C_DateAndTime.CompareCalendarTime(eventInfo.startTime, now) >= 0 and
                C_DateAndTime.CompareCalendarTime(eventInfo.endTime, now) < 0
        end
    end
end

function LM.Environment:GetHolidays()
    return CopyTable(self.holidaysByID)
end

function LM.Environment:GetHolidayName(id)
    return self.holidaysByID[id]
end

function LM.Environment:SaveMouseButtonClicked()
    self.mouseButtonClicked = GetMouseButtonClicked()
end

function LM.Environment:ClearMouseButtonClicked()
    self.mouseButtonClicked = nil
end

function LM.Environment:GetMouseButtonClicked()
    return self.mouseButtonClicked
end
