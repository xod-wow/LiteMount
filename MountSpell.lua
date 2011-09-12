--[[----------------------------------------------------------------------------

  LiteMount/MountSpell.lua

  Querying mounting spells. Needed because IsSpellKnown() never returns
  true for companion spells.

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

    for i = 1, GetNumCompanions("MOUNT") do
        local cs = select(3, GetCompanionInfo("MOUNT", i))
        if cs == spellId then
            return true
        end
    end

    return nil
end
