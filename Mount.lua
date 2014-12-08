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

function LM_Mount:ClearTags()
    table.wipe(self.tags)
end

function LM_Mount:AddTags(...)
    for _,t in ipairs({...}) do
        self.tags[t] = true
    end
end

function LM_Mount:RemoveTags(...)
    for _,t in ipairs({...}) do
        self.tags[t] = nil
    end
end

function LM_Mount:HasTags(...)
    local rv = true
    for _,t in ipairs({...}) do
        rv  = rv and self.tags[t]
    end
    return rv
end

function LM_Mount:OverrideTags()
    local tags = LM_TagOverrideTable[self.spellId]
    if tags then
        self:ClearTags()
        self:AddTags(unpack(tags))
    end
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

function LM_Mount:GetMountBySpell(spellId)

    if self.cacheBySpellId[spellId] then
        return self.cacheBySpellId[spellId]
    end

    local m = LM_Mount:new()
    local spell_info = { GetSpellInfo(spellId) }

    if not spell_info[1] then
        LM_Debug("LM_Mount: Failed GetMountBySpell #"..spellId)
        return
    end

    m.name = spell_info[1]
    m.spellName = spell_info[1]
    m.icon = spell_info[3]
    m.flags = 0
    m.tags = { }
    m.castTime = spell_info[4]
    m.spellId = spell_info[7]
    m:OverrideFlags()

    self.cacheByName[m.name] = m
    self.cacheBySpellId[m.spellId] = m

    return m
end

function LM_Mount:GetMountByIndex(mountIndex)
    local mount_info = { C_MountJournal.GetMountInfo(mountIndex) }
    local mount_extra = { C_MountJournal.GetMountInfoExtra(mountIndex) }

    if not mount_info[1] then
        LM_Debug(string.format("LM_Mount: Failed GetMountInfo #%d (of %d)",
                               mountIndex, C_MountJournal:GetNumMounts()))
        return
    end

    -- Exclude mounts not collected
    if not mount_info[11] then return end

    -- Exclude faction-specific mounts
    -- mount_info[9] : 0 = Horde, 1 = Alliance.
    -- See MOUNT_FACTION_TEXTURES in Blizzard_PetJournal.lua and the
    -- PLAYER_FACTION_GROUP global. Some websites are wrong (at the
    -- time of writing) about this.
    if mount_info[8] and mount_info[9] then
        local playerFaction = UnitFactionGroup("player")
        if playerFaction ~= PLAYER_FACTION_GROUP[mount_info[9]] then
            LM_Debug(string.format("LM_Mount: "..mount_info[1].." not available to "..playerFaction.." #%d (of %d)",
                                   mountIndex, C_MountJournal:GetNumMounts()))
            return
        end
    end

    if self.cacheByName[mount_info[1]] then
        return self.cacheByName[mount_info[1]]
    end

    local m = LM_Mount:new()

    m.modelId       = mount_extra[1]
    m.name          = mount_info[1]
    m.spellId       = mount_info[2]
    m.icon          = mount_info[3]
    m.isSelfMount   = mount_extra[4]
    m.mountType     = mount_extra[5]
    m.tags          = { }

    LM_Debug("LM_Mount: mount type of "..m.name.." is "..m.mountType)

    -- This attempts to set the old-style flags on mounts based on their new-style "mount type"
    -- This list is almost certainly not complete, and may be mistaken in places
    -- list source: http://wowpedia.org/API_C_MountJournal.GetMountInfoExtra 20131015

    if m.mountType == 230 then -- ground mount
        m.flags = bit.bor(LM_FLAG_BIT_RUN)
        m:AddTags(LM_TAG_RUN)
    elseif m.mountType == 231 then -- riding/sea turtle
        m.flags = bit.bor(LM_FLAG_BIT_WALK, LM_FLAG_BIT_SWIM)
        m:AddTags(LM_TAG_SWIM, LM_TAG_WALK)
    elseif m.mountType == 232 then -- Vashj'ir Seahorse
        m.flags = bit.bor(LM_FLAG_BIT_VASHJIR)
        m:AddTags(LM_TAG_VASHJIR)
    elseif m.mountType == 241 then -- AQ-only bugs
        m.flags = bit.bor(LM_FLAG_BIT_AQ)
        m:AddTags(LM_TAG_AQ)
    elseif m.mountType == 247 then -- Red Flying Cloud
        m.flags = bit.bor(LM_FLAG_BIT_RUN, LM_FLAG_BIT_FLY)
        m:AddTags(LM_TAG_RUN, LM_TAG_FLY)
    elseif m.mountType == 248 then -- Flying mounts
        m.flags = bit.bor(LM_FLAG_BIT_FLY)
        m:AddTags(LM_TAG_FLY)
    elseif m.mountType == 254 then -- Subdued Seahorse
        m.flags = bit.bor(LM_FLAG_BIT_SWIM, LM_FLAG_BIT_VASHJIR)
        m:AddTags(LM_TAG_SWIM, LM_TAG_VASHJIR)
    elseif m.mountType == 269 then -- Water Striders
        m.flags = bit.bor(LM_FLAG_BIT_RUN, LM_FLAG_BIT_FLOAT)
        m:AddTags(LM_TAG_RUN, LM_TAG_WATERWALK)
    else
        m.flags = 0
    end
    LM_Debug("LM_Mount flags for "..m.name.." are ".. m.flags)

    local spell_info = { GetSpellInfo(m.spellId) }
    m.spellName = spell_info[1]
    m.castTime = spell_info[7]

    m:OverrideFlags()
    m:OverrideTags()

    self.cacheByName[m.name] = m
    self.cacheBySpellId[m.spellId] = m

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

function LM_Mount:DefaultFlags(v)
    if v then self.flags = v end
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

    if self.itemId then
        return LM_MountItem:IsUsable(self.itemId, flags)
    else
        return LM_MountSpell:IsUsable(self.spellId, flags)
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
