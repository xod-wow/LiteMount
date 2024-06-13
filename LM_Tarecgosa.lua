--[[----------------------------------------------------------------------------

  LiteMount/LM_Tarecgosa.lua

  This doesn't work because there is no action that will equip and mount
  in one. I'm leaving it here as a reference in case I want to do something
  similar in the future.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.Tarecgosa = setmetatable({ }, LM.Mount)
LM.Tarecgosa.__index = LM.Tarecgosa

function LM.Tarecgosa:Get()

    -- We're not actually going to use the spell action, but it gives
    -- us all the attributes, tooltip, icon, etc.

    local m = LM.Spell.Get(self, LM.SPELL.TARECGOSAS_VISAGE, "FLY")
    m.itemID = LM.ITEM.DRAGONWRATH_TARECGOSAS_REST
    m:Refresh()
    return m
end

function LM.Tarecgosa:IsCollected()
    return ( C_Item.GetItemCount(self.itemID) > 0 )
end

function LM.Tarecgosa:InProgress()
    local castingSpell = select(10, UnitCastingInfo("player"))
    if castingSpell == self.spellID then
        return true
    end
end

function LM.Tarecgosa:GetCastAction(context)
    if self:InProgress() then
        return { ['type'] = "macro", ['macrotext'] = "" }
    end

    local itemName = C_Item.GetItemInfo(self.itemID)

    -- We could move this back into LM.ItemSummoned if I could figure
    -- out how to determine what slot an item went into automatically.
    local action = LM.SecureAction:Item(itemName)

    -- Make sure you're not just wearing the item around like a champ
    if not IsEquippedItem(self.itemID) then
        action['lm-nextaction'] = LM.Tarecgosa2:Get(self.itemID)
    end

    return attrs
end

function LM.Tarecgosa:IsCastable()

    -- If we're in the middle of casting it, accept responsbility and
    -- do nothing so spamming the button works ok.
    if self:InProgress() then
        return true
    end

    -- IsSpellUsable seems to test correctly whether it's indoors etc.
    if not C_Spell.IsSpellUsable(self.spellID) then
        return false
    end

    if LM.Options.db.profile.enableTwoPress then
        if C_Item.GetItemCount(self.itemID) == 0 then
            return false
        end
    elseif not C_Item.IsEquippedItem(self.itemID) then
        return false
    end

    return true
end


LM.Tarecgosa2 = setmetatable({ }, LM.Mount)
LM.Tarecgosa2.__index = LM.Tarecgosa2

function LM.Tarecgosa2:Get(itemID)
    local m = setmetatable({ }, self)
    m.itemID = itemID
    m.spellID = select(2, C_Item.GetItemSpell(itemID))
    m.mainHand = GetInventoryItemID("player", 16)
    m.offHand = GetInventoryItemID("player", 17)

    return m
end

function LM.Tarecgosa2:Macro()
    local text = "/use 16"
    if self.mainHand then
        text = text .. format("\n/run EquipItemByName(%d)", self.mainHand)
    end
    if self.offHand then
        text = text .. format("\n/run EquipItemByName(%d)", self.offHand)
    end
    return text
end

function LM.Tarecgosa2:GetCastAction()

    local tryAgain = {
        ['type'] = 'macro',
        ['macrotext'] = '',
        ['lm-nextaction'] = self,
    }

    if not IsEquippedItem(self.itemID) or not C_Spell.IsSpellUsable(self.spellID) then
        return LM.SecureAction:New(tryAgain)
    end

    --[[
    local start, duration, enable = C_Item.GetItemCooldown(self.itemID)
    if (enable == true or enable == 1) and duration > 0 then
        return tryAgain
    end
    ]]

    return LM.SecureAction:Macro(self:Macro())
end
