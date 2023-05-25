--[[----------------------------------------------------------------------------

  LiteMount/LM_TravelForm.lua

  Travel Form is the biggest pain in the butt ever invented.  Blizzard
  change how it works, how fast it is, how many spells it is, and almost
  every other aspect of it ALL THE DAMN TIME.

  LEAVE TRAVEL FORM ALONE!

  Also IsUsableSpell doesn't work right on it.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

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

-- IsUsableSpell doesn't return false for Travel Form indoors like it should,
-- because you can swim indoors with it (apparently).
function LM.TravelForm:IsCastable()
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
