--[[----------------------------------------------------------------------------

  LiteMount/UI/UIFilter.lua

  UI Filter state abstracted out similar to how C_MountJournal does it

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local DefaultFilterList = {
    family = { },
    flag = { },
    group = { },
    other = { HIDDEN=true, UNUSABLE=true },
    priority = { },
    source = { },
    typeid = { },
}

LM.UIFilter = {
        filteredMountList = LM.MountList:New(),
        searchText = nil,
        filterList = CopyTable(DefaultFilterList),
    }

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0", true)
local callbacks = CallbackHandler:New(LM.UIFilter)

local PriorityColors = {
    [''] = COMMON_GRAY_COLOR,
    [0] =  RED_FONT_COLOR,
    [1] =  UNCOMMON_GREEN_COLOR,
    [2] =  RARE_BLUE_COLOR,
    [3] =  EPIC_PURPLE_COLOR,
    [4] =  LEGENDARY_ORANGE_COLOR,
}

local function searchMatch(src, text)
    src = src:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):lower()
    text = text:lower()
    return src:find(text, 1, true) ~= nil
end

-- Clear -----------------------------------------------------------------------

function LM.UIFilter.Clear()
    LM.UIFilter.ClearCache()
    LM.UIFilter.filterList = CopyTable(DefaultFilterList)
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.IsFiltered()
    return not tCompare(LM.UIFilter.filterList, DefaultFilterList, 2)
end

-- Fetch -----------------------------------------------------------------------

-- Don't call CanDragonRide thousands of times for no reason
local dragonRidingSort = false

-- Show all the collected mounts before the uncollected mounts, then by name
local function FilterSort(a, b)
    if a.isCollected and not b.isCollected then return true end
    if not a.isCollected and b.isCollected then return false end
    if dragonRidingSort then
        if a.dragonRiding and not b.dragonRiding then return true end
        if not a.dragonRiding and b.dragonRiding then return false end
    end
    return a.name < b.name
end

function LM.UIFilter.UpdateCache()
    for _,m in ipairs(LM.MountRegistry.mounts) do
        if not LM.UIFilter.IsFilteredMount(m) then
            tinsert(LM.UIFilter.filteredMountList, m)
        end
    end
    dragonRidingSort = LM.Environment:CanDragonride()
    sort(LM.UIFilter.filteredMountList, FilterSort)
end

function LM.UIFilter.ClearCache()
    table.wipe(LM.UIFilter.filteredMountList)
end

function LM.UIFilter.GetFilteredMountList()
    if next(LM.UIFilter.filteredMountList) == nil then
        LM.UIFilter.UpdateCache()
    end
    return LM.UIFilter.filteredMountList
end


-- Sources ---------------------------------------------------------------------

function LM.UIFilter.GetSources()
    local out = {}
    for i = 1, LM.UIFilter.GetNumSources() do
        if LM.UIFilter.IsValidSourceFilter(i) then
            out[#out+1] = i
        end
    end
    return out
end

function LM.UIFilter.GetNumSources()
    return C_PetJournal.GetNumPetSources() + 1
end

function LM.UIFilter.SetAllSourceFilters(v)
    LM.UIFilter.ClearCache()
    if v then
        table.wipe(LM.UIFilter.filterList.source)
    else
        for i = 1,LM.UIFilter.GetNumSources() do
            if LM.UIFilter.IsValidSourceFilter(i) then
                LM.UIFilter.filterList.source[i] = true
            end
        end
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.SetSourceFilter(i, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.filterList.source[i] = nil
    else
        LM.UIFilter.filterList.source[i] = true
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.IsSourceChecked(i)
    return not LM.UIFilter.filterList.source[i]
end

function LM.UIFilter.IsValidSourceFilter(i)
    -- Mounts have an extra filter "OTHER" that pets don't have
    if C_MountJournal.IsValidSourceFilter(i) then
        return true
    elseif i == C_PetJournal.GetNumPetSources() + 1 then
        return true
    else
        return false
    end
end

function LM.UIFilter.GetSourceText(i)
    local n = C_PetJournal.GetNumPetSources()
    if i <= n then
        return _G["BATTLE_PET_SOURCE_"..i]
    elseif i == n+1 then
        return OTHER
    end
end


-- Families --------------------------------------------------------------------

function LM.UIFilter.GetFamilies()
    local out = {}
    for k in pairs(LM.MOUNTFAMILY) do
        table.insert(out, k)
    end
    table.sort(out, function (a, b) return L[a] < L[b] end)
    return out
end

function LM.UIFilter.SetAllFamilyFilters(v)
    LM.UIFilter.ClearCache()
    if v then
        table.wipe(LM.UIFilter.filterList.family)
    else
        for k in pairs(LM.MOUNTFAMILY) do
            LM.UIFilter.filterList.family[k] = true
        end
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.SetFamilyFilter(i, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.filterList.family[i] = nil
    else
        LM.UIFilter.filterList.family[i] = true
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.IsFamilyChecked(i)
    return not LM.UIFilter.filterList.family[i]
end

function LM.UIFilter.IsValidFamilyFilter(i)
    return LM.MOUNTFAMILY[i] ~= nil
end

function LM.UIFilter.GetFamilyText(i)
    return L[i]
end


-- TypeIDs ---------------------------------------------------------------------

function LM.UIFilter.IsTypeIDChecked(t)
    return not LM.UIFilter.filterList.typeid[t]
end

function LM.UIFilter.SetTypeIDFilter(t, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.filterList.typeid[t] = nil
    else
        LM.UIFilter.filterList.typeid[t] = true
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.SetAllTypeIDFilters(v)
    LM.UIFilter.ClearCache()
    for n in pairs(LM.MOUNT_TYPES) do
        if v then
            LM.UIFilter.filterList.typeid[n] = nil
        else
            LM.UIFilter.filterList.typeid[n] = true
        end
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.GetTypeIDs()
    local out = {}
    for t in pairs(LM.MOUNT_TYPES) do table.insert(out, t) end
    sort(out, function (a,b) return LM.MOUNT_TYPES[a] < LM.MOUNT_TYPES[b] end)
    return out
end

function LM.UIFilter.GetTypeIDText(t)
    return LM.MOUNT_TYPES[t]
end


-- Flags ("Type" now) ----------------------------------------------------------

function LM.UIFilter.IsFlagChecked(f)
    return not LM.UIFilter.filterList.flag[f]
end

function LM.UIFilter.SetFlagFilter(f, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.filterList.flag[f] = nil
    else
        LM.UIFilter.filterList.flag[f] = true
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.SetAllFlagFilters(v)
    LM.UIFilter.ClearCache()
    for _,f in ipairs(LM.UIFilter.GetFlags()) do
        if v then
            LM.UIFilter.filterList.flag[f] = nil
        else
            LM.UIFilter.filterList.flag[f] = true
        end
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.GetFlags()
    return LM.Options:GetFlags()
end

function LM.UIFilter.GetFlagText(f)
    -- "FAVORITES -> _G.FAVORITES
    return L[f] or f
end


-- Groups ----------------------------------------------------------------------

function LM.UIFilter.IsGroupChecked(g)
    return not LM.UIFilter.filterList.group[g]
end

function LM.UIFilter.SetGroupFilter(g, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.filterList.group[g] = nil
    else
        LM.UIFilter.filterList.group[g] = true
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.SetAllGroupFilters(v)
    LM.UIFilter.ClearCache()
    for _,g in ipairs(LM.UIFilter.GetGroups()) do
        if v then
            LM.UIFilter.filterList.group[g] = nil
        else
            LM.UIFilter.filterList.group[g] = true
        end
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.GetGroups()
    local groups = LM.Options:GetGroupNames()
    table.insert(groups, NONE)
    return groups
end

function LM.UIFilter.GetGroupText(f)
    if f == NONE then
        return f:upper()
    else
        return f
    end
end


-- Priorities ------------------------------------------------------------------

function LM.UIFilter.IsPriorityChecked(p)
    return not LM.UIFilter.filterList.priority[p]
end

function LM.UIFilter.SetPriorityFilter(p, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.filterList.priority[p] = nil
    else
        LM.UIFilter.filterList.priority[p] = true
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.SetAllPriorityFilters(v)
    LM.UIFilter.ClearCache()
    if v then
        table.wipe(LM.UIFilter.filterList.priority)
    else
        for _,p in ipairs(LM.UIFilter.GetPriorities()) do
            LM.UIFilter.filterList.priority[p] = true
        end
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.GetPriorities()
    return LM.Options:GetAllPriorities()
end

function LM.UIFilter.GetPriorityColor(p)
    return PriorityColors[p] or PriorityColors['']
end

function LM.UIFilter.GetPriorityText(p)
    local c = PriorityColors[p] or PriorityColors['']
    return c:WrapTextInColorCode(p),
           c:WrapTextInColorCode(L['LM_PRIORITY_DESC'..p])
end


-- Rarities --------------------------------------------------------------------

-- 0 <= r <= 1

function LM.UIFilter.GetRarityColor(r)
    if r <= 1 then
        return PriorityColors[4]
    elseif r <= 5 then
        return PriorityColors[3]
    elseif r <= 20 then
        return PriorityColors[2]
    elseif r <= 50 then
        return PriorityColors[1]
    else
        return PriorityColors['']
    end
end

-- Other -----------------------------------------------------------------------

function LM.UIFilter.IsOtherChecked(k)
    return not LM.UIFilter.filterList.other[k]
end

function LM.UIFilter.SetOtherFilter(k, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.filterList.other[k] = nil
    else
        LM.UIFilter.filterList.other[k] = true
    end
    callbacks:Fire('OnFilterChanged')
end

-- Search ----------------------------------------------------------------------

function LM.UIFilter.SetSearchText(t)
    LM.UIFilter.ClearCache()
    LM.UIFilter.searchText = t
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.GetSearchText(t)
    return LM.UIFilter.searchText
end


-- Check -----------------------------------------------------------------------

local function stripcodes(str)
    return str:gsub("|c........(.-)|r", "%1"):gsub("|T.-|t", "")
end

function LM.UIFilter.IsFilteredMount(m)

    -- Source filters

    local source = m.sourceType
    if not source or source == 0 then
        source = LM.UIFilter.GetNumSources()
    end

    if LM.UIFilter.filterList.source[source] == true then
        return true
    end

    -- TypeID filters
    if LM.UIFilter.filterList.typeid[m.mountTypeID or 0] == true then
        return true
    end

    -- Family filters
    if m.family and LM.UIFilter.filterList.family[m.family] == true then
        return true
    end

    -- Group filters

    -- Does the mount info indicate it should be hidden. This happens (for
    -- example) with some mounts that have different horde/alliance versions
    -- with the same name.

    if LM.UIFilter.filterList.other.HIDDEN and m.isFiltered then
        return true
    end

    if LM.UIFilter.filterList.other.COLLECTED and m.isCollected then
        return true
    end

    if LM.UIFilter.filterList.other.NOT_COLLECTED and not m.isCollected then
        return true
    end

    -- isUsable is only set for journal mounts so nil is true
    if LM.UIFilter.filterList.other.UNUSABLE and m.isUsable == false then
        return true
    end

    -- Priority Filters
    for _,p in ipairs(LM.UIFilter.GetPriorities()) do
        if LM.UIFilter.filterList.priority[p] and LM.Options:GetPriority(m) == p then
            return true
        end
    end

    -- Groups filter has a magic NONE for anything with no groups
    local mountGroups = m:GetGroups()
    if not next(mountGroups) then
        if LM.UIFilter.filterList.group[NONE] then return true end
    else
        local isFiltered = true
        for g in pairs(mountGroups) do
            if not LM.UIFilter.filterList.group[g] then
                isFiltered = false
            end
        end
        if isFiltered then return true end
    end

    -- Flags
    if next(LM.UIFilter.filterList.flag) then
        local isFiltered = true
        for f in pairs(m:GetFlags()) do
            if LM.FLAG[f] ~= nil and not LM.UIFilter.filterList.flag[f] then
                isFiltered = false
                break
            end
        end
        if isFiltered then return true end
    end

    -- Search text from the input box.
    -- strfind is expensive, avoid if possible, leave all this at the end

    local filtertext = LM.UIFilter.GetSearchText()
    if not filtertext or filtertext == SEARCH or filtertext == "" then
        return false
    end

    if filtertext == "=" then
        local hasAura = AuraUtil.FindAuraByName(m.name, "player")
        return hasAura == nil
    end

    if strfind(m.name:lower(), filtertext:lower(), 1, true) then
        return false
    end

    if m.description and searchMatch(m.description, filtertext) then
        return false
    end

    if m.sourceText and searchMatch(stripcodes(m.sourceText), filtertext) then
        return false
    end

    return true
end
