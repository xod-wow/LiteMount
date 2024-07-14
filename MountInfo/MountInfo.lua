--[[----------------------------------------------------------------------------

  LiteMount/MountInfo/MountInfo.lua

  Copyright 2024 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LM.MountInfo = {}

local function GetMountInfo(mountID, spellID)
    local name, _, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, _, isSteadyFlight = C_MountJournal.GetMountInfoByID(mountID)
    local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountID)

    local info = {
        -- GetMountInfoByID
        mountID = mountID,
        name = name,
        spellID = spellID,
        icon = icon,
        isActive = isActive,
        isUsable = isUsable,
        sourceType = sourceType,
        isFavorite = isFavorite,
        isFactionSpecific = isFactionSpecific,
        faction = faction,
        shouldHideOnChar = shouldHideOnChar,
        isCollected = isCollected,
        isSteadyFlight = isSteadyFlight,
        -- GetMountInfoExtraByID
        creatureDisplayInfoID = creatureDisplayInfoID,
        description = description,
        source = source,
        isSelfMount = isSelfMount,
        mountTypeID = mountTypeID,
        uiModelSceneID = uiModelSceneID,
        animID = animID,
        spellVisualKitID = spellVisualKitID,
        disablePlayerMountPreview = disablePlayerMountPreview
    }
        
    local family, familyName = LM.MountInfo.GetMountFamilyBySpellID(spellID)
    if family then
        info.family = family
        info.familyName = familyName
    end

    local expansion, expansionName = LM.MountInfo.GetMountExpansionByMountID(mountID)
    if expansion then
        info.expansion = expansion
        info.expansionName = expansionName
    end

    return info
end

function LM.MountInfo.GetMountInfoBySpellID(spellID)
    local mountID = C_MountJournal.GetMountFromSpell(spellID)
    return GetMountInfo(mountID, spellID)
end

function LM.MountInfo.GetMountInfoByMountID(mountID)
    local _, spellID = C_MountJournal.GetMountInfoByID(mountID)
    return GetMountInfo(mountID, spellID)
end
