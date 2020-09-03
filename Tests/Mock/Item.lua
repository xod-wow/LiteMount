function UseItemByName(itemName)
    print(">>> UseItem " .. itemName)
    local spellName, spellID = GetItemSpell(itemName)
    CastSpell(spellID)
end

function IsEquippableItem(id)
    return ( id == 71086 )
end

function IsEquippedItem(id)
    return MockState.equipped[id]
end

function GetItemInfo(id)
    if type(id) == 'number' then
        local info = data.GetItemInfo[id]
        if info then return unpack(info) end
    else
        for _, info in pairs(data.GetItemInfo) do
            if info[1] == id then return unpack(info) end
        end
    end
end

function GetItemCount(id)
    if data.GetItemInfo[id] then
        return 1
    else
        return 0
    end
end

function GetItemCooldown(id)
    -- start, duration, enable
    return 0, 0, 1
end

function GetItemSpell(id)
    if type(id) == 'number' then
        local info = data.GetItemSpell[id]
        if info then return unpack(info) end
    else
        for itemID, info in pairs(data.GetItemInfo) do
            if info[1] == id then
                return unpack(data.GetItemSpell[itemID] or {})
            end
        end
    end
end
