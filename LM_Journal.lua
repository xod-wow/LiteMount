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

function LM.Journal:Get(id)
    local mountInfo = LM.MountInfo.GetMountInfoByMountID(id)
    if not mountInfo then
        LM.Debug("LM.Mount: Failed GetMountInfo for ID = #%d", id)
        return
    end

    local m = LM.Mount.new(self)
    Mixin(m, mountInfo)

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

function LM.Journal:GetCastAction(context)
    local castActions

    if self.castActions then
        castActions = CopyTable(self.castActions)
    elseif self.mountID == 1727 then
        -- You can't cast Tarecgosa's Visage by name. But you also can't always SummonByID
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
