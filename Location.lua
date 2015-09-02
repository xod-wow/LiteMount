--[[----------------------------------------------------------------------------

  LiteMount/Location.lua

  Some basics about the current location with respect to mounting.  Most of
  the mojo is done by IsUsableSpell to know if a mount can be cast, this
  just helps with the prioritization.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Location = LM_CreateAutoEventFrame("Frame", "LM_Location")
LM_Location:RegisterEvent("PLAYER_LOGIN")

function LM_Location:Initialize()
    self.continent = -1
    self.areaId = -1
    self.instanceId = -1
    self.zoneText = -1
    self.minimapZoneText = ""
    self.subZoneText = ""

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("WORLD_MAP_UPDATE")
end

function LM_Location:Update()

    -- Can just ignore this case because you get a WORLD_MAP_UPDATE
    -- event when the map is closed anyway.  No point recording the
    -- areas of the user browsing the world map.
    if WorldMapFrame:IsShown() then return end

    LM_Debug("World map frame is hidden, actually updating location.")

    -- No matter how much you may want to, do not call SetMapToCurrentZone()
    self.continent = GetCurrentMapContinent()
    self.areaId = GetCurrentMapAreaID()
    self.realZoneText = GetRealZoneText()
    self.zoneText = GetZoneText()
    self.subZoneText = GetSubZoneText()
    self.instanceId = select(8, GetInstanceInfo())
end

function LM_Location:PLAYER_LOGIN()
    self:Initialize()
end

function LM_Location:PLAYER_ENTERING_WORLD()
    LM_Debug("Updating location due to PLAYER_ENTERING_WORLD.")
    self:Update()
end

function LM_Location:WORLD_MAP_UPDATE()
    LM_Debug("Updating location due to WORLD_MAP_UPDATE.")
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
function LM_Location:CanFly()

    -- Can only fly in Draenor if you have the achievement
    if self.continent == 7 then
        local completed = select(4, GetAchievementInfo(10018))
        if not completed then
            return nil
        end
    end

    -- This is the Draenor starting area, which is not on the Draenor
    -- continent (not on any continent). I don't know if you can fly there
    -- if you have the achievement.
    if self.areaId == 970 then
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

function LM_Location:GetId()
    return self.areaId
end

function LM_Location:GetInstanceId()
    return self.instanceId
end

function LM_Location:IsAQ()
    if self.areaId == 766 then return true end
end

function LM_Location:IsVashjir()
    if self.areaId == 610 then return true end
    if self.areaId == 614 then return true end
    if self.areaId == 615 then return true end
end

function LM_Location:IsDraenorNagrand()
    if self.areaId == 950 then return true end
end
