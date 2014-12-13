--[[----------------------------------------------------------------------------

  LiteMount/MountSpell.lua

  Querying mounting spells. Needed because IsSpellKnown() never returns
  true for companion spells.

  Copyright 2011-2014 Mike Battersby

----------------------------------------------------------------------------]]--

LM_MountSpell = { }

-- GetSpellBookItemInfo and IsSpellKnown don't work for companions. The
-- first part of this can probably be replaced with IsSpellKnown() but
-- it's working so I'm leaving it alone.

function LM_MountSpell:IsKnown(spellId)
    local spellname = GetSpellInfo(spellId)

    if spellname and GetSpellBookItemInfo(spellname) then
        return true
    end

    if spellId == LM_SPELL_TELAARI_TALBUK or
       spellId == LM_SPELL_FROSTWOLF_WAR_WOLF then
        return true
    end

    for i = 1, C_MountJournal.GetNumMounts() do
        local cs = select(2, C_MountJournal.GetMountInfo(i))
        if cs == spellId then
            return true
        end
    end

    return nil
end

local function KnowProfessionSkillLine(needSkillLine, needRank)
    for _,i in ipairs({ GetProfessions() }) do
        if i then
            local _, _, rank, _, _, _, sl = GetProfessionInfo(i)
            if sl == needSkillLine and rank >= needRank then
                return true
            end
        end
    end
    return false
end

-- Draenor Ability spells are weird.  The name of the Garrison Ability
-- (localized) is name = GetSpellInfo(DraenorZoneAbilitySpellID).
-- But, GetSpellInfo(name) returns the actual current spell that's active.

function LM_MountSpell:IsUsable(spellId, flags)
    if not IsUsableSpell(spellId) then
        return nil
    end

    local need = LM_PROFESSION_MOUNT_REQUIREMENTS[spellId]
    if need and not KnowProfessionSkillLine(need[1], need[2]) then
        return nil
    end

    if spellId == LM_SPELL_TELAARI_TALBUK or
       spellId == LM_SPELL_FROSTWOLF_WAR_WOLF then
        local DraenorZoneAbilityName = GetSpellInfo(DraenorZoneAbilitySpellID)

        local id = select(7, GetSpellInfo(DraenorZoneAbilityName))
        if id ~= spellId then return false end
    end

    return true
end
