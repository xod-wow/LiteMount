--[[----------------------------------------------------------------------------

  LiteMount/Location.lua

  Some basics about the current location with respect to mounting.  Most of
  the mojo is done by IsUsableSpell to know if a mount can be cast, this
  just helps with the prioritization.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Location = LM_CreateAutoEventFrame("Frame", "LM_Location")
LM_Location:RegisterEvent("PLAYER_LOGIN")

-- Magical develper only debugging-fu
local I_AM_X = GetAddOnMetadata("LiteMount", "Version") == "@project-version@"

function LM_Location:Initialize()
    self.continent = -1
    self.areaID = -1
    self.instanceID = -1
    self.zoneText = -1
    self.minimapZoneText = ""
    self.subZoneText = ""

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

local function FrameApply(frames, func, ...)
    for i,f in ipairs(frames) do f[func](f, ...) end
end

-- I used to be nice. I swear I tried to be nice and only passively listen to
-- the map events, but then craptastic addons like Archy decided to constantly
-- futz with the map on a timer and screw it for everyone. Now it's battle to
-- the death. :(

function LM_Location:Update()

    local origID = GetCurrentMapAreaID()

    local WMUListeners = { GetFramesRegisteredForEvent("WORLD_MAP_UPDATE") }
    FrameApply(WMUListeners, "UnregisterEvent", "WORLD_MAP_UPDATE")

    SetMapToCurrentZone()

    self.continent = GetCurrentMapContinent()
    self.areaID = GetCurrentMapAreaID()
    self.realZoneText = GetRealZoneText()
    self.zoneText = GetZoneText()
    self.subZoneText = GetSubZoneText()
    self.minimapZoneText = GetMinimapZoneText()
    self.instanceID = select(8, GetInstanceInfo())

    SetMapByID(origID)
    FrameApply(WMUListeners, "RegisterEvent", "WORLD_MAP_UPDATE")
end

function LM_Location:PLAYER_LOGIN()
    self:Initialize()
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

-- In 6.0 Blizzard made all mounts able to to run, so this very accurate
-- and good test for flyability no longer works.  For now we will fall back
-- to the rubbish IsFlyableArea() until a better idea comes along.

--[[
function LM_Location:CanFly()
    for _,s in ipairs(CAN_FLY_IF_USABLE_SPELLS) do
        if not IsUsableSpell(s) then
            return nil
        end
    end
    return true
end
]]--

-- Draenor (continent 7) is flagged flyable, but you can only fly there if
-- you have completed a dodgy achievement, "Draenor Pathfinder" (10018).
--
-- Broken Isles is the same except the flying unlock is not available yet.
function LM_Location:CanFly()

    -- Can only fly in Draenor if you have the achievement
    -- Achievement check on alts is bugged in 7.0 check for skyterror
    if self.continent == 7 then
        local completed = select(4, GetAchievementInfo(10018))
        local hasSkyTerror = LM_PlayerMounts:GetMountBySpell(LM_SPELL_SOARING_SKYTERROR)
        if not completed and not hasSkyTerror then
            return nil
        end
    end

    -- Broken Isles Pathfinder, Part 2
    if self.continent == 8 then
        local completed = select(4, GetAchievementInfo(11446))
        if not completed then
            return nil
        end
    end

    -- Can't fly in the Legion Class Hall areas
    if C_Garrison.IsPlayerInGarrison(LE_GARRISON_TYPE_7_0) then
        return nil
    end

    -- This is the Draenor starting area, which is not on the Draenor
    -- continent (not on any continent). I don't know if you can fly there
    -- if you have the achievement.
    if self.areaID == 970 then
        return nil
    end

    -- Hellheim quest area reached from Stormheim on Lost Isles
    if self.areaID == 1022 then
        return nil
    end

    -- Warrior "Class Hall" area Skyhold (1035) and the intro beach area (1031)
    if tContains({ 1031, 1035 }, self.areaID) then
        return nil
    end

    return IsFlyableArea()
end

-- The difference between IsSwimming and IsSubmerged is that IsSubmerged will
-- also return true when you are standing on the bottom.  Note that it sadly
-- does not return false when you are floating on the top, that is still counted
-- as being submerged.

function LM_Location:CanSwim()
    return IsSubmerged()
end

function LM_Location:GetName()
    return self.realZoneText
end

function LM_Location:GetID()
    return self.areaID
end

function LM_Location:GetInstanceID()
    return self.instanceID
end

function LM_Location:IsAQ()
    if self.areaID == 766 then return true end
end

function LM_Location:IsVashjir()
    if self.areaID == 610 then return true end
    if self.areaID == 614 then return true end
    if self.areaID == 615 then return true end
end

function LM_Location:IsDraenorNagrand()
    if self.areaID == 950 then return true end
end

function LM_Location:Dump()
    LM_Print("--- Location Dump ---")
    LM_Print("continent: " .. self.continent)
    LM_Print("areaID: " .. self.areaID)
    LM_Print("instanceID: " .. self.instanceID)
    LM_Print("zoneText: " .. self.zoneText)
    LM_Print("subZoneText: " .. self.subZoneText)
    LM_Print("minimapZoneText: " .. self.minimapZoneText)
    LM_Print("IsFlyableArea(): " .. (IsFlyableArea() and "true" or "false"))
end
