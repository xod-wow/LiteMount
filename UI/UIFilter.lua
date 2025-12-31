--[[----------------------------------------------------------------------------

  LiteMount/UI/UIFilter.lua

  UI Filter state abstracted out similar to how C_MountJournal does it

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local DefaultFilterList = {
    family = { },
    flag = { },
    group = { },
    other = { HIDDEN=true, UNUSABLE=true, ZONEMATCH=true },
    priority = { },
    source = { },
    expansion = { },
    typename = { }
}

LM.UIFilter = {
        filteredMountList = LM.MountList:New(),
        searchText = nil,
        sortKey = 'default',
        filterList = CopyTable(DefaultFilterList),
        typeNamesInUse = {},
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

-- Sorting ---------------------------------------------------------------------

local SortKeysByProject = LM.TableWithDefault({
    [1] = {
        'default',
        'name',
        'priority',
        'rarity',
        'summons',
        'family',
        'expansion',
--@debug@
        'mountid',
        'spellid',
--@end-debug@
    },
    DEFAULT = {
        'default',
        'name',
        'priority',
        'summons'
    },
})

local SortKeyTexts = {
    ['default']     = DEFAULT,
    ['name']        = NAME,
    ['priority']    = L.LM_PRIORITY,
    ['rarity']      = RARITY,
    ['summons']     = SUMMONS,
    ['family']      = L.LM_FAMILY,
    ['expansion']   = EXPANSION_FILTER_TEXT,
--@debug@
    ['mountid']     = 'Mount ID',
    ['spellid']     = 'Spell ID',
--@end-debug@
}

function LM.UIFilter.GetSortKey()
    return LM.UIFilter.sortKey
end

function LM.UIFilter.SetSortKey(k)
    if LM.UIFilter.sortKey == k then
        return
    else
        LM.UIFilter.sortKey = ( k or 'default' )
        LM.UIFilter.ClearCache()
        callbacks:Fire('OnFilterChanged')
    end
end

function LM.UIFilter.GetSortKeys()
    return SortKeysByProject[WOW_PROJECT_ID]
end

function LM.UIFilter.GetSortKeyText(k)
    return SortKeyTexts[k] or UNKNOWN
end

-- Fetch -----------------------------------------------------------------------

function LM.UIFilter.UpdateCache()
    for _,m in ipairs(LM.MountRegistry.mounts) do
        if not LM.UIFilter.IsFilteredMount(m) then
            tinsert(LM.UIFilter.filteredMountList, m)
        end
    end
    LM.UIFilter.filteredMountList:Sort(LM.UIFilter.sortKey)
end

function LM.UIFilter.UpdateMountInCache(m)
    local i = tIndexOf(LM.UIFilter.filteredMountList, m)
    local isFiltered = LM.UIFilter.IsFilteredMount(m)
    if isFiltered and i then
        table.remove(LM.UIFilter.filteredMountList, i)
    elseif not isFiltered and not i then
        tinsert(LM.UIFilter.filteredMountList, m)
        LM.UIFilter.filteredMountList:Sort(LM.UIFilter.sortKey)
    end
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


-- Expansions ------------------------------------------------------------------

function LM.UIFilter.GetExpansions()
    local out = { 'NONE' }
    for i = 0, GetExpansionLevel() do
        out[#out+1] = i
    end
    return out
end

function LM.UIFilter.GetNumExpansions()
    return GetNumExpansions()
end

function LM.UIFilter.SetAllExpansionFilters(v)
    LM.UIFilter.ClearCache()
    if v then
        table.wipe(LM.UIFilter.filterList.expansion)
    else
        for _,i in ipairs(LM.UIFilter.GetExpansions()) do
            LM.UIFilter.filterList.expansion[i] = true
        end
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.SetExpansionFilter(i, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.filterList.expansion[i] = nil
    else
        LM.UIFilter.filterList.expansion[i] = true
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.IsExpansionChecked(i)
    return not LM.UIFilter.filterList.expansion[i]
end

function LM.UIFilter.IsValidExpansionFilter(i)
    if i == 'NONE' then
        return true
    else
        return i >= 0 and i <= GetExpansionLevel()
    end
end

function LM.UIFilter.GetExpansionText(name)
    if name == 'NONE' then
        return NONE:upper()
    else
        return GetExpansionName(name)
    end
end


-- Families --------------------------------------------------------------------

function LM.UIFilter.GetFamilies()
    return LM.MountDB.GetModelList()
end

function LM.UIFilter.SetAllFamilyFilters(v)
    LM.UIFilter.ClearCache()
    if v then
        table.wipe(LM.UIFilter.filterList.family)
    else
        for _, modelName in ipairs(LM.UIFilter.GetFamilies()) do
            LM.UIFilter.filterList.family[modelName] = true
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
    return LM.ModelDB.IsValidModel(i)
end

function LM.UIFilter.GetFamilyText(i)
    return L[i]
end


-- TypeNames -------------------------------------------------------------------

function LM.UIFilter.IsTypeNameChecked(t)
    return not LM.UIFilter.filterList.typename[t]
end

function LM.UIFilter.SetTypeNameFilter(t, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.filterList.typename[t] = nil
    else
        LM.UIFilter.filterList.typename[t] = true
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.SetAllTypeNameFilters(v)
    LM.UIFilter.ClearCache()
    for n in pairs(LM.MOUNT_TYPE_NAMES) do
        if v then
            LM.UIFilter.filterList.typename[n] = nil
        else
            LM.UIFilter.filterList.typename[n] = true
        end
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.GetTypeNames()
    local out = {}
    for t in pairs(LM.MOUNT_TYPE_NAMES) do
        if LM.UIFilter.typeNamesInUse[t] then
            table.insert(out, t)
        end
    end
    sort(out)
    return out
end

function LM.UIFilter.GetTypeNameText(t)
    return t
end

function LM.UIFilter.RegisterUsedTypeID(id)
    local typeInfo = LM.MOUNT_TYPE_INFO[id]
    if typeInfo then
        LM.UIFilter.typeNamesInUse[typeInfo.name] = true
    end
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
    table.insert(groups, 'NONE')
    return groups
end

function LM.UIFilter.GetGroupText(f)
    if f == 'NONE' then
        return NONE:upper()
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
    r = r or 50
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

    -- Expansion filters
    if not m.expansion then
        if LM.UIFilter.filterList.expansion['NONE'] == true then
            return true
        end
    else
        if LM.UIFilter.filterList.expansion[m.expansion] == true then
            return true
        end
    end

    -- Source filters

    local source = m.sourceType
    if not source or source == 0 then
        source = LM.UIFilter.GetNumSources()
    end

    if LM.UIFilter.filterList.source[source] == true then
        return true
    end

    -- TypeName filters
    local typeInfo = LM.MOUNT_TYPE_INFO[m.mountTypeID or 0]
    if typeInfo and LM.UIFilter.filterList.typename[typeInfo.name] == true then
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

    if LM.UIFilter.filterList.other.HIDDEN and m:IsHidden() then
        return true
    end

    if LM.UIFilter.filterList.other.COLLECTED and m:IsCollected() then
        return true
    end

    if LM.UIFilter.filterList.other.NOT_COLLECTED and not m:IsCollected() then
        return true
    end

    if LM.UIFilter.filterList.other.UNUSABLE then
        -- We can't find out the usability of filtered mounts and they are all
        -- set to be unusable but we want to display them or not with just the
        -- HIDDEN filter and not UNUSABLE.
        if not m:IsHidden() and not m:IsFilterUsable() then
            return true
        end
    end

    if not LM.UIFilter.filterList.other.ZONEMATCH then
        if not m:MatchesFilters("ZONEMATCH") then
            return true
        end
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
        if LM.UIFilter.filterList.group['NONE'] then return true end
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

--@debug@
    if tonumber(filtertext) then
        return m.mountTypeID ~= tonumber(filtertext)
    end
--@end-debug@

    if strfind(m.name:lower(), filtertext:lower(), 1, true) then
        return false
    end

    if m:MatchesFilters(filtertext) then
        return false
    end

    if m.descriptionText and searchMatch(m.descriptionText, filtertext) then
        return false
    end

    if m.sourceText and searchMatch(stripcodes(m.sourceText), filtertext) then
        return false
    end

    return true
end


-- Initialize ------------------------------------------------------------------

function LM.UIFilter.Initialize()
    LM.db.RegisterCallback(LM.UIFilter, "OnOptionsModified",
        function (e, m)
            if m then
                LM.UIFilter.UpdateMountInCache(m)
            else
                LM.UIFilter.ClearCache()
            end
        end)
end
