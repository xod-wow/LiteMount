C_MountJournal = { }

function C_MountJournal.GetCollectedFilterSetting(setting)
end

function C_MountJournal.SetCollectedFilterSetting(setting, value)
end

function C_MountJournal.SetAllSourceFilters()
end

function C_MountJournal.SetSourceFilter()
end

function C_MountJournal.IsSourceChecked()
    return true
end

function C_MountJournal.IsValidSourceFilter(setting)
    return true
end

function C_MountJournal.SetAllTypeFilters()
end

function C_MountJournal.SetTypeFilter()
end

function C_MountJournal.IsTypeChecked()
    return true
end

function C_MountJournal.IsValidTypeFilter(setting)
    return true
end

function C_MountJournal.SetSearch(text)
end

function C_MountJournal.GetNumDisplayedMounts()
    local n = 0
    for id in pairs(data.GetMountInfoByID) do
        n = n + 1
    end
    return n
end

function C_MountJournal.GetDisplayedMountInfo(idx)
    local i = 0
    for id,info in pairs(data.GetMountInfoByID) do
        i = i + 1
        if i == idx then
            return MockGetFromData(data.GetMountInfoByID, id)
        end
    end
end

function C_MountJournal.GetMountIDs()
    local ids = {}
    for id in pairs(data.GetMountInfoByID) do
        ids[#ids+1] = id
    end
    sort(ids)
    return ids
end

function C_MountJournal.GetMountInfoByID(id)
    return MockGetFromData(data.GetMountInfoByID, id)
end

function C_MountJournal.GetMountInfoExtraByID(id)
    return MockGetFromData(data.GetMountInfoExtraByID, id)
end

function C_MountJournal.AreMountEquipmentEffectsSuppressed()
    return false
end

function C_MountJournal.GetAppliedMountEquipmentID()
    -- Angler's Water Striders
    return 168416
end
