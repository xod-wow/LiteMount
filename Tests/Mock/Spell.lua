-- Assume that all spells put a buff on you with the same id
function CastSpell(id)
    MockState.buffs[id] = true
    print(">>> CastSpell " .. id .. " " .. C_Spell.GetSpellName(id))
end

function CastSpellByName(name)
    local info = C_Spell.GetSpellInfo(name)
    if info then CastSpell(info.spellID) end
end

function CancelAura(id)
    MockState.buffs[id] = nil
    print(">>> CancelAura " .. id .. " " .. C_Spell.GetSpellName(id))
end

function CancelAuraByName(name)
    local id = select(7, GetSpellInfo(name))
    if id then CancelAura(id) end
end

function IsSpellKnown(id)
    if id == 90265 or id == 34090 then
        return MockState.playerKnowsFlying
    else
        return data.GetSpellInfo[id] ~= nil
    end
end

function IsPlayerSpell(id)
    return true
end

-- I should probably pick a test spell and have it be channeling sometimes
function UnitChannelInfo(unit)
end

function UnitAura(unit, idx, filter)
    if filter and filter:find('HARMFUL') then
        tbl = MockState.debuffs
    else
        tbl = MockState.buffs
    end

    local buffs = {}
    for id in pairs(tbl) do
        buffs[#buffs+1] = id
    end
    sort(buffs)

    if buffs[idx] then
        return GetSpellInfo(buffs[idx]), nil, nil, nil, nil, nil, nil, nil, nil, buffs[idx]
    end
end
