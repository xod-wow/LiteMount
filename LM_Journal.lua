--[[----------------------------------------------------------------------------

  LiteMount/LM_Journal.lua

  Information about a mount from the mount journal.

  Copyright 2011-2014 Mike Battersby

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
    local mount_info = { C_MountJournal.GetMountInfo(mountIndex) }
    local mount_extra = { C_MountJournal.GetMountInfoExtra(mountIndex) }

    if not mount_info[1] then
        LM_Debug(string.format("LM_Mount: Failed GetMountInfo #%d (of %d)",
                               mountIndex, C_MountJournal:GetNumMounts()))
        return
    end

    -- Exclude mounts not collected and ones Blizzard decide are hidden
    if mount_info[10] or not mount_info[11] then return end

    if self.cacheByName[mount_info[1]] then
        return self.cacheByName[mount_info[1]]
    end

    local m = setmetatable({ }, LM_Journal)

    m.journalIndex  = mountIndex
    m.modelId       = mount_extra[1]
    m.name          = mount_info[1]
    m.spellId       = mount_info[2]
    m.icon          = mount_info[3]
    m.isSelfMount   = mount_extra[4]
    m.mountType     = mount_extra[5]
    m.needsFaction  = PLAYER_FACTION_GROUP[mount_info[9]]

    -- LM_Debug("LM_Mount: mount type of "..m.name.." is "..m.mountType)

    -- This attempts to set the old-style flags on mounts based on their
    -- new-style "mount type". This list is almost certainly not complete,
    -- and may be mistaken in places. List source:
    --   http://wowpedia.org/API_C_MountJournal.GetMountInfoExtra

    if m.mountType == 230 then -- ground mount
        m.flags = bit.bor(LM_FLAG_BIT_RUN)
    elseif m.mountType == 231 then -- riding/sea turtle
        m.flags = bit.bor(LM_FLAG_BIT_WALK, LM_FLAG_BIT_SWIM)
    elseif m.mountType == 232 then -- Vashj'ir Seahorse
        m.flags = bit.bor(LM_FLAG_BIT_VASHJIR)
    elseif m.mountType == 241 then -- AQ-only bugs
        m.flags = bit.bor(LM_FLAG_BIT_AQ)
    elseif m.mountType == 247 then -- Red Flying Cloud
        m.flags = bit.bor(LM_FLAG_BIT_FLY)
    elseif m.mountType == 248 then -- Flying mounts
        m.flags = bit.bor(LM_FLAG_BIT_FLY)
    elseif m.mountType == 254 then -- Subdued Seahorse
        m.flags = bit.bor(LM_FLAG_BIT_SWIM, LM_FLAG_BIT_VASHJIR)
    elseif m.mountType == 269 then -- Water Striders
        m.flags = bit.bor(LM_FLAG_BIT_RUN, LM_FLAG_BIT_FLOAT)
    else
        m.flags = 0
    end
    -- LM_Debug("LM_Mount flags for "..m.name.." are ".. m.flags)

    local spell_info = { GetSpellInfo(m.spellId) }
    m.spellName = spell_info[1]
    m.castTime = spell_info[7]

    self.cacheByName[m.name] = m
    self.cacheBySpellId[m.spellId] = m

    return m
end
