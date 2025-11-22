C_UnitAuras = {}

function C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter)
    local tbl = (filter and filter:find('HARMFUL')) and MockState.debuffs or MockState.buffs

    local buffs = {}
    for id in pairs(tbl) do
        buffs[#buffs+1] = id
    end
    sort(buffs)

    if buffs[idx] then
        local name = C_Spell.GetSpellName(buffs[idx])
        return { name = name, spellId = buffs[idx], }
    end
end

function C_UnitAuras.GetAuraDataBySpellName(unitToken, spellName, filter)
    local tbl = filter and filter:find('HARMFUL') and MockState.debuffs or MockState.buffs

    for id in pairs(tbl) do
        local spellName = C_Spell.GetSpellName(id)
        if name == spellName then
            return { name = name, spellId = id, }
        end
    end
end

function C_UnitAuras.GetPlayerAuraBySpellID(spellID)
    for _, tbl in ipairs({ MockState.debuffs or MockState.buffs }) do
        for id in pairs(tbl) do
            if id == spellID then
                local spellName = C_Spell.GetSpellName(id)
                return { name = name, spellId = id, }
            end
        end
    end
end
