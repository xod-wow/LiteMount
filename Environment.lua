--[[----------------------------------------------------------------------------

  LiteMount/Location.lua

  Some basics about the current game state with respect to mounting. Most of
  the mojo is done by IsUsableSpell to know if a mount can be cast, this just
  helps with the prioritization.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.Environment = LM.CreateAutoEventFrame("Frame")
LM.Environment:RegisterEvent("PLAYER_LOGIN")

function LM.Environment:Initialize()
    self.uiMapID = -1
    self.uiMapPath = { }
    self.uiMapPathIDs = { }

    self.instanceID = -1
    self.zoneText = nil

    self:UpdateSwimTimes()

    self.startedFalling = 0
    self.stoppedFalling = 0
    self.stoppedMoving = GetTime()

    local elapsed = 0
    self:SetScript('OnUpdate', self.OnUpdate)

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
    self:RegisterEvent("PLAYER_STARTED_MOVING")
    self:RegisterEvent("PLAYER_STOPPED_MOVING")
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
        GetTime() - self.startedFalling > 1
end

-- A jump in place takes approximately 0.83 seconds

function LM.Environment:JumpTime()
    local airTime = self.stoppedFalling - self.startedFalling
    if airTime > 0.73 and airTime < 0.93 then
        local timeSinceLanded = GetTime() - self.stoppedFalling
        return timeSinceLanded
    end
end

function LM.Environment:StationaryTime()
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

function LM.Environment:Update()
    local map = C_Map.GetBestMapForUnit("player")

    -- Right after zoning this can be unknown.
    if not map then return end

    local info = C_Map.GetMapInfo(map)

    self.uiMapID  = map
    self.uiMapName = info.name

    wipe(self.uiMapPath)
    wipe(self.uiMapPathIDs)
    while info do
        tinsert(self.uiMapPath, info.mapID)
        self.uiMapPathIDs[info.mapID] = true
        info = C_Map.GetMapInfo(info.parentMapID)
    end

    self.zoneText = GetZoneText()
    self.subZoneText = GetSubZoneText()
    self.instanceID = select(8, GetInstanceInfo())

    LM.Options:RecordInstance()
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
    LM.Debug("Updating swim times due to MOUNT_JOURNAL_USABILITY_CHANGED.")
    self:UpdateSwimTimes()
end

function LM.Environment:PLAYER_ENTERING_WORLD()
    LM.Debug("Updating location due to PLAYER_ENTERING_WORLD.")
    self:Update()
end

function LM.Environment:ZONE_CHANGED()
    LM.Debug("Updating location due to ZONE_CHANGED.")
    self:Update()
end

function LM.Environment:ZONE_CHANGED_INDOORS()
    LM.Debug("Updating location due to ZONE_CHANGED_INDOORS.")
    self:Update()
end

function LM.Environment:ZONE_CHANGED_NEW_AREA()
    LM.Debug("Updating location due to ZONE_CHANGED_NEW_AREA.")
    self:Update()
end

function LM.Environment:MapInPath(...)
    for i = 1, select('#', ...) do
        local id = select(i, ...)
        if self.uiMapPathIDs[id] then return true end
    end
    return false
end

function LM.Environment:InInstance(...)
    for i = 1, select('#', ...) do
        local id = select(i, ...)
        if self.instanceID == id then return true end
    end
    return false
end

-- apprenticeRiding = IsSpellKnown(33388)
-- expertRiding = IsSpellKnown(34090)
-- artisanRiding = IsSpellKnown(34091)
-- masterRiding = IsSpellKnown(90265)

function LM.Environment:KnowsFlyingSkill()
    -- These are in this order because it's more likely you are high level and
    -- know the most advanced one.
    return IsSpellKnown(90265) or IsSpellKnown(34090)
end

local InstanceFlyableOverride = {
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
    [2363] = false,         -- Queen's Winter Conservatory
}

function LM.Environment:ForceFlyable(instanceID)
    instanceID = instanceID or select(8, GetInstanceInfo())
    InstanceFlyableOverride[instanceID] = true
end

-- Can't fly if you haven't learned a flying skill. Various expansion
-- continents from Draenor onwards need achievement unlocks to be able to fly.

function LM.Environment:CanFly()

    -- If you don't know how to fly, you can't fly
    if not self:KnowsFlyingSkill() then
        return false
    end

    if InstanceFlyableOverride[self.instanceID] ~= nil then
        return InstanceFlyableOverride[self.instanceID]
    end

    -- Battle for Azeroth Pathfinder, Part 2
    -- Zan'dalar (1642), Kul'tiras (1643) and Nazjatar (1718)
    if self:InInstance(1642, 1643, 1718) then
        if not IsSpellKnown(278833) then return false end
    end

    -- Presumably Shadowlands Pathfinder at some point
    if self:InInstance(2222) then
        return false
    end

    -- Can't fly in Warfronts
    if C_Scenario.IsInScenario() then
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
    for _, mapID in ipairs(self.uiMapPath) do
        tinsert(path, format("%s (%d)", C_Map.GetMapInfo(mapID).name, mapID))
    end

    return {
        format("map: %s (%d)",  C_Map.GetMapInfo(self.uiMapID).name, self.uiMapID),
        "mapPath: " .. table.concat(path, " -> "),
        "instance: " .. self.instanceID,
        "zoneText: " .. GetZoneText(),
        "subZoneText: " .. GetSubZoneText(),
        "IsFlyableArea(): " .. (IsFlyableArea() and "true" or "false"),
    }
end

local maxMapID
function LM.Environment:MaxMapID()
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

function LM.Environment:GetMaps(str)
    local searchStr = string.lower(str or "")

    local lines = {}

    for i = 1, self:MaxMapID() do
        local info = C_Map.GetMapInfo(i)
        if info then
            local searchName = string.lower(info.name)
            if info.mapID == tonumber(str) or searchName:find(searchStr) then
                tinsert(lines, format("% 4d : %s (parent %d)", info.mapID, info.name, info.parentMapID or 0))
            end
        end
    end
    return lines
end

function LM.Environment:GetContinents(str)
    local searchStr = string.lower(str or "")

    local lines = {}

    for i = 1, self:MaxMapID() do
        local info = C_Map.GetMapInfo(i)
        if info and info.mapType == Enum.UIMapType.Continent then
            local searchName = string.lower(info.name)
            if info.mapID == tonumber(str) or searchName:find(searchStr) then
                tinsert(lines, format("% 4d : %s", info.mapID, info.name))
            end
        end
    end
    return lines
end
