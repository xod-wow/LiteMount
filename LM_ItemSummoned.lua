--[[----------------------------------------------------------------------------

  LiteMount/LM_ItemSummoned.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

LM.ItemSummoned = setmetatable({ }, LM.Mount)
LM.ItemSummoned.__index = LM.ItemSummoned

-- In theory we might be able to just use the itemID and use
--      spellName = C_Item.GetItemSpell(itemID)
-- the trouble is the names aren't definitely unique and that makes me
-- worried.  Since there are such a small number of these, keeping track of
-- the spell as well isn't a burden.

function LM.ItemSummoned:Get(itemID, spellID, ...)

    local m = LM.Spell.Get(self, spellID, ...)
    if m then
        -- Used to do GetItemInfo here, but it doesn't work the first
        -- time you log in until the server returns the info and
        -- GET_ITEM_INFO_RECEIVED fires, but I can't be bothered handling
        -- the event and it's not really needed.
        m.itemID = itemID
    end

    return m
end

function LM.ItemSummoned:IsCollected()
    return C_Item.GetItemCount(self.itemID) > 0
end

function LM.ItemSummoned:GetCastAction(context)
    -- I assume that if you actually have the item, GetItemInfo() works
    local itemName = C_Item.GetItemInfo(self.itemID)
    return LM.SecureAction:Item(itemName)
end

function LM.ItemSummoned:IsCastable()

    -- IsSpellUsable seems to test correctly whether it's indoors etc.
    if not C_Spell.IsSpellUsable(self.spellID) then
        return false
    end

    if C_Item.IsEquippableItem(self.itemID) then
        if not C_Item.IsEquippedItem(self.itemID) then
            return false
        end
    else
        if C_Item.GetItemCount(self.itemID) == 0 then
            return false
        end
    end

    -- Either equipped or non-equippable and in bags
    local start, duration, enable = C_Container.GetItemCooldown(self.itemID)
    if duration > 0 and (enable == true or enable == 1) then
        return false
    end

    return LM.Mount.IsCastable(self)
end
