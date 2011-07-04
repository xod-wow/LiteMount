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

function LM_Location:SetFlySpell()
end

function LM_Location:PLAYER_LOGIN()
    self:Initialize()
end

function LM_Location:PLAYER_ENTERING_WORLD()
    self:SetFlySpell()
    self:Update()
end

function LM_Location:WORLD_MAP_UPDATE()
    self:Update()
end

function LM_Location:CanFly()
    -- XXX FIXME XXX
    -- Possibly use IsUsableSpell() on flying mount in conjunction with
    -- some IsMoving() tests.
    return IsFlyableArea()
end

function LM_Location:CanWalk()
    return true
end

function LM_Location:CanSwim()
    return IsSwimming()
end

function LM_Location:CanFloat()
    return IsSwimming()
end

function LM_Location:GetName()
    return self.realzonetext
end

function LM_Location:IsAQ()
end

function LM_Location:IsVashjir()
end

