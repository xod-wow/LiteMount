--[[----------------------------------------------------------------------------

  LiteMount/Mount.lua

  Information about one mount.

----------------------------------------------------------------------------]]--

LM_Mount = {
    ["cacheByItemId"] = { },
    ["cacheByName"]   = { },
    ["cacheBySpellId"] = { }
}
LM_Mount.__index = LM_Mount
function LM_Mount:new() return setmetatable({ }, LM_Mount) end

function LM_Mount:FixupFlags()
    -- Which fly/walk flagged mounts can mount in no-fly areas is arbitrary.
    if bit.band(self.flags, LM_FLAG_BIT_FLY) == LM_FLAG_BIT_FLY then
        self.flags = LM_FLAG_BIT_FLY
    end

    -- Most ground-only mounts are also flagged to swim
    -- XXX FIXME XXX
    local fws = bit.bor(LM_FLAG_BIT_FLY, LM_FLAG_BIT_RUN, LM_FLAG_BIT_SWIM)
    local ws = bit.bor(LM_FLAG_BIT_RUN, LM_FLAG_BIT_SWIM)
    if bit.band(self.flags, fws) == ws then
        self.flags = self.flags - LM_FLAG_BIT_SWIM
    end

    local flags = LM_FlagOverrideTable[self.spellId]
    if flags then
        self.flags = flags
    end

    if self.castTime == 0 then
        self.flags = bit.bor(self.flags, LM_FLAG_BIT_MOVING)
    end
end

function LM_Mount:GetMountByItem(itemId, spellId)

    if self.cacheByItemId[itemId] then
        return self.cacheByItemId[itemId]
    end

    local m = LM_Mount:GetMountBySpell(spellId)
    if not m then return end

    local ii = { GetItemInfo(itemId) }
    if not ii[1] then
        LM_Debug("LM_Mount: Failed GetItemInfo #"..itemId)
        return
    end

    m.itemId = itemId
    m.itemName = ii[1]

    self.cacheByItemId[itemId] = m

    return m
end

function LM_Mount:GetMountBySpell(spellId)

    if self.cacheBySpellId[spellId] then
        return self.cacheBySpellId[spellId]
    end

    local m = LM_Mount:new()
    local si = { GetSpellInfo(spellId) }

    if not si[1] then
        LM_Debug("LM_Mount: Failed GetMountBySpell #"..spellId)
        return
    end

    m.name = si[1]
    m.spellId = spellId
    m.spellName = si[1]
    m.icon = si[3]
    m.flags = 0
    m.castTime = si[7]
    m:FixupFlags()

    self.cacheByName[m.name] = m
    self.cacheBySpellId[m.spellId] = m

    return m
end

function LM_Mount:GetMountByIndex(mountIndex)
    local ci = { GetCompanionInfo("MOUNT", mountIndex) }

    if not ci[2] then
        LM_Debug(string.format("LM_Mount: Failed GetMountByIndex #%d (of %d)",
                               mountIndex, GetNumCompanions("MOUNT")))
        return
    end

    if self.cacheByName[ci[2]] then
        return self.cacheByName[ci[2]]
    end

    local m = LM_Mount:new()

    m.name = ci[2]
    m.spellId = ci[3]
    m.icon = ci[4]
    m.flags = ci[6]

    local si = { GetSpellInfo(m.spellId) }
    m.spellName = si[1]
    m.castTime = si[7]

    m:FixupFlags()

    self.cacheByName[m.name] = m
    self.cacheBySpellId[m.spellId] = m

    return m
end

function LM_Mount:SetFlags(f)
    self.flags = f
end

function LM_Mount:SpellId()
    return self.spellId
end

function LM_Mount:SpellName()
    return self.spellName
end

function LM_Mount:Icon()
    return self.icon
end

function LM_Mount:Name()
    return self.name
end

function LM_Mount:DefaultFlags()
    return self.flags
end

function LM_Mount:Flags()
    return LM_Options:ApplySpellFlags(self.spellId, self.flags)
end

function LM_Mount:CanFly()
    return bit.band(self:Flags(), LM_FLAG_BIT_FLY)
end

function LM_Mount:CanRun()
    return bit.band(self:Flags(), LM_FLAG_BIT_RUN)
end

function LM_Mount:CanWalk()
    return bit.band(self:Flags(), LM_FLAG_BIT_WALK)
end

function LM_Mount:CanFloat()
    return bit.band(self:Flags(), LM_FLAG_BIT_FLOAT)
end

function LM_Mount:CanSwim()
    return bit.band(self:Flags(), LM_FLAG_BIT_SWIM)
end

function LM_Mount:CastTime()
    return self.castTime
end

function LM_Mount:Usable()
    if self.itemId then
        return LM_MountItem:IsUsable(self.itemId)
    else
        return IsUsableSpell(self.spellId)
    end
end

function LM_Mount:SetupActionButton(button)
    if self.itemName then
        LM_Debug("LM_Mount setting button to item "..self.itemName)
        button:SetAttribute("type", "item")
        button:SetAttribute("item", self.itemName)
    else
        LM_Debug("LM_Mount setting button to spell "..self.spellName)
        button:SetAttribute("type", "spell")
        button:SetAttribute("spell", self.spellName)
    end
end

function LM_Mount:Dump()
    LM_Print(string.format("%s %d %02x (%02x)",
             self.name, self.spellId, self:Flags(), self.flags))
end
