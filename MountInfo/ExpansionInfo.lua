--[[----------------------------------------------------------------------------

  LiteMount/MountInfo/ExpansionInfo.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

function LM.MountInfo.GetMountExpansionBySpellID(spellID)
    local expansionID = nil -- something here
    return expansionID, GetExpansionName(expansionID)
end

function LM.MountInfo.GetMountExpansionByMountID(mountID)
    local _, spellID = C_MountJournal.GetMountInfoByID(mountID)
    return LM.MountInfo.GetMountExpansionBySpellID(spellID)
end

function LM.MountInfo.GetMountExpansionNameByID(expansionID)
    return GetExpansionName(expansionID)
end

function LM.MountInfo.GetMountExpansionIDs()
    local expansionIDs = {}
    for i = 1, GetNumExpansions() do
        -- classic is 0
        local expansionID = i-1
        table.insert(expansionIDs, expansionID)
    end
    return expansionIDs
end

function LM.MountInfo.IsValidMountExpansionID(expansionID)
    return expansionID >= 0 and expansionID < GetNumExpansions()
end
