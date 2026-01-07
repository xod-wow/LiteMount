--[[----------------------------------------------------------------------------

  LiteMount/Location.lua

  Some basics about the current game state with respect to mounting. Most of
  the mojo is done by IsSpellUsable to know if a mount can be cast, this just
  helps with the prioritization.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

LM.Environment = LM.CreateAutoEventFrame("Frame")
LM.Environment:RegisterEvent("PLAYER_LOGIN")

local issecretvalue = issecretvalue or function () return false end

function LM.Environment:Initialize()
    self:InitializeHolidays()
    self:InitializeEJInstances()
    self:UpdateSwimTimes()

    self.combatTravelForm = nil
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
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
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

local StateUpdateFunctions = {
    canFly =
        function (self)
            return self:CanFly()
        end,
    canMountInPhaseDiving =
        function ()
            -- "Orbs of Power", the third node unlock in the Reshii Wraps talent tree
            if WOW_PROJECT_ID == 1 then
                local configID = C_Traits.GetConfigIDByTreeID(1115)
                if configID then
                    local nodeInfo = C_Traits.GetNodeInfo(configID, 105869)
                    return nodeInfo and nodeInfo.currentRank == 1
                end
            end
            return false
        end,
    druidFormInfo =
        function ()
            if UnitClassBase("player") == "DRUID" then
                local id = GetShapeshiftFormID()
                if id then
                    local index = GetShapeshiftForm()
                    local _, _, _, spellID = GetShapeshiftFormInfo(index)
                    if spellID then
                        local info = C_Spell.GetSpellInfo(spellID)
                        info.formID = id
                        return info
                    end
                end
            end
            return {}
        end,
    flightStyle =
        function (self)
            return select(2, self:GetFlightStyle())
        end,
    herbTime =
        function (self)
            return self.lastHerbTime or 0
        end,
    isCombatTravelForm =
        function (self)
            return self.combatTravelForm
        end,
    isDrivableArea =
        function (self)
            return self:IsDrivableArea()
        end,
    isFalling =
        function (self)
            return IsFalling() and
                self.startedFalling > self.stoppedFalling and
                GetTime() - self.startedFalling >= 0.45
        end,
    isFloating =
        function (self)
            local name, _, _, rate = GetMirrorTimerInfo(2)
            local cantBreathe = ( name == "BREATH" and rate < 0 )
            return IsSubmerged() and not cantBreathe and
                ( GetTime() - (self.lastDryTime or 0 ) < 1.0)
        end,
    isFlyableArea =
        function (self)
            return self:IsFlyableArea()
        end,
    isMovingOrFalling =
        function ()
            return (GetUnitSpeed("player") > 0 or IsFalling())
        end,
    isPhaseDiving =
        function (self)
            return WOW_PROJECT_ID == 1 and self.playerBuffIDs[1214374] ~= nil
        end,
    isTheMaw =
        function (self)
            if WOW_PROJECT_ID == 1 then
                local instanceID = select(8, GetInstanceInfo())

                -- This is the instanced starting experience
                if instanceID == 2364 then return true end

                -- This is the instanced post-Maldraxxus questing
                if instanceID == 2456 then return true end

                -- Sanctum of Domination raid allows mounting normally
                if instanceID == 2450 then return false end

                -- Otherwise, The Maw is just zones in instance 2222
                return self:IsMapInPath(1543)
            end
            return false
        end,
    jumpTime =
        function (self)
            -- A jump in place takes approximately 0.83 seconds
            local airTime = self.stoppedFalling - self.startedFalling
            if airTime > 0.73 and airTime < 0.93 then
                local timeSinceLanded = GetTime() - self.stoppedFalling
                return timeSinceLanded
            end
        end,
    knowsFlyingSkill =
        function (self)
            return self:KnowsFlyingSkill()
        end,
    knowsRidingSkill =
        function (self)
            return self:KnowsRidingSkill()
        end,
    mineTime =
        function (self)
            return self.lastMineTime or 0
        end,
    playerBuffIDs =
        function ()
            local buffIDs = {}
            local i = 1
            while true do
                local auraInfo = C_UnitAuras.GetAuraDataByIndex('player', i)
                if auraInfo == nil then
                    break
                elseif not issecretvalue(auraInfo.spellId) then
                    buffIDs[auraInfo.spellId] = true
                end
                i = i + 1
            end
            return buffIDs
        end,
    playerDebuffIDs =
        function ()
            local debuffIDs = {}
            local i = 1
            while true do
                local auraInfo = C_UnitAuras.GetAuraDataByIndex('player', i, 'HARMFUL')
                if auraInfo == nil then
                    break
                elseif not issecretvalue(auraInfo.spellId) then
                    debuffIDs[auraInfo.spellId] = true
                end
                i = i + 1
            end
            return debuffIDs
        end,
    playerModel =
        function (self)
            return self:GetPlayerModel()
        end,
}

function LM.Environment:GetStationaryTime()
    if self.stoppedMoving == nil then
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

local herbSpellName = C_Spell.GetSpellName(2366)
local mineSpellName = C_Spell.GetSpellName(2575)
-- local mineSpellName2 = C_Spell.GetSpellName(195122)

function LM.Environment:UNIT_SPELLCAST_SUCCEEDED(ev, unit, guid, spellID)
    -- Strictly speaking this check isn't needed because of RegisterUnitEvent
    if unit == 'player' then
        local spellName = C_Spell.GetSpellName(spellID)
        if spellName == herbSpellName then
            self.lastHerbTime = GetTime()
        elseif spellName == mineSpellName then
            self.lastMineTime = GetTime()
        end
    end
end

function LM.Environment:UPDATE_SHAPESHIFT_FORM()
    if GetShapeshiftFormID() == 3 and InCombatLockdown() then
        LM.Debug("Changed to travel form in combat.")
        self.combatTravelForm = true
    else
        self.combatTravelForm = nil
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

-- C_Map.GetMapInfo use a terrific amount of (garbage collected) memory, so
-- cache the map paths for efficiency. This is absoluately required because
-- this is called many times during activation.

LM.Environment.mapPathCache = {}

function LM.Environment:GetMapPath()
    local mapID = C_Map.GetBestMapForUnit('player') or 0
    if mapID and not self.mapPathCache[mapID] then
        self.mapPathCache[mapID] = {}
        local id = mapID
        while id and id > 0 do
            table.insert(self.mapPathCache[mapID], id)
            id = C_Map.GetMapInfo(id).parentMapID
        end
    end
    return self.mapPathCache[mapID]
end

function LM.Environment:IsMapInPath(mapID, checkGroup)
    for _, pathMapID in ipairs(self:GetMapPath()) do
        if self:MapIsMap(mapID, pathMapID, checkGroup) then return true end
    end
    return false
end

function LM.Environment:IsInInstance(...)
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
    if not (steadyInfo and skyridingInfo) then return end

    if LM.UnitAura('player', steadyInfo.spellID) then
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
    return IsPlayerSpell(90265)
        or IsPlayerSpell(54197)
        or IsPlayerSpell(34091)
        or IsPlayerSpell(34090)
end

-- Overrides have 3 possible return values, true, false, nil (no override)
local InstanceFlyableOverride = {
    [1662] = false,     -- Suramar campaign scenario
    [1750] = false,     -- Azuremyst Isle
    [2275] = false,     -- Lesser Vision Vale of Eternal Twilight
    [2512] = true,      -- The Primalist Future
    [2549] =            -- Amirdrassil Raid
        function (self)
            -- Skyriding debuff Blessing of the Emerald Dream (429226)
            -- This is an approximation, it doesn't make the area skyriding
            -- it just forces the journal skyriding mounts to work. Notably
            -- Soar does not work with it, so there is a hack there too.
            if self.playerDebuffIDs[429226] then return true end
        end,
    [2597] = false,     -- Zaralek Caverns - Chapter 1 Scenario
                        -- The debuff "Hostile Airways" (406608) but it's always up
    [2662] = true,      -- The Dawnbreaker (Dungeon) after /reload it goes wrong
}

function LM.Environment:GetFlyableOverride()
    local instanceID = select(8, GetInstanceInfo())
    local override = InstanceFlyableOverride[instanceID]
    if type(override) == 'function' then
        local value = override(self)
        if value ~= nil then return value end
    else
        if override ~= nil then return override end
    end
end

function LM.Environment:IsFlyableArea()

    local override = self:GetFlyableOverride()
    if override ~= nil then
        return override
    end

    if false and WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
        -- Northrend requires Cold Weather Flying
        if self:IsInInstance(571) then
            if not IsPlayerSpell(54197) then
                return false
            end
        end
        -- Eastern Kingdoms, Kalimdor and Deepholm require Flight Master's License
        if self:IsInInstance(0, 1, 646) then
            if not IsPlayerSpell(90267) then
                return false
            end
        end
        -- Pandaria requires Wisdom of the Four Winds
        if self:IsInInstance(870) then
            if not IsPlayerSpell(115913) then
                return false
            end
        end
    end

    if self:IsInInstance(2552, 2601, 2738) then
        -- In Khaz Algar (Surface) (2552), Khaz Algar (2601) and K'aresh (2739)
        -- before unlocking Steady Flight, IsFlyableArea() is false and I don't
        -- know of a check to see if Skyriding would work.
        if select(4, GetAchievementInfo(40231)) == false then
            return true
        end
    elseif self:IsMapInPath(1978) then
        -- In Dragon Isles (1978) IsFlyableArea() is false until you unlock
        -- Dragon Isles Pathfinder.
        if select(4, GetAchievementInfo(19307)) == false then
            return true
        end
    end

    -- Detect Legion: Remix with aura and require unlock for dragonriding.
    -- This is a massive mess by Blizzard. You can steady fly from the start
    -- but you can't skyride (opposite of normal). The game says Skyriding
    -- is unlocked by completing quest A Fixed Point In Time (89418) but it's
    -- unlocked a handful of quests earlier by Eternal Gratitude (89416). All
    -- of this might be different if you never unlocked Steady Flight on your
    -- account.

    if PlayerIsTimerunning and PlayerIsTimerunning() and self.playerBuffIDs[1213439] then
        local _, flightStyle = self:GetFlightStyle()
        if flightStyle == 'skyriding' and not C_QuestLog.IsQuestFlaggedCompleted(89416) then
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

    -- TWW intro area has this debuff preventing flying
    if self.playerDebuffIDs[456486] then
        return false
    end

    -- You would think, if anything was sensible at all, that IsFlyableArea()
    -- would return whether you could steady fly, and IsAdvancedFlyableArea()
    -- would return whether you could skyride. You would be wrong. Huge amounts
    -- of the world are not marked for advanced flying, despite it working fine.

    return IsFlyableArea()
end

-- Area allows flying and you know how to fly
function LM.Environment:CanFly()

    if IsAdvancedFlyableArea and IsAdvancedFlyableArea() then
        -- This has a compat for Cataclysm Classic to return false always
        if not C_MountJournal.IsDragonridingUnlocked() then
            -- This enables soar for Dracthyr on new accounts without Skyriding
            if not C_Spell.IsSpellUsable(LM.SPELL.SOAR) then
                return false
            end
        end
    elseif not self:KnowsFlyingSkill() then
        return false
    end

    return self:IsFlyableArea()
end

-- Blizzard's IsDrivableArea is always false so far. If the mount is usable
-- then we are in the right area. Save duplicating all the code.

function LM.Environment:IsDrivableArea()
    return LM.Drive.IsUsable()
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
    local modelFileID = ModelScanFrame:GetModelFileID()
    ModelScanFrame:Hide()
    return modelFileID
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

    if C_Map.IsMapValidForNavBardropDown then
        out = C_Map.IsMapValidForNavBarDropdown(info.mapID)
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

function LM.Environment:GetMapContinent(mapID)
    while true do
        local info = C_Map.GetMapInfo(mapID)
        if not info then return end
        if info.mapType == Enum.UIMapType.Continent then
            return mapID, info.name
        elseif mapID == info.parentMapID then
            return
        else
            mapID = info.parentMapID
        end
    end
end

function LM.Environment:GetContinents(str)
    local searchStr = string.lower(str or "")

    local lines = {}

    for i = 1, self:GetMaxMapID() do
        local info = C_Map.GetMapInfo(i)
        if info
            and info.mapType == Enum.UIMapType.Continent
            and info.parentMapID > 0
            and C_Map.IsMapValidForNavBarDropdown(i) then
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

-- This is altering client state (hopefully temporarily). This has to happen
-- during login, otherwise Blizzard_EncounterJournal will be super confused.

function LM.Environment:InitializeEJInstances()
    self.instancesByID = {}
    local savedTier = EJ_GetCurrentTier()
    for tierID = 1, EJ_GetNumTiers() do
        if tierID > GetNumExpansions() then
            break
        end
        EJ_SelectTier(tierID)
        for _, queryRaid in ipairs({ true, false }) do
            local i = 1
            while true do
                local instanceID, name, _, _, _, _, _, _, _, hasDifficulty, _, isRaidClassic, isRaid = EJ_GetInstanceByIndex(i, queryRaid)
                if not instanceID then break end
                if WOW_PROJECT_ID ~= 1 then
                    isRaid = isRaidClassic
                end
                self.instancesByID[instanceID] = {
                    id = instanceID,
                    name = name,
                    isRaid = isRaid,
                    tierID = tierID,
                }
                i = i + 1
            end
        end
    end
    EJ_SelectTier(savedTier)
end

function LM.Environment:GetEJInstances()
    return self.instancesByID
end

function LM.Environment:GetInstanceNameByID(id)
    if self.instancesByID[id] then
        return self.instancesByID[id].name
    else
        return LM.db.global.instances[id]
    end
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

function LM.Environment:RefreshState()
    -- Update first so the other updaters can use them.
    self.playerBuffIDs = StateUpdateFunctions.playerBuffIDs(self)
    self.playerDebuffIDs = StateUpdateFunctions.playerDebuffIDs(self)
    for k, f in pairs(StateUpdateFunctions) do
        if k ~= 'playerBuffIDs' and k ~= 'playerDebuffIDs' then
            self[k] = f(self)
        end
    end
end
