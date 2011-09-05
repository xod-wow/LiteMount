--[[----------------------------------------------------------------------------

  LiteMount/Mount.lua

  Information about one mount.

----------------------------------------------------------------------------]]--

LM_Mount = {
    ["CacheByItemId"] = { },
    ["CacheByName"]   = { },
    ["CacheBySpellId"] = { }
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
    local fws = bit.bor(LM_FLAG_BIT_FLY, LM_FLAG_BIT_WALK, LM_FLAG_BIT_SWIM)
    local ws = bit.bor(LM_FLAG_BIT_WALK, LM_FLAG_BIT_SWIM)
    if bit.band(self.flags, fws) == ws then
        self.flags = self.flags - LM_FLAG_BIT_SWIM
    end

    local flags = LM_FlagOverrideTable[self.spellid]
    if flags then
        self.flags = flags
    end

    if self.casttime == 0 then
        self.flags = bit.bor(self.flags, LM_FLAG_BIT_MOVING)
    end
end

function LM_Mount:GetMountByItem(itemId)

    if self.CacheByItemId[itemId] then
        return self.CacheByItemId[itemId]
    end

    local m = LM_Mount:new()

    local ii = { GetItemInfo(itemId) }
    if not ii[1] then
        LM_Debug("LM_Mount: Failed GetItemInfo #"..itemId)
        return
    end

    m.itemid = itemId
    m.itemname = ii[1]

    m.spellname = GetItemSpell(itemId)
    if not m.spellname then
        LM_Debug("LM_Mount: Failed GetItemSpell #"..itemId)
        return
    end

    local link = GetSpellLink(m.spellname)
    if not link then
        LM_Debug("LM_Mount: Failed GetSpellLink "..m.spellname)
        return
    end

    -- At the moment excluding only works off spell ID. Usable items
    -- do have spell IDs, but they're hard to get at.
    m.spellid = string.find(link, "|Hspell:(%d+)|h")
    if not m.spellid then
        LM_Debug("LM_Mount: finding spell ID from link failed "..link)
        return
    end

    local si = { GetSpellInfo(m.spellid) }
    if not si[1] then
        LM_Debug("LM_Mount: Failed GetSpellInfo #"..m.spellid)
        return
    end

    m.name = si[1]
    m.icon = si[3]
    m.flags = 0
    m.casttime = si[7]
    m:FixupFlags()
    m.defaultflags = m.flags

    self.CacheByItemId[itemId] = m
    self.CacheByName[m.name] = m
    self.CacheBySpellId[m.spellid] = m

    return m
end

function LM_Mount:GetMountBySpell(spellId)

    if self.CacheBySpellId[spellId] then
        return self.CacheBySpellId[spellId]
    end

    local m = LM_Mount:new()
    local si = { GetSpellInfo(spellId) }

    if not si[1] then
        LM_Debug("LM_Mount: Failed GetMountBySpell #"..spellId)
        return
    end

    m.name = si[1]
    m.spellid = spellId
    m.spellname = si[1]
    m.icon = si[3]
    m.flags = 0
    m.casttime = si[7]
    m:FixupFlags()
    m.defaultflags = m.flags

    self.CacheByName[m.name] = m
    self.CacheBySpellId[m.spellid] = m

    return m
end

function LM_Mount:GetMountByIndex(mountIndex)
    local ci = { GetCompanionInfo("MOUNT", mountIndex) }

    if not ci[2] then
        LM_Debug(string.format("LM_Mount: Failed GetMountByIndex #%d (of %d)",
                               mountIndex, GetNumCompanions("MOUNT")))
        return
    end

    if self.CacheByName[ci[2]] then
        return self.CacheByName[ci[2]]
    end

    local m = LM_Mount:new()

    m.name = ci[2]
    m.spellid = ci[3]
    m.icon = ci[4]
    m.flags = ci[6]

    local si = { GetSpellInfo(m.spellid) }
    m.spellname = si[1]
    m.casttime = si[7]

    m:FixupFlags()
    m.defaultflags = m.flags

    self.CacheByName[m.name] = m
    self.CacheBySpellId[m.spellid] = m

    return m
end

function LM_Mount:SetFlags(f)
    self.flags = f
end

function LM_Mount:SpellId()
    return self.spellid
end

function LM_Mount:SpellName()
    return self.spellname
end

function LM_Mount:Icon()
    return self.icon
end

function LM_Mount:Name()
    return self.name
end

function LM_Mount:DefaultFlags()
    return self.defaultflags
end

function LM_Mount:Flags()
    return self.flags
end

function LM_Mount:CanFly()
    return bit.band(self.flags, LM_FLAG_BIT_FLY)
end

function LM_Mount:CanWalk()
    return bit.band(self.flags, LM_FLAG_BIT_WALK)
end

function LM_Mount:CanSlowWalk()
    return bit.band(self.flags, LM_FLAG_BIT_SLOWWALK)
end

function LM_Mount:CanFloat()
    return bit.band(self.flags, LM_FLAG_BIT_FLOAT)
end

function LM_Mount:CanSwim()
    return bit.band(self.flags, LM_FLAG_BIT_SWIM)
end

function LM_Mount:CastTime()
    return self.casttime
end

function LM_Mount:Usable()
    if self.itemid then
        return LM_MountItem:IsUsable(self.itemid)
    else
        return IsUsableSpell(self.spellid)
    end
end

function LM_Mount:SetupActionButton(button)
    if self.itemname then
        LM_Debug("LM_Mount setting button to item "..self.itemname)
        button:SetAttribute("type", "item")
        button:SetAttribute("item", self.itemname)
    else
        LM_Debug("LM_Mount setting button to spell "..self.spellname)
        button:SetAttribute("type", "spell")
        button:SetAttribute("spell", self.spellname)
    end
end

function LM_Mount:Dump()
    LM_Print(string.format("%s %d %02x", self.name, self.spellid, self.flags))
end
