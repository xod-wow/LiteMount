--[[----------------------------------------------------------------------------

  LiteMount/LM_Journal.lua

  Information about a mount from the mount journal.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell
local C_MountJournal = LM.C_MountJournal or C_MountJournal

LM.Journal = setmetatable({ }, LM.Mount)
LM.Journal.__index = LM.Journal

--  [1] name,
--  [2] spellID,
--  [3] icon,
--  [4] isActive,
--  [5] isUsable,
--  [6] sourceType,
--  [7] isFavorite,
--  [8] isFactionSpecific,
--  [9] faction,
-- [10] isFiltered,
-- [11] isCollected,
-- [12] mountID,
-- [13] isSteadyFlight = C_MountJournal.GetMountInfoByID(mountID)

--  [1] creatureDisplayInfoID,
--  [2] description,
--  [3] source,
--  [4] isSelfMount,
--  [5] mountTypeID,
--  [6] uiModelSceneID = C_MountJournal.GetMountInfoExtraByID(mountID)

function LM.Journal:Get(id)
    local name, spellID, icon, _, _, sourceType, _, _, faction, _, _, _, isSteadyFlight = C_MountJournal.GetMountInfoByID(id)
    local modelID, descriptionText, sourceText, isSelfMount, mountTypeID, sceneID = C_MountJournal.GetMountInfoExtraByID(id)

    if not name then
        LM.Debug("LM.Mount: Failed GetMountInfo for ID = #%d", id)
        return
    end

    local m = LM.Mount.new(self)

    m.modelID       = modelID
    m.sceneID       = sceneID
    m.name          = name
    m.spellID       = spellID
    m.mountID       = id
    m.icon          = icon
    m.isSelfMount   = isSelfMount
    m.mountTypeID   = mountTypeID
    m.description   = descriptionText
    m.sourceType    = sourceType
    m.sourceText    = sourceText
    m.isSteadyFlight= isSteadyFlight
    m.needsFaction  = PLAYER_FACTION_GROUP[faction]
    m.flags         = { }

    -- LM.Debug("LM.Mount: mount type of "..m.name.." is "..m.mountTypeID)

    -- This list is could be added to in the future by Blizzard. See:
    --   https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountInfoExtraByID
    --
    -- Numbers also need to be given names in SpellInfo.lua when new
    -- ones are added.

    local typeInfo = LM.MOUNT_TYPE_INFO[m.mountTypeID]
    if not typeInfo then
--@debug@
        LM.PrintError('Mount with unknown type number: %s = %d', m.name, m.mountTypeID)
--@end-debug@
    elseif typeInfo.skip then
        return
    else
        Mixin(m.flags, typeInfo.flags)
    end

    return m
end

function LM.Journal:GetFlags()
    local flags = LM.Mount.GetFlags(self)

    -- XXX FIXME XXX is this still required at all? If so it should be fixed
    -- Dynamic Kua'fon flags
    if self.mountTypeID == 398 then
        flags = CopyTable(flags)
        -- It seems like Alliance don't show the achievement as done but
        -- do flag the quest as completed.
        if C_QuestLog.IsQuestFlaggedCompleted(56205) then
            flags.FLY = true
        else
            flags.RUN = true
        end
    end

    return flags
end

function LM.Journal:IsMountable()
    local usable = select(5, C_MountJournal.GetMountInfoByID(self.mountID))
    return usable
end

-- This flag is set for the journal mounts in MountRegistry as it's not at all
-- dynamically queryable and overall just sucks.
function LM.Journal:IsUsable()
    return self.isUsable
end

function LM.Journal:IsCastable()
    local usable = select(5, C_MountJournal.GetMountInfoByID(self.mountID))
    if not usable then
        return false
    end
    if not C_Spell.IsSpellUsable(self.spellID) then
        return false
    end
    -- Tarecgosa workarounds for macro
    if self.mountID == 1727 and GetRunningMacro() ~= nil then
        if LM.Environment:IsCantSummonForm() then return false end
    end
    return LM.Mount.IsCastable(self)
end

function LM.Journal:IsFavorite()
    local isFavorite = select(7, C_MountJournal.GetMountInfoByID(self.mountID))
    return isFavorite
end

function LM.Journal:IsFiltered()
    local isFiltered = select(10, C_MountJournal.GetMountInfoByID(self.mountID))
    return isFiltered
end

function LM.Journal:IsCollected()
    local isCollected = select(11, C_MountJournal.GetMountInfoByID(self.mountID))
    return isCollected
end

-- This is a bit complicated.
--
-- Casting the spell is better than SummonByID in most ways, because it takes
-- advantages of all the auto-cancelling that spellcasts do.
--
-- You can't cast Tarecgosa's Visage (id = 1727) by casting the spell, who
-- knows why, so you have to summon by ID. It's not protected BUT it plain
-- doesn't work if you are in a druid form.
--
-- For keybind use we can cancelform and go, but CancelShapeshiftForm() is
-- protected call from a /click so from the macro Tarecgosa can't work.
--
-- I could maybe work around this by having the Execute happen in the PostClick
-- handler and setting the action to "cancelaura" and the form name, but that's
-- a lot of effort for 1 broken mount spell, one class and only via /click.

function LM.Journal:GetCastAction(context)
    if GetRunningMacro() ~= nil and self.mountID == 1727 then
        -- This relies on not getting here if in a druid form
        return LM.SecureAction:Execute(function () C_MountJournal.SummonByID(self.mountID) end)
    end

    local castActions

    if self.mountID == 1727 then
        castActions = { format("/run C_MountJournal.SummonByID(%d)", self.mountID) }
        if LM.Environment:IsCantSummonForm() then
            table.insert(castActions, 1, "/cancelform")
        end
    end

    if context and context.preCast then
        castActions = castActions or { "/cast " .. C_Spell.GetSpellName(self.spellID) }
        table.insert(castActions, 1, "/cast [@player] " .. context.preCast)
    end

    if castActions and GetRunningMacro() == nil then
        return LM.SecureAction:Macro(table.concat(castActions, "\n"))
    else
        return LM.Mount.GetCastAction(self, context)
    end
end

function LM.Journal:Dump(prefix)
    prefix = prefix or ""
    LM.Mount.Dump(self, prefix)
    LM.Print(prefix .. " isUsable: " .. tostring(self.isUsable))
    LM.Print(prefix .. " mountTypeID: " .. tostring(self.mountTypeID))
    LM.Print(prefix .. " sourceType: " .. tostring(self.sourceType))
end
