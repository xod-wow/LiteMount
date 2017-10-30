--[[----------------------------------------------------------------------------

  LiteMount/LM_Journal.lua

  Information about a mount from the mount journal.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

_G.LM_Journal = setmetatable({ }, LM_Mount)
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
-- [10] isFiltered,
-- [11] isCollected,
-- [12] mountID = C_MountJournal.GetMountInfoByID(mountID)

--  [1] creatureDisplayID,
--  [2] descriptionText,
--  [3] sourceText,
--  [4] isSelfMount,
--  [5] mountType = C_MountJournal.GetMountInfoExtraByID(mountID)

function LM_Journal:Get(id)
    local name, spellID, icon, _, _, _, _, _, faction, isFiltered, isCollected, mountID = C_MountJournal.GetMountInfoByID(id)
    local modelID, _, _, isSelfMount, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)

    if not name then
        LM_Debug(format("LM_Mount: Failed GetMountInfo for ID = #%d", id))
        return
    end

    local m = LM_Mount.new(self)

    m.modelID       = modelID
    m.name          = name
    m.spellID       = spellID
    m.mountID       = mountID
    m.icon          = icon
    m.isSelfMount   = isSelfMount
    m.mountType     = mountType
    m.isFiltered    = isFiltered
    m.isCollected   = isCollected
    m.needsFaction  = PLAYER_FACTION_GROUP[faction]
    m.flags         = { }

    -- LM_Debug("LM_Mount: mount type of "..m.name.." is "..m.mountType)

    -- This attempts to set the old-style flags on mounts based on their
    -- new-style "mount type". This list is almost certainly not complete,
    -- and may be mistaken in places. List source:
    --   http://wowpedia.org/API_C_MountJournal.GetMountInfoExtra

    if m.mountType == 230 then          -- ground mount
        m.flags['RUN'] = true
    elseif m.mountType == 231 then      -- riding/sea turtle
        m.flags['SWIM'] = true
    elseif m.mountType == 232 then      -- Vashj'ir Seahorse
        m.flags['VASHJIR'] = true
    elseif m.mountType == 241 then      -- AQ-only bugs
        m.flags['AQ'] = true
    elseif m.mountType == 247 then      -- Red Flying Cloud
        m.flags['FLY'] = true
    elseif m.mountType == 248 then      -- Flying mounts
        m.flags['FLY'] = true
    elseif m.mountType == 254 then      -- Swimming only mounts
        m.flags['SWIM'] = true
    elseif m.mountType == 269 then      -- Water Striders (floating)
        m.flags['RUN'] = true
        m.flags['FLOAT'] = true
    elseif m.mountType == 284 then      -- Chauffeured Mekgineer's Chopper
        m.flags['WALK'] = true
    end

    return m
end

function LM_Journal:Refresh()
    local isFiltered, isCollected = select(10, C_MountJournal.GetMountInfoByID(self.mountID))
    self.isFiltered = isFiltered
    self.isCollected = isCollected
end

function LM_Journal:IsCastable()
    local usable = select(5, C_MountJournal.GetMountInfoByID(self.mountID))
    if not usable then
        return false
    end
    if not IsUsableSpell(self.spellID) then
        return false
    end
    return LM_Mount.IsCastable(self)
end

-- Note, at some point we needed to use type=macro and
-- /run C_MountJournal.SummonByID(%d)
-- in a custom SetupActionButton, but now don't again, phew.
