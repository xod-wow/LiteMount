--[[----------------------------------------------------------------------------

  LiteMount/LM_TravelForm.lua

  Travel Form is the biggest pain in the butt ever invented.  Blizzard
  change how it works, how fast it is, how many spells it is, and almost
  every other aspect of it ALL THE DAMN TIME.

  LEAVE TRAVEL FORM ALONE!

  Also IsSpellUsable doesn't work right on it.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LM.TravelForm = setmetatable({ }, LM.Spell)
LM.TravelForm.__index = LM.TravelForm


-- Druid forms don't reliably have a corresponding player buff, so we need
-- to check the spell from GetShapeshiftFormInfo.
function LM.TravelForm:IsActive(buffTable)
    local id = GetShapeshiftForm()
    if id > 0 then
        return select(4, GetShapeshiftFormInfo(id)) == self.spellID
    end
end

-- In Wrath Classic, you can't fly in Dalaran except in Krasus Landing near
-- the flight master. Normal flying mounts detect this correctly but the
-- flight forms do not.
--
-- As far as I can tell there's no way to tell (that's locale-independent).
-- There's no visible buff, IsFlyablArea() is true and Flight Form is not
-- greyed out. Other flying mounts ARE flagged as unusable but only ones you
-- know ever become usable so it's not reliable.
--
-- So, here's a huge hack that figures out approxiately if you are in the
-- right area or not.

local KrasusLandingCenter = CreateVector2D(0.727, 0.456)
local DalaranDenySpells = { LM.SPELL.FLIGHT_FORM_CLASSIC, LM.SPELL.SWIFT_FLIGHT_FORM_CLASSIC }

function LM.TravelForm:IsAreaDenied()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then return false end
    if not tContains(DalaranDenySpells, self.spellID) then return false end

    local map = C_Map.GetBestMapForUnit('player')
    if map ~= 125 then return false end

    local pos = C_Map.GetPlayerMapPosition(map, 'player')
    if not pos then return false end

    pos:Subtract(KrasusLandingCenter)
    if pos:GetLengthSquared() < 0.0064 then return false end

    return true
end

-- IsSpellUsable doesn't return false for Travel Form indoors like it should,
-- because you can swim indoors with it (apparently).
function LM.TravelForm:IsCastable()
    if self:IsAreaDenied() then return false end
    if IsIndoors() and not IsSubmerged() then return false end
    local id = GetShapeshiftFormID()
    -- Don't recast over mount-like forms as it behaves as a dismount
    if id == 3 or id == 27 then return false end
    return LM.Spell.IsCastable(self)
end

function LM.TravelForm:GetCancelAction()
    -- Is there any good reason to use /cancelform instead?
    return LM.SecureAction:CancelAura(self.name)
end

function LM.TravelForm:IsHidden()
    return not IsPlayerSpell(self.spellID)
end
