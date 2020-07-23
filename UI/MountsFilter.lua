--[[----------------------------------------------------------------------------

  LiteMount/UI/MountsFilter.lua

  UI Filter state abstracted out similar to how C_MountJournal does it

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

_G.LM_UIFilter = {
        filteredMountList = { },
        searchText = nil,
        flagFilterList =  { },
        sourceFilterList = { },
        priorityFilterList = { },
    }

local PriorityColors = {
    [''] = COMMON_GRAY_COLOR,
    [0] =  RED_FONT_COLOR,
    [1] =  RARE_BLUE_COLOR,
    [2] =  EPIC_PURPLE_COLOR,
    [3] =  LEGENDARY_ORANGE_COLOR,
}

-- Clear -----------------------------------------------------------------------

function LM_UIFilter.Clear()
    table.wipe(LM_UIFilter.flagFilterList)
    table.wipe(LM_UIFilter.sourceFilterList)
    table.wipe(LM_UIFilter.priorityFilterList)
    table.wipe(LM_UIFilter.filteredMountList)
end

function LM_UIFilter.IsFiltered()
    if next(LM_UIFilter.sourceFilterList) ~= nil then
        return true
    end

    if next(LM_UIFilter.priorityFilterList) ~= nil then
        return true
    end

    if next(LM_UIFilter.flagFilterList) ~= nil then
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

function LM_UIFilter.UpdateCache()
    for _,m in ipairs(LM_PlayerMounts.mounts) do
        if not LM_UIFilter.IsFilteredMount(m) then
            tinsert(LM_UIFilter.filteredMountList, m)
        end
    end
    sort(LM_UIFilter.filteredMountList, FilterSort)
end

function LM_UIFilter.ClearCache()
    table.wipe(LM_UIFilter.filteredMountList)
end

function LM_UIFilter.GetFilteredMountList()
    if next(LM_UIFilter.filteredMountList) == nil then
        LM_UIFilter.UpdateCache()
    end
    return LM_UIFilter.filteredMountList
end


-- Sources ---------------------------------------------------------------------

function LM_UIFilter.GetNumSources()
    return C_PetJournal.GetNumPetSources() + 1
end

function LM_UIFilter.SetAllSourceFilters(v)
    LM_UIFilter.ClearCache()
    if v then
        table.wipe(LM_UIFilter.sourceFilterList)
    else
        for i = 1,LM_UIFilter.GetNumSources() do
            if LM_UIFilter.IsValidSourceFilter(i) then
                LM_UIFilter.sourceFilterList[i] = true
            end
        end
    end
end

function LM_UIFilter.SetSourceFilter(i, v)
    LM_UIFilter.ClearCache()
    if v then
        LM_UIFilter.sourceFilterList[i] = nil
    else
        LM_UIFilter.sourceFilterList[i] = true
    end
end

function LM_UIFilter.IsSourceChecked(i)
    return not LM_UIFilter.sourceFilterList[i]
end

function LM_UIFilter.IsValidSourceFilter(i)
    -- Mounts have an extra filter "OTHER" that pets don't have
    if C_MountJournal.IsValidSourceFilter(i) then
        return true
    elseif i == C_PetJournal.GetNumPetSources() + 1 then
        return true
    else
        return false
    end
end

function LM_UIFilter.GetSourceText(i)
    local n = C_PetJournal.GetNumPetSources()
    if i <= n then
        return _G["BATTLE_PET_SOURCE_"..i]
    elseif i == n+1 then
        return OTHER
    end
end


-- Flags -----------------------------------------------------------------------

function LM_UIFilter.IsFlagChecked(f)
    return not LM_UIFilter.flagFilterList[f]
end

function LM_UIFilter.SetFlagFilter(f, v)
    LM_UIFilter.ClearCache()
    if v then
        LM_UIFilter.flagFilterList[f] = nil
    else
        LM_UIFilter.flagFilterList[f] = true
    end
end

function LM_UIFilter:SetAllFlagFilters(v)
    for _,f in ipairs(LM_UIFilter.GetFlags()) do
        LM_UIFilter.SetFlagFilter(f, v)
    end
end

function LM_UIFilter.GetFlags()
    return LM_Options:GetAllFlags()
end

function LM_UIFilter.GetFlagText(f)
    if LM_Options:IsPrimaryFlag(f) then
        return ITEM_QUALITY_COLORS[2].hex
            .. L[f]
            .. FONT_COLOR_CODE_CLOSE
    else
        return f
    end
end


-- Priorities ------------------------------------------------------------------

function LM_UIFilter.IsPriorityChecked(p)
    return not LM_UIFilter.priorityFilterList[p]
end

function LM_UIFilter.SetPriorityFilter(p, v)
    LM_UIFilter.ClearCache()
    if v then
        LM_UIFilter.priorityFilterList[p] = nil
    else
        LM_UIFilter.priorityFilterList[p] = true
    end
end

function LM_UIFilter:SetAllPriorityFilters(v)
    for _,p in ipairs(LM_UIFilter.GetPriorities()) do
        LM_UIFilter.SetPriorityFilter(p, v)
    end
end

function LM_UIFilter.GetPriorities()
    return { 0, 1, 2, 3 }
end

function LM_UIFilter.GetPriorityText(p)
    local c = PriorityColors[p] or PriorityColors['']
    return c:WrapTextInColorCode(p),
           c:WrapTextInColorCode(L['LM_PRIORITY_DESC'..p])
end


-- Search ----------------------------------------------------------------------

function LM_UIFilter.SetSearchText(t)
    LM_UIFilter.ClearCache()
    LM_UIFilter.searchText = t
end

function LM_UIFilter.GetSearchText(t)
    return LM_UIFilter.searchText
end


-- Check -----------------------------------------------------------------------

function LM_UIFilter.IsFilteredMount(m)

    local filters = LM_UIFilter.flagFilterList

    -- Does the mount info indicate it should be hidden. This happens (for
    -- example) with some mounts that have different horde/alliance versions
    -- with the same name.
    if m.isFiltered then
        return true
    end

    -- Source filters

    local source = m.sourceType
    if not source or source == 0 then
        source = LM_UIFilter.GetNumSources()
    end

    if LM_UIFilter.sourceFilterList[source] == true then
        return true
    end

    -- Flag filters

    if LM_UIFilter.flagFilterList.COLLECTED and m.isCollected then
        return true
    end

    if LM_UIFilter.flagFilterList.NOT_COLLECTED and not m.isCollected then
        return true
    end

    if LM_UIFilter.flagFilterList.UNUSABLE and m.needsFaction and m.needsFaction ~= UnitFactionGroup("player") then
        return true
    end

    -- Priority Filters
    for _,p in ipairs(LM_UIFilter.GetPriorities()) do
        if LM_UIFilter.priorityFilterList[p] and LM_Options:GetPriority(m) == p then
            return true
        end
    end

    -- This weirdness is because some mounts don't have any flags and we show them all the
    -- time instead of never. I should check if it's easier to just look for no flags on the
    -- mount itself. XXX FIXME XXX

    local okflags = CopyTable(m:CurrentFlags())
    local noFilters = true
    for _,flagName in ipairs(LM_UIFilter:GetFlags()) do
        if LM_UIFilter.flagFilterList[flagName] then
            okflags[flagName] = nil
            noFilters = false
        end
    end
    if noFilters == false and next(okflags) == nil then
        return true
    end

    -- Search text from the input box.
    -- strfind is expensive, avoid if possible, leave all this at the end

    local filtertext = LM_UIFilter.GetSearchText()
    if not filtertext or filtertext == SEARCH or filtertext == "" then
        return false
    end

    if filtertext == "=" then
        local hasAura
        if _G.AuraUtil then
            hasAura = AuraUtil.FindAuraByName(m.name, "player")
        else
            hasAura = UnitAura("player", m.name)
        end

        return hasAura == nil
    end

    return strfind(m.name:lower(), filtertext:lower(), 1, true) == nil
end
