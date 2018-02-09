--[[----------------------------------------------------------------------------

  LiteMount/LM_Journal.lua

  Information about a mount from the mount journal.

  Copyright 2011-2018 Mike Battersby

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
    local name, spellID, icon, _, _, sourceType, isFavorite, _, faction, isFiltered, isCollected, mountID = C_MountJournal.GetMountInfoByID(id)
    local modelID, _, sourceText, isSelfMount, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)

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
    m.sourceType    = sourceType
    m.sourceText    = sourceText
    m.isFavorite    = isFavorite
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
    local isFavorite, _, _, isFiltered, isCollected = select(7, C_MountJournal.GetMountInfoByID(self.mountID))
    self.isFavorite = isFavorite
    self.isFiltered = isFiltered
    self.isCollected = isCollected
    LM_Mount.Refresh(self)
end

local BlizzardFilterSettings = {
    LE_MOUNT_JOURNAL_FILTER_COLLECTED,
    LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED,
    LE_MOUNT_JOURNAL_FILTER_UNUSABLE,
}

--
-- In an ideal world this would be a one-liner:
--
--      C_MountJournal.SetIsFavoriteByID(id, setting)
--
-- but you can only set favorites on displayed journal mounts by index. That
-- means we have to clear all the filters, find the index, favorite, and try
-- to set the filters back the way they were. Yuck.
--

function LM_Journal:SetFavorite(setting)
    local SavedCollectedFilters = { }
    local SavedSourceFilters = { }

    -- Evil, but try not to be too evil saving what we can and restoring it
    -- This is almost certainly going to break in future patches.

    local SavedSearchText = MountJournal.searchBox:GetText()
    C_MountJournal.SetSearch("")

    for _,f in ipairs(BlizzardFilterSettings) do
        SavedCollectedFilters[f] = C_MountJournal.GetCollectedFilterSetting(f)
        C_MountJournal.SetCollectedFilterSetting(f, true)
    end
    for i=1,C_PetJournal.GetNumPetSources() do
        if C_MountJournal.IsValidSourceFilter(i) then
            SavedSourceFilters[i] = C_MountJournal.IsSourceChecked(i)
            C_MountJournal.SetSourceFilter(i, true)
        end
    end

    local id
    for i = 1, C_MountJournal.GetNumDisplayedMounts() do
        id = select(12, C_MountJournal.GetDisplayedMountInfo(i))
        if id == self.mountID then
            C_MountJournal.SetIsFavorite(i, setting)
            break
        end
    end
    self:Refresh()

    -- Restore saved settings
    C_MountJournal.SetSearch(SavedSearchText or "")
    for f,v in pairs(SavedCollectedFilters) do
        C_MountJournal.SetCollectedFilterSetting(f, v)
    end
    for i,v in pairs(SavedSourceFilters) do
        C_MountJournal.SetSourceFilter(i, v)
    end

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

function LM_Journal:Dump(prefix)
    prefix = prefix or ""
    LM_Mount.Dump(self, prefix)
    LM_Print(prefix .. " mountType: " .. tostring(self.mountType))
    LM_Print(prefix .. " sourceType: " .. tostring(self.sourceType))
end
