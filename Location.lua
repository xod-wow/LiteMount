--[[----------------------------------------------------------------------------

  LiteMount/Location.lua

  Figure out what kind of mounts we can use where the player is now.  This
  has all the complicated mojo in it.  And it probably still won't work.
  This would be a lot simpler if IsUsableSpell() just told you whether a
  mount command would succeed, but IsUsableSpell() is client-side and
  mount success is determined on the server.

----------------------------------------------------------------------------]]--

LM_Location = LM_CreateAutoEventFrame("Frame", "LM_Location")
LM_Location:RegisterEvent("PLAYER_LOGIN")

local CAN_FLY_IF_USABLE_SPELL = LM_SPELL_BRONZE_DRAKE

function LM_Location:Initialize()
    self.continent = -1
    self.areaid = -1
    self.zonetext = -1
    self.minimapzonetext = ""
    self.subzonetext = ""

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("WORLD_MAP_UPDATE")
end

function LM_Location:Update()

    -- Not sure what to do if this is the case.
    if WorldMapFrame:IsShown() then return end

    -- SetMapToCurrentZone()
    self.continent = GetCurrentMapContinent()
    self.areaid = GetCurrentMapAreaID()
    self.realzonetext = GetRealZoneText()
    self.zonetext = GetZoneText()
    self.subzonetext = GetSubZoneText()
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

function LM_Location:CanFly()
    return IsUsableSpell(CAN_FLY_IF_USABLE_SPELL)
end

function LM_Location:CanWalk()
    -- Note, Ghost Wolf can be used indoors.
    return IsOutdoors()
end

function LM_Location:CanSwim()
    return IsSwimming()
end

function LM_Location:CanFloat()
end

function LM_Location:GetName()
    return self.realzonetext
end

function LM_Location:GetId()
    return self.areaid
end

function LM_Location:IsAQ()
    if self.areaid == 766 then return 1 end
end

function LM_Location:IsVashjir()
    if not IsSwimming() then return nil end
    if self.areaid == 610 then return 1 end
    if self.areaid == 614 then return 1 end
    if self.areaid == 615 then return 1 end
end
