--[[----------------------------------------------------------------------------

  LiteMount/LM_Drive.lua

  D.R.I.V.E. system for Undermine, G-99 Breakneck

  Copyright 2025 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

LM.Drive = setmetatable({ }, LM.Spell)
LM.Drive.__index = LM.Drive

-- Check if the spell is in one of the zone spell slots.

function LM.Drive:IsCollected()
    return true
end

function LM.Drive:IsCastable()
    -- In the raid zone there seems to be a different copy of G-99 Breakneck
    -- that obeys the normal rules for IsSpellUsable
    if select(8, GetInstanceInfo()) == 2769 then
        return C_Spell.IsSpellUsable(self.name)
    else
        local zoneAbilities = C_ZoneAbility.GetActiveAbilities()
        for _,info in ipairs(zoneAbilities) do
            local zoneSpellName = C_Spell.GetSpellName(info.spellID)
            local zoneSpellID = C_Spell.GetSpellInfo(zoneSpellName).spellID
            if zoneSpellID == self.spellID then
                return C_Spell.IsSpellUsable(info.spellID) and LM.Mount.IsCastable(self)
            end
        end
    end
    return false
end
