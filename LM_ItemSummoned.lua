--[[----------------------------------------------------------------------------

  LiteMount/LM_ItemSummoned.lua

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_ItemSummoned = setmetatable({ }, LM_Mount)
LM_ItemSummoned.__index = LM_ItemSummoned

-- In theory we might be able to just use the itemID and use
--      spellName = GetItemSpell(itemID)
-- the trouble is the names aren't definitely unique and that makes me
-- worried.  Since there are such a small number of these, keeping track of
-- the spell as well isn't a burden.

function LM_ItemSummoned:Get(itemID, spellID, flags)

    local m = LM_Spell.Get(self, spellID)
    if m then
        -- Used to do GetItemInfo here, but it doesn't work the first
        -- time you log in until the server returns the info and
        -- GET_ITEM_INFO_RECEIVED fires, but I can't be bothered handling
        -- the event and it's not really needed.
        m.itemID = itemID
        m.flags = flags
        m.isCollected = ( GetItemCount(m.itemID) > 0 )
    end

    return m
end

function LM_ItemSummoned:Refresh()
    self.isCollected = ( GetItemCount(self.itemID) > 0 )
end

function LM_ItemSummoned:GetSecureAttributes()
    -- I assume that if you actually have the item, GetItemInfo() works
    local itemName = GetItemInfo(self.itemID)
    return { ["type"] = "item", ["item"] = itemName }
end

function LM_ItemSummoned:IsCastable()

    -- IsUsableSpell seems to test correctly whether it's indoors etc.
    if not IsUsableSpell(self.spellID) then
        return false
    end

    if IsEquippableItem(self.itemID) then
        if not IsEquippedItem(self.itemID) then
            return false
        end
    else
        if GetItemCount(self.itemID) == 0 then
            return false
        end
    end

    -- Either equipped or non-equippable and in bags
    local start, duration, enable = GetItemCooldown(self.itemID)
    if duration > 0 and enable == 1 then
        return false
    end

    return true
end

