-- GetItemInfo() return doesn't have the itemID in it so
-- we need a looker-upper

local function GetIDByName(name)
    local id = MockGetKVFromData(data.GetItemInfo, name, 1)
    return id
end

C_Item = {}

function C_Item.UseItemByName(itemName)
    print(">>> UseItem " .. itemName)
    local spellName, spellID = GetItemSpell(itemName)
    print(">>> ", spellName, spellID)
    CastSpell(spellID)
end

function C_Item.IsEquippableItem(id)
    return ( id == 71086 )
end

function C_Item.IsEquippedItem(id)
    return MockState.equipped[id]
end

function C_Item.IsEquippedItemType(itemType)
    if math.random() < 0.2 then
        return true
    else
        return false
    end
end

function C_Item.GetItemInfo(id)
    if type(id) == 'number' then
        return MockGetFromData(data.GetItemInfo, id)
    else
        return MockGetFromData(data.GetItemInfo, id, 1)
    end
end

function C_Item.GetItemCount(id)
    if data.GetItemInfo[id] then
        return 1
    else
        return 0
    end
end

function C_Item.GetItemCooldown(id)
    -- start, duration, enable
    return 0, 0, 1
end

function C_Item.GetItemSpell(id)
    if type(id) ~= 'number' then
        id = GetIDByName(id)
    end
    return MockGetFromData(data.GetItemSpell, id)
end
