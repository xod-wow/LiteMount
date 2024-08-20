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
-- advantage of all the auto-cancelling that spellcasts do.
--
-- Reworked to never use macro so we can do preUse and preCast even with /click.
--
-- Could return functioning of preUse/preCast + cancelform + journal mount using
-- a macro only from the keybind, but it's probably nicer if everything behaves
-- the same.

local NeedsCancelFormIDs = {
    [1] = true,     -- Cat
    [3] = true,     -- Bear
    [5] = true,     -- Mount
    [8] = true,     -- Bear (Classic)
    [36] = true,    -- Treant
}

function LM.Journal:GetCastAction(context)
    local forceSummonByID = false

    -- Can't cast Tarecgosa's Visage (id 1727) by casting the spell, who knows why.
    if self.mountID == 1727 then
        forceSummonByID = true
    end

    -- Summon Charger and Summon Warhorse are busted on Cata Classic, though
    -- weirdly Summon (Great) Exarch's Elekk and Summon (Great) Sunwalker Kodo
    -- work fine.
    if WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
        if self.mountID == 41 or self.mountID == 84 then
            forceSummonByID = true
        end
    end

    local summonFunc = function () C_MountJournal.SummonByID(self.mountID) end

    -- C_MountJournal.SummonByID is completely blocked by some druid forms
    -- which need to be cancelled. Unfortunately this overrides preX but can't
    -- do anything about it.

    local druidFormID, druidFormSpellInfo = LM.Environment:GetDruidForm()
    local needsCancelForm = NeedsCancelFormIDs[druidFormID]

    if context and context.preCast and not needsCancelForm then
        local act = LM.SecureAction:Spell(context.preCast)
        act:AddExecute(summonFunc)
        return act
    end

    if context and context.preUse and not needsCancelForm then
        local act = LM.SecureAction:Item(context.preUse)
        act:AddExecute(summonFunc)
        return act
    end

    if forceSummonByID then
        local act
        if needsCancelForm then
            act = LM.SecureAction:CancelAura(druidFormSpellInfo.name)
        else
            act = LM.SecureAction:NoAction()
        end
        act:AddExecute(summonFunc)
        return act
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
