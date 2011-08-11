--[[----------------------------------------------------------------------------

  LiteMount/MountItem.lua

  Querying mounting items.

----------------------------------------------------------------------------]]--

LM_MountItem = { }

function LM_MountItem:IsEquipped(itemId)
    for i = 1,INVSLOT_LAST_EQUIPPED do
        local id = GetInventoryItemId("player", i)
        if id and id == itemId then
            return true
        end
    end
end

function LM_MountItem:CanBeEquipped(itemId)
    local equiploc = select(9, GetItemInfo(itemId))
    if not equiploc or equiploc == "" or equiploc == "INVTYPE_BAG" then
        return nil
    end
    return true
end

function LM_MountItem:IsInBags(itemId)
end
