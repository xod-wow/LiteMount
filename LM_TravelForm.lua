--[[----------------------------------------------------------------------------

  LiteMount/LM_TravelForm.lua

  Travel Form is the biggest pain in the butt ever invented.  Blizzard
  change how it works, how fast it is, how many spells it is, and almost
  every other aspect of it ALL THE DAMN TIME.

  LEAVE TRAVEL FORM ALONE!

  Also IsUsableSpell doesn't work right on it.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.TravelForm = setmetatable({ }, LM.Spell)
LM.TravelForm.__index = LM.TravelForm

-- Only cancel forms that we will activate (mount-style ones).
-- See: https://wow.gamepedia.com/API_GetShapeshiftFormID
-- Form IDs that you put here must be cancelled automatically on
-- mounting.

local savedFormName = nil

local restoreFormIDs = {
    [1] = true,     -- Cat Form
    [5] = true,     -- Bear Form
    [31] = true,    -- Moonkin Form
}

-- IsUsableSpell doesn't return false for Travel Form indoors like it should,
-- because you can swim indoors with it (apparently).
function LM.TravelForm:IsCastable()
    if IsIndoors() and not IsSubmerged() then return false end
    return LM.Spell.IsCastable(self)
end

-- Check for the bad Travel Form from casting it in combat and
-- don't consider that to be mounted
function LM.TravelForm:IsCancelable()
    if GetShapeshiftFormID() == 27 then
        local _, run, fly, swim = GetUnitSpeed('player')
        if fly < run then
            return false
        end
    end
    return LM.Spell.IsCancelable(self)
end

-- Work around a Blizzard bug with calling shapeshift forms in macros in 8.0
-- Breaks after you respec unless you include (Shapeshift) after it.

local function GetFormNameWithSubtext()
    local idx = GetShapeshiftForm()
    local spellID = select(4, GetShapeshiftFormInfo(idx))
    local n = GetSpellInfo(spellID)
    local s = GetSpellSubtext(spellID) or ''
    return format('%s(%s)', n, s)
end

-- You can cast Travel Form using the SpellID (unlike the journal mounts
-- where you can't), which bypasses a bug. This takes care of saving the
-- current form name as well.
--
-- Takes care of saving the current form in case we need to restore it

function LM.TravelForm:GetMountAttributes()
    local currentFormID = GetShapeshiftFormID()

    if currentFormID and restoreFormIDs[currentFormID] then
        savedFormName = GetFormNameWithSubtext()
        LM.Debug(" - saving current form " .. tostring(savedFormName))
    end

    return { ["type"] = "spell", ["spell"] = self.spellID }
end
function LM.TravelForm:GetCancelAttributes()
    if savedFormName then
        local attr = { ["type"] = "spell", ["spell"] = savedFormName }
        savedFormName = nil
        return attr
    else
        return { ["type"] = "cancelaura", ["spell"] = self.name }
    end
end
