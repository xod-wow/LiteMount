--[[----------------------------------------------------------------------------

  LiteMount/UI/UIFilter.lua

  UI Filter state abstracted out similar to how C_MountJournal does it

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

LM.UIFilter = {
        filteredMountList = { },
        searchText = nil,
        flagFilterList =  { },
        sourceFilterList = { },
        priorityFilterList = { },
    }

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0", true)
local callbacks = CallbackHandler:New(LM.UIFilter)

local PriorityColors = {
    [''] = COMMON_GRAY_COLOR,
    [0] =  RED_FONT_COLOR,
    [1] =  RARE_BLUE_COLOR,
    [2] =  EPIC_PURPLE_COLOR,
    [3] =  LEGENDARY_ORANGE_COLOR,
}

local function searchMatch(src, text)
    src = src:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):lower()
    text = text:lower()
    return src:find(text, 1, true) ~= nil
end

-- Clear -----------------------------------------------------------------------

function LM.UIFilter.Clear()
    table.wipe(LM.UIFilter.flagFilterList)
    table.wipe(LM.UIFilter.sourceFilterList)
    table.wipe(LM.UIFilter.priorityFilterList)
    table.wipe(LM.UIFilter.filteredMountList)
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.IsFiltered()
    if next(LM.UIFilter.sourceFilterList) ~= nil then
        return true
    end

    if next(LM.UIFilter.priorityFilterList) ~= nil then
        return true
    end

    if next(LM.UIFilter.flagFilterList) ~= nil then
        return true
    end

    return false
end

-- Fetch -----------------------------------------------------------------------

-- Show all the collected mounts before the uncollected mounts, then by name
local function FilterSort(a, b)
    if a.isCollected and not b.isCollected then return true end
    if not a.isCollected and b.isCollected then return false end
    return a.name < b.name
end

function LM.UIFilter.UpdateCache()
    for _,m in ipairs(LM.PlayerMounts.mounts) do
        if not LM.UIFilter.IsFilteredMount(m) then
            tinsert(LM.UIFilter.filteredMountList, m)
        end
    end
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

function LM.UIFilter.GetNumSources()
    return C_PetJournal.GetNumPetSources() + 1
end

function LM.UIFilter.SetAllSourceFilters(v)
    LM.UIFilter.ClearCache()
    if v then
        table.wipe(LM.UIFilter.sourceFilterList)
    else
        for i = 1,LM.UIFilter.GetNumSources() do
            if LM.UIFilter.IsValidSourceFilter(i) then
                LM.UIFilter.sourceFilterList[i] = true
            end
        end
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.SetSourceFilter(i, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.sourceFilterList[i] = nil
    else
        LM.UIFilter.sourceFilterList[i] = true
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.IsSourceChecked(i)
    return not LM.UIFilter.sourceFilterList[i]
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


-- Flags -----------------------------------------------------------------------

function LM.UIFilter.IsFlagChecked(f)
    return not LM.UIFilter.flagFilterList[f]
end

function LM.UIFilter.SetFlagFilter(f, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.flagFilterList[f] = nil
    else
        LM.UIFilter.flagFilterList[f] = true
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter:SetAllFlagFilters(v)
    LM.UIFilter.ClearCache()
    for _,f in ipairs(LM.UIFilter.GetFlags()) do
        if v then
            LM.UIFilter.flagFilterList[f] = nil
        else
            LM.UIFilter.flagFilterList[f] = true
        end
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.GetFlags()
    return LM.Options:GetAllFlags()
end

function LM.UIFilter.GetFlagText(f)
    if LM.Options:IsPrimaryFlag(f) then
        return ITEM_QUALITY_COLORS[2].hex
            .. L[f]
            .. FONT_COLOR_CODE_CLOSE
    else
        return f
    end
end


-- Priorities ------------------------------------------------------------------

function LM.UIFilter.IsPriorityChecked(p)
    return not LM.UIFilter.priorityFilterList[p]
end

function LM.UIFilter.SetPriorityFilter(p, v)
    LM.UIFilter.ClearCache()
    if v then
        LM.UIFilter.priorityFilterList[p] = nil
    else
        LM.UIFilter.priorityFilterList[p] = true
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter:SetAllPriorityFilters(v)
    LM.UIFilter.ClearCache()
    v = v and true or nil
    for _,p in ipairs(LM.UIFilter.GetPriorities()) do
        if v then
            LM.UIFilter.priorityFilterList[p] = nil
        else
            LM.UIFilter.priorityFilterList[p] = true
        end
    end
    callbacks:Fire('OnFilterChanged')
end

function LM.UIFilter.GetPriorities()
    return { 0, 1, 2, 3 }
end

function LM.UIFilter.GetPriorityText(p)
    local c = PriorityColors[p] or PriorityColors['']
    return c:WrapTextInColorCode(p),
           c:WrapTextInColorCode(L['LM_PRIORITY_DESC'..p])
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

function LM.UIFilter.IsFilteredMount(m)

    local filters = LM.UIFilter.flagFilterList

    -- Source filters

    local source = m.sourceType
    if not source or source == 0 then
        source = LM.UIFilter.GetNumSources()
    end

    if LM.UIFilter.sourceFilterList[source] == true then
        return true
    end

    -- Flag filters

    -- Does the mount info indicate it should be hidden. This happens (for
    -- example) with some mounts that have different horde/alliance versions
    -- with the same name.

    if LM.UIFilter.flagFilterList.HIDDEN and m.isFiltered then
        return true
    end

    if LM.UIFilter.flagFilterList.COLLECTED and m.isCollected then
        return true
    end

    if LM.UIFilter.flagFilterList.NOT_COLLECTED and not m.isCollected then
        return true
    end

    -- isUsable is only set for journal mounts so nil is true
    if LM.UIFilter.flagFilterList.UNUSABLE and m.isUsable == false then
        return true
    end

    -- Priority Filters
    for _,p in ipairs(LM.UIFilter.GetPriorities()) do
        if LM.UIFilter.priorityFilterList[p] and LM.Options:GetPriority(m) == p then
            return true
        end
    end

    -- This weirdness is because some mounts don't have any flags and we show them all the
    -- time instead of never. I should check if it's easier to just look for no flags on the
    -- mount itself. XXX FIXME XXX

    local okflags = CopyTable(m:CurrentFlags())
    local noFilters = true
    for _,flagName in ipairs(LM.UIFilter:GetFlags()) do
        if LM.UIFilter.flagFilterList[flagName] then
            okflags[flagName] = nil
            noFilters = false
        end
    end
    if noFilters == false and next(okflags) == nil then
        return true
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

    if m.sourceText and searchMatch(m.sourceText, filtertext) then
        return false
    end

    return true
end
