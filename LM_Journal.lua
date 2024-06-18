--[[----------------------------------------------------------------------------

  LiteMount/LM_Journal.lua

  Information about a mount from the mount journal.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

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
-- [13] isForDragonriding = C_MountJournal.GetMountInfoByID(mountID)

--  [1] creatureDisplayInfoID,
--  [2] description,
--  [3] source,
--  [4] isSelfMount,
--  [5] mountTypeID,
--  [6] uiModelSceneID = C_MountJournal.GetMountInfoExtraByID(mountID)

function LM.Journal:Get(id)
    local name, spellID, icon, _, _, sourceType, _, _, faction, _, _, mountID, dragonRiding = C_MountJournal.GetMountInfoByID(id)
    local modelID, descriptionText, sourceText, isSelfMount, mountTypeID, sceneID = C_MountJournal.GetMountInfoExtraByID(mountID)

    if not name then
        LM.Debug("LM.Mount: Failed GetMountInfo for ID = #%d", id)
        return
    end

    local m = LM.Mount.new(self)

    m.modelID       = modelID
    m.sceneID       = sceneID
    m.name          = name
    m.spellID       = spellID
    m.mountID       = mountID
    m.icon          = icon
    m.isSelfMount   = isSelfMount
    m.mountTypeID   = mountTypeID
    m.description   = descriptionText
    m.sourceType    = sourceType
    m.sourceText    = sourceText
    m.dragonRiding  = dragonRiding
    m.needsFaction  = PLAYER_FACTION_GROUP[faction]
    m.flags         = { }

    -- LM.Debug("LM.Mount: mount type of "..m.name.." is "..m.mountTypeID)

    -- This list is could be added to in the future by Blizzard. See:
    --   http://wowpedia.org/API_C_MountJournal.GetMountInfoExtraByID
    --
    -- Numbers also need to be given names in SpellInfo.lua when new
    -- ones are added.

    if m.mountTypeID == 225 then          -- Cataclysm Classic: Spectral Steed/Wolf
        m.flags['RUN'] = true
    elseif m.mountTypeID == 229 then      -- Cataclysm Classic: Drakes
        m.flags['FLY'] = true
        -- m.mountTypeID = 248
    elseif m.mountTypeID == 230 then      -- ground mount
        m.flags['RUN'] = true
    elseif m.mountTypeID == 231 then      -- riding/sea turtle
        m.flags['SWIM'] = true
    elseif m.mountTypeID == 232 then      -- Vashj'ir Seahorse
        -- no flags
    elseif m.mountTypeID == 238 then      -- Cataclysm Classic: Drakes (2)
        m.flags['FLY'] = true
        -- m.mountTypeID = 248
    elseif m.mountTypeID == 241 then      -- AQ-only bugs
        -- no flags
    elseif m.mountTypeID == 254 then      -- Swimming only mounts
        m.flags['SWIM'] = true
    elseif m.mountTypeID == 284 then      -- Chauffeured Mekgineer's Chopper
        m.flags['RUN'] = true
        m.flags['SLOW'] = true
    elseif m.mountTypeID == 402 then      -- Original DF Dragonriding mounts
        m.flags['FLY'] = true
        m.flags['DRAGONRIDING'] = true
    elseif m.mountTypeID == 407 then      -- Flying + Aquatic
        -- Can't dragonride (at least for now)
        m.flags['FLY'] = true
        m.flags['SWIM'] = true
    elseif m.mountTypeID == 408 then      -- Unsuccessful Prototype Fleetpod
        m.flags['RUN'] = true
        m.flags['SLOW'] = true
    elseif m.mountTypeID == 412 then      -- Ground + Aquatic (Ottuk etc.)
        m.flags['RUN'] = true
        m.flags['SWIM'] = true
    elseif m.mountTypeID == 424 then      -- Flying + Dragonriding Drake
        m.flags['FLY'] = true
        m.flags['DRAGONRIDING'] = true
    elseif m.mountTypeID == 436 then      -- Flying + Aquatic + Dragonriding
        m.flags['FLY'] = true
        m.flags['DRAGONRIDING'] = true
    elseif m.mountTypeID == 437 then      -- Flying discs
        m.flags['FLY'] = true
        m.flags['DRAGONRIDING'] = true
    elseif m.mountTypeID == 398 then      -- Used to be Kua'fon
        -- Kua'fon can fly if achievement 13573 is completed, otherwise run
        return
    elseif m.mountTypeID == 242 then      -- Flyers for when dead in some zones
        return
    elseif m.mountTypeID == 247 then      -- Used to be Red Flying Cloud
        return
    elseif m.mountTypeID == 248 then      -- Was flying mounts
        return
    elseif m.mountTypeID == 430 then      -- Whelpling, what on earth is this: ABORT
        return
    elseif m.mountTypeID == 411 then      -- Used to be Whelpling
        return
    elseif m.mountTypeID == 426 then      -- Used to be Dragonriding copies for races
        return
    elseif m.mountTypeID == 428 then      -- Used to be Flying + Dragonriding Protodrake
        return
    elseif m.mountTypeID == 429 then      -- Used to be Flying + Dragonriding Roc/Pterrodax
        return
    elseif m.mountTypeID == 442 then      -- Soar, now a journal mount but useless?
        return
--@debug@
    else
        LM.PrintError('Mount with unknown type number: %s = %d', m.name, m.mountTypeID)
--@end-debug@
    end

    -- Aquatic Shades for Otto. This should probably be moved off somewhere
    -- else and made more generic.
    if m.mountID == 1656 then
        m.castActions = {}
         local item = Item:CreateFromItemID(202042)
         item:ContinueOnItemLoad(
            function ()
                m.castActions[1] = "/use " .. item:GetItemName()
            end)
        local spell = Spell:CreateFromSpellID(m.spellID)
        spell:ContinueOnSpellLoad(
            function ()
                m.castActions[2] = "/cast " .. spell:GetSpellName()
            end)
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

    if castActions then
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
