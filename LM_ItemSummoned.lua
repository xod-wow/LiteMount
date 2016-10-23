--[[----------------------------------------------------------------------------

  LiteMount/LM_ItemSummoned.lua

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_ItemSummoned = setmetatable({ }, LM_Mount)
LM_ItemSummoned.__index = LM_ItemSummoned

local function PlayerHasItem(itemID)
    if GetItemCount(itemID) > 0 then
        return true
    end
end

-- In theory we might be able to just use the itemID and use
--      spellName = GetItemSpell(itemID)
-- the trouble is the names aren't definitely unique and that makes me
-- worried.  Since there are such a small number of these, keeping track of
-- the spell as well isn't a burden.

function LM_ItemSummoned:Get(itemID, spellID, flags)

    if not PlayerHasItem(itemID) then return end

    if self.cacheByItemID[itemID] then
        return self.cacheByItemID[itemID]
    end

    local m = LM_Spell:Get(spellID, true)
    if not m then return end

    setmetatable(m, LM_ItemSummoned)

    local itemName = GetItemInfo(itemID)
    if not itemName then
        LM_Debug("LM_Mount: Failed GetItemInfo #"..itemID)
        return
    end

    m.itemID = itemID
    m.itemName = itemName
    m.flags = flags

    self.cacheByItemID[itemID] = m

    return m
end

function LM_ItemSummoned:SetupActionButton(button)
    LM_Debug("LM_Mount setting button to item "..self.itemName)
    button:SetAttribute("type", "item")
    button:SetAttribute("item", self.itemName)
end

function LM_ItemSummoned:IsUsable()

    local spellId = self:SpellID()

    -- IsUsableSpell seems to test correctly whether it's indoors etc.
    if spellId and not IsUsableSpell(spellId) then
        return false
    end

    local itemID = self:ItemID()

    if IsEquippableItem(itemID) then
        if not IsEquippedItem(itemID) then
            return false
        end
    else
        if not PlayerHasItem(itemID) then
            return false
        end
    end

    -- Either equipped or non-equippable and in bags
    local start, duration, enable = GetItemCooldown(itemID)
    if duration > 0 and enable == 1 then
        return false
    end

    return true
end

