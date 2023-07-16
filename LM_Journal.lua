--[[----------------------------------------------------------------------------

  LiteMount/LM_Journal.lua

  Information about a mount from the mount journal.

  Copyright 2011-2021 Mike Battersby

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
-- [13] isForDragonRiding = C_MountJournal.GetMountInfoByID(mountID)

--  [1] creatureDisplayInfoID,
--  [2] description,
--  [3] source,
--  [4] isSelfMount,
--  [5] mountTypeID,
--  [6] uiModelSceneID = C_MountJournal.GetMountInfoExtraByID(mountID)

function LM.Journal:Get(id, isUsable)
    local name, spellID, icon, _, _, sourceType, isFavorite, _, faction, isFiltered, isCollected, mountID, dragonRiding = C_MountJournal.GetMountInfoByID(id)
    local modelID, descriptionText, sourceText, isSelfMount, mountTypeID, sceneID = C_MountJournal.GetMountInfoExtraByID(mountID)

    if not name then
        LM.Debug(format("LM.Mount: Failed GetMountInfo for ID = #%d", id))
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
    m.isFavorite    = isFavorite
    m.isFiltered    = isFiltered
    m.isCollected   = isCollected
    m.isUsable      = isFiltered == false and isUsable == true
    m.dragonRiding  = dragonRiding
    m.needsFaction  = PLAYER_FACTION_GROUP[faction]
    m.flags         = { }

    -- LM.Debug("LM.Mount: mount type of "..m.name.." is "..m.mountTypeID)

    -- This list is could be added to in the future by Blizzard. See:
    --   http://wowpedia.org/API_C_MountJournal.GetMountInfoExtraByID
    --
    -- Numbers also need to be given names in SpellInfo.lua when new
    -- ones are added.

    if m.mountTypeID == 230 then          -- ground mount
        m.flags['RUN'] = true
    elseif m.mountTypeID == 231 then      -- riding/sea turtle
        m.flags['SWIM'] = true
    elseif m.mountTypeID == 232 then      -- Vashj'ir Seahorse
        -- no flags
    elseif m.mountTypeID == 241 then      -- AQ-only bugs
        -- no flags
    elseif m.mountTypeID == 242 then      -- Flyers for when dead in some zones
        m.flags['FLY'] = true
    elseif m.mountTypeID == 247 then      -- Red Flying Cloud
        m.flags['FLY'] = true
    elseif m.mountTypeID == 248 then      -- Flying mounts
        m.flags['FLY'] = true
    elseif m.mountTypeID == 254 then      -- Swimming only mounts
        m.flags['SWIM'] = true
    elseif m.mountTypeID == 284 then      -- Chauffeured Mekgineer's Chopper
        m.flags['RUN'] = true
        m.flags['SLOW'] = true
    elseif m.mountTypeID == 398 then      -- Kua'fon
        -- Kua'fon can fly if achievement 13573 is completed, otherwise run
    elseif m.mountTypeID == 402 then      -- Dragonriding
        m.flags['DRAGONRIDING'] = true
    elseif m.mountTypeID == 407 then      -- Flying + Aquatic (Aurelid etc.)
        m.flags['FLY'] = true
        m.flags['SWIM'] = true
    elseif m.mountTypeID == 408 then      -- Unsuccessful Prototype Fleetpod
        m.flags['RUN'] = true
        m.flags['SLOW'] = true
    elseif m.mountTypeID == 411 then      -- Whelpling, what on earth is this: ABORT
        return
    elseif m.mountTypeID == 412 then      -- Ground + Aquatic (Ottuk etc.)
        m.flags['RUN'] = true
        m.flags['SWIM'] = true
    elseif m.mountTypeID == 424 then      -- Flying + Dragonriding Drake
        m.flags['FLY'] = true
        m.mountTypeID = 248
    elseif m.mountTypeID == 426 then      -- Dragonriding copies for Azeroth comp: ABORT
        return
    elseif m.mountTypeID == 428 then      -- Flying + Dragonriding Protodrake
        m.flags['FLY'] = true
        m.mountTypeID = 248
    elseif m.mountTypeID == 429 then      -- Flying + Dragonriding Roc/Pterrodax
        m.flags['FLY'] = true
        m.mountTypeID = 248
    elseif m.mountTypeID == 430 then      -- Literally only "Temp" right now: ABORT
        return
--@debug@
    else
        LM.PrintError(string.format('Mount with unknown type number: %s = %d', m.name, m.mountTypeID))
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

function LM.Journal:Refresh()
    local isFavorite, _, _, isFiltered, isCollected = select(7, C_MountJournal.GetMountInfoByID(self.mountID))
    self.isFavorite = isFavorite
    self.isFiltered = isFiltered
    self.isCollected = isCollected
    LM.Mount.Refresh(self)
end

function LM.Journal:IsCastable()
    local usable = select(5, C_MountJournal.GetMountInfoByID(self.mountID))
    if not usable then
        return false
    end
    if not IsUsableSpell(self.spellID) then
        return false
    end
    return LM.Mount.IsCastable(self)
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
        castActions = castActions or { "/cast " .. GetSpellInfo(self.spellID) }
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
