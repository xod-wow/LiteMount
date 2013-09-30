--[[----------------------------------------------------------------------------

  LiteMount/Location.lua

  Some basics about the current location with respect to mounting.  Most of
  the mojo is done by IsUsableSpell to know if a mount can be cast, this
  just helps with the prioritization.

  Copyright 2011-2013 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Location = LM_CreateAutoEventFrame("Frame", "LM_Location")
LM_Location:RegisterEvent("PLAYER_LOGIN")

local CAN_FLY_IF_USABLE_SPELLS = {
                                   LM_SPELL_RED_FLYING_CLOUD,  -- can't swim
                                   LM_SPELL_BRONZE_DRAKE       -- can't run
                                 }

function LM_Location:Initialize()
    self.continent = -1
    self.areaId = -1
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

    -- No matter how much you may want to, do not call SetMapToCurrentZone()
    self.continent = GetCurrentMapContinent()
    self.areaId = GetCurrentMapAreaID()
    self.realzonetext = GetRealZoneText()
    self.zoneText = GetZoneText()
    self.subZoneText = GetSubZoneText()
end

function LM_Location:PLAYER_LOGIN()
    self:Initialize()
end

function LM_Location:PLAYER_ENTERING_WORLD()
    self:Update()
end

function LM_Location:WORLD_MAP_UPDATE()
    self:Update()
end

-- In 5.4 Blizzard made the Bronze Drake able to swim, so now there is
-- this double test, one for a mount that can't run and another that can't
-- swim.
function LM_Location:CanFly()
    for _,s in ipairs(CAN_FLY_IF_USABLE_SPELLS) do
        if not IsUsableSpell(s) then
            return nil
        end
    end
    return true
end

function LM_Location:CanSwim()
    return IsSwimming()
end

function LM_Location:GetName()
    return self.realzonetext
end

function LM_Location:GetId()
    return self.areaId
end

function LM_Location:IsAQ()
    if self.areaId == 766 then return 1 end
end

function LM_Location:IsVashjir()
    if not IsSwimming() then return nil end
    if self.areaId == 610 then return 1 end
    if self.areaId == 614 then return 1 end
    if self.areaId == 615 then return 1 end
end
