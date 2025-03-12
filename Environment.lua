--[[----------------------------------------------------------------------------
  LiteMount/Location.lua

  Some basics about the current game state with respect to mounting. Most of
  the mojo is done by IsSpellUsable to know if a mount can be cast, this just
  helps with the prioritization.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell
local C_MountJournal = LM.C_MountJournal or C_MountJournal

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

    -- Sanctum of Domination raid allows mounting normally
    if instanceID == 2450 then return false end

    -- Otherwise, The Maw is just zones in instance 2222
    return LM.Environment:IsMapInPath(1543, mapPath)
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

function LM.Environment:GetDruidForm()
    if select(2, UnitClass("player")) == "DRUID" then
        local id = GetShapeshiftFormID()
        if id then
            local index = GetShapeshiftForm()
            local _, _, _, spellID = GetShapeshiftFormInfo(index)
            if spellID then
                return id, C_Spell.GetSpellInfo(spellID)
            else
                LM.PrintError('Uh-oh, druid form query failure please tell the author')
                LM.PrintError('id=%d, index=%d, spellID=nil', id, index)
            end
        end
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

-- Blizzard appears sometime in the TWW pre-patch have changed
-- IsAdvancedFlyableArea so that is really IsFlightStyleSkyriding. So
--
--  skyridingArea = IsFlyableArea() and IsAdvancedFlyableArea()
--  flyingArea = IsFlyableArea() and not IsAdvancedFlyableArea()

local steadyInfo = C_Spell.GetSpellInfo(LM.SPELL.FLIGHT_STYLE_STEADY_FLIGHT)
local skyridingInfo = C_Spell.GetSpellInfo(LM.SPELL.FLIGHT_STYLE_SKYRIDING)

function LM.Environment:GetFlightStyle()
    if not steadyInfo and skyridingInfo then return end

    if IsAdvancedFlyableArea() == false then
        return steadyInfo.name, "steady"
    else
        return skyridingInfo.name, "skyriding"
    end
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


-- Overrides have 3 possible return values, true, false, nil (no override)
local InstanceFlyableOverride = {
    -- Clear these out for TWW, everything I tested is flagged correctly.
    [2512] = true,      -- The Primalist Future
    [2549] =            -- Amirdrassil Raid
        function ()
            -- Skyriding debuff Blessing of the Emerald Dream (429226)
            -- This is an approximation, it doesn't make the area skyriding
            -- it just forces the journal skyriding mounts to work. Notably
            -- Soar does not work with it, so there is a hack there too.
            if LM.UnitAura('player', 429226, 'HARMFUL') then return true end
        end,
    [2597] = false,     -- Zaralek Caverns - Chapter 1 Scenario
                        -- The debuff "Hostile Airways" (406608) but it's always up
    [2662] = true,      -- The Dawnbreaker (Dungeon) after /reload it goes wrong
}

function LM.Environment:GetFlyableOverride(mapPath)
    local instanceID = select(8, GetInstanceInfo())
    local override = InstanceFlyableOverride[instanceID]
    if type(override) == 'function' then
        local value = override(mapPath)
        if value ~= nil then return value end
    else
        if override ~= nil then return override end
    end
end

function LM.Environment:IsFlyableArea(mapPath)

    local override = self:GetFlyableOverride(mapPath)
    if override ~= nil then
        return override
    end

    if WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
        -- Northrend requires Cold Weather Flying
        if self:InInstance(571) then
            if not IsPlayerSpell(54197) then
                return false
            end
        end
        -- Eastern Kingdoms, Kalimdor and Deepholm require Flight Master's License
        if self:InInstance(0, 1, 646) then
            if not IsPlayerSpell(90267) then
                return false
            end
        end
    end

    if self:InInstance(2552, 2601) then
        -- In Khaz Algar (Surface) (2552) and Khaz Algar (2601) before you
        -- unlock Steady Flight, IsFlyableArea() is false and I don't know of a
        -- check to see if Skyriding would work.
        if select(4, GetAchievementInfo(40231)) == false then
            return true
        end
    elseif self:IsMapInPath(1978, mapPath) then
        -- In Dragon Isles (1978) IsFlyableArea() is false until you unlock
        -- Dragon Isles Pathfinder.
        if select(4, GetAchievementInfo(19307)) == false then
            return true
        end
    end

    -- Can't fly in Warfronts
    if C_Scenario and C_Scenario.IsInScenario() then
        local scenarioType = select(10, C_Scenario.GetInfo())
        if scenarioType == LE_SCENARIO_TYPE_WARFRONT then
            return false
        end
    end

    -- TWW intro area has this debuff preventing flying
    if LM.UnitAura('player', 456486, 'HARMFUL') then
        return false
    end

    return IsFlyableArea()
end

-- Area allows flying and you know how to fly
function LM.Environment:CanFly(mapPath)

    if IsAdvancedFlyableArea and IsAdvancedFlyableArea() then
        -- This has a compat for Cataclysm Classic to return false always
        if not C_MountJournal.IsDragonridingUnlocked() then
            -- This enables soar for Dracthyr on new accounts withouth Skyriding
            if not C_Spell.IsSpellUsable(LM.SPELL.SOAR) then
                return false
            end
        end
    elseif not self:KnowsFlyingSkill() then
        return false
    end

    return self:IsFlyableArea(mapPath)
end

-- Blizzard's IsDrivableArea is always false so far. If the mount is usable
-- then we are in the right area. Save duplicating all the code.

function LM.Environment:IsDrivableArea()
    return LM.Drive.IsUsable()
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
-- is ModelSceneID 596? I don't know but it's what DressUpFrame uses so ...
-- This used in conditions to check if we're wearing a transmog outfit.

local ModelSceneScanFrame = CreateFrame('ModelScene', nil, nil, 'ModelSceneMixinTemplate')
ModelSceneScanFrame:SetSize(100, 100)

function LM.Environment:GetPlayerTransmogInfo()
    ModelSceneScanFrame:Show()
    ModelSceneScanFrame:ClearScene()
    ModelSceneScanFrame:SetViewInsets(0, 0, 0, 0)
    ModelSceneScanFrame:ReleaseAllActors()
    ModelSceneScanFrame:TransitionToModelSceneID(596, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true)
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
