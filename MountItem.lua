--[[----------------------------------------------------------------------------

  LiteMount/MountItem.lua

  Querying mounting items.

----------------------------------------------------------------------------]]--

LM_MountItem = { }

function LM_MountItem:HasItem(itemId)
    if GetItemCount(itemId) > 0 then
        return true
    end
end

function LM_MountItem:IsUsable(itemId)

    if IsEquippableItem(itemId) then
        if not IsEquippedItem(itemId) then
            return false
        end
    else
        if GetItemCount(itemId) == 0 then
            return false
        end
    end

    -- Either equipped or non-equippable and in bags
    local start, duration, enable = GetItemCooldown(itemId)
    if duration > 0 and enable == 0 then
        return false
    end

    return true
end

