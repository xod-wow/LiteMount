--[[----------------------------------------------------------------------------

  LiteMount/Location.lua

  Some basics about the current location with respect to mounting.  Most of
  the mojo is done by IsUsableSpell to know if a mount can be cast, this
  just helps with the prioritization.

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

_G.LM_Location = LM_CreateAutoEventFrame("Frame", "LM_Location")
LM_Location:RegisterEvent("PLAYER_LOGIN")

function LM_Location:Initialize()
    self.continent = -1
    self.uiMapID = -1
    self.uiMapPath = { }
    self.instanceID = -1

    self:UpdateSwimTimes()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
end

local function FrameApply(frames, func, ...)
    for _,f in ipairs(frames) do f[func](f, ...) end
end

function LM_Location:UpdateSwimTimes()
    if not IsSubmerged() then
        self.lastDryTime = GetTime()
    end
end

function LM_Location:IsFloating()
    return IsSubmerged() and not self:CantBreathe() and
           ( GetTime() - (self.lastDryTime or 0 ) < 1.0)
end

-- I used to be nice. I swear I tried to be nice and only passively listen to
-- the map events, but then craptastic addons like Archy decided to constantly
-- futz with the map on a timer and screw it for everyone. Now it's battle to
-- the death. :(

function LM_Location:Update()

    self.uiMapID = C_Map.GetBestMapForUnit("player")

    local info = C_Map.GetMapInfo(self.uiMapID)
    self.uiMapName = info.name

    wipe(self.uiMapPath)
    while info do
        tinsert(self.uiMapPath, info.mapID)
        info = C_Map.GetMapInfo(info.parentMapID)
    end

    local continentInfo = MapUtil.GetMapParentInfo(self.uiMapID, Enum.UIMapType.Continent, true)
    if continentInfo then
        self.continent = continentInfo.mapID
    else
        self.continent = -1
    end
    self.realZoneText = GetRealZoneText()
    self.zoneText = GetZoneText()
    self.subZoneText = GetSubZoneText()
    self.minimapZoneText = GetMinimapZoneText()
    self.instanceID = select(8, GetInstanceInfo())
end

function LM_Location:PLAYER_LOGIN()
    self:Initialize()
end

function LM_Location:MOUNT_JOURNAL_USABILITY_CHANGED()
    LM_Debug("Updating swim times due to MOUNT_JOURNAL_USABILITY_CHANGED.")
    self:UpdateSwimTimes()
end

function LM_Location:PLAYER_ENTERING_WORLD()
    LM_Debug("Updating location due to PLAYER_ENTERING_WORLD.")
    self:Update()
end

function LM_Location:ZONE_CHANGED()
    LM_Debug("Updating location due to ZONE_CHANGED.")
    self:Update()
end

function LM_Location:ZONE_CHANGED_INDOORS()
    LM_Debug("Updating location due to ZONE_CHANGED_INDOORS.")
    self:Update()
end

function LM_Location:ZONE_CHANGED_NEW_AREA()
    LM_Debug("Updating location due to ZONE_CHANGED_NEW_AREA.")
    self:Update()
end

local FlyableNoContinent = {
    [897] = true,           -- Deaths of Chromie scenario
}

-- apprenticeRiding = IsSpellKnown(33388)
-- expertRiding = IsSpellKnown(34090)
-- artisanRiding = IsSpellKnown(34091)
-- masterRiding = IsSpellKnown(90265)

function LM_Location:KnowsFlyingSkill()
    -- These are in this order because it's more likely you are high level and
    -- know the most advanced one.
    return IsSpellKnown(90265) or IsSpellKnown(34091) or IsSpellKnown(34090)
end

-- Can't fly if you haven't learned a flying skill
-- Draenor and Lost Isles need achievement unlocks to be able to fly.
function LM_Location:CanFly()

    -- If you don't know how to fly, you can't fly
    if not self:KnowsFlyingSkill() then
        return false
    end

    -- I'm going to assume, across the board, that you can't fly in
    -- "no continent" / -1 and fix it up later if it turns out you can.
    if self.continent == -1 and not FlyableNoContinent[self.mapID] then
        return false
    end

    -- Draenor Pathfinder
    if self.continent == 7 and not IsSpellKnown(191645) then
        return false
    end

    -- Broken Isles Pathfinder, Part 2
    if self.continent == 8 and not IsSpellKnown(233368) then
        return false
    end

    -- Argus is non-flyable, but some parts of it are flagged wrongly
    if self.continent == 9 then
        return false
    end

    return IsFlyableArea()
end

function LM_Location:CantBreathe()
    local name, _, _, rate = GetMirrorTimerInfo(2)
    return (name == "BREATH" and rate < 0)
end

function LM_Location:Dump()
    local path = { }
    for _, mapID in ipairs(self.uiMapPath) do
        tinsert(path, format("%s (%d)", C_Map.GetMapInfo(mapID).name, mapID))
    end

    LM_Print("--- Location Dump ---")
    LM_Print("continent: " .. self.continent)
    LM_Print("uiMapID: " .. self.uiMapID)
    LM_Print("uiMapPath: " .. table.concat(path, " -> "))
    LM_Print("instanceID: " .. self.instanceID)
    LM_Print("zoneText: " .. GetZoneText())
    LM_Print("subZoneText: " .. GetSubZoneText())
    LM_Print("minimapZoneText: " .. GetMinimapZoneText())
    LM_Print("IsFlyableArea(): " .. (IsFlyableArea() and "true" or "false"))
end
