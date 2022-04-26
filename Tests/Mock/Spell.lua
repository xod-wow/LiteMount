function GetSpellInfo(id)
    local info
    if type(id) == 'number' then
        if data.GetSpellInfo[id] then return unpack(data.GetSpellInfo[id]) end
    elseif type(id) == 'string' then
        for _,info in pairs(data.GetSpellInfo) do
            if info[1] == id then return unpack(info) end
        end
    end
    -- print("GetSpellInfo", tostring(id))
end

-- Assume that all spells put a buff on you with the same id
function CastSpell(id)
    MockState.buffs[id] = true
    print(">>> CastSpell " .. id .. " " .. GetSpellInfo(id))
end

function CastSpellByName(name)
    print(name)
    print(GetSpellInfo(name))
    local id = select(7, GetSpellInfo(name))
    if id then CastSpell(id) end
end

function CancelAura(id)
    MockState.buffs[id] = nil
    print(">>> CancelAura " .. id .. " " .. GetSpellInfo(id))
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

function IsUsableSpell(id)
    if MockState.moving then
        for _,info in pairs(data.GetMountInfoByID) do
            if info[2] == id then
                return false
            end
        end
    end
    return data.GetSpellInfo[id] ~= nil
end

function GetSpellCooldown(id)
    return 0
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
