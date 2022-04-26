C_MountJournal = { }

function C_MountJournal.SetCollectedFilterSetting(setting, value)
end

function C_MountJournal.SetAllSourceFilters()
end

function C_MountJournal.SetAllTypeFilters()
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
    for _,info in pairs(data.GetMountInfoByID) do
        i = i + 1
        if i == idx then
            return unpack(info)
        end
    end
end

function C_MountJournal.GetMountIDs()
    local ids = {}
    for id in pairs(data.GetMountInfoByID) do
        ids[#ids+1] = id
    end
    return ids
end

function C_MountJournal.GetMountInfoByID(id)
    local info = data.GetMountInfoByID[id]
    if id then return unpack(info) end
end

function C_MountJournal.GetMountInfoExtraByID(id)
    local info = data.GetMountInfoExtraByID[id]
    if id then return unpack(info) end
end

function C_MountJournal.AreMountEquipmentEffectsSuppressed()
    return false
end

function C_MountJournal.GetAppliedMountEquipmentID()
    -- Angler's Water Striders
    return 168416
end
