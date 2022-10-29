-- GetItemInfo() return doesn't have the itemID in it so
-- we need a looker-upper

local function GetIDByName(name)
    local id = MockGetKVFromData(data.GetItemInfo, name, 1)
    return id
end

function UseItemByName(itemName)
    print(">>> UseItem " .. itemName)
    local spellName, spellID = GetItemSpell(itemName)
    print(">>> ", spellName, spellID)
    CastSpell(spellID)
end

function IsEquippableItem(id)
    return ( id == 71086 )
end

function IsEquippedItem(id)
    return MockState.equipped[id]
end

function IsEquippedItemType(itemType)
    if math.random() < 0.2 then
        return true
    else
        return false
    end
end

function GetItemInfo(id)
    if type(id) == 'number' then
        return MockGetFromData(data.GetItemInfo, id)
    else
        print(id, MockGetFromData(data.GetItemInfo, id, 1))
        return MockGetFromData(data.GetItemInfo, id, 1)
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
    if type(id) ~= 'number' then
        id = GetIDByName(id)
    end
    return MockGetFromData(data.GetItemSpell, id)
end
