--[[----------------------------------------------------------------------------

  LiteMount/LM_Tarecgosa.lua

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

_G.LM_Tarecgosa = setmetatable({ }, LM_Mount)
LM_Tarecgosa.__index = LM_Tarecgosa

function LM_Tarecgosa:Get()

    -- We're not actually going to use the spell action, but it gives
    -- us all the attributes, tooltip, icon, etc.

    local m = LM_Spell.Get(self, LM_SPELL.TARECGOSAS_VISAGE, "FLY")
    m.itemID = LM_ITEM.DRAGONWRATH_TARECGOSAS_REST
    m:Refresh()
    return m
end

function LM_Tarecgosa:Refresh()
    self.isCollected = ( GetItemCount(self.itemID) > 0 )
end

function LM_Tarecgosa:InProgress()
    local castingSpell = select(10, UnitCastingInfo("player"))
    if castingSpell == self.spellID then
        return true
    end
end

function LM_Tarecgosa:GetSecureAttributes()
    if self:InProgress() then
        return { ['type'] = "macro", ['macrotext'] = "" }
    end

    local itemName = GetItemInfo(self.itemID)

    -- We could move this back into LM_ItemSummoned if I could figure
    -- out how to determine what slot an item went into automatically.
    local attrs = {
        ["type"] = "item",
        ["item"] = itemName
    }

    -- Make sure you're not just wearing the item around like a champ
    if not IsEquippedItem(self.itemID) then
        attrs['lm-nextaction'] = LM_Tarecgosa2:Get(self.itemID)
    end

    return attrs
end

function LM_Tarecgosa:IsCastable()

    -- If we're in the middle of casting it, accept responsbility and
    -- do nothing so spamming the button works ok.
    if self:InProgress() then
        return true
    end

    -- IsUsableSpell seems to test correctly whether it's indoors etc.
    if not IsUsableSpell(self.spellID) then
        return false
    end

    if LM_Options.db.profile.enableTwoPress then
        if GetItemCount(self.itemID) == 0 then
            return false
        end
    elseif not IsEquippedItem(self.itemID) then
        return false
    end

    return true
end


_G.LM_Tarecgosa2 = setmetatable({ }, LM_Mount)
LM_Tarecgosa2.__index = LM_Tarecgosa2

function LM_Tarecgosa2:Get(itemID)
    local m = setmetatable({ }, self)
    m.itemID = itemID
    m.spellID = select(3, GetItemSpell(itemID))
    m.mainHand = GetInventoryItemID("player", 16)
    m.offHand = GetInventoryItemID("player", 17)

    return m
end

function LM_Tarecgosa2:Macro()
    local text = "/use 16"
    if self.mainHand then
        text = text .. format("\n/run EquipItemByName(%d)", self.mainHand)
    end
    if self.offHand then
        text = text .. format("\n/run EquipItemByName(%d)", self.offHand)
    end
    return text
end

function LM_Tarecgosa2:GetSecureAttributes()

    local tryAgain = {
        ['type'] = 'macro',
        ['macrotext'] = '',
        ['lm-nextaction'] = self,
    }

    if not IsEquippedItem(self.itemID) or not IsUsableSpell(self.spellID) then
        return tryAgain
    end

    --[[
    local start, duration, enable = GetItemCooldown(self.itemID)
    if enable == 1 and duration > 0 then
        return tryAgain
    end
    ]]

    return { ['type'] = 'macro', ['macrotext'] = self:Macro() }
end

