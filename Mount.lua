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
LM_Mount.__eq = function (a,b) return a:Name() == b:Name() end
LM_Mount.__lt = function (a,b) return a:Name() < b:Name() end

function LM_Mount:new()
    return setmetatable({ }, LM_Mount)
end

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
    m.castTime = si[4]
    m:FixupFlags()

    self.cacheByName[m.name] = m
    self.cacheBySpellId[m.spellId] = m

    return m
end

function LM_Mount:GetMountByIndex(mountIndex)
    local ci = { C_MountJournal.GetMountInfo(mountIndex) }
    local ce = { C_MountJournal.GetMountInfoExtra(mountIndex) }

    if not ci[1] then
        LM_Debug(string.format("LM_Mount: Failed GetMountInfo #%d (of %d)",
                               mountIndex, C_MountJournal:GetNumMounts()))
        return
    end

    if not ci[11] then
        -- mount not collected
        LM_Debug(string.format("LM_Mount: Mount " .. ci[1] .. " not collected #%d (of %d)",
                               mountIndex, C_MountJournal:GetNumMounts()))
        return
    end

    if self.cacheByName[ci[1]] then
        return self.cacheByName[ci[1]]
    end

    local m = LM_Mount:new()

    m.modelId   = ce[1]
    m.name      = ci[1]
    m.spellId   = ci[2]
    m.icon      = ci[3]

    local mountType = ce[5]
    LM_Debug("LM_Mount: mount type of "..m.name.." is "..mountType)

    -- This attempts to set the old-style flags on mounts based on their new-style "mount type"
    -- This list is almost certainly not complete
    -- list source: http://wowpedia.org/API_C_MountJournal.GetMountInfoExtra 20131015

    if mountType == 230 then -- ground mount
        m.flags = bit.bor(LM_FLAG_BIT_RUN, LM_FLAG_BIT_FLOAT, LM_FLAG_BIT_SWIM, LM_FLAG_BIT_JUMP)
    elseif mountType == 231 then -- riding/sea turtle
        m.flags = bit.bor(LM_FLAG_BIT_WALK, LM_FLAG_BIT_FLOAT, LM_FLAG_BIT_SWIM)
    elseif mountType == 232 then -- Vashj'ir Seahorse
        m.flags = bit.bor(LM_FLAG_BIT_VASHJIR)
    elseif mountType == 241 then -- AQ-only bugs
        m.flags = bit.bor(LM_FLAG_BIT_AQ)
    elseif mountType == 242 then -- Swift Spectral Gryphon
        m.flags = bit.bor(LM_FLAG_BIT_RUN, LM_FLAG_BIT_FLY, LM_FLAG_BIT_FLOAT, LM_FLAG_BIT_SWIM, LM_FLAG_BIT_JUMP)
    elseif mountType == 247 then -- Red Flying Cloud
        m.flags = bit.bor(LM_FLAG_BIT_RUN, LM_FLAG_BIT_FLY, LM_FLAG_BIT_FLOAT, LM_FLAG_BIT_JUMP)
    elseif mountType == 248 then -- flying mounts
        m.flags = bit.bor(LM_FLAG_BIT_RUN, LM_FLAG_BIT_FLY, LM_FLAG_BIT_FLOAT, LM_FLAG_BIT_SWIM, LM_FLAG_BIT_JUMP)
    elseif mountType == 254 then -- Subdued Seahorse
        m.flags = bit.bor(LM_FLAG_BIT_SWIM)
    elseif mountType == 269 then -- Water Striders
        m.flags = bit.bor(LM_FLAG_BIT_WALK, LM_FLAG_BIT_FLOAT, LM_FLAG_BIT_SWIM)
    else
        m.flags = bit.bor(LM_FLAG_BIT_RUN, LM_FLAG_BIT_FLY, LM_FLAG_BIT_FLOAT, LM_FLAG_BIT_SWIM, LM_FLAG_BIT_JUMP)
    end
    LM_Debug("LM_Mount flags for "..m.name.." are "..m.flags)

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

function LM_Mount:ItemId()
    return self.itemId
end

function LM_Mount:ModelId()
    return self.modelId
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

function LM_Mount:IsUsable()

    if GetUnitSpeed("player") > 0 or IsFalling() then
        if self:CastTime() > 0 then return end
    end

    if self.itemId then
        return LM_MountItem:IsUsable(self.itemId)
    else
        return LM_MountSpell:IsUsable(self.spellId)
    end
end

function LM_Mount:IsExcluded()
    return LM_Options:IsExcludedSpell(self.spellId)
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
             self.name, self.spellId, self:Flags(), self:DefaultFlags()))
end
