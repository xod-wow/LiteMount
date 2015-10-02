--[[----------------------------------------------------------------------------

  LiteMount/LM_Journal.lua

  Information about a mount from the mount journal.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Journal = setmetatable({ }, LM_Mount)
LM_Journal.__index = LM_Journal

--  [1] creatureName,
--  [2] spellID,
--  [3] icon,
--  [4] active,
--  [5] isUsable,
--  [6] sourceType,
--  [7] isFavorite,
--  [8] isFactionSpecific,
--  [9] faction,
-- [10] hideOnChar,
-- [11] isCollected = C_MountJournal.GetMountInfo(index)

--  [1]creatureDisplayID,
--  [2]descriptionText,
--  [3]sourceText,
--  [4]isSelfMount,
--  [5]mountType = C_MountJournal.GetMountInfoExtra(index)

function LM_Journal:Get(mountIndex)
    local name, spellId, icon, _, _, _, _, _, faction, hideOnChar, isCollected = C_MountJournal.GetMountInfo(mountIndex)
    local modelId, _, _, isSelfMount, mountType = C_MountJournal.GetMountInfoExtra(mountIndex)

    if not name then
        LM_Debug(format("LM_Mount: Failed GetMountInfo #%d (of %d)",
                        mountIndex, C_MountJournal:GetNumMounts()))
        return
    end

    -- Exclude mounts not collected and ones Blizzard decide are hidden
    if hideOnChar or not isCollected then return end

    if self.cacheByName[name] then
        return self.cacheByName[name]
    end

    local m = setmetatable({ }, LM_Journal)

    m.journalIndex  = mountIndex
    m.modelId       = modelId
    m.name          = name
    m.spellId       = spellId
    m.icon          = icon
    m.isSelfMount   = isSelfMount
    m.mountType     = mountType
    m.needsFaction  = PLAYER_FACTION_GROUP[faction]

    -- LM_Debug("LM_Mount: mount type of "..m.name.." is "..m.mountType)

    -- This attempts to set the old-style flags on mounts based on their
    -- new-style "mount type". This list is almost certainly not complete,
    -- and may be mistaken in places. List source:
    --   http://wowpedia.org/API_C_MountJournal.GetMountInfoExtra

    if m:Type() == 230 then -- ground mount
        m.flags = bit.bor(LM_FLAG_BIT_RUN)
    elseif m:Type() == 231 then -- riding/sea turtle
        m.flags = bit.bor(LM_FLAG_BIT_WALK)
    elseif m:Type() == 232 then -- Vashj'ir Seahorse
        m.flags = bit.bor(LM_FLAG_BIT_VASHJIR)
    elseif m:Type() == 241 then -- AQ-only bugs
        m.flags = bit.bor(LM_FLAG_BIT_AQ)
    elseif m:Type() == 247 then -- Red Flying Cloud
        m.flags = bit.bor(LM_FLAG_BIT_FLY)
    elseif m:Type() == 248 then -- Flying mounts
        m.flags = bit.bor(LM_FLAG_BIT_FLY)
    elseif m:Type() == 254 then -- Subdued Seahorse
        m.flags = bit.bor(LM_FLAG_BIT_SWIM, LM_FLAG_BIT_VASHJIR)
    elseif m:Type() == 269 then -- Water Striders
        m.flags = bit.bor(LM_FLAG_BIT_RUN, LM_FLAG_BIT_SWIM, LM_FLAG_BIT_FLOAT)
    elseif m:Type() == 284 then -- Chauffeured Mekgineer's Chopper
        m.flags = bit.bor(LM_FLAG_BIT_WALK)
    else
        m.flags = 0
    end
    -- LM_Debug("LM_Mount flags for "..m.name.." are ".. m.flags)

    local spellName, _, _, _, _, _, castTime = GetSpellInfo(m.spellId)
    m.spellName = spellName
    m.castTime = castTime

    self.cacheByName[m:Name()] = m
    self.cacheBySpellId[m:SpellId()] = m

    return m
end

function LM_Journal:IsUsable(flags)
    local usable = select(5, C_MountJournal.GetMountInfo(self:JournalIndex()))
    if not usable then return end
    if not IsUsableSpell(self:SpellId()) then return end
    return LM_Mount.IsUsable(self, flags)
end
