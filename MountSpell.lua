--[[----------------------------------------------------------------------------

  LiteMount/MountSpell.lua

  Querying mounting spells.

----------------------------------------------------------------------------]]--

MountSpell = { }

-- GetSpellBookItemInfo only works for spells which are in one of the
-- class spellbook pages. So not racials, not companions and not
-- much faster.

function MountSpell:IsKnown(spellId)
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
