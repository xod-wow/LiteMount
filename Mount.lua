--[[----------------------------------------------------------------------------

  LiteMount/Mount.lua

  Information about one mount.

  Copyright 2011-2014 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Mount = {
    ["cacheByItemId"] = { },
    ["cacheByName"]   = { },
    ["cacheBySpellId"] = { }
}
LM_Mount.__index = LM_Mount

function LM_Mount:new()
    return setmetatable({ }, LM_Mount)
end

function LM_Mount:OverrideFlags()
    local flags = LM_FlagOverrideTable[self.spellId]
    if flags then
        self.flags = flags
    end
end

function LM_Mount:GetMountByItem(itemId, spellId)

    if self.cacheByItemId[itemId] then
        return self.cacheByItemId[itemId]
    end

    local m = LM_Mount:GetMountBySpell(spellId)
    if not m then return end

    local item_info = { GetItemInfo(itemId) }
    if not item_info[1] then
        LM_Debug("LM_Mount: Failed GetItemInfo #"..itemId)
        return
    end

    m.itemId = itemId
    m.itemName = item_info[1]

    self.cacheByItemId[itemId] = m

    return m
end

function LM_Mount:SpellId(v)
    if v then self.spellId = v end
    return self.spellId
end

function LM_Mount:ItemId(v)
    if v then self.itemId = v end
    return self.itemId
end

function LM_Mount:ModelId(v)
    if v then self.modelId = v end
    return self.modelId
end

function LM_Mount:SelfMount(v)
    if v then self.isSelfMount = v end
    return self.isSelfMount
end

function LM_Mount:Type(v)
    if v then self.mountType = v end
    return self.mountType
end

function LM_Mount:SpellName(v)
    if v then self.spellName = v end
    return self.spellName
end

function LM_Mount:Icon(v)
    if v then self.icon = v end
    return self.icon
end

function LM_Mount:Name(v)
    if v then self.name = v end
    return self.name
end

function LM_Mount:NeedsFaction(v)
    if v then self.needsFaction = v end
    return self.needsFaction
end

function LM_Mount:DefaultFlags(v)
    if v then self.flags = v end
    return self.flags
end

function LM_Mount:Flags()
    return LM_Options:ApplySpellFlags(self.spellId, self:DefaultFlags())
end

function LM_Mount:CanFly()
    return self:FlagsSet(LM_FLAG_BIT_FLY)
end

function LM_Mount:CanRun()
    return self:FlagsSet(LM_FLAG_BIT_RUN)
end

function LM_Mount:CanWalk()
    return self:FlagsSet(LM_FLAG_BIT_WALK)
end

function LM_Mount:CanFloat()
    return self:FlagsSet(LM_FLAG_BIT_FLOAT)
end

function LM_Mount:CanSwim()
    return self:FlagsSet(LM_FLAG_BIT_SWIM)
end

function LM_Mount:CastTime()
    return self.castTime
end

-- This is a bit of a convenience since bit.isset doesn't exist
function LM_Mount:FlagsSet(f)
    return bit.band(self:Flags(), f) == f
end

local IceFloesSpellName

function LM_Mount:PlayerHasIceFloes()
    if not IceFloesSpellName then
        IceFloesSpellName = GetSpellInfo(108839)
    end
    return UnitAura("player", IceFloesSpellName)
end

function LM_Mount:PlayerIsMovingOrFalling()
    return (GetUnitSpeed("player") > 0 or IsFalling())
end

function LM_Mount:IsUsable(flags)

    if not self:PlayerHasIceFloes() and self:PlayerIsMovingOrFalling() then
        if self:CastTime() > 0 then return end
    end

    local faction = self:NeedsFaction()
    local pFaction = UnitFactionGroup("player")
    if faction and faction ~= pFaction then
        return
    end

    return true
end

function LM_Mount:IsExcluded()
    return LM_Options:IsExcludedSpell(self.spellId)
end

function LM_Mount:SetupActionButton(button)
    LM_Debug("LM_Mount setting button to spell "..self.spellName)
    button:SetAttribute("type", "spell")
    button:SetAttribute("spell", self.spellName)
end

function LM_Mount:Dump(prefix)
    if prefix == nil then
        prefix = ""
    end

    local function yesno(t) if t then return "yes" else return "no" end end

    LM_Print(prefix .. self:Name())
    LM_Print(prefix .. " spell: " .. string.format("%s (id %d)", self:SpellName(), self:SpellId()))
    LM_Print(prefix .. " casttime: " .. self:CastTime())
    LM_Print(prefix .. " flags: " .. string.format("%02x (default %02x)", self:Flags(), self:DefaultFlags()))
    LM_Print(prefix .. " excluded: " .. yesno(self:IsExcluded()))
    LM_Print(prefix .. " usable: " .. yesno(self:IsUsable()) .. " (spell " .. yesno(IsUsableSpell(self:SpellId())) .. ")")
end
