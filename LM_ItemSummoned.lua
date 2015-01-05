--[[----------------------------------------------------------------------------

  LiteMount/LM_ItemSummoned.lua

  Copyright 2011-2014 Mike Battersby

----------------------------------------------------------------------------]]--

LM_ItemSummoned = setmetatable({ }, LM_Mount)
LM_ItemSummoned.__index = LM_ItemSummoned

local function PlayerHasItem(itemId)
    if GetItemCount(itemId) > 0 then
        return true
    end
end

-- In theory we might be able to just use the itemId and use
--      spellName = GetItemSpell(itemId)
-- the trouble is the names aren't definitely unique and that makes me
-- worried.  Since there are such a small number of these, keeping track of
-- the spell as well isn't a burden.

function LM_ItemSummoned:Get(itemId, spellId, flags)

    if not PlayerHasItem(itemId) then return end

    if self.cacheByItemId[itemId] then
        return self.cacheByItemId[itemId]
    end

    local m = LM_Spell:Get(spellId, true)
    if not m then return end

    setmetatable(m, LM_ItemSummoned)

    local itemName = GetItemInfo(itemId)
    if not itemName then
        LM_Debug("LM_Mount: Failed GetItemInfo #"..itemId)
        return
    end

    m.itemId = itemId
    m.itemName = itemName
    m.flags = flags

    self.cacheByItemId[itemId] = m

    return m
end

function LM_ItemSummoned:SetupActionButton(button)
    LM_Debug("LM_Mount setting button to item "..self.itemName)
    button:SetAttribute("type", "item")
    button:SetAttribute("item", self.itemName)
end

function LM_ItemSummoned:IsUsable(flags)

    local spell = self:SpellId()

    -- IsUsableSpell seems to test correctly whether it's indoors etc.
    if spell and not IsUsableSpell(spell) then
        return false
    end

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

