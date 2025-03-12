--[[----------------------------------------------------------------------------

  LiteMount/LM_Drive.lua

  D.R.I.V.E. system for Undermine, G-99 Breakneck

  Copyright 2025 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

LM.Drive = setmetatable({ }, LM.Spell)
LM.Drive.__index = LM.Drive

--
-- G-99 Breakneck has all kinds of funky overriding going on. And despite the
-- item that teaches it saying it's a mount, it's not in the journal.
--
-- The base spell ID is 1215279. This is what you can cast by ID (nothing
-- else works).
--
-- By default (in places you can't D.R.I.V.E.) it is an instant-cast spell
-- that displays an error message with a red X icon (iconID 4200126).
--
-- If you are mounted in G-99 Heartbreaker it is not overridden.
--
-- In the Undermine zone it is part of the zone abilities, and the zone ability
-- spell ID is also 1215279. It is overridden to 460013, which seems to be the
-- full version of the mount.
--
-- Inside the Liberation of Undermine raid it is overridden with a version
-- that doesn't have boost enabled and no horn, 1218373.
--
-- C_Spell.GetOverrideSpell(1215279) works to get the actual ID.
--
-- FindBaseSpellByID(overrideID) returns 1215279 correctly.
--
-- IsPlayerSpell(1215279) works to see if you've unlocked it.
--
-- C_Spell.IsSpellUsable(1215279) works for both situations.
--

function LM.Drive.IsUsable()
    if C_Spell.GetOverrideSpell(LM.SPELL.G_99_BREAKNECK) ~= LM.SPELL.G_99_BREAKNECK then
        return true
    end

    -- Spell isn't overridden if you're in the mount, but obviously it's usable.

    local name = C_Spell.GetSpellName(LM.SPELL.G_99_BREAKNECK)
    if LM.UnitAura('player', name) then
        return true
    end

    -- Bug workarounds from here

    -- Spell override sometimes get stuck in the client (I assume it's not cache
    -- invalidating correctly) and the API returns no override. The Blizzard icon
    -- also shows wrongly. Not sure of the exact circumstances but the two times
    -- I've triggered it have been to do with raid group.

    if LM.Environment:InInstance(2769) then
        return true
    end

    if C_ZoneAbility then
        local zoneAbilities = C_ZoneAbility.GetActiveAbilities()
        for _,zoneAbility in ipairs(zoneAbilities) do
            if zoneAbility.spellID == LM.SPELL.G_99_BREAKNECK then
                return true
            end
        end
    end

    return false
end

function LM.Drive:IsCastable()
    if not self:IsUsable() then
        return false
    end
    return LM.Spell.IsCastable(self)
end
